import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../../core/network/supabase_client_manager.dart';
import '../../role/domain/role.dart';
import '../domain/auth_session.dart';
import '../domain/user.dart';
import 'auth_data_source.dart';
import 'auth_mock_data_source.dart';

/// Supabase Authentication Data Source with Mock Fallback
class SupabaseAuthDataSource implements AuthDataSource {
  final AuthDataSource _fallbackMock = AuthMockDataSource();

  sb.SupabaseClient? get _client => SupabaseClientManager.client;

  @override
  Future<AuthSession> login({
    required String emailOrMobile,
    required String password,
  }) async {
    final client = _client;
    if (client == null) {
      debugPrint('[SupabaseAuthDataSource] Supabase unconfigured, falling back to mock login.');
      return _fallbackMock.login(emailOrMobile: emailOrMobile, password: password);
    }

    try {
      final response = await client.auth.signInWithPassword(
        email: emailOrMobile.trim(),
        password: password,
      );

      final sbUser = response.user;
      final session = response.session;

      if (sbUser == null || session == null) {
        throw Exception('Login failed: invalid session returned from Supabase.');
      }

      // Fetch extended user profile from public.users table
      final userRecord = await client
          .from('users')
          .select('*, societies(name)')
          .eq('id', sbUser.id)
          .maybeSingle();

      final roleStr = userRecord?['role'] as String? ?? 'SOCIETY_ADMIN';
      final societyId = userRecord?['society_id'] as String? ?? 'soc_shyam_heights';
      final societyName = (userRecord?['societies'] as Map<String, dynamic>?)?['name'] as String? ?? 'Shyam Heights';

      final user = User(
        id: sbUser.id,
        email: sbUser.email ?? emailOrMobile,
        name: (userRecord?['full_name'] as String?) ?? sbUser.userMetadata?['full_name'] as String? ?? 'Society Admin',
        mobile: (userRecord?['phone'] as String?) ?? '+91 98765 43210',
        role: Role.fromString(roleStr),
        societyId: societyId,
        societyName: societyName,
        profilePhotoUrl: userRecord?['avatar_url'] as String?,
        createdAt: DateTime.tryParse(sbUser.createdAt) ?? DateTime.now(),
      );

      return AuthSession(
        token: session.accessToken,
        user: user,
      );
    } catch (e) {
      debugPrint('[SupabaseAuthDataSource] Supabase login error: $e, trying mock fallback.');
      return _fallbackMock.login(emailOrMobile: emailOrMobile, password: password);
    }
  }

  @override
  Future<void> sendPasswordReset({required String emailOrMobile}) async {
    final client = _client;
    if (client == null) {
      return _fallbackMock.sendPasswordReset(emailOrMobile: emailOrMobile);
    }

    try {
      await client.auth.resetPasswordForEmail(emailOrMobile.trim());
    } catch (e) {
      debugPrint('[SupabaseAuthDataSource] Reset password error: $e');
      return _fallbackMock.sendPasswordReset(emailOrMobile: emailOrMobile);
    }
  }

  @override
  Future<User> updateProfile({
    required String userId,
    required String name,
    required String mobile,
    String? profilePhotoUrl,
  }) async {
    final client = _client;
    if (client == null) {
      return _fallbackMock.updateProfile(
        userId: userId,
        name: name,
        mobile: mobile,
        profilePhotoUrl: profilePhotoUrl,
      );
    }

    try {
      await client.from('users').update({
        'full_name': name,
        'phone': mobile,
        if (profilePhotoUrl != null) 'avatar_url': profilePhotoUrl,
      }).eq('id', userId);

      // Also update auth user metadata
      await client.auth.updateUser(
        sb.UserAttributes(
          data: {
            'full_name': name,
            'phone': mobile,
          },
        ),
      );

      final userRecord = await client
          .from('users')
          .select('*, societies(name)')
          .eq('id', userId)
          .single();

      final roleStr = userRecord['role'] as String? ?? 'SOCIETY_ADMIN';
      final societyId = userRecord['society_id'] as String? ?? 'soc_shyam_heights';
      final societyName = (userRecord['societies'] as Map<String, dynamic>?)?['name'] as String? ?? 'Shyam Heights';

      return User(
        id: userId,
        email: userRecord['email'] as String? ?? '',
        name: name,
        mobile: mobile,
        role: Role.fromString(roleStr),
        societyId: societyId,
        societyName: societyName,
        profilePhotoUrl: profilePhotoUrl ?? userRecord['avatar_url'] as String?,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('[SupabaseAuthDataSource] Update profile error: $e');
      return _fallbackMock.updateProfile(
        userId: userId,
        name: name,
        mobile: mobile,
        profilePhotoUrl: profilePhotoUrl,
      );
    }
  }

  @override
  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final client = _client;
    if (client == null) {
      return _fallbackMock.changePassword(
        userId: userId,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    }

    try {
      await client.auth.updateUser(
        sb.UserAttributes(password: newPassword),
      );
    } catch (e) {
      debugPrint('[SupabaseAuthDataSource] Change password error: $e');
      return _fallbackMock.changePassword(
        userId: userId,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    }
  }
}
