import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:nordic_nrf_mesh/nordic_nrf_mesh.dart';

import 'golain_doozMeshManager.dart';
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
  final bleMeshManager = BleMeshManager();

  StreamSubscription? _scanSubscription;
  StreamSubscription? _provisioningSubscription;

  /// Initializes the streams required for the plugin and returns an instance of [Golain].
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
    // loading mesh network in the initialization
    loadMeshNetwork();
  }

  /// Disposes the streams used by the plugin.
  void dispose() {
    onNetworkUpdateSubscription.cancel();
    onNetworkImportSubscription.cancel();
    onNetworkLoadingSubscription.cancel();
    _scanSubscription?.cancel();
    _provisioningSubscription?.cancel();
    _deinit();
  }

  Future<void> loadMeshNetwork() async {
    await _meshManagerApi.loadMeshNetwork();
  }

  /// Resets the mesh network stored in phones cache.
  void resetMeshNetwork() async {
    await _meshManagerApi.resetMeshNetwork();
  }

  /// Scans for unprovisioned devices.
  ///
  /// Returns a list of [DiscoveredDevice]s. Await this method to get the list.
  /// The list is empty if no devices are found.
  Future<List<DiscoveredDevice>> scanUnprovisionedDevices(
      {required Duration duration}) async {
    Set<DiscoveredDevice> devices0 = <DiscoveredDevice>{};
    List<DiscoveredDevice> devices = [];
    _serviceData.clear();
    _scanSubscription?.cancel();
    devices.clear();
    _scanSubscription = _nordicNrfMesh.scanForUnprovisionedNodes().listen(
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
  /// Pass the [DiscoveredDevice] that you want to provision.
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

      final provisioningEvent = ProvisioningEvent();
      final provisionedMeshNode = await _nordicNrfMesh
          .provisioning(
            _meshManagerApi,
            BleMeshManager(),
            device,
            deviceUUID,
            events: provisioningEvent,
          )
          .timeout(const Duration(minutes: 1));
      log('Provisioning successful');
      // provisionedMeshNode.then((node) {
      //   log('Provisioning successful');
      // }).catchError((_) {
      //   log('Provisioning failed');
      //   scanUnprovisionedDevices(duration: const Duration(seconds: 10));
      // });
    } catch (e) {
      log(e.toString());
    } finally {
      isProvisioning = false;
    }
  }

  /// Get the list of provisioned nodes.
  ///
  /// Returns a list of [DiscoveredDevice]s. Await this method to get the list.
  /// The list is empty if no devices are found.
  /// Check for permissions before calling this method.
  Future<List<DiscoveredDevice>> provisionedNodesInRange({
    Duration? timeoutDuration,
  }) async {
    Set<DiscoveredDevice> provisionedDevices = {};

    isScanning = true;
    _provisioningSubscription =
        _nordicNrfMesh.scanForProxy().listen((device) async {
      if (provisionedDevices.every((d) => d.id != device.id)) {
        provisionedDevices.add(device);
      }
    });
    await Future.delayed(timeoutDuration!, _stopProvisionedScan);
    return provisionedDevices.toList();
  }

  /// Stops scanning for provisioned devices.
  Future<void> _stopProvisionedScan() async {
    await _provisioningSubscription?.cancel();
    isScanning = false;
  }

  /// Connect to the devices.
  ///
  /// Pass the List of [DiscoveredDevice]s that you want to connect to.
  Future<void> connectToDevice({
    required int companyId,
    required DiscoveredDevice device,
  }) async {
    bleMeshManager.callbacks = DoozProvisionedBleMeshManagerCallbacks(
      _meshManagerApi,
      bleMeshManager,
    );

    log('device: ${device.id} connecting...');
    await bleMeshManager.connect(device);

    //first one is the default provisioner which is to be ignored
    List<ProvisionedMeshNode> nodes =
        (await _meshManagerApi.meshNetwork!.nodes).skip(1).toList();
    for (final node in nodes) {
      final elements = await node.elements;
      for (final element in elements) {
        for (final model in element.models) {
          // iOS specific way to bind app key with the correct model id
          int passedModelId = model.modelId;
          if (Platform.isIOS) {
            // hardcoded model ids according to the hardware
            if (model.modelId == 0x1111) {
              String dataPlaneModelId =
                  "0x${companyId.toRadixString(16).toUpperCase()}1111";
              log("dataPlaneModelId: $dataPlaneModelId");
              passedModelId = int.parse(dataPlaneModelId);
            } else if (model.modelId == 0x2222) {
              String controlPlaneModelId =
                  "0x${companyId.toRadixString(16).toUpperCase()}2222";
              log("controlPlaneModelId: $controlPlaneModelId");
              passedModelId = int.parse(controlPlaneModelId);
            }
          }
          if (model.boundAppKey.isEmpty) {
            if (element == elements.first && model == element.models.first) {
              continue;
            }

            final unicast = await node.unicastAddress;
            log('Binding model $passedModelId to app key on node $unicast');
            await _meshManagerApi.sendConfigModelAppBind(
              unicast,
              element.address,
              passedModelId,
            );
            log('Binding successful for model ${model.modelId}');
          }
        }
      }
    }
  }

  /// Disconnects from the devices.
  void _deinit() async {
    await bleMeshManager.disconnect();
    await bleMeshManager.callbacks!.dispose();
  }

  /// Golain Data Plane Get Method
  ///
  /// Pass the [elementAddress], [companyId], [opcode] and [data].
  /// Model ID for this plane is 0x1111.
  /// Passed Model ID is concatenated with the [companyId] to form the model ID.
  Future<VendorModelMessageData> dataPlaneGet({
    required int elementAddress,
    required int companyId,
    required int opcode,
    required Uint8List data,
  }) async {
    int passedModelId =
        int.parse("0x${companyId.toRadixString(16).toUpperCase()}1111");
    final vendorMessage = _meshManagerApi
        .golainVendorModelSend(
          elementAddress,
          opcode,
          data,
          modelId: passedModelId,
          // companyId
        )
        .timeout(
          const Duration(seconds: 10),
        );

    return vendorMessage;
  }

  /// Golain Control Plane Get Method
  ///
  /// Pass the [elementAddress], [companyId], [opcode] and [data].
  /// Model ID for this plane is 0x2222.
  /// Passed Model ID is concatenated with the [companyId] to form the model ID.
  Future<VendorModelMessageData> controlPlaneGet({
    required int elementAddress,
    required int companyId,
    required int opcode,
    required Uint8List data,
  }) async {
    int passedModelId =
        int.parse("0x${companyId.toRadixString(16).toUpperCase()}2222");
    final vendorMessage = _meshManagerApi
        .golainVendorModelSend(
          elementAddress,
          opcode,
          data,
          modelId: passedModelId,
        )
        .timeout(
          const Duration(seconds: 5),
        );

    return vendorMessage;
  }

  /// Golain Data Plane Get Method
  ///
  /// Pass the [elementAddress], [companyId], [opcode] and [data].
  /// Model ID for this plane is 0x2222.
  /// Passed Model ID is concatenated with the [companyId] to form the model ID.
  Future<VendorModelMessageData> controlPlaneSet({
    required int elementAddress,
    required int companyId,
    required int opcode,
    required Uint8List data,
  }) async {
    int passedModelId =
        int.parse("0x${companyId.toRadixString(16).toUpperCase()}2222");

    final vendorMessage = _meshManagerApi
        .golainVendorModelSend(
          elementAddress,
          opcode,
          data,
          modelId: passedModelId,
        )
        .timeout(
          const Duration(seconds: 5),
        );

    return vendorMessage;
  }
}
