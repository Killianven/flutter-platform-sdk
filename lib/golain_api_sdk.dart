import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:golain/models/devices.dart';
import 'package:golain/models/fleet.dart';
// import 'package:golain/constants.dart';


 
 class GolainApi{

  Dio dio = Dio();

 Future<Map<String, dynamic>> getDeviceShadow(
      String fleetId, String deviceId, String authToken, String orgId, String projectId, String baseUrl) async {
    try {
      dio.options.headers['Authorization'] = "Bearer $authToken";
      dio.options.headers['ORG-ID'] = orgId;
      Response response = await dio.get(
        "$baseUrl/$projectId/fleets/$fleetId/devices/$deviceId/shadow",
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get shadow');
      }
    } catch (e) {
      //print(response.data);
      throw Exception('Failed to get shadow response');
    }
  }

//post request to create shadow
  Future<Map<String, dynamic>> createDeviceShadow(
    String projectId,
      String fleetId,
      String deviceId,
      String authToken,
      String orgId,
      String shadowData,
      String baseUrl) async {
    try {
      dio.options.headers['Authorization'] = "Bearer $authToken";
      dio.options.headers['ORG-ID'] = orgId;
      final response = await dio.post(
          '$baseUrl/$projectId/fleets/$fleetId/devices/$deviceId/shadow',
          data: shadowData);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to create shadow');
      }
    } catch (e) {
      throw Exception('Failed to create shadow response');
    }
  }

//put request to update shadow
  Future<Map<String, dynamic>> updateDeviceShadow(
    String projectId,
      String fleetID,
      String deviceId,
      String shadowData,
      String authToken,
      String orgId,
      String baseUrl) async {
    try {
      dio.options.headers['Authorization'] = "Bearer $authToken";
      dio.options.headers['ORG-ID'] = orgId;
      final response = await dio.patch(
          '$baseUrl/$projectId/fleets/$fleetID/devices/$deviceId/shadow',
          data: shadowData);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to update shadow');
      }
    } catch (e) {
      throw Exception('Failed to update shadow response');
    }
 }


 Future<List<Device>> getDevices(
    String accessToken, String organisationId, String fleetId, String fleetUrl) async {
  try {
    dio.options.headers['Authorization'] = "Bearer $accessToken";
    dio.options.headers['ORG-ID'] = organisationId;
    Response response = await dio.get('fleetUrl/$fleetId/devices');
    if (response.statusCode == 200) {
      log(response.data.toString());
      List<dynamic> data = response.data['data']['devices'];
      List<Device> devices = [];
      for (var device in data) {
        Device newDevice = Device(
          deviceId: device['id'],
          deviceName: device['device_name'],
          certificateId: device['certificate_id'],
          currentShadow: device['current_shadow'],
          shadowDefinitionId: device['shadow_definition_id'],
          statusFlags: device['status_flags'],
          connected: device['connected'],
          lastSeen: device['last_seen'],
          topicSlug: device['topic_slug'],
          fleetId: device['fleet_id'],
          projectId: device['project_id'],
          orgId: device['org_id'],
          updatedBy: device['updated_by'],
          createdAt: device['created_at'],
          pendingOtaUpdateId: device['pending_ota_update_id'],
        );
        devices.add(newDevice);
      }
      return devices;
    } else {
      throw Exception("Failed to get devices");
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future<List<Fleet>> getFleets(String accessToken, String organisationId, String fleetUrl) async {
  try {
    dio.options.headers['Authorization'] = "Bearer $accessToken";
    dio.options.headers['ORG-ID'] = organisationId;
    Response response = await dio.get(fleetUrl);
    if (response.statusCode == 200) {
      List<dynamic> data = response.data['data']['fleets'];
      log(data.toString());
      List<Fleet> fleets = [];
      for (var fleet in data) {
        Fleet newFleet = Fleet(
            fleetId: fleet['id'],
            fleetName: fleet['fleet_name'],
            fleetDesc: fleet['fleet_description'],
            shadowDefinitionId: fleet['shadow_definition_id'],
            provisioningPolicyId: fleet['provisioning_policy_id'],
            loggingPolicyId: fleet['logging_policy_id'],
            userAuthenticationPolicyId: fleet['user_authentication_policy_id'],
            otaPolicyId: fleet['ota_policy_id'],
            projectId: fleet['project_id'],
            orgId: fleet['org_id'],
            createdAt: fleet['created_at'] 
        );
        fleets.add(newFleet);
      }
      return fleets;
    } else {
      throw Exception("Failed to get devices");
    }
  } catch (e) {
    log(e.toString());
      throw Exception(e.toString());
  }
}
  }
