import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'golain_platform_interface.dart';

class Golain {
  Future<String?> getPlatformVersion() {
    return GolainPlatform.instance.getPlatformVersion();
  }

  /// Initializes the streams required for the plugin and returns an instance of [Golain].
  Golain();

  /// Scans for unprovisioned devices.
  ///
  /// Returns a list of [DiscoveredDevice]s. Await this method to get the list.
  /// The list is empty if no devices are found.
  /// Throws [PermissionDeniedException] if the bluetooth permission is not granted.
  /// Throws [BluetoothNotEnabledException] if the bluetooth is not enabled.
  Future<List<DiscoveredDevice>> scanUnprovisionedDevices() {
    // TODO: implement scanUnprovisionedDevices
    throw UnimplementedError();
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
