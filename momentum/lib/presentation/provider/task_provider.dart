// lib/presentation/providers/task_provider.dart
import 'package:flutter/foundation.dart';
import 'package:task_management/domain/entities/task_entity.dart';

import '../../core/errors/failure.dart';
import '../../domain/repositories/task_repository.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository taskRepository;

  TaskProvider({required this.taskRepository});

  List<TaskEntity> _tasks = [];
  bool _isLoading = false;
  Failure? _error;
  String? _successMessage;

  List<TaskEntity> get tasks => _tasks;
  bool get isLoading => _isLoading;
  Failure? get error => _error;
  String? get successMessage => _successMessage;

  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await taskRepository.getTasks();

    result.fold(
      (failure) {
        _error = failure;
        _isLoading = false;
        notifyListeners();
      },
      (tasks) {
        _tasks = tasks;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
    );
  }

  Future<void> createTask(TaskEntity task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await taskRepository.createTask(task);

    result.fold(
      (failure) {
        _error = failure;
        _isLoading = false;
        notifyListeners();
      },
      (createdTask) {
        _tasks.add(createdTask);
        _isLoading = false;
        _error = null;
        _successMessage = 'Task created successfully';
        notifyListeners();
        
        // Clear success message after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          _successMessage = null;
          notifyListeners();
        });
      },
    );
  }

  Future<void> updateTask(TaskEntity task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await taskRepository.updateTask(task);

    result.fold(
      (failure) {
        _error = failure;
        _isLoading = false;
        notifyListeners();
      },
      (updatedTask) {
        final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
        if (index != -1) {
          _tasks[index] = updatedTask;
        }
        _isLoading = false;
        _error = null;
        _successMessage = 'Task updated successfully';
        notifyListeners();
        
        Future.delayed(const Duration(seconds: 3), () {
          _successMessage = null;
          notifyListeners();
        });
      },
    );
  }

  Future<void> deleteTask(String taskId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await taskRepository.deleteTask(taskId);

    result.fold(
      (failure) {
        _error = failure;
        _isLoading = false;
        notifyListeners();
      },
      (_) {
        _tasks.removeWhere((task) => task.id == taskId);
        _isLoading = false;
        _error = null;
        _successMessage = 'Task deleted successfully';
        notifyListeners();
        
        Future.delayed(const Duration(seconds: 3), () {
          _successMessage = null;
          notifyListeners();
        });
      },
    );
  }

  Future<void> syncTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await taskRepository.syncTasks();

    result.fold(
      (failure) {
        _error = failure;
        _isLoading = false;
        notifyListeners();
      },
      (_) {
        _isLoading = false;
        _error = null;
        _successMessage = 'Tasks synced successfully';
        notifyListeners();
        
        // Reload tasks after sync
        loadTasks();
        
        Future.delayed(const Duration(seconds: 3), () {
          _successMessage = null;
          notifyListeners();
        });
      },
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}