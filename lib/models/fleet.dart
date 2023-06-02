class Fleet {
  String fleetId;
  String fleetName;
  String fleetDesc;
  String shadowDefinitionId;
  String provisioningPolicyId;
  String loggingPolicyId;
  String userAuthenticationPolicyId;
  String otaPolicyId;
  String projectId;
  String orgId;
  String createdAt;

  Fleet({
      required this.fleetId,
      required this.fleetName,
      required this.fleetDesc,
      required this.shadowDefinitionId,
      required this.provisioningPolicyId,
      required this.loggingPolicyId,
      required this.userAuthenticationPolicyId,
      required this.otaPolicyId,
      required this.projectId,
      required this.orgId,
      required this.createdAt,
     }
  );
  
}
