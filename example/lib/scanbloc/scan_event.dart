// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'scan_bloc.dart';

@immutable
abstract class ScanEvent extends Equatable {
  const ScanEvent();
  @override
  List<Object> get props => [];
}

class PermissionRequested extends ScanEvent {}

class ScanRequested extends ScanEvent {}

class ResetMeshNetwork extends ScanEvent {}

class ExportMeshNetwork extends ScanEvent {}

class ImportMeshNetwork extends ScanEvent {
  final File filePath;
  const ImportMeshNetwork(this.filePath);
}
class Provision extends ScanEvent {
  final DiscoveredDevice device;
  const Provision(this.device);
}

class ProvisionedDevicesRequested extends ScanEvent {}

class ConnectToDevice extends ScanEvent {
  final DiscoveredDevice provisionedDevice;
  const ConnectToDevice(this.provisionedDevice);
}

class VendorModelDataGetRequested extends ScanEvent {
  final int elementAddress;
  final String data;
  const VendorModelDataGetRequested(
    this.elementAddress,
    this.data,
  );
}

class VendorModelControlGetRequested extends ScanEvent {
  final int elementAddress;
  final Uint8List data;
  const VendorModelControlGetRequested(
    this.elementAddress,
    this.data,
  );
}

class VendorModelControlSetRequested extends ScanEvent {
  final int elementAddress;
  final Uint8List data;
  const VendorModelControlSetRequested(
    this.elementAddress,
    this.data,
  );
}

class DeprovisioningRequested extends ScanEvent {
  final int elementAddress;
  const DeprovisioningRequested(this.elementAddress);
}
