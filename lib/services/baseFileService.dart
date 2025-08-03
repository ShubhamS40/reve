import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class BaseApiService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final String baseUrl =
      'http://192.168.0.101:3000/index/qr'; // For Android emulator pointing to localhost

  Future<String?> _refreshAccessToken(String refreshToken) async {
    final url = Uri.parse('$baseUrl/refresh');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['accessToken'];
    } else {
      return null;
    }
  }

  Future<http.Response> authenticatedPost(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    String? accessToken = await _storage.read(key: 'acessToken');
    String? refreshToken = await _storage.read(key: 'refreshToken');

    if (accessToken == null) {
      throw Exception('Missing tokens');
    }

    Uri url = Uri.parse('$baseUrl/$endpoint');

    Future<http.Response> send(String token) {
      return http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
    }

    http.Response response = await send(accessToken);

    if (response.statusCode == 401 || response.statusCode == 403) {
      // Access token expired, try refreshing
      String? newAccessToken = await _refreshAccessToken(refreshToken!);
      if (newAccessToken != null) {
        await _storage.write(key: 'accessToken', value: newAccessToken);
        response = await send(newAccessToken);
      }
    }

    return response;
  }

  Future<http.Response> authenticatedGet(String endpoint) async {
    String? accessToken = await _storage.read(key: 'accessToken');
    String? refreshToken = await _storage.read(key: 'refreshToken');

    if (accessToken == null || refreshToken == null) {
      throw Exception('Missing tokens');
    }

    Uri url = Uri.parse('$baseUrl/$endpoint');

    Future<http.Response> send(String token) {
      return http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
    }

    http.Response response = await send(accessToken);

    if (response.statusCode == 401 || response.statusCode == 403) {
      String? newAccessToken = await _refreshAccessToken(refreshToken);
      if (newAccessToken != null) {
        await _storage.write(key: 'accessToken', value: newAccessToken);
        response = await send(newAccessToken);
      }
    }

    return response;
  }
}
