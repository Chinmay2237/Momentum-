
import 'package:dartz/dartz.dart';
import 'package:task_management/core/errors/exception.dart';
import 'package:task_management/domain/entities/task_entity.dart';

// Abstract repository defining the contract for task-related operations.
// This allows for a clean separation between the domain and data layers.
abstract class TaskRepository {
  Future<Either<Failure, List<TaskEntity>>> getTasks();
  Future<Either<Failure, TaskEntity>> createTask(TaskEntity task);
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task);
  Future<Either<Failure, void>> deleteTask(String taskId);
  Future<Either<Failure, void>> syncTasks(); // Added this line
}
