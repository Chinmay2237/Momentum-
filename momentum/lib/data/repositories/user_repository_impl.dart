
import 'package:dartz/dartz.dart';
import 'package:task_management/core/errors/failure.dart';
import 'package:task_management/domain/entities/user_entity.dart';
import 'package:task_management/domain/repositories/user_repository.dart';

// A concrete implementation of the UserRepository using an in-memory list.
class UserRepositoryImpl implements UserRepository {
  final List<UserEntity> _users = const [
    UserEntity(id: 101, fullName: 'Alice Johnson', email: 'alice@example.com'),
    UserEntity(id: 102, fullName: 'Bob Williams', email: 'bob@example.com'),
    UserEntity(id: 103, fullName: 'Charlie Brown', email: 'charlie@example.com'),
  ];
  UserEntity? _currentUser;

  @override
  Future<Either<Failure, List<UserEntity>>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 200)); // Simulate network latency
    return Right(_users);
  }

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final user = _users.firstWhere((user) => user.email == email, orElse: () => const UserEntity(id: -1, fullName: '', email: ''));
    if (user.id != -1) {
      _currentUser = user;
      return Right(user);
    } else {
      return Left(ServerFailure( 'Invalid credentials'));
    }
  }

@override
Future<Either<Failure, UserEntity>> register(String email, String password) async {
  await Future.delayed(const Duration(milliseconds: 300));
  // Generate a fullName from email or use a default value
  final fullName = email.split('@').first; // Or use "New User" as default
  final newUser = UserEntity(id: _users.length + 101, fullName: fullName, email: email);
  // In a real app, you would add the user to the list.
  _currentUser = newUser;
  return Right(newUser);
}

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return Right(_currentUser);
  }
}
