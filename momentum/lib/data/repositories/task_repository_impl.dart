// lib/data/repositories/task_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:task_management/core/services/connectivity_service.dart';
import 'package:task_management/data/datasources/local_data_source.dart';
import 'package:task_management/data/datasources/remote_data_source.dart';
import 'package:task_management/data/models/user_model.dart';
import 'package:task_management/domain/entities/task_entity.dart';
import 'package:task_management/domain/repositories/task_repository.dart';
import 'package:task_management/data/models/task_model.dart';

import '../../core/errors/exception.dart';

class TaskRepositoryImpl implements TaskRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final ConnectivityService connectivityService;

  TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
  });

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks() async {
    try {
      final hasConnection = await connectivityService.isConnected;
      
      if (hasConnection) {
        final remoteTasks = await remoteDataSource.getTasks();
        // Save to local storage
        for (final task in remoteTasks) {
          await localDataSource.saveTask(task);
        }
        return Right(remoteTasks.map((e) => e.toEntity()).toList());
      } else {
        final localTasks = await localDataSource.getTasks();
        return Right(localTasks.map((e) => e.toEntity()).toList());
      }
    } on ServerException catch (e) {
      // Fallback to local storage if API fails
      try {
        final localTasks = await localDataSource.getTasks();
        return Right(localTasks.map((e) => e.toEntity()).toList());
      } on CacheException catch (cacheError) {
        return Left(ServerFailure(
          message: '${e.message} and ${cacheError.message}',
          code: e.code,
        ));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Unexpected error while fetching tasks: $e',
        code: 'UNEXPECTED_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> getTask(String taskId) async {
    try {
      final hasConnection = await connectivityService.isConnected;
      
      if (hasConnection) {
        try {
          // Try to get from remote first
          final remoteTasks = await remoteDataSource.getTasks();
          final task = remoteTasks.firstWhere((t) => t.id == taskId);
          await localDataSource.saveTask(task);
          return Right(task.toEntity());
        } catch (e) {
          // Fallback to local if not found remotely
          final localTask = await localDataSource.getTask(taskId);
          if (localTask != null) {
            return Right(localTask.toEntity());
          }
          throw Exception('Task not found');
        }
      } else {
        final localTask = await localDataSource.getTask(taskId);
        if (localTask != null) {
          return Right(localTask.toEntity());
        }
        return Left(CacheFailure(
          message: 'Task not found in local storage',
          code: 'TASK_NOT_FOUND',
        ));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Unexpected error while fetching task: $e',
        code: 'UNEXPECTED_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> createTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      final hasConnection = await connectivityService.isConnected;
      
      if (hasConnection) {
        final createdTask = await remoteDataSource.createTask(taskModel);
        await localDataSource.saveTask(createdTask);
        return Right(createdTask.toEntity());
      } else {
        // Save to local storage with sync flag false
        final localTask = taskModel.copyWith(isSynced: false);
        await localDataSource.saveTask(localTask);
        return Right(localTask.toEntity());
      }
    } on ServerException catch (e) {
      // Save to local storage with sync flag false
      try {
        final taskModel = TaskModel.fromEntity(task).copyWith(isSynced: false);
        await localDataSource.saveTask(taskModel);
        return Right(taskModel.toEntity());
      } on CacheException catch (cacheError) {
        return Left(ServerFailure(
          message: '${e.message} and ${cacheError.message}',
          code: e.code,
        ));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Unexpected error while creating task: $e',
        code: 'UNEXPECTED_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      final hasConnection = await connectivityService.isConnected;
      
      if (hasConnection) {
        final updatedTask = await remoteDataSource.updateTask(taskModel);
        await localDataSource.saveTask(updatedTask);
        return Right(updatedTask.toEntity());
      } else {
        // Update local storage with sync flag false
        final localTask = taskModel.copyWith(isSynced: false);
        await localDataSource.saveTask(localTask);
        return Right(localTask.toEntity());
      }
    } on ServerException catch (e) {
      // Update local storage with sync flag false
      try {
        final taskModel = TaskModel.fromEntity(task).copyWith(isSynced: false);
        await localDataSource.saveTask(taskModel);
        return Right(taskModel.toEntity());
      } on CacheException catch (cacheError) {
        return Left(ServerFailure(
          message: '${e.message} and ${cacheError.message}',
          code: e.code,
        ));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Unexpected error while updating task: $e',
        code: 'UNEXPECTED_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    try {
      final hasConnection = await connectivityService.isConnected;
      
      if (hasConnection) {
        await remoteDataSource.deleteTask(taskId);
        await localDataSource.deleteTask(taskId);
        return const Right(null);
      } else {
        // Mark as deleted locally if API fails
        await localDataSource.deleteTask(taskId);
        return const Right(null);
      }
    } on ServerException catch (e) {
      // Mark as deleted locally if API fails
      try {
        await localDataSource.deleteTask(taskId);
        return const Right(null);
      } on CacheException catch (cacheError) {
        return Left(ServerFailure(
          message: '${e.message} and ${cacheError.message}',
          code: e.code,
        ));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Unexpected error while deleting task: $e',
        code: 'UNEXPECTED_ERROR',
      ));
    }
  }

  Future<Either<Failure, List<UserEntity>>> getUsers() async {
    try {
      final hasConnection = await connectivityService.isConnected;
      
      if (hasConnection) {
        final remoteUsers = await remoteDataSource.getUsers();
        // Save to local storage
        for (final user in remoteUsers) {
          await localDataSource.saveUsers(user as List<UserModel>);
        }
        return Right(remoteUsers.map((e) => e.toEntity()).toList());
      } else {
        final localUsers = await localDataSource.getUsers();
        return Right(localUsers.map((e) => e.toEntity()).toList());
      }
    } on ServerException catch (e) {
      // Fallback to local storage
      try {
        final localUsers = await localDataSource.getUsers();
        return Right(localUsers.map((e) => e.toEntity()).toList());
      } on CacheException catch (cacheError) {
        return Left(ServerFailure(
          message: '${e.message} and ${cacheError.message}',
          code: e.code,
        ));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Unexpected error while fetching users: $e',
        code: 'UNEXPECTED_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> syncTasks() async {
    try {
      final hasConnection = await connectivityService.isConnected;
      if (!hasConnection) {
        return Left(NetworkFailure(
          message: 'No internet connection',
          code: 'NO_CONNECTION',
        ));
      }

      final localTasks = await localDataSource.getTasks();
      final unsyncedTasks = localTasks.where((task) => !task.isSynced).toList();

      for (final task in unsyncedTasks) {
        try {
          if (task.id.startsWith('local_')) {
            // This is a new task that needs to be created
            final createdTask = await remoteDataSource.createTask(task);
            await localDataSource.saveTask(createdTask);
          } else {
            // This is an existing task that needs to be updated
            final updatedTask = await remoteDataSource.updateTask(task);
            await localDataSource.saveTask(updatedTask);
          }
        } catch (e) {
          // Continue with other tasks if one fails
          continue;
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Unexpected error during sync: $e',
        code: 'SYNC_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasksByStatus(String status) async {
    try {
      final tasks = await localDataSource.getTasks();
      final filteredTasks = tasks.where((task) => task.status == status).toList();
      return Right(filteredTasks.map((e) => e.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Unexpected error while filtering tasks: $e',
        code: 'UNEXPECTED_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasksByPriority(String priority) async {
    try {
      final tasks = await localDataSource.getTasks();
      final filteredTasks = tasks.where((task) => task.priority == priority).toList();
      return Right(filteredTasks.map((e) => e.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Unexpected error while filtering tasks: $e',
        code: 'UNEXPECTED_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasksByDueDate(DateTime date) async {
    try {
      final tasks = await localDataSource.getTasks();
      final filteredTasks = tasks.where((task) => 
        task.dueDate.year == date.year &&
        task.dueDate.month == date.month &&
        task.dueDate.day == date.day
      ).toList();
      return Right(filteredTasks.map((e) => e.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Unexpected error while filtering tasks: $e',
        code: 'UNEXPECTED_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> searchTasks(String query) async {
    try {
      final tasks = await localDataSource.getTasks();
      final filteredTasks = tasks.where((task) => 
        task.title.toLowerCase().contains(query.toLowerCase()) ||
        task.description.toLowerCase().contains(query.toLowerCase())
      ).toList();
      return Right(filteredTasks.map((e) => e.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Unexpected error while searching tasks: $e',
        code: 'UNEXPECTED_ERROR',
      ));
    }
  }
}