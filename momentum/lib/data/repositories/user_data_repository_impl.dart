// lib/data/repositories/user_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management/core/services/connectivity_service.dart';
import 'package:task_management/data/datasources/local_data_source.dart';
import 'package:task_management/data/datasources/remote_data_source.dart';
import 'package:task_management/domain/repositories/user_repository.dart';

import '../../core/errors/exception.dart';
import '../../core/errors/failure.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/user_entity.dart';

abstract class UserRepositoryImpl implements UserRepository {
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
Future<Either<Failure, UserEntity>> register(String email, String password) async {
  try {
    final hasConnection = await connectivityService.isConnected;
    
    if (!hasConnection) {
      return Left(NetworkFailure('No internet connection'));
    }

    final token = await remoteDataSource.register(email, password);
    
    // Save token to shared preferences
    await sharedPreferences.setString('auth_token', token);
    await sharedPreferences.setString('user_email', email);
    
    // Create and return a UserEntity instead of just the token
    // You'll need to get the actual user data from somewhere
    // This is a temporary solution - you should modify your API to return user data
    final userEntity = UserEntity(
      id: 0, // You need to get the actual user ID from registration
      fullName: 'New User', // You need to get the actual name
      email: email,
    );
    
    return Right(userEntity);
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  } catch (e) {
    return Left(ServerFailure('Unexpected error during registration: $e'));
  }
}
@override
Future<Either<Failure, UserEntity>> login(String email, String password) async {
  try {
    final hasConnection = await connectivityService.isConnected;
    
    if (!hasConnection) {
      return Left(NetworkFailure('No internet connection'));
    }

    final userEntity = await remoteDataSource.login(email, password);
     final token = await remoteDataSource.register(email, password);
    
    // Save token to shared preferences if needed
   await sharedPreferences.setString('auth_token', token);
    await sharedPreferences.setString('user_email', email);
    
    return Right(userEntity as UserEntity);
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  } catch (e) {
    return Left(ServerFailure('Unexpected error during login: $e'));
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
       'Failed to logout: $e',
       
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
        '${e.message} and ${cacheError.message}',
        
        ));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(
       e.message,
       
      ));
    } catch (e) {
      return Left(ServerFailure(
      'Unexpected error while fetching users: $e',
       
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
        'User not found in local storage',
      
      ));
    }
  } on CacheException catch (e) {
    return Left(CacheFailure(
     e.message,
     
    ));
  } catch (e) {
    return Left(ServerFailure(
      'Unexpected error while fetching user: $e',
    
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
     'Failed to check login status: $e',
      
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
       'Failed to get auth token: $e',
       
      ));
    }
  }
}