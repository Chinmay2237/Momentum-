// lib/data/datasources/local_data_source.dart
import 'package:hive/hive.dart';
import 'package:task_management/data/models/task_model.dart';
import 'package:task_management/data/models/user_model.dart';

import '../../core/errors/exception.dart';

abstract class LocalDataSource {
  Future<void> saveTask(TaskModel task);
  Future<List<TaskModel>> getTasks();
  Future<TaskModel?> getTask(String taskId);
  Future<void> deleteTask(String taskId);
  Future<void> saveUsers(List<UserModel> users);
  Future<List<UserModel>> getUsers();
  Future<UserModel?> getUser(String userId);
  Future<void> clearAllData();
}

class LocalDataSourceImpl implements LocalDataSource {
  final Box<TaskModel> taskBox;
  final Box<UserModel> userBox;

  LocalDataSourceImpl({required this.taskBox, required this.userBox});

  @override
  Future<void> saveTask(TaskModel task) async {
    try {
      await taskBox.put(task.id, task);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save task',
        code: 'SAVE_TASK_FAILED',
      );
    }
  }

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      return taskBox.values.toList();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get tasks',
        code: 'GET_TASKS_FAILED',
      );
    }
  }

  @override
  Future<TaskModel?> getTask(String taskId) async {
    try {
      return taskBox.get(taskId);
    } catch (e) {
      throw CacheException(
        message: 'Failed to get task',
        code: 'GET_TASK_FAILED',
      );
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await taskBox.delete(taskId);
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete task',
        code: 'DELETE_TASK_FAILED',
      );
    }
  }

  @override
  Future<void> saveUsers(List<UserModel> users) async {
    try {
      final Map<int, UserModel> userMap = {
        for (var user in users) user.id: user
      };
      await userBox.putAll(userMap);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save users',
        code: 'SAVE_USERS_FAILED',
      );
    }
  }

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      return userBox.values.toList();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get users',
        code: 'GET_USERS_FAILED',
      );
    }
  }

  @override
  Future<UserModel?> getUser(String userId) async {
    try {
      return userBox.get(userId);
    } catch (e) {
      throw CacheException(
        message: 'Failed to get user',
        code: 'GET_USER_FAILED',
      );
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      await taskBox.clear();
      await userBox.clear();
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear data',
        code: 'CLEAR_DATA_FAILED',
      );
    }
  }
}