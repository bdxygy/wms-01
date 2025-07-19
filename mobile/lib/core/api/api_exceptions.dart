class ApiException implements Exception {
  final String message;
  final String code;
  final dynamic details;

  ApiException({
    required this.message,
    required this.code,
    this.details,
  });

  @override
  String toString() => 'ApiException: $message (Code: $code)';
}

class NetworkException extends ApiException {
  NetworkException({
    required super.message,
    required super.code,
    super.details,
  });

  @override
  String toString() => 'NetworkException: $message (Code: $code)';
}

class ServerException extends ApiException {
  ServerException({
    required super.message,
    required super.code,
    super.details,
  });

  @override
  String toString() => 'ServerException: $message (Code: $code)';
}

class AuthException extends ApiException {
  AuthException({
    required super.message,
    required super.code,
    super.details,
  });

  @override
  String toString() => 'AuthException: $message (Code: $code)';
}

class ValidationException extends ApiException {
  ValidationException({
    required super.message,
    required super.code,
    super.details,
  });

  @override
  String toString() => 'ValidationException: $message (Code: $code)';
}

class SecurityException extends ApiException {
  SecurityException({
    required super.message,
    required super.code,
    super.details,
  });

  @override
  String toString() => 'SecurityException: $message (Code: $code)';
}