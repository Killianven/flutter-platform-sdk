class Device{
  String deviceName;
  String deviceId;
  String certificateId;
  String currentShadow;
  String shadowDefinitionId;
  String statusFlags;
  bool connected;
  String lastSeen;
  String topicSlug;
  String fleetId;
  String projectId;
  String orgId;
  String updatedBy;
  String createdAt;
  String pendingOtaUpdateId;
  
  Device({
    required this.deviceName,
    required this.deviceId,
    required this.certificateId,
    required this.currentShadow,
    required this.shadowDefinitionId,
    required this.statusFlags,
    required this.connected,
    required this.lastSeen,
    required this.topicSlug,
    required this.fleetId,
    required this.projectId,
    required this.orgId,
    required this.updatedBy,
    required this.createdAt,
    required this.pendingOtaUpdateId,
  
  }
  );
}