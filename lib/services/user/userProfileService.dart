import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:reva/models/user/userProfileSubscription.dart';
import '../signup/AuthenticationService.dart';

class UserProfileService {
  final Authenticationservice _authenticationservice = Authenticationservice();
  // Update this to your actual backend URL when deploying
  final String baseUrl =
      "http://192.168.0.101:3000"; // For Android emulator pointing to localhost
  final String apiPath = "/index"; // API-specific path
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Method to show error messages
  void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Method to handle network errors with retry logic
  Future<http.Response?> _makeAuthenticatedRequest(
      String url, String accessToken,
      {int retryCount = 3}) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': accessToken,
        },
      );
      return response;
    } on SocketException {
      if (retryCount > 0) {
        // Wait before retrying
        await Future.delayed(const Duration(seconds: 2));
        return _makeAuthenticatedRequest(url, accessToken,
            retryCount: retryCount - 1);
      } else {
        print(
            'Network error: Unable to connect to server after multiple attempts');
        return null;
      }
    } catch (e) {
      print('Error making authenticated request: $e');
      return null;
    }
  }

  // Method to get user profile without context (for background operations)
  Future<UserProfileWithSubscription?> getUserProfileWithSubscription() async {
    try {
      // Get the user ID from secure storage
      final userId = await _secureStorage.read(key: 'userId');
      if (userId == null) {
        print("User ID not found in secure storage");
        return null;
      }

      // Get the access token
      final accessToken = await _authenticationservice.getAccessToken();
      if (accessToken == null) {
        print("Access token not found");
        return null;
      }

      // Make the API request with retry logic
      final url = '$baseUrl$apiPath/user/profile-with-subscription/$userId';
      final response = await _makeAuthenticatedRequest(url, accessToken);

      if (response == null) {
        print('Failed to get response from server');
        return null;
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserProfileWithSubscription.fromJson(data);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Token expired, try to refresh
        final refreshToken = await _secureStorage.read(key: 'refreshToken');
        if (refreshToken != null) {
          final newToken =
              await _authenticationservice.refreshAccessToken(refreshToken);
          if (newToken != null) {
            // Retry with new token
            return getUserProfileWithSubscription();
          }
        }
        print('Authentication failed, please login again');
        return null;
      } else {
        print(
            'Error fetching user profile with subscription: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception fetching user profile with subscription: $e');
      return null;
    }
  }

  // Method to get user profile with context for error handling
  Future<UserProfileWithSubscription?>
      getUserProfileWithSubscriptionWithContext(BuildContext context) async {
    try {
      final profile = await getUserProfileWithSubscription();
      if (profile == null) {
        showErrorMessage(
            context, 'Failed to load profile data. Please try again.');
      }
      return profile;
    } catch (e) {
      showErrorMessage(context, 'An error occurred: ${e.toString()}');
      return null;
    }
  }
}
