import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nordic_nrf_mesh/nordic_nrf_mesh.dart';
import 'package:permission_handler/permission_handler.dart';

import 'golain_doozMeshManager.dart';
import 'golain_platform_interface.dart';

class Golain {
  Future<String?> getPlatformVersion() {
    return GolainPlatform.instance.getPlatformVersion();
  }

  StreamSubscription? _subscription;
  final NordicNrfMesh _nordicNrfMesh = NordicNrfMesh();
  final FlutterReactiveBle _flutterReactiveBle = FlutterReactiveBle();
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
  Dio dio = Dio();
  final _devices = <DiscoveredDevice>[];
  final _deviceConnectionController = StreamController<ConnectionStateUpdate>();

  // ignore: cancel_subscriptions
  late StreamSubscription<ConnectionStateUpdate> _connection;

  /// Initializes the streams required for the plugin and returns an instance of [Golain].
  // Golain() {
  //   _meshManagerApi = _nordicNrfMesh.meshManagerApi;
  //   _meshNetwork = _meshManagerApi.meshNetwork;
  //   onNetworkUpdateSubscription =
  //       _meshManagerApi.onNetworkUpdated.listen((network) {
  //     _meshNetwork = network;
  //   });
  //   onNetworkImportSubscription =
  //       _meshManagerApi.onNetworkImported.listen((network) {
  //     _meshNetwork = network;
  //   });
  //   onNetworkLoadingSubscription =
  //       _meshManagerApi.onNetworkLoaded.listen((network) {
  //     _meshNetwork = network;
  //   });
  //   // loading mesh network in the initialization
  //   loadMeshNetwork();
  // }

  // /// Disposes the streams used by the plugin.
  // void dispose() {
  //   onNetworkUpdateSubscription.cancel();
  //   onNetworkImportSubscription.cancel();
  //   onNetworkLoadingSubscription.cancel();
  //   _scanSubscription?.cancel();
  //   _provisioningSubscription?.cancel();
  //   _deinit();
  // }

  Future<void> loadMeshNetwork() async {
    await _meshManagerApi.loadMeshNetwork();
  }

  Future<IMeshNetwork> importMeshNetwork(File file) async {
    final newfile = await file.readAsString();
    return _meshManagerApi.importMeshNetworkJson(newfile);
  }

  /// Exports the mesh network stored in phones cache.
  Future<String> exportMeshNetwork() async {
    if (_meshManagerApi.meshNetwork == null) {
      throw Exception("Mesh Network not loaded");
    }
    final String? meshNetwork = await _meshManagerApi.exportMeshNetwork();
    return meshNetwork!;
  }

  /// Resets the mesh network stored in phones cache.
  void resetMeshNetwork() async {
    await _meshManagerApi.resetMeshNetwork();
  }

  /// Creates a group with the given [groupName].
  Future<GroupData> createGroup(String groupName) async {
    var data = await _meshManagerApi.meshNetwork!.addGroupWithName(groupName);
    return data!;
  }

  /// Removes the group with the given [address].
  void removeGroup(String address) async {
    await _meshManagerApi.meshNetwork!.removeGroup(int.parse(address));
  }

  Future<List<ElementData>> getElementsForGroup(String address) async {
    var elements =
        await _meshManagerApi.meshNetwork!.elementsForGroup(int.parse(address));
    return elements;
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
  /// Returns the element address of the device.
  Future<int> connectToDevice({
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
            return element.address;
          }
        }
      }
    }
    return -1;
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

  /// Deprovision the node.
  ///
  /// Pass the [unicastAddress] of the node to be deprovisioned.
  Future<String> deprovisionNode({
    required int unicastAddress,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final node = await _meshManagerApi.meshNetwork!.getNode(unicastAddress);
    final nodes = await _meshManagerApi.meshNetwork!.nodes;
    try {
      final provisionedNode =
          nodes.firstWhere((element) => element.uuid == node!.uuid);
      await _meshManagerApi.deprovision(provisionedNode).timeout(timeout);
      return 'Node deprovisioned';
    } on TimeoutException catch (_) {
      return 'Board didn\'t respond';
    } on PlatformException catch (e) {
      return e.toString();
    } on StateError catch (_) {
      return 'No node found with this uuid';
    } catch (e) {
      return e.toString();
    }
  }

  /// Send Config Model Publication Set

  Future<ConfigModelPublicationStatus> sendPublication(
      {selectedElementAddress, selectedSubscriptionAddress, selectedModelId}) {
    return _meshManagerApi
        .sendConfigModelPublicationSet(selectedElementAddress,
            selectedSubscriptionAddress, selectedModelId)
        .timeout(const Duration(seconds: 40));
  }

  /// Send Config Model Subscription Add

  Future<ConfigModelSubscriptionStatus> sendSubscription({
    selectedElementAddress,
    selectedSubscriptionAddress,
    selectedModelId,
  }) {
    return _meshManagerApi
        .sendConfigModelSubscriptionAdd(selectedElementAddress,
            selectedSubscriptionAddress, selectedModelId)
        .timeout(const Duration(seconds: 40));
  }

  // To scan for devices

  Future<List<DiscoveredDevice>> scanBLEDevice(
      List<Uuid> serviceIds, Duration duration) async {
    try {
      _devices.clear();
      _subscription?.cancel();
      await _requestPermissions();
      _subscription = _flutterReactiveBle
          .scanForDevices(withServices: serviceIds)
          .listen((device) async {
        isScanning = true;
        final deviceIndex =
            _devices.indexWhere((element) => element.id == device.id);
        if (deviceIndex >= 0) {
          _devices[deviceIndex] = device;
        } else {
          isScanning = false;
          _devices.add(device);
        }
      });

      return await Future.delayed(
        Duration(seconds: duration.inSeconds),
        () {
          return _devices;
        },
      );
    } catch (e) {
      log(e.toString());
    }
    return _devices;
  }

  Future<void> stopScan() async {
    log('Stop ble discovery');

    await _subscription?.cancel();
    _subscription = null;
  }

  /// To connect to the device
  /// Pass the [device] to connect to the device.

  Future<void> connectBLEDevice(DiscoveredDevice device) async {
    try {
      _connection = _flutterReactiveBle
          .connectToDevice(id: device.id)
          .listen((connectionState) {
        log('Connection state: $connectionState');
        _deviceConnectionController.add(connectionState);
        if (connectionState.connectionState ==
            DeviceConnectionState.connected) {
          Fluttertoast.showToast(
            msg: 'Connected to ${device.name}',
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
          );
        }
      });
    } catch (e) {
      log(e.toString());
    }
  }

  /// To disconnect from the device
  /// Pass the [device] to disconnect from the device.
  /// Pass the [duration] to disconnect after the specified duration.

  Future<void> disconnectBLEDevice(
      DiscoveredDevice device, Duration duration) async {
    try {
      await _connection.cancel();
    } catch (e) {
      log(e.toString());
    } finally {
      _deviceConnectionController.add(ConnectionStateUpdate(
          deviceId: device.id,
          connectionState: DeviceConnectionState.disconnected,
          failure: null));
      Fluttertoast.showToast(
        msg: 'Disconnected from ${device.name}',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
      );
    }
  }

  Future<List<DiscoveredService>> discoverServices(
      DiscoveredDevice device) async {
    try {
      final services = await _flutterReactiveBle.discoverServices(device.id);
      log('Discovered services: $services');
      return services;
    } catch (e) {
      log(e.toString());
    }
    return [];
  }

  /// read characteristic
  /// Pass the [device] to read the characteristic from the device.

  Future<List<int>> readCharacteristic(
      QualifiedCharacteristic characteristic) async {
    try {
      var res = await _flutterReactiveBle.readCharacteristic(
        characteristic,
      );
      log('Read characteristic: $res');
      return res;
    } catch (e) {
      log(e.toString());
    }
    return [];
  }

  /// write characteristic
  /// Pass the [device] to write the characteristic from the device.
  ///
  /// Pass the [value] to write the characteristic from the device.
  ///
  Future<void> writeCharacteristicwithResponse(
      QualifiedCharacteristic characteristic, List<int> value) async {
    try {
      await _flutterReactiveBle.writeCharacteristicWithResponse(
        characteristic,
        value: value,
      );
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> writeCharacteristicwithoutResponse(
      QualifiedCharacteristic characteristic, List<int> value) async {
    try {
      await _flutterReactiveBle.writeCharacteristicWithoutResponse(
        characteristic,
        value: value,
      );
    } catch (e) {
      log(e.toString());
    }
  }
}

Future<void> _requestPermissions() async {
  if (defaultTargetPlatform == TargetPlatform.android) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt < 31) {
      await Permission.locationWhenInUse.request();
      await Permission.locationAlways.request();
      await Permission.bluetooth.request();
    } else {
      await Permission.bluetoothScan.request();
      await Permission.bluetoothConnect.request();
    }
  } else {
    await Permission.bluetooth.request();
  }
}
