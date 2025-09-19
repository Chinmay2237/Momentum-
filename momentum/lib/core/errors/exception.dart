
// A generic class to represent a failure in the application,
// such as a network error or a parsing error.
class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;
}

// Represents a failure from the server (API).
class ServerFailure extends Failure {
  final String? code;
  const ServerFailure({required String message, this.code}) : super(message);
}

// Represents a failure from the local cache (e.g., Hive).
class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message);
}

// Custom Exception for API-related errors.
class ServerException implements Exception {
  final String message;
  final String? code;

  ServerException({required this.message, this.code});
}

// Custom Exception for Cache-related errors.
class CacheException implements Exception {
  final String message;

  CacheException({required this.message});
}
