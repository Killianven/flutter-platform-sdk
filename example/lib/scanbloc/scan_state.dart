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

class ProvisionedDevices extends ScanState {
  final List<DiscoveredDevice> provisionedDevices;
  const ProvisionedDevices(this.provisionedDevices);

  @override
  List<Object> get props => [provisionedDevices];
}

class ProvisionDeviceRequestFailure extends ScanState {
  final String message;
  const ProvisionDeviceRequestFailure(this.message);

  @override
  List<Object> get props => [message];
}

class ConnectedDevice extends ScanState{
  final String message;
  const ConnectedDevice(this.message);

  @override
  List<Object> get props => [message];
}

class ConnectionFailure extends ScanState{
  final String message;
  const ConnectionFailure(this.message);

  @override
  List<Object> get props => [message];
}