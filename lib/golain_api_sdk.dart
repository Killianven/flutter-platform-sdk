import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:golain/models/devices.dart';
import 'package:golain/models/fleet.dart';

import 'models/auth.dart';
// import 'package:golain/constants.dart';


 
 class GolainAPI{

  Dio dio = Dio();
  String? baseUrl;
  String? orgId;
  String? projectId;
  Auth?   auth;
  String? fleetUrl;

  GolainAPI (String baseUrl, String orgId, String projectId,String fleetUrl){
    this.baseUrl = baseUrl;
    this.orgId = orgId;
    this.projectId = projectId;
    this.auth = auth;
    this.fleetUrl = fleetUrl;
   
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['ORG-ID'] = orgId;
  }

 Future<Map<String, dynamic>> getDeviceShadow(
     Device device, String authToken) async {
      dio.options.headers['Authorization'] = "Bearer ${authToken}";
    try {
      Response response = await dio.get(
        "$baseUrl/${device.project_id}/fleets/${device.fleet_id}/devices/${device.id}/shadow",
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get shadow');
      }
    } catch (e) {
      
      throw Exception('Failed to get shadow response');
    }
  }

//post request to create shadow
  Future<Map<String, dynamic>> createDeviceShadow(
      Device device,
      String shadowData,String authToken) async {
         dio.options.headers['Authorization'] = "Bearer ${authToken}";
    try {
      final response = await dio.post(
          '$baseUrl/core/api/v1/projects/${device.project_id}/fleets/${device.fleet_id}/devices/${device.id}/shadow',
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
    Device device,
      String shadowData, String authToken) async {
         dio.options.headers['Authorization'] = "Bearer ${authToken}";
    try {
      final response = await dio.patch(
          '$baseUrl/core/api/v1/projects/${device.project_id}/fleets/${device.fleet_id}/devices/${device.id}/shadow',
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


 Future<List<Device>> getDevices(Fleet fleet, String authToken) async {
   dio.options.headers['Authorization'] = "Bearer ${authToken}";
  try {
    Response response = await dio.get('$baseUrl/core/api/v1/projects/${fleet.project_id}/fleets/${fleet.id}/devices');
    if (response.statusCode == 200) {
      log(response.data.toString());
      List<dynamic> data = response.data['data']['devices'];
      List<Device> devices = [];
      for (var device in data) {
        Device newDevice = Device.fromJson(device);
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

Future<List<Fleet>> getFleets(String authToken) async {
   dio.options.headers['Authorization'] = "Bearer ${authToken}";
  try {
    Response response = await dio.get(fleetUrl!);
    if (response.statusCode == 200) {
      List<dynamic> data = response.data['data']['fleets'];
      log(data.toString());
      List<Fleet> fleets = [];
      for (var fleet in data) {
        Fleet newFleet = Fleet.fromJson(fleet);
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
