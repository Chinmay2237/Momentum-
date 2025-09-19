
import 'package:dartz/dartz.dart';
import 'package:task_management/core/errors/exception.dart';
import 'package:task_management/domain/entities/user_entity.dart';
import 'package:task_management/domain/repositories/user_repository.dart';

// A concrete implementation of the UserRepository using an in-memory list.
class UserRepositoryImpl implements UserRepository {
  final List<UserEntity> _users = const [
    UserEntity(id: 101, fullName: 'Alice Johnson', email: 'alice@example.com'),
    UserEntity(id: 102, fullName: 'Bob Williams', email: 'bob@example.com'),
    UserEntity(id: 103, fullName: 'Charlie Brown', email: 'charlie@example.com'),
  ];

  @override
  Future<Either<Failure, List<UserEntity>>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 200)); // Simulate network latency
    return Right(_users);
  }
}
