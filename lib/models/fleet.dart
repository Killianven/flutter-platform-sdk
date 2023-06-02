import 'package:json_annotation/json_annotation.dart';
part 'fleet.g.dart';

@JsonSerializable()
class Fleet {
  String id;
  String fleet_name;
  String fleet_description;
  String shadow_definition_id;
  String provisioning_policy_id;
  String logging_policy_id;
  String user_authentication_policy_id;
  String ota_policy_id;
  String project_id;
  String org_id;
  String created_at;

  Fleet({
    required this.id,
    required this.fleet_name,
    required this.fleet_description,
    required this.shadow_definition_id,
    required this.provisioning_policy_id,
    required this.logging_policy_id,
    required this.user_authentication_policy_id,
    required this.ota_policy_id,
    required this.project_id,
    required this.org_id,
    required this.created_at,
    
     } 
  );


  factory Fleet.fromJson(Map<String, dynamic> json) => _$FleetFromJson(json);

  Map<String, dynamic> toJson() => _$FleetToJson(this);
}
