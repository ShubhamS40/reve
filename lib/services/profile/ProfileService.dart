import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reva/models/profile/profileModel.dart';
import '../signup/AuthenticationService.dart';

class UserProfileService {
  final Authenticationservice _authenticationservice = Authenticationservice();
  // Use the same host as AuthenticationService for consistency
  final String baseUrl =
      'http://192.168.0.101:3000/index/profile'; // For Android emulator pointing to localhost
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final accessToken = await _authenticationservice.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
      'x-auth-token': accessToken ?? '',
    };
  }

  Future<http.Response> _authenticatedProfilePost(String endpoint,
      {Map<String, dynamic>? body}) async {
    String? accessToken = await _authenticationservice.getAccessToken();

    Uri url = Uri.parse('$baseUrl/$endpoint');

    try {
      // Include authentication token if available
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      if (accessToken != null) {
        headers['x-auth-token'] = accessToken;
      }

      final response = await http.post(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      // Handle authentication errors
      if (response.statusCode == 401 || response.statusCode == 403) {
        // Try to refresh token and retry
        String? refreshToken = await _secureStorage.read(key: 'refreshToken');
        if (refreshToken != null) {
          final newToken =
              await _authenticationservice.refreshAccessToken(refreshToken);
          if (newToken != null) {
            // Update header with new token
            headers['x-auth-token'] = newToken;

            // Retry request with new token
            return await http.post(
              url,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            );
          }
        }
      }

      return response;
    } catch (e) {
      print('Exception in authenticated profile request: $e');
      throw e;
    }
  }

  Future<bool> submitStep1(Step1 data) async {
    final http.Response response = await _authenticatedProfilePost(
      'profile1',
      body: data.toJson(),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("response,${response.body}");
      print("response,${data.toJson()}");
      print('Having issue while the submitting the step 1');
      return false;
    }
  }

  Future<bool> submitStep2(Step2 data) async {
    final http.Response response = await _authenticatedProfilePost(
      'profile2',
      body: data.toJson(),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Having issue while the submitting the step 2');
      return false;
    }
  }

  Future<bool> submitStep3(Step3 data) async {
    final http.Response response = await _authenticatedProfilePost(
      'profile3',
      body: data.toJson(),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Having issue while the submitting the step 3');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      print("data:${data.toJson()}");
      // return false;
      return false;
    }
  }

  Future<bool> submitStep4(Step4 data) async {
    final http.Response response = await _authenticatedProfilePost(
      'profile4',
      body: data.toJson(),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Having issue while the submitting the step 4');
      return false;
    }
  }

  Future<bool> submitStep5(Step5 data) async {
    final http.Response response = await _authenticatedProfilePost(
      'profile5',
      body: data.toJson(),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Having issue while the submitting the step 5');
      return false;
    }
  }
}
