// lib/data/repositories/user_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management/core/services/connectivity_service.dart';
import 'package:task_management/data/datasources/local_data_source.dart';
import 'package:task_management/data/datasources/remote_data_source.dart';
import 'package:task_management/domain/repositories/user_repository.dart';

import '../../core/errors/exception.dart';
import '../../domain/entities/task_entity.dart';

class UserRepositoryImpl implements UserRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final ConnectivityService connectivityService;
  final SharedPreferences sharedPreferences;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
    required this.sharedPreferences,
  });

  @override
  Future<Either<Failure, String>> register(String email, String password) async {
    try {
      final hasConnection = await connectivityService.isConnected;
      
      if (!hasConnection) {
        return Left(NetworkFailure(
          message: 'No internet connection',
          code: 'NO_CONNECTION',
        ));
      }

      final token = await remoteDataSource.register(email, password);
      
      // Save token to shared preferences
      await sharedPreferences.setString('auth_token', token);
      await sharedPreferences.setString('user_email', email);
      
      return Right(token);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Unexpected error during registration: $e',
        code: 'UNEXPECTED_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, String>> login(String email, String password) async {
    try {
      final hasConnection = await connectivityService.isConnected;
      
      if (!hasConnection) {
        return Left(NetworkFailure(
          message: 'No internet connection',
          code: 'NO_CONNECTION',
        ));
      }

      final token = await remoteDataSource.login(email, password);
      
      // Save token to shared preferences
      await sharedPreferences.setString('auth_token', token);
      await sharedPreferences.setString('user_email', email);
      
      return Right(token);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Unexpected error during login: $e',
        code: 'UNEXPECTED_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await sharedPreferences.remove('auth_token');
      await sharedPreferences.remove('user_email');
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to logout: $e',
        code: 'LOGOUT_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getUsers() async {
    try {
      final hasConnection = await connectivityService.isConnected;
      
      if (hasConnection) {
        final remoteUsers = await remoteDataSource.getUsers();
        // Save to local storage
        await localDataSource.saveUsers(remoteUsers);
        return Right(remoteUsers.map((e) => e.toEntity()).toList());
      } else {
        final localUsers = await localDataSource.getUsers();
        return Right(localUsers.map((e) => e.toEntity()).toList());
      }
    } on ServerException catch (e) {
      // Fallback to local storage if API fails
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
Future<Either<Failure, UserEntity>> getUser(String userId) async {
  try {
    final hasConnection = await connectivityService.isConnected;
    
    if (hasConnection) {
      try {
        // Convert String userId to int for the API call
        final int userIdInt = int.parse(userId);
        // Try to get from remote first
        final remoteUser = await remoteDataSource.getUser(userIdInt);
        // Save to local storage
        await localDataSource.saveUsers([remoteUser]);
        return Right(remoteUser.toEntity());
      } catch (e) {
        // Fallback to local if not found remotely
        final localUser = await localDataSource.getUser(userId);
        if (localUser != null) {
          return Right(localUser.toEntity());
        }
        throw Exception('User not found');
      }
    } else {
      final localUser = await localDataSource.getUser(userId);
      if (localUser != null) {
        return Right(localUser.toEntity());
      }
      return Left(CacheFailure(
        message: 'User not found in local storage',
        code: 'USER_NOT_FOUND',
      ));
    }
  } on CacheException catch (e) {
    return Left(CacheFailure(
      message: e.message,
      code: e.code,
    ));
  } catch (e) {
    return Left(ServerFailure(
      message: 'Unexpected error while fetching user: $e',
      code: 'UNEXPECTED_ERROR',
    ));
  }
}
  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final token = sharedPreferences.getString('auth_token');
      return Right(token != null);
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to check login status: $e',
        code: 'CHECK_LOGIN_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, String?>> getAuthToken() async {
    try {
      final token = sharedPreferences.getString('auth_token');
      return Right(token);
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to get auth token: $e',
        code: 'GET_TOKEN_FAILED',
      ));
    }
  }
}