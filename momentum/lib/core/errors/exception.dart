// lib/core/errors/exception.dart
class ServerException implements Exception {
  final String message;
  final String? code;

  ServerException(this.message, [this.code]);
  
  @override
  String toString() => code != null ? '[$code] $message' : message;
}

class CacheException implements Exception {
  final String message;
  final String? code;

  CacheException(this.message, [this.code]);
  
  @override
  String toString() => code != null ? '[$code] $message' : message;
}