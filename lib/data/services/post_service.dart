import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:blog_app/data/model/post_model.dart';

class PostService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  Future<List<PostModel>> fetchPosts() async {
    try {
      final url = Uri.parse('$baseUrl/posts');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final List<PostModel> posts = jsonData
            .map((json) => PostModel.fromJson(json))
            .toList();
        return posts;
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching posts: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    try {
      final url = Uri.parse('$baseUrl/users');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }
}
