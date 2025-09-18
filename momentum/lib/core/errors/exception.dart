// lib/core/errors/exceptions.dart
import 'package:equatable/equatable.dart';

class AppException implements Exception {
  final String message;
  final String code;

  AppException({required this.message, required this.code});

  @override
  String toString() => 'AppException: $message (Code: $code)';
}

class NetworkException extends AppException {
  NetworkException({super.message = 'Network error occurred', super.code = 'NETWORK_ERROR'});
}

class ServerException extends AppException {
  ServerException({super.message = 'Server error occurred', super.code = 'SERVER_ERROR'});
}

class CacheException extends AppException {
  CacheException({super.message = 'Cache error occurred', super.code = 'CACHE_ERROR'});
}

class ValidationException extends AppException {
  ValidationException({super.message = 'Validation error occurred', super.code = 'VALIDATION_ERROR'});
}

// lib/core/errors/failures.dart

abstract class Failure extends Equatable {
  final String message;
  final String code;

  const Failure({required this.message, required this.code});

  @override
  List<Object> get props => [message, code];

  @override
  String toString() => 'Failure: $message (Code: $code)';
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Network error occurred', super.code = 'NETWORK_ERROR'});
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server error occurred', super.code = 'SERVER_ERROR'});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error occurred', super.code = 'CACHE_ERROR'});
}

class ValidationFailure extends Failure {
  const ValidationFailure({super.message = 'Validation error occurred', super.code = 'VALIDATION_ERROR'});
}