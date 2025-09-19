import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_management/core/constants/api_constants.dart';
import 'package:task_management/data/models/task_model.dart';

import '../../core/errors/exception.dart';
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
    try {
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}'),
        body: json.encode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['token'];
      } else {
        throw ServerException(
          message: 'Registration failed: ${response.statusCode}',
          code: 'REGISTRATION_FAILED',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error during registration',
        code: 'UNEXPECTED_ERROR',
      );
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
          message: 'Login failed: ${response.statusCode}',
          code: 'LOGIN_FAILED',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error during login',
        code: 'UNEXPECTED_ERROR',
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
          message: 'Failed to fetch tasks: ${response.statusCode}',
          code: 'FETCH_TASKS_FAILED',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error while fetching tasks',
        code: 'UNEXPECTED_ERROR',
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
          message: 'Failed to create task: ${response.statusCode}',
          code: 'CREATE_TASK_FAILED',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error while creating task',
        code: 'UNEXPECTED_ERROR',
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
          message: 'Failed to update task: ${response.statusCode}',
          code: 'UPDATE_TASK_FAILED',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error while updating task',
        code: 'UNEXPECTED_ERROR',
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
          message: 'Failed to delete task: ${response.statusCode}',
          code: 'DELETE_TASK_FAILED',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error while deleting task',
        code: 'UNEXPECTED_ERROR',
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
          message: 'Failed to fetch users: ${response.statusCode}',
          code: 'FETCH_USERS_FAILED',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error while fetching users',
        code: 'UNEXPECTED_ERROR',
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
          message: 'Failed to fetch user: ${response.statusCode}',
          code: 'FETCH_USER_FAILED',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error while fetching user',
        code: 'UNEXPECTED_ERROR',
      );
    }
  }
}
