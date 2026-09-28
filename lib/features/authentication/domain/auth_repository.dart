import 'auth_session.dart';
import 'user.dart';

abstract class AuthRepository {
  Future<AuthSession> login({
    required String emailOrMobile,
    required String password,
  });

  Future<void> sendPasswordReset({
    required String emailOrMobile,
  });

  Future<User?> restoreSession();

  Future<void> logout();

  Future<User> updateProfile({
    required String userId,
    required String name,
    required String mobile,
    String? profilePhotoUrl,
  });

  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  });

  Future<List<User>> getUsers({String? societyId});

  Future<User> createUser({
    required User user,
    required String temporaryPassword,
  });

  Future<User> updateUser(User user);

  Future<void> deleteUser(String userId);

  String generateNextUserId(String city);
}
