// lib/domain/repositories/user_repository.dart
import 'package:dartz/dartz.dart';

import '../../core/errors/exception.dart';
import '../entities/task_entity.dart';

abstract class UserRepository {
  Future<Either<Failure, List<UserEntity>>> getUsers();
  Future<Either<Failure, UserEntity>> getUser(String userId); // Change to String
  Future<Either<Failure, void>> register(String email, String password);
  Future<Either<Failure, String>> login(String email, String password);
  Future<void> logout();
  Future<Either<Failure, bool>> isLoggedIn();
  Future<Either<Failure, String?>> getAuthToken();
}