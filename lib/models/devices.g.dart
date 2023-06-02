// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'devices.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device _$DeviceFromJson(Map<String, dynamic> json) => Device(
      id: json['id'] as String,
      device_name: json['device_name'] as String,
      certificate_id: json['certificate_id'] as String,
      current_shadow: json['current_shadow'] as String,
      shadow_definition_id: json['shadow_definition_id'] as String,
      status_flags: json['status_flags'] as String,
      connected: json['connected'] as bool,
      last_seen: json['last_seen'] as String,
      topic_slug: json['topic_slug'] as String,
      fleet_id: json['fleet_id'] as String,
      project_id: json['project_id'] as String,
      org_id: json['org_id'] as String,
      updated_by: json['updated_by'] as String,
      created_at: json['created_at'] as String,
      pending_ota_update_id: json['pending_ota_update_id'] as String,
    );

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
      'id': instance.id,
      'device_name': instance.device_name,
      'certificate_id': instance.certificate_id,
      'current_shadow': instance.current_shadow,
      'shadow_definition_id': instance.shadow_definition_id,
      'status_flags': instance.status_flags,
      'connected': instance.connected,
      'last_seen': instance.last_seen,
      'topic_slug': instance.topic_slug,
      'fleet_id': instance.fleet_id,
      'project_id': instance.project_id,
      'org_id': instance.org_id,
      'updated_by': instance.updated_by,
      'created_at': instance.created_at,
      'pending_ota_update_id': instance.pending_ota_update_id,
    };
