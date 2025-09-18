// core/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../errors/exception.dart';

class ApiService {
  final http.Client client;

  ApiService({required this.client});

  Future<Map<String, dynamic>> post(String endpoint, 
      {required Map<String, dynamic> body}) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/$endpoint'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw ServerException(message: 'Failed to post data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/$endpoint'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ServerException(message: 'Failed to get data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, 
      {required Map<String, dynamic> body}) async {
    final response = await client.put(
      Uri.parse('${ApiConstants.baseUrl}/$endpoint'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ServerException(message: 'Failed to update data: ${response.statusCode}');
    }
  }

  Future<void> delete(String endpoint) async {
    final response = await client.delete(
      Uri.parse('${ApiConstants.baseUrl}/$endpoint'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ServerException(message: 'Failed to delete data: ${response.statusCode}');
    }
  }
}