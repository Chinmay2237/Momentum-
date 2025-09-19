
import 'package:dartz/dartz.dart';
import 'package:task_management/core/errors/failure.dart';
import 'package:task_management/domain/entities/task_entity.dart';
import 'package:task_management/domain/repositories/task_repository.dart';

// A concrete implementation of the TaskRepository that uses a simple in-memory list.
// This serves as a placeholder for a real data source (e.g., API, database).
class TaskRepositoryImpl implements TaskRepository {
  final List<TaskEntity> _tasks = [
    TaskEntity(
      id: '1',
      title: 'Design the new logo',
      description: 'Create a modern and fresh logo for the Momentum brand.',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      priority: 'High',
      status: 'To-Do',
      assignedUserId: 101,
      createdAt: DateTime.now(),
      isSynced: true,
    ),
    TaskEntity(
      id: '2',
      title: 'Develop the landing page',
      description: 'Build the main landing page using Flutter Web.',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      priority: 'Medium',
      status: 'In Progress',
      assignedUserId: 102,
      createdAt: DateTime.now(),
      isSynced: true,
    ),
  ];

  @override
  Future<Either<Failure, TaskEntity>> createTask(TaskEntity task) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network latency
    final newTask = task.copyWith(isSynced: false); // Mark as not synced initially
    _tasks.add(newTask);
    return Right(newTask);
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _tasks.removeWhere((task) => task.id == taskId);
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Right(List.from(_tasks));
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      final updatedTask = task.copyWith(isSynced: false, updatedAt: DateTime.now());
      _tasks[index] = updatedTask;
      return Right(updatedTask);
    } else {
      return const Left(Failure('Task not found'));
    }
  }

  @override
  Future<Either<Failure, void>> syncTasks() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate syncing by marking all tasks as synced
    for (var i = 0; i < _tasks.length; i++) {
      if (!_tasks[i].isSynced) {
        _tasks[i] = _tasks[i].copyWith(isSynced: true);
      }
    }
    return const Right(null);
  }
}
