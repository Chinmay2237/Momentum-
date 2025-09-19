
import 'package:dartz/dartz.dart';
import 'package:task_management/core/errors/exception.dart';
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
    ),
  ];

  @override
  Future<Either<Failure, TaskEntity>> createTask(TaskEntity task) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network latency
    _tasks.add(task);
    return Right(task);
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
      _tasks[index] = task;
      return Right(task);
    } else {
      return const Left(Failure('Task not found'));
    }
  }
}
