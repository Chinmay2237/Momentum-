// lib/core/errors/failure.dart
class Failure {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  String toString() => code != null ? '[$code] $message' : message;
}

class ServerFailure extends Failure {
  const ServerFailure(String message, [String? code]) : super(message, code);
}

class CacheFailure extends Failure {
  const CacheFailure(String message, [String? code]) : super(message, code);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message, [String? code]) : super(message, code);
}