import 'dart:async';

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

  StreamSubscription? _scanSubscription;
  // final _serviceData = <String, Uuid>{};
  // final List<DiscoveredDevice> _devices = [];

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
    _meshManagerApi.loadMeshNetwork();
  }

  void dispose() {
    onNetworkUpdateSubscription.cancel();
    onNetworkImportSubscription.cancel();
    onNetworkLoadingSubscription.cancel();
    _scanSubscription?.cancel();
  }

  /// Scans for unprovisioned devices.
  ///
  /// Returns a list of [DiscoveredDevice]s. Await this method to get the list.
  /// The list is empty if no devices are found.
  /// Throws [PermissionDeniedException] if the bluetooth permission is not granted.
  /// Throws [BluetoothNotEnabledException] if the bluetooth is not enabled.
  Future<List<DiscoveredDevice>> scanUnprovisionedDevices() async {
    // TODO: implement scanUnprovisionedDevices
     Set<DiscoveredDevice> _devices = <DiscoveredDevice>{};
     List<DiscoveredDevice> devices = [];
    
     
    _scanSubscription?.cancel();
    devices.clear();
    // ignore: await_only_futures
    _scanSubscription = await _nordicNrfMesh.scanForUnprovisionedNodes().listen (
      (device) async {
         if(_devices.every((element) => element.id != device.id)) {
          _devices.add(device);
          // devices.add(device);
           devices=_devices.toList();
         }
      },
    );
  
    return Future.delayed(
      const Duration(seconds: 5),
      () {
        _scanSubscription?.cancel();
        return devices;
      },
    );
  }

  /// Stops scanning for unprovisioned devices.
  ///
  /// Call this method with a timeout to the [scanUnprovisionedDevices] method.
  /// Otherwise, the scanning will continue forever consuming battery of the mobile.
  Future<void> stopScanning() {
    // TODO: implement scanUnprovisionedDevices

   
    throw UnimplementedError();
  }

  /// Provisions a device.
  ///
  /// Await this method to provision the devices.
  /// Pass the list of [DiscoveredDevice]s that you want to provision.
  Future<void> provisionDevice(List<DiscoveredDevice> devices) {
    // TODO: implement provisionDevice
    throw UnimplementedError();
  }
}
