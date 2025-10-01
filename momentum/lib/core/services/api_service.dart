
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../errors/exception.dart';

class ApiService {
  final http.Client client;

  ApiService({required this.client});

  // User Authentication
  Future<Map<String, dynamic>> register(String email, String password) async {
    return _post(ApiConstants.reqresBaseUrl, 'register', {'email': email, 'password': password});
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    return _post(ApiConstants.reqresBaseUrl, 'login', {'email': email, 'password': password});
  }

  // Task Management
  Future<List<dynamic>> getTasks() async {
    final response = await _get(ApiConstants.jsonPlaceholderBaseUrl, 'todos');
    return response;
  }

  Future<Map<String, dynamic>> createTask(Map<String, dynamic> taskData) async {
    return _post(ApiConstants.jsonPlaceholderBaseUrl, 'todos', taskData);
  }

  Future<Map<String, dynamic>> updateTask(int taskId, Map<String, dynamic> taskData) async {
    return _put(ApiConstants.jsonPlaceholderBaseUrl, 'todos/$taskId', taskData);
  }

  Future<void> deleteTask(int taskId) async {
    await _delete(ApiConstants.jsonPlaceholderBaseUrl, 'todos/$taskId');
  }

  // User Information
  Future<Map<String, dynamic>> getUsers() async {
    return _get(ApiConstants.reqresBaseUrl, 'users');
  }

  Future<Map<String, dynamic>> getUser(int userId) async {
    return _get(ApiConstants.reqresBaseUrl, 'users/$userId');
  }

  // Private helper methods
  Future<dynamic> _post(String baseUrl, String endpoint, Map<String, dynamic> body) async {
    final response = await client.post(
      Uri.parse('$baseUrl/$endpoint'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw ServerException('Failed to post data: ${response.statusCode}');
    }
  }

  Future<dynamic> _get(String baseUrl, String endpoint) async {
    final response = await client.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ServerException('Failed to get data: ${response.statusCode}');
    }
  }

  Future<dynamic> _put(String baseUrl, String endpoint, Map<String, dynamic> body) async {
    final response = await client.put(
      Uri.parse('$baseUrl/$endpoint'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ServerException('Failed to update data: ${response.statusCode}');
    }
  }

  Future<void> _delete(String baseUrl, String endpoint) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ServerException('Failed to delete data: ${response.statusCode}');
    }
  }
}
