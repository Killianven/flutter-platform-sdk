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

class LoadingState extends ScanState {}

class ResetMeshNetworkSuccess extends ScanState {}

class ResetMeshNetworkFailure extends ScanState {
  final String message;
  const ResetMeshNetworkFailure(this.message);

  @override
  List<Object> get props => [message];
}
class ScanningSuccess extends ScanState {
  final List<DiscoveredDevice> scannedDevices;
  const ScanningSuccess(this.scannedDevices);

  @override
  List<Object> get props => [scannedDevices];
}

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

class ConnectedDevice extends ScanState {
  final String message;
  const ConnectedDevice(this.message);

  @override
  List<Object> get props => [message];
}

class ConnectionFailure extends ScanState {
  final String message;
  const ConnectionFailure(this.message);

  @override
  List<Object> get props => [message];
}

class VendorModelDataGetSuccess extends ScanState {
  final VendorModelMessageData data;
  const VendorModelDataGetSuccess(this.data);

  @override
  List<Object> get props => [data];
}

class VendorModelDataFailure extends ScanState {
  final String error;
  const VendorModelDataFailure(this.error);

  @override
  List<Object> get props => [error];
}

class VendorModelControlGetSuccess extends ScanState {
  final VendorModelMessageData data;
  const VendorModelControlGetSuccess(this.data);

  @override
  List<Object> get props => [data];
}

class VendorModelControlSetSuccess extends ScanState {
  final VendorModelMessageData data;
  const VendorModelControlSetSuccess(this.data);

  @override
  List<Object> get props => [data];
}

class VendorModelControlFailure extends ScanState {
  final String error;
  const VendorModelControlFailure(this.error);

  @override
  List<Object> get props => [error];
}
