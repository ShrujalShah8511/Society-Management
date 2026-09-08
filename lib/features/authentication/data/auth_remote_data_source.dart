import '../../../core/network/api_client.dart';
import '../domain/auth_session.dart';
import '../domain/user.dart';
import 'auth_data_source.dart';

class AuthRemoteDataSource implements AuthDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  @override
  Future<AuthSession> login({
    required String emailOrMobile,
    required String password,
  }) async {
    final response = await _apiClient.post('/auth/login', body: {
      'emailOrMobile': emailOrMobile,
      'password': password,
    });
    return AuthSession.fromMap(response as Map<String, dynamic>);
  }

  @override
  Future<void> sendPasswordReset({required String emailOrMobile}) async {
    await _apiClient.post('/auth/forgot-password', body: {
      'emailOrMobile': emailOrMobile,
    });
  }

  @override
  Future<User> updateProfile({
    required String userId,
    required String name,
    required String mobile,
    String? profilePhotoUrl,
  }) async {
    final response = await _apiClient.put('/users/$userId/profile', body: {
      'name': name,
      'mobile': mobile,
      'profilePhotoUrl': profilePhotoUrl,
    });
    return User.fromMap(response as Map<String, dynamic>);
  }

  @override
  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.post('/users/$userId/change-password', body: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }
}
