
import 'package:dartz/dartz.dart';
import 'package:task_management/core/errors/failure.dart';
import 'package:task_management/domain/entities/user_entity.dart';

// Abstract repository defining the contract for user-related operations.
abstract class UserRepository {
  Future<Either<Failure, List<UserEntity>>> getUsers();
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> register( String email, String password);
  Future<Either<Failure, UserEntity?>> getCurrentUser();
}
