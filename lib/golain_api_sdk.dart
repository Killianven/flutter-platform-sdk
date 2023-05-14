import 'package:dio/dio.dart';
import 'package:golain/constants.dart';


 
 class GolainApi{

  Dio dio = Dio();

 Future<Map<String, dynamic>> getDeviceShadow(
      String fleetId, String deviceId, String authToken, String orgId, String projectId) async {
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
      String shadowData) async {
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
      String orgId) async {
    try {
      dio.options.headers['Authorization'] = "Bearer $authToken";
      dio.options.headers['ORG-ID'] = orgId;
      final response = await dio.put(
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

  }