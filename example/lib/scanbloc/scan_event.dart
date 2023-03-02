part of 'scan_bloc.dart';

@immutable
abstract class ScanEvent extends Equatable {
  const ScanEvent();
  @override
  List<Object> get props => [];
}

class PermissionRequested extends ScanEvent {}

class ScanRequested extends ScanEvent {}

class Provision extends ScanEvent {
  DiscoveredDevice device;
  Provision(this.device);
}
