import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/health_models.dart';

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<ActivityLog>> fetchActivityLogs(int page, int limit) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/posts?_page=$page&_limit=$limit'),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => ActivityLog.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load activity logs');
    }
  }
}
