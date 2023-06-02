import 'package:json_annotation/json_annotation.dart';
part 'devices.g.dart';

@JsonSerializable()
class Device{
  String id;
  String device_name;
  String certificate_id;
  String current_shadow;
  String shadow_definition_id;
  String status_flags;
  bool connected;
  String last_seen;
  String topic_slug;
  String fleet_id;
  String project_id;
  String org_id;
  String updated_by;
  String created_at;
  String pending_ota_update_id;
  
  Device({
    required this.id,
    required this.device_name,
    required this.certificate_id,
    required this.current_shadow,
    required this.shadow_definition_id,
    required this.status_flags,
    required this.connected,
    required this.last_seen,
    required this.topic_slug,
    required this.fleet_id,
    required this.project_id,
    required this.org_id,
    required this.updated_by,
    required this.created_at,
    required this.pending_ota_update_id,
  }
  );

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceToJson(this);


  
}