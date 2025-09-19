
import 'package:dartz/dartz.dart';
import 'package:task_management/core/errors/exception.dart';
import 'package:task_management/domain/entities/user_entity.dart';

// Abstract repository defining the contract for user-related operations.
abstract class UserRepository {
  Future<Either<Failure, List<UserEntity>>> getUsers();
}
