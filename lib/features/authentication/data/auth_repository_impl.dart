import 'dart:convert';
import '../../../core/storage/session_storage.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';
import '../domain/user.dart';
import 'auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;
  final SessionStorage _sessionStorage;

  AuthRepositoryImpl({
    required AuthDataSource dataSource,
    required SessionStorage sessionStorage,
  })  : _dataSource = dataSource,
        _sessionStorage = sessionStorage;

  @override
  Future<AuthSession> login({
    required String emailOrMobile,
    required String password,
  }) async {
    final session = await _dataSource.login(
      emailOrMobile: emailOrMobile,
      password: password,
    );
    await _sessionStorage.saveToken(session.token);
    await _sessionStorage.saveUserData(jsonEncode(session.user.toMap()));
    return session;
  }

  @override
  Future<void> sendPasswordReset({required String emailOrMobile}) {
    return _dataSource.sendPasswordReset(emailOrMobile: emailOrMobile);
  }

  @override
  Future<User?> restoreSession() async {
    final token = await _sessionStorage.getToken();
    final userData = await _sessionStorage.getUserData();
    if (token == null || userData == null) {
      return null;
    }
    try {
      final userMap = jsonDecode(userData) as Map<String, dynamic>;
      final user = User.fromMap(userMap);
      if (user.id == 'usr-admin-001') {
        final updatedAdmin = user.copyWith(
          name: 'Shrujal Shah',
          societyName: 'Shyam Heights',
        );
        await _sessionStorage.saveUserData(jsonEncode(updatedAdmin.toMap()));
        return updatedAdmin;
      }
      return user;
    } catch (_) {
      await _sessionStorage.clear();
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _sessionStorage.clear();
  }

  @override
  Future<User> updateProfile({
    required String userId,
    required String name,
    required String mobile,
    String? profilePhotoUrl,
  }) async {
    final updated = await _dataSource.updateProfile(
      userId: userId,
      name: name,
      mobile: mobile,
      profilePhotoUrl: profilePhotoUrl,
    );
    await _sessionStorage.saveUserData(jsonEncode(updated.toMap()));
    return updated;
  }

  @override
  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) {
    return _dataSource.changePassword(
      userId: userId,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
