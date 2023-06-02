// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fleet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Fleet _$FleetFromJson(Map<String, dynamic> json) => Fleet(
      id: json['id'] as String,
      fleet_name: json['fleet_name'] as String,
      fleet_description: json['fleet_description'] as String,
      shadow_definition_id: json['shadow_definition_id'] as String,
      provisioning_policy_id: json['provisioning_policy_id'] as String,
      logging_policy_id: json['logging_policy_id'] as String,
      user_authentication_policy_id:
          json['user_authentication_policy_id'] as String,
      ota_policy_id: json['ota_policy_id'] as String,
      project_id: json['project_id'] as String,
      org_id: json['org_id'] as String,
      created_at: json['created_at'] as String,
    );

Map<String, dynamic> _$FleetToJson(Fleet instance) => <String, dynamic>{
      'id': instance.id,
      'fleet_name': instance.fleet_name,
      'fleet_description': instance.fleet_description,
      'shadow_definition_id': instance.shadow_definition_id,
      'provisioning_policy_id': instance.provisioning_policy_id,
      'logging_policy_id': instance.logging_policy_id,
      'user_authentication_policy_id': instance.user_authentication_policy_id,
      'ota_policy_id': instance.ota_policy_id,
      'project_id': instance.project_id,
      'org_id': instance.org_id,
      'created_at': instance.created_at,
    };
