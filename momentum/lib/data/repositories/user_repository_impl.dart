import 'package:dartz/dartz.dart';
import 'package:task_management/core/errors/failure.dart';
import 'package:task_management/data/models/user_model.dart';
import 'package:task_management/domain/entities/user_entity.dart';
import 'package:task_management/domain/repositories/user_repository.dart';
import 'package:task_management/core/services/auth_service.dart';

class UserRepositoryImpl implements UserRepository {
  final AuthService authService;

  UserRepositoryImpl(this.authService);

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    try {
      final response = await authService.login(email, password);
      // Assuming the API returns user data along with the token
      final user = UserModel.fromJson(response); 
      return Right(user);
    } catch (e) {
      return Left(ServerFailure('Invalid credentials'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(String email, String password) async {
    try {
      final response = await authService.register(email, password);
      final user = UserModel.fromJson(response);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure('Registration failed'));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getUsers() async {
    // This will be implemented later
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    // This will be implemented later
    throw UnimplementedError();
  }
}
