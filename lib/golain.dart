import 'dart:async';
import 'dart:io';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:nordic_nrf_mesh/nordic_nrf_mesh.dart';

import 'golain_platform_interface.dart';

class Golain {
  Future<String?> getPlatformVersion() {
    return GolainPlatform.instance.getPlatformVersion();
  }

  final NordicNrfMesh _nordicNrfMesh = NordicNrfMesh();
  late IMeshNetwork? _meshNetwork;
  late final MeshManagerApi _meshManagerApi;
  late final StreamSubscription<IMeshNetwork?> onNetworkUpdateSubscription;
  late final StreamSubscription<IMeshNetwork?> onNetworkImportSubscription;
  late final StreamSubscription<IMeshNetwork?> onNetworkLoadingSubscription;
  bool isScanning = false;
  bool isProvisioning = false;
  final _serviceData = <String, Uuid>{};

  StreamSubscription? _scanSubscription;

  //Initializes the streams required for the plugin and returns an instance of [Golain].
  Golain() {
    _meshManagerApi = _nordicNrfMesh.meshManagerApi;
    _meshNetwork = _meshManagerApi.meshNetwork;
    onNetworkUpdateSubscription =
        _meshManagerApi.onNetworkUpdated.listen((network) {
      _meshNetwork = network;
    });
    onNetworkImportSubscription =
        _meshManagerApi.onNetworkImported.listen((network) {
      _meshNetwork = network;
    });
    onNetworkLoadingSubscription =
        _meshManagerApi.onNetworkLoaded.listen((network) {
      _meshNetwork = network;
    });

    loadMeshNetwork();
  }

  void dispose() {
    onNetworkUpdateSubscription.cancel();
    onNetworkImportSubscription.cancel();
    onNetworkLoadingSubscription.cancel();
    _scanSubscription?.cancel();
  }

  Future<void> loadMeshNetwork() async {
    await _meshManagerApi.loadMeshNetwork();
  }

  /// Scans for unprovisioned devices.
  ///
  /// Returns a list of [DiscoveredDevice]s. Await this method to get the list.
  /// The list is empty if no devices are found.
  /// Throws [PermissionDeniedException] if the bluetooth permission is not granted.
  /// Throws [BluetoothNotEnabledException] if the bluetooth is not enabled.
  Future<List<DiscoveredDevice>> scanUnprovisionedDevices(
      {required Duration duration}) async {
    Set<DiscoveredDevice> devices0 = <DiscoveredDevice>{};
    List<DiscoveredDevice> devices = [];
    _serviceData.clear();
    _scanSubscription?.cancel();
    devices.clear();
    // ignore: await_only_futures
    _scanSubscription = await _nordicNrfMesh.scanForUnprovisionedNodes().listen(
      (device) async {
        isScanning = true;
        if (devices0.every((element) => element.id != device.id)) {
          final deviceUUid = Uuid.parse(_meshManagerApi.getDeviceUuid(
              device.serviceData[meshProvisioningUuid]!.toList()));
          _serviceData[device.id] = deviceUUid;
          devices0.add(device);
          devices = devices0.toList();
        }
      },
    );

    return Future.delayed(
      Duration(seconds: duration.inSeconds),
      () {
        isScanning = false;
        _scanSubscription?.cancel();
        return devices;
      },
    );
  }

  /// Stops scanning for unprovisioned devices.
  ///
  /// Call this method with a timeout to the [scanUnprovisionedDevices] method.
  /// Otherwise, the scanning will continue forever consuming battery of the mobile.
  Future<void> stopScanning() async {
    await _scanSubscription?.cancel();
    throw UnimplementedError();
  }

  /// Provisions a device.
  ///
  /// Await this method to provision the devices.
  /// Pass the list of [DiscoveredDevice]s that you want to provision.
  ///
  ///
  ///
  ///

  Future<void> provisionDevice(DiscoveredDevice device) async {
    if (_meshNetwork == null) {
      return Future.error("Mesh Network not loaded");
    }

    if (isScanning) {
      await stopScanning();
    }
    if (isProvisioning) {
      throw Exception("Already Provisioning");
    }

    //not provisioning yet

    isProvisioning = true;

    try {
      String deviceUUID;

      if (Platform.isAndroid) {
        deviceUUID = _serviceData[device.id].toString();
      } else if (Platform.isIOS) {
        deviceUUID = device.id.toString();
      } else {
        throw UnimplementedError("Platform not supported");
      }

      final provisingEvent = ProvisioningEvent();
      final provisionedMeshNode = _nordicNrfMesh
          .provisioning(_meshManagerApi, BleMeshManager(), device, deviceUUID,
              events: provisingEvent)
          .timeout(const Duration(minutes: 1));

      await provisionedMeshNode.then((value) {
        isProvisioning = false;
      }).catchError((e) {
        print(e);
        isProvisioning = false;
      });
    } catch (e) {
      print(e);
      scanUnprovisionedDevices(duration: const Duration(seconds: 10));
    }
  }
}
