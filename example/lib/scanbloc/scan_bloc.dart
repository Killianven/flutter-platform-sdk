import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:golain/golain.dart';
import 'package:golain_example/utils/constants.dart';
import 'package:permission_handler/permission_handler.dart';

part 'scan_event.dart';
part 'scan_state.dart';

// This is the BLoC that handles the scanning of devices
// It is responsible for requesting permissions and scanning for devices
// It also handles the provisioning of devices

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final Golain _golain = Golain();

  ScanBloc() : super(ScanReady()) {
    on<PermissionRequested>((event, emit) async {
      try {
        await _requestPermissions();
        emit(PermissionGranted());
      } catch (e) {
        emit(PermissionDenied());
      }
    });

// This is the event that triggers the scanning of devices

    on<ScanRequested>((event, emit) async {
      try {
        final scannedDevices =
            await _golain.scanUnprovisionedDevices(duration: kconstDuration);
        emit(ScanningSuccess(scannedDevices));
      } catch (e) {
        emit(ScanningFailure(e.toString()));
      }
    });

// This is the event that triggers the provisioning of devices

    on<Provision>((event, emit) async {
      try {
        await _golain.provisionDevice(event.device);
        emit(Provisioned());
      } catch (e) {
        emit(ScanningFailure(e.toString()));
      }
    });

// This is the event that triggers the retrieval of provisioned devices

    on<ProvisionedDevicesRequested>((event, emit) async {
      try {
        final provisionedDevices = await _golain.provisionedNodesInRange(
            timeoutDuration: const Duration(seconds: 8));
        emit(ProvisionedDevices(provisionedDevices));
      } catch (e) {
        emit(ProvisionDeviceRequestFailure(e.toString()));
      }
    });

// This is the event that triggers the connection to a device

    on<ConnectToDevice>((event, emit) async {
      try {
        await _golain.connectToDevice();
        emit(const ConnectedDevice('Connected to device'));
      } catch (e) {
        emit(ConnectionFailure(e.toString()));
      }
    });
  }
}

// This is the function that requests permissions
// It checks the platform and the version of the Android device
// If the device is running Android 12 or higher, it requests the new permissions
// If the device is running Android 11 or lower, it requests the old permissions

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
