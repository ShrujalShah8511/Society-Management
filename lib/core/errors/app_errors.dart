abstract class AppFailure implements Exception {
  final String message;
  final String? code;

  const AppFailure(this.message, {this.code});

  @override
  String toString() => message;
}

class ServerFailure extends AppFailure {
  const ServerFailure(super.message, {super.code});
}

class AuthFailure extends AppFailure {
  const AuthFailure(super.message, {super.code});
}

class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message, {super.code});
}

class StorageFailure extends AppFailure {
  const StorageFailure(super.message, {super.code});
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure(super.message, {super.code});
}

class PermissionDeniedFailure extends AppFailure {
  const PermissionDeniedFailure([
    super.message = 'You do not have permission to perform this action.',
    String? code,
  ]) : super(code: code ?? 'PERMISSION_DENIED');
}
