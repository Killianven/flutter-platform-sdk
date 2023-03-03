part of 'scan_bloc.dart';

@immutable
abstract class ScanState extends Equatable {
  const ScanState();

  @override
  List<Object> get props => [];
}

class ScanReady extends ScanState {}

class PermissionGranted extends ScanState {}

class PermissionDenied extends ScanState {}

class ScanningSuccess extends ScanState {
  final List<DiscoveredDevice> scannedDevices;
  const ScanningSuccess(this.scannedDevices);

  @override
  List<Object> get props => [scannedDevices];
}

class ScanningInProgress extends ScanState {}

class ScanningFailure extends ScanState {
  final String message;
  const ScanningFailure(this.message);

  @override
  List<Object> get props => [message];
}

class Provisioned extends ScanState {}
