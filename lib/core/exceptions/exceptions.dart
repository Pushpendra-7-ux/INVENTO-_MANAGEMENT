class DatabaseException implements Exception {
  final String message;
  final dynamic originalError;

  const DatabaseException(this.message, [this.originalError]);

  @override
  String toString() => 'DatabaseException: $message';
}

class ValidationException implements Exception {
  final String message;
  final String? field;

  const ValidationException(this.message, [this.field]);

  @override
  String toString() => 'ValidationException: $message${field != null ? ' (field: $field)' : ''}';
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException(this.message);

  @override
  String toString() => 'NotFoundException: $message';
}

class DuplicateException implements Exception {
  final String message;
  final String? field;

  const DuplicateException(this.message, [this.field]);

  @override
  String toString() => 'DuplicateException: $message';
}
