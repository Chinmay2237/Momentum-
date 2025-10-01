
import 'package:flutter/material.dart';
import 'package:task_management/data/models/task_model.dart';
import 'package:task_management/domain/entities/task_entity.dart';
import 'package:task_management/domain/repositories/task_repository.dart';
import 'package:task_management/domain/repositories/user_repository.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository taskRepository;
  final UserRepository userRepository;

  TaskProvider({
    required this.taskRepository,
    required this.userRepository,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<TaskEntity> _tasks = [];
  List<TaskEntity> get tasks => _tasks;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> getTasks() async {
    setLoading(true);
    final result = await taskRepository.getTasks();
    result.fold(
      (failure) {
        // Handle failure
      },
      (tasks) {
        _tasks = tasks;
      },
    );
    setLoading(false);
  }

  Future<void> createTask(TaskEntity task) async {
    final result = await taskRepository.createTask(task);
    result.fold(
      (failure) {
        // Handle failure
      },
      (task) {
        getTasks();
      },
    );
  }

  Future<void> updateTask(TaskEntity task) async {
    final result = await taskRepository.updateTask(task);
    result.fold(
      (failure) {
        // Handle failure
      },
      (task) {
        getTasks();
      },
    );
  }

  Future<void> deleteTask(String taskId) async {
    final result = await taskRepository.deleteTask(taskId);
    result.fold(
      (failure) {
        // Handle failure
      },
      (_) {
        getTasks();
      },
    );
  }
}
