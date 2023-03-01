import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:golain/golain.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

part 'scan_event.dart';
part 'scan_state.dart';

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final Golain _golain = Golain();

  ScanBloc() : super(ScanningInitial()) {
    on<PermissionRequested>((event, emit) async {
      try {
        await _requestPermissions();
        emit(PermissionGranted());
      } catch (e) {
        emit(PermissionDenied());
      }
    });

    on<ScanRequested>((event, emit) async {
      try {
        final scannedDevices = await _golain.scanUnprovisionedDevices();
        emit(ScanningSuccess(scannedDevices));
      } catch (e) {
        emit(ScanningFailure(e.toString()));
      }
    });
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
