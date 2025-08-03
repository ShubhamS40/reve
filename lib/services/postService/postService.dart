import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:reva/models/PostModel/postModel.dart';

class PostService {
  final FlutterSecureStorage _flutterSecureStorage = FlutterSecureStorage();
  final String baseUrl =
      'http://192.168.0.101:3000/index/posts'; // For Android emulator pointing to localhost

  Future<String?> _getAuthToken() async {
    // Replace this with your secure storage logic
    return 'your_access_token';
  }

  /// Create a new post
  Future<PostModel?> createPost({
    String? content,
    List<String>? media,
    String visibility = "public",
  }) async {
    final token = await _getAuthToken();
    final url = Uri.parse('$baseUrl/createPost');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'content': content,
        'media': media ?? [],
        'visibility': visibility,
      }),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return PostModel.fromJson(json['data']);
    } else {
      print('Create Post failed: ${response.body}');
      return null;
    }
  }

  /// Fetch all posts
  Future<List<PostModel>> getAllPosts() async {
    final token = await _getAuthToken();
    final url = Uri.parse('$baseUrl');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'];
      return data.map((item) => PostModel.fromJson(item)).toList();
    } else {
      print('Fetch Posts failed: ${response.body}');
      return [];
    }
  }

  /// Get post by ID
  Future<PostModel?> getPostById(String postId) async {
    final token = await _getAuthToken();
    final url = Uri.parse('$baseUrl/$postId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return PostModel.fromJson(json['data']);
    } else {
      print('Get Post failed: ${response.body}');
      return null;
    }
  }

  /// Update a post
  Future<PostModel?> updatePost({
    required String postId,
    String? content,
    List<String>? media,
    String? visibility,
  }) async {
    final token = await _getAuthToken();
    final url = Uri.parse('$baseUrl/$postId');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'content': content,
        'media': media,
        'visibility': visibility,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return PostModel.fromJson(json['data']);
    } else {
      print('Update Post failed: ${response.body}');
      return null;
    }
  }

  /// Delete a post
  Future<bool> deletePost(String postId) async {
    final token = await _getAuthToken();
    final url = Uri.parse('$baseUrl/$postId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Delete Post failed: ${response.body}');
      return false;
    }
  }

  /// Toggle like on a post
  Future<bool> toggleLike(String postId) async {
    final token = await _getAuthToken();
    final url = Uri.parse('$baseUrl/$postId/like');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Toggle Like failed: ${response.body}');
      return false;
    }
  }
}
