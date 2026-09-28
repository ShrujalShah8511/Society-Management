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
  }) async {
    await _dataSource.changePassword(
      userId: userId,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    final userData = await _sessionStorage.getUserData();
    if (userData != null) {
      try {
        final userMap = jsonDecode(userData) as Map<String, dynamic>;
        if (userMap['id'] == userId) {
          final updatedUser = User.fromMap(userMap).copyWith(mustChangePassword: false);
          await _sessionStorage.saveUserData(jsonEncode(updatedUser.toMap()));
        }
      } catch (_) {}
    }
  }

  @override
  Future<List<User>> getUsers({String? societyId}) {
    return _dataSource.getUsers(societyId: societyId);
  }

  @override
  Future<User> createUser({
    required User user,
    required String temporaryPassword,
  }) {
    return _dataSource.createUser(user: user, temporaryPassword: temporaryPassword);
  }

  @override
  Future<User> updateUser(User user) {
    return _dataSource.updateUser(user);
  }

  @override
  Future<void> deleteUser(String userId) {
    return _dataSource.deleteUser(userId);
  }

  @override
  String generateNextUserId(String city) {
    return _dataSource.generateNextUserId(city);
  }
}
