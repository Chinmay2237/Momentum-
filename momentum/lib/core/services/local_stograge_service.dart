// lib/core/services/local_storage_service.dart
import 'package:hive/hive.dart';
import 'package:task_management/data/models/task_model.dart';
import 'package:task_management/data/models/user_model.dart';

import '../constants/api_constants.dart';
import '../errors/exception.dart';

abstract class LocalStorageService {
  Future<void> init();
  Future<void> saveTask(TaskModel task);
  Future<List<TaskModel>> getTasks();
  Future<TaskModel?> getTask(String taskId);
  Future<void> deleteTask(String taskId);
  Future<void> saveUsers(List<UserModel> users);
  Future<List<UserModel>> getUsers();
  Future<UserModel?> getUser(int userId);
  Future<void> clearAllData();
  Future<void> close();
}

class LocalStorageServiceImpl implements LocalStorageService {
  late Box<TaskModel> _taskBox;
  late Box<UserModel> _userBox;
  late Box<dynamic> _settingsBox;

  @override
  Future<void> init() async {
    _taskBox = await Hive.openBox<TaskModel>(AppConstants.hiveTasksBox);
    _userBox = await Hive.openBox<UserModel>(AppConstants.hiveUsersBox);
    _settingsBox = await Hive.openBox<dynamic>(AppConstants.hiveSettingsBox);
  }

  @override
  Future<void> saveTask(TaskModel task) async {
    try {
      await _taskBox.put(task.id, task);
    } catch (e) {
      throw CacheException('Failed to save task: $e', 'SAVE_TASK_FAILED');
    }
  }

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      return _taskBox.values.toList();
    } catch (e) {
      throw CacheException('Failed to get tasks: $e', 'GET_TASKS_FAILED');
    }
  }

  @override
  Future<TaskModel?> getTask(String taskId) async {
    try {
      return _taskBox.get(taskId);
    } catch (e) {
      throw CacheException('Failed to get task: $e', 'GET_TASK_FAILED');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await _taskBox.delete(taskId);
    } catch (e) {
      throw CacheException('Failed to delete task: $e', 'DELETE_TASK_FAILED');
    }
  }

  @override
  Future<void> saveUsers(List<UserModel> users) async {
    try {
      final Map<int, UserModel> userMap = {
        for (var user in users) user.id: user
      };
      await _userBox.putAll(userMap);
    } catch (e) {
      throw CacheException('Failed to save users: $e', 'SAVE_USERS_FAILED');
    }
  }

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      return _userBox.values.toList();
    } catch (e) {
      throw CacheException('Failed to get users: $e', 'GET_USERS_FAILED');
    }
  }

  @override
  Future<UserModel?> getUser(int userId) async {
    try {
      return _userBox.get(userId);
    } catch (e) {
      throw CacheException('Failed to get user: $e', 'GET_USER_FAILED');
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      await _taskBox.clear();
      await _userBox.clear();
      await _settingsBox.clear();
    } catch (e) {
      throw CacheException('Failed to clear data: $e', 'CLEAR_DATA_FAILED');
    }
  }

  @override
  Future<void> close() async {
    try {
      await _taskBox.close();
      await _userBox.close();
      await _settingsBox.close();
    } catch (e) {
      throw CacheException('Failed to close boxes: $e', 'CLOSE_BOXES_FAILED');
    }
  }

  // Additional utility methods
  Future<List<TaskModel>> getUnsyncedTasks() async {
    try {
      return _taskBox.values.where((task) => !task.isSynced).toList();
    } catch (e) {
      throw CacheException('Failed to get unsynced tasks: $e', 'GET_UNSYNCED_TASKS_FAILED');
    }
  }

  Future<List<String>> getDeletedTaskIds() async {
    try {
      final deletedIds = _settingsBox.get('deleted_task_ids', defaultValue: <String>[]);
      return List<String>.from(deletedIds);
    } catch (e) {
      throw CacheException('Failed to get deleted task IDs: $e', 'GET_DELETED_IDS_FAILED');
    }
  }

  Future<void> markTaskAsDeleted(String taskId) async {
    try {
      final deletedIds = await getDeletedTaskIds();
      deletedIds.add(taskId);
      await _settingsBox.put('deleted_task_ids', deletedIds);
    } catch (e) {
      throw CacheException('Failed to mark task as deleted: $e', 'MARK_TASK_DELETED_FAILED');
    }
  }

  Future<void> removeDeletedMark(String taskId) async {
    try {
      final deletedIds = await getDeletedTaskIds();
      deletedIds.remove(taskId);
      await _settingsBox.put('deleted_task_ids', deletedIds);
    } catch (e) {
      throw CacheException('Failed to remove deleted mark: $e', 'REMOVE_DELETED_MARK_FAILED');
    }
  }
}