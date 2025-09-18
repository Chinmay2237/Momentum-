// lib/domain/repositories/task_repository.dart
import 'package:dartz/dartz.dart';
import 'package:task_management/domain/entities/task_entity.dart';

import '../../core/errors/exception.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<TaskEntity>>> getTasks();
  Future<Either<Failure, TaskEntity>> getTask(String taskId);
  Future<Either<Failure, TaskEntity>> createTask(TaskEntity task);
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task);
  Future<Either<Failure, void>> deleteTask(String taskId);
  Future<Either<Failure, void>> syncTasks();
  Future<Either<Failure, List<TaskEntity>>> getTasksByStatus(String status);
  Future<Either<Failure, List<TaskEntity>>> getTasksByPriority(String priority);
  Future<Either<Failure, List<TaskEntity>>> getTasksByDueDate(DateTime date);
  Future<Either<Failure, List<TaskEntity>>> searchTasks(String query);
}