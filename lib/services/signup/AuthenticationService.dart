import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reva/authentication/signup/signup.dart';
import 'package:reva/models/signup/authenticationmodel.dart';
import 'package:http/http.dart' as http;

class Authenticationservice {
  // Update this URL to your actual backend URL when deploying
  final String baseurl =
      "http://192.168.0.101:3000/index/auth"; // For Android emulator pointing to localhost
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<Users?> Signup(String firstName, String lastName, String mobileNumber,
      String MPIN) async {
    final url = Uri.parse('$baseurl/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'mobileNumber': mobileNumber,
          'MPIN': MPIN,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data == null || data['User'] == null) {
          print("Data or 'User' is null");
          return null;
        }

        // Store mobile number in secure storage
        final userMobileNumber = data['mobileNumber'] ?? mobileNumber;
        await _secureStorage.write(
            key: 'mobileNumber', value: userMobileNumber);

        print('Signup successful: ${data['msg']}');

        // Create user from response data
        final user = Users.fromJson(data['User']);
        return user;
      } else {
        print("Signup failed: ${response.body}");
        print("Response status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Signup exception: $e");
      return null;
    }
  }

  Future<Users?> Login(String mobileNumber, String MPIN) async {
    final url = Uri.parse('$baseurl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobileNumber': mobileNumber,
          'mpin': MPIN,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['acessToken'];
        final refreshToken = data['refreshToken'];
        final id = data['id'];
        final mobilenumber = data['mobilenumber'];

        // Store tokens and user info in secure storage
        await _secureStorage.write(key: 'accessToken', value: accessToken);
        await _secureStorage.write(key: 'refreshToken', value: refreshToken);
        await _secureStorage.write(key: 'userId', value: id);
        await _secureStorage.write(key: 'mobileNumber', value: mobilenumber);

        print('Login successful: $data');

        // Create a user object with available data
        return Users(
          id: id ?? '',
          firstName: '', // These will be populated when getting user info
          lastName: '',
          mobileNumber: mobilenumber,
          mpin: '', // We don't store the MPIN in the object
          otpVerified: true, // Assuming login means verified
          refreshToken: refreshToken,
          refreshTokenExpiresAt: DateTime.now().add(Duration(days: 7)),
        );
      } else {
        print("Login failed: ${response.body}");
        print("Response status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Login exception: $e");
      return null;
    }
  }

  // Check if user has an active subscription
  Future<bool> checkSubscription(String userId) async {
    try {
      final url = Uri.parse('$baseurl/../subscription/check');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['hasActiveSubscription'] ?? false;
      } else {
        print("Subscription check failed: ${response.body}");
        print("Response status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Subscription check exception: $e");
      return false;
    }
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'accessToken');
  }

  Future<bool> logout() async {
    final url = Uri.parse('$baseurl/logout');
    final refreshToken = await _secureStorage.read(key: 'refreshToken');

    if (refreshToken == null) {
      print('No refresh token found for logout');
      return false;
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        // Clear all stored tokens and user data on successful logout
        await _secureStorage.delete(key: 'accessToken');
        await _secureStorage.delete(key: 'refreshToken');
        await _secureStorage.delete(key: 'userData');
        // Keep mobileNumber for convenience on next login

        print('Logout successful');
        return true;
      } else {
        print("Logout failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Logout exception: $e");
      return false;
    }
  }

  Future<String?> refreshAccessToken(String refreshToken) async {
    final url = Uri.parse('$baseurl/refreshtoken');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['accessToken'];
        final newRefreshToken = data['refreshToken'];

        // Save new tokens to secure storage
        await _secureStorage.write(key: 'accessToken', value: newAccessToken);
        await _secureStorage.write(key: 'refreshToken', value: newRefreshToken);

        print('Token refreshed successfully');
        return newAccessToken;
      } else {
        print('Refresh failed: ${response.body}');
        print('Status code: ${response.statusCode}');

        // If refresh token is invalid or expired, clear tokens and require re-login
        if (response.statusCode == 403) {
          await _secureStorage.delete(key: 'accessToken');
          await _secureStorage.delete(key: 'refreshToken');
          print('Session expired, please login again');
        }
        return null;
      }
    } catch (e) {
      print('Exception during token refresh: $e');
      return null;
    }
  }

  Future<http.Response> authenticatedPost(String endpoint,
      {Map<String, dynamic>? body}) async {
    String? accessToken = await _secureStorage.read(key: 'accessToken');

    Uri url = Uri.parse('$baseurl/$endpoint');

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
          final newToken = await refreshAccessToken(refreshToken);
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
      print('Exception in authenticated request: $e');
      throw e;
    }
  }

  Future<http.Response> authenticatedGet(String endpoint) async {
    String? accessToken = await _secureStorage.read(key: 'accessToken');

    Uri url = Uri.parse('$baseurl/$endpoint');

    try {
      // Include authentication token if available
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      if (accessToken != null) {
        headers['x-auth-token'] = accessToken;
      }

      final response = await http.get(
        url,
        headers: headers,
      );

      // Handle authentication errors
      if (response.statusCode == 401 || response.statusCode == 403) {
        // Try to refresh token and retry
        String? refreshToken = await _secureStorage.read(key: 'refreshToken');
        if (refreshToken != null) {
          final newToken = await refreshAccessToken(refreshToken);
          if (newToken != null) {
            // Update header with new token
            headers['x-auth-token'] = newToken;

            // Retry request with new token
            return await http.get(
              url,
              headers: headers,
            );
          }
        }
      }

      return response;
    } catch (e) {
      print('Exception in authenticated GET request: $e');
      throw e;
    }
  }

  Future<http.Response> authenticatedPostheaders(String endpoint,
      {Map<String, dynamic>? body}) async {
    String? accessToken = await _secureStorage.read(key: 'accessToken');
    String? refreshToken = await _secureStorage.read(key: 'refreshToken');

    if (accessToken == null || refreshToken == null) {
      throw Exception('Access or Refresh token not found');
    }

    Uri url = Uri.parse('$baseurl/$endpoint');

    Future<http.Response> sendRequest(String token) {
      return http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: body != null ? jsonEncode(body) : null,
      );
    }

    try {
      http.Response response = await sendRequest(accessToken);

      if (response.statusCode == 401 || response.statusCode == 403) {
        // Token expired, try to refresh
        String? newAccessToken = await refreshAccessToken(refreshToken);

        if (newAccessToken != null) {
          // Retry with new token
          response = await sendRequest(newAccessToken);
        } else {
          // If refresh failed, throw exception
          throw Exception('Authentication failed. Please login again.');
        }
      }

      return response;
    } catch (e) {
      print('Exception in authenticated request: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>?> sendOtp(String mobileNumber) async {
    final url = Uri.parse('$baseurl/sendOtp');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobileNumber': mobileNumber}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userId = data['userId'];

        // Store userId for verification later
        if (userId != null) {
          await _secureStorage.write(key: 'userId', value: userId);
        }

        print('OTP sent successfully');
        return data;
      } else {
        print("Error while sending OTP: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception while sending OTP: $e");
      return null;
    }
  }

  Future<bool> verifyOtp(String otp, String userId) async {
    final url = Uri.parse('$baseurl/verifyOtp');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'otp': otp, 'userId': userId}),
      );

      if (response.statusCode == 200) {
        print("OTP verified successfully");
        await _secureStorage.write(key: 'otpVerified', value: 'true');
        return true;
      } else {
        print("Error while verifying OTP: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Exception while verifying OTP: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    final token = await _secureStorage.read(key: 'accessToken');

    if (token == null) {
      print("Access token not found");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseurl/userInfo'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Store user data in secure storage for offline access
        if (data['user'] != null) {
          await _secureStorage.write(
              key: 'userData', value: json.encode(data['user']));
        }
        return data['user'];
      } else if (response.statusCode == 401) {
        // Token expired, try to refresh
        final refreshToken = await _secureStorage.read(key: 'refreshToken');
        if (refreshToken != null) {
          final newToken = await refreshAccessToken(refreshToken);
          if (newToken != null) {
            // Retry with new token
            return getUserInfo();
          }
        }
        print('Authentication failed, please login again');
        return null;
      } else {
        print('Error fetching user info: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception fetching user info: $e');
      return null;
    }
  }

  Future<bool> resetMpin(String mobileNumber, String newMpin) async {
    final url = Uri.parse('$baseurl/resetMpin');

    try {
      // Check if OTP has been verified
      final otpVerified = await _secureStorage.read(key: 'otpVerified');
      if (otpVerified != 'true') {
        print('OTP not verified, cannot reset MPIN');
        return false;
      }

      // Get userId from secure storage
      final userId = await _secureStorage.read(key: 'userId');
      if (userId == null) {
        print('User ID not found');
        return false;
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobileNumber': mobileNumber,
          'newMpin': newMpin,
          'userId': userId
        }),
      );

      if (response.statusCode == 200) {
        print('MPIN reset successful');

        // Clear OTP verification status after successful reset
        await _secureStorage.delete(key: 'otpVerified');

        return true;
      } else {
        print('MPIN reset failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception during MPIN reset: $e');
      return false;
    }
  }
}
