import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_management/core/constants/api_constants.dart';
import 'package:task_management/data/models/task_model.dart';

import '../../core/errors/exception.dart';
import '../../core/errors/failure.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

// lib/data/datasources/remote_data_source.dart
abstract class RemoteDataSource {
  Future<String> register(String email, String password);
  Future<String> login(String email, String password);
  Future<List<TaskModel>> getTasks();
  Future<TaskModel> createTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String taskId);
  Future<List<UserModel>> getUsers();
  Future<UserModel> getUser(int userId);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final http.Client client;
  final String? authToken;

  RemoteDataSourceImpl({required this.client, this.authToken});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

@override
Future<String> register(String email, String password) async {
  final response = await client.post(
    Uri.parse('${ApiConstants.baseUrl}/register'),
    body: json.encode({'email': email, 'password': password}),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final data = json.decode(response.body);
    // Return the token as expected by the interface
    return data['token'] ?? data['access_token'] ?? 'dummy_token';
  } else {
    throw ServerException('Registration failed: ${response.statusCode}');
  }
}

  @override
  Future<String> login(String email, String password) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
        body: json.encode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['token'];
      } else {
        throw ServerException(
          'Login failed: ${response.statusCode}',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        'Unexpected error during login',
      );
    }
  }


  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      final response = await client.get(
        Uri.parse(
            '${ApiConstants.jsonPlaceholderBaseUrl}${ApiConstants.todos}'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((task) => TaskModel.fromJson(task)).toList();
      } else {
        throw ServerException(
          'Failed to fetch tasks: ${response.statusCode}',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        'Unexpected error while fetching tasks',
      );
    }
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final response = await client.post(
        Uri.parse(
            '${ApiConstants.jsonPlaceholderBaseUrl}${ApiConstants.todos}'),
        body: json.encode(task.toJson()),
        headers: _headers,
      );

      if (response.statusCode == 201) {
        return TaskModel.fromJson(json.decode(response.body));
      } else {
        throw ServerException(
          'Failed to create task: ${response.statusCode}',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        'Unexpected error while creating task',
      );
    }
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final response = await client.put(
        Uri.parse(
            '${ApiConstants.jsonPlaceholderBaseUrl}${ApiConstants.todos}/${task.id}'),
        body: json.encode(task.toJson()),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return TaskModel.fromJson(json.decode(response.body));
      } else {
        throw ServerException(
          'Failed to update task: ${response.statusCode}',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        'Unexpected error while updating task',
      );
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      final response = await client.delete(
        Uri.parse(
            '${ApiConstants.jsonPlaceholderBaseUrl}${ApiConstants.todos}/$taskId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw ServerException(
          'Failed to delete task: ${response.statusCode}',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        'Unexpected error while deleting task',
      );
    }
  }

  @override
  Future<List<UserModel>> getUsers() async {
    // Remove the parameter
    try {
      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.users}'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> users = data['data'];
        return users.map((user) => UserModel.fromJson(user)).toList();
      } else {
        throw ServerException(
          'Failed to fetch users: ${response.statusCode}',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        'Unexpected error while fetching users',
      );
    }
  }

  @override
  Future<UserModel> getUser(int userId) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.users}/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return UserModel.fromJson(data['data']);
      } else {
        throw ServerException(
          'Failed to fetch user: ${response.statusCode}',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        'Unexpected error while fetching user',
      );
    }
  }
}
