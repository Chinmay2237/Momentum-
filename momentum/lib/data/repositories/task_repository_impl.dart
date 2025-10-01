import 'package:dartz/dartz.dart';
import '../../core/errors/failure.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local_data_source.dart';
import '../datasources/remote_data_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;

  TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks() async {
    try {
      final remoteTasks = await remoteDataSource.getTasks();
      await localDataSource.cacheTasks(remoteTasks);
      return Right(remoteTasks);
    } catch (e) {
      try {
        final localTasks = await localDataSource.getTasks();
        return Right(localTasks);
      } catch (e) {
        return Left(ServerFailure('Failed to fetch tasks'));
      }
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> createTask(TaskEntity task) async {
    try {
      final remoteTask = await remoteDataSource.createTask(task);
      await localDataSource.cacheTask(remoteTask);
      return Right(remoteTask);
    } catch (e) {
      return Left(ServerFailure('Failed to create task'));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task) async {
    try {
      final remoteTask = await remoteDataSource.updateTask(task);
      await localDataSource.cacheTask(remoteTask);
      return Right(remoteTask);
    } catch (e) {
      return Left(ServerFailure('Failed to update task'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    try {
      await remoteDataSource.deleteTask(id);
      await localDataSource.deleteTask(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete task'));
    }
  }
}
