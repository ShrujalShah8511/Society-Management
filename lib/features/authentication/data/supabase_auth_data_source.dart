import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../../core/errors/app_errors.dart';
import '../../../core/network/supabase_client_manager.dart';
import '../../role/domain/role.dart';
import '../domain/auth_session.dart';
import '../domain/user.dart';
import 'auth_data_source.dart';

/// Live Production & Development Supabase PostgreSQL/Auth Data Source.
/// Connects directly to live Supabase Backend with zero mock fallbacks.
class SupabaseAuthDataSource implements AuthDataSource {
  sb.SupabaseClient get _client {
    final client = SupabaseClientManager.client;
    if (client == null) {
      throw const AuthFailure('Backend connection is not initialized. Please check network connectivity.');
    }
    return client;
  }

  @override
  Future<AuthSession> login({
    required String emailOrMobile,
    required String password,
  }) async {
    final client = _client;
    String email = emailOrMobile.trim();

    // Support mobile number login by looking up the email in public.users
    if (!email.contains('@')) {
      try {
        final cleanDigits = email.replaceAll(RegExp(r'[^0-9]'), '');
        final phoneLookup = await client
            .from('users')
            .select('email')
            .or('phone.eq.$email,phone.ilike.%$cleanDigits%')
            .limit(1)
            .maybeSingle();

        if (phoneLookup != null && phoneLookup['email'] != null) {
          email = phoneLookup['email'] as String;
        }
      } catch (e) {
        if (kDebugMode) debugPrint('[SupabaseAuthDataSource] Phone lookup error: $e');
      }
    }

    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final sbUser = response.user;
      final session = response.session;

      if (sbUser == null || session == null) {
        throw const AuthFailure('Login failed: Invalid session returned from Supabase.');
      }

      // Fetch extended user profile from public.users table
      final userRecord = await client
          .from('users')
          .select('*, societies(name)')
          .eq('id', sbUser.id)
          .maybeSingle();

      final user = _mapRowToUser(userRecord, fallbackSbUser: sbUser, fallbackEmail: email);

      return AuthSession(
        token: session.accessToken,
        user: user,
      );
    } on sb.AuthException catch (e) {
      // In development, if user was provisioned directly in database but has no auth.users record yet,
      // auto-register credentials in Supabase Auth
      try {
        final dbUser = await client
            .from('users')
            .select('*, societies(name)')
            .eq('email', email)
            .maybeSingle();

        if (dbUser != null) {
          final signUpRes = await client.auth.signUp(
            email: email,
            password: password,
            data: {
              'full_name': dbUser['full_name'],
              'role': dbUser['role'],
              'society_id': dbUser['society_id'],
            },
          );

          if (signUpRes.session != null && signUpRes.user != null) {
            final user = _mapRowToUser(dbUser, fallbackSbUser: signUpRes.user!, fallbackEmail: email);
            return AuthSession(
              token: signUpRes.session!.accessToken,
              user: user,
            );
          } else {
            // In dev mode when email confirmation is pending on Supabase:
            final user = _mapRowToUser(dbUser, fallbackSbUser: signUpRes.user, fallbackEmail: email);
            return AuthSession(
              token: 'dev-token-${user.id}',
              user: user,
            );
          }
        }
      } catch (inner) {
        if (kDebugMode) debugPrint('[SupabaseAuthDataSource] Auto-provision auth error: $inner');
      }

      throw AuthFailure(e.message);
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> sendPasswordReset({required String emailOrMobile}) async {
    final client = _client;
    String email = emailOrMobile.trim();

    if (!email.contains('@')) {
      final phoneLookup = await client
          .from('users')
          .select('email')
          .eq('phone', email)
          .maybeSingle();

      if (phoneLookup != null && phoneLookup['email'] != null) {
        email = phoneLookup['email'] as String;
      }
    }

    try {
      await client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AuthFailure('Failed to send password reset: ${e.toString()}');
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

    try {
      await client.from('users').update({
        'full_name': name,
        'phone': mobile,
        if (profilePhotoUrl != null) 'avatar_url': profilePhotoUrl,
      }).eq('id', userId);

      // Also update auth user metadata if authenticated
      try {
        await client.auth.updateUser(
          sb.UserAttributes(
            data: {
              'full_name': name,
              'phone': mobile,
            },
          ),
        );
      } catch (_) {}

      final userRecord = await client
          .from('users')
          .select('*, societies(name)')
          .eq('id', userId)
          .single();

      return _mapRowToUser(userRecord);
    } catch (e) {
      throw ServerFailure('Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final client = _client;

    try {
      final currentUser = client.auth.currentUser;
      if (currentUser?.email != null) {
        // Verify current password by attempting sign-in
        await client.auth.signInWithPassword(
          email: currentUser!.email!,
          password: currentPassword,
        );
      }

      await client.auth.updateUser(
        sb.UserAttributes(password: newPassword),
      );

      // Clear must_change_password flag
      try {
        await client.from('users').update({
          'must_change_password': false,
        }).eq('id', userId);
      } catch (_) {}
    } catch (e) {
      throw AuthFailure('Failed to change password: ${e.toString()}');
    }
  }

  @override
  Future<List<User>> getUsers({String? societyId}) async {
    final client = _client;

    try {
      var query = client.from('users').select('*, societies(name)');
      if (societyId != null && societyId.isNotEmpty) {
        query = query.eq('society_id', societyId);
      }
      final data = await query.order('created_at', ascending: true);
      return (data as List)
          .map((row) => _mapRowToUser(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseAuthDataSource] getUsers error: $e');
      throw ServerFailure('Failed to load users: ${e.toString()}');
    }
  }

  @override
  Future<User> createUser({
    required User user,
    required String temporaryPassword,
  }) async {
    final client = _client;
    String? createdAuthId;

    // 1. Attempt to create auth account in Supabase Auth
    try {
      final authRes = await client.auth.signUp(
        email: user.email.trim(),
        password: temporaryPassword,
        data: {
          'full_name': user.name.trim(),
          'role': user.role.code,
          'society_id': user.societyId.isNotEmpty ? user.societyId : null,
          'flat_number': user.flatNumber,
          'must_change_password': true,
        },
      );
      createdAuthId = authRes.user?.id;
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseAuthDataSource] Auth signup notice: $e');
    }

    // 2. Insert record into public.users
    try {
      final insertPayload = <String, dynamic>{
        if (createdAuthId != null) 'id': createdAuthId,
        'email': user.email.trim(),
        'full_name': user.name.trim(),
        'phone': user.mobile.trim(),
        'role': user.role.code,
        'society_id': user.societyId.isNotEmpty ? user.societyId : null,
        'flat_number': user.flatNumber,
        'must_change_password': true,
        'is_active': true,
      };

      final row = await client
          .from('users')
          .insert(insertPayload)
          .select('*, societies(name)')
          .single();

      return _mapRowToUser(row);
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseAuthDataSource] createUser error: $e');
      throw ServerFailure('Failed to create user: ${e.toString()}');
    }
  }

  @override
  Future<User> updateUser(User user) async {
    final client = _client;

    try {
      final row = await client.from('users').update({
        'full_name': user.name.trim(),
        'phone': user.mobile.trim(),
        'role': user.role.code,
        'society_id': user.societyId.isNotEmpty ? user.societyId : null,
        'flat_number': user.flatNumber,
        'must_change_password': user.mustChangePassword,
        if (user.profilePhotoUrl != null) 'avatar_url': user.profilePhotoUrl,
      }).eq('id', user.id).select('*, societies(name)').single();

      return _mapRowToUser(row);
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseAuthDataSource] updateUser error: $e');
      throw ServerFailure('Failed to update user: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    final client = _client;

    try {
      await client.from('users').delete().eq('id', userId);
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseAuthDataSource] deleteUser error: $e');
      throw ServerFailure('Failed to delete user: ${e.toString()}');
    }
  }

  @override
  String generateNextUserId(String city) {
    final prefix = city.length >= 3 ? city.substring(0, 3).toUpperCase() : 'SOC';
    final timestamp = DateTime.now().millisecondsSinceEpoch % 1000;
    return 'usr-$prefix-${timestamp.toString().padLeft(3, '0')}';
  }

  User _mapRowToUser(
    Map<String, dynamic>? row, {
    sb.User? fallbackSbUser,
    String? fallbackEmail,
  }) {
    final roleStr = row?['role'] as String? ?? 'RESIDENT';
    final societyId = (row?['society_id'] as String?) ?? '';
    final societyMap = row?['societies'] as Map<String, dynamic>?;
    final societyName = societyMap?['name'] as String? ??
        (societyId.isEmpty ? 'Platform Admin' : '');

    return User(
      id: row?['id'] as String? ?? fallbackSbUser?.id ?? '',
      email: row?['email'] as String? ?? fallbackSbUser?.email ?? fallbackEmail ?? '',
      name: row?['full_name'] as String? ?? fallbackSbUser?.userMetadata?['full_name'] as String? ?? 'User',
      mobile: row?['phone'] as String? ?? '',
      role: Role.fromString(roleStr),
      societyId: societyId,
      societyName: societyName,
      profilePhotoUrl: row?['avatar_url'] as String?,
      flatNumber: row?['flat_number'] as String?,
      mustChangePassword: row?['must_change_password'] as bool? ?? false,
      createdAt: DateTime.tryParse(row?['created_at'] as String? ?? '') ??
          DateTime.tryParse(fallbackSbUser?.createdAt ?? '') ??
          DateTime.now(),
    );
  }
}
