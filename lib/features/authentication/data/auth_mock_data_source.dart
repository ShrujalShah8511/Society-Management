import 'dart:async';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_errors.dart';
import '../../role/domain/role.dart';
import '../domain/auth_session.dart';
import '../domain/user.dart';
import 'auth_data_source.dart';

class AuthMockDataSource implements AuthDataSource {
  final Map<String, User> _users = {};
  final Map<String, String> _passwords = {};

  AuthMockDataSource() {
    _seedDefaultUsers();
  }

  void _seedDefaultUsers() {
    final societyAdmin = User(
      id: 'usr-admin-001',
      email: 'admin@society.com',
      name: 'Shrujal Shah',
      mobile: '9876543210',
      role: Role.societyAdmin,
      societyId: AppConstants.defaultSocietyId,
      societyName: 'Shyam Heights',
      profilePhotoUrl: null,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    );

    final superAdmin = User(
      id: 'usr-super-001',
      email: 'superadmin@society.com',
      name: 'Shrujal Shah',
      mobile: '9998887776',
      role: Role.superAdmin,
      societyId: AppConstants.defaultSocietyId,
      societyName: 'Shyam Heights',
      profilePhotoUrl: null,
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
    );

    final resident = User(
      id: 'usr-res-001',
      email: 'resident@society.com',
      name: 'Priya Verma',
      mobile: '9123456780',
      role: Role.resident,
      societyId: AppConstants.defaultSocietyId,
      societyName: 'Shyam Heights',
      profilePhotoUrl: null,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    );

    final committee = User(
      id: 'usr-comm-001',
      email: 'committee@society.com',
      name: 'Sunil Nair',
      mobile: '9123456781',
      role: Role.committeeMember,
      societyId: AppConstants.defaultSocietyId,
      societyName: 'Shyam Heights',
      profilePhotoUrl: null,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    );

    final security = User(
      id: 'usr-sec-001',
      email: 'security@society.com',
      name: 'Ramesh Singh',
      mobile: '9123456782',
      role: Role.security,
      societyId: AppConstants.defaultSocietyId,
      societyName: 'Shyam Heights',
      profilePhotoUrl: null,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );

    final staff = User(
      id: 'usr-stf-001',
      email: 'staff@society.com',
      name: 'Manoj Kumar',
      mobile: '9123456783',
      role: Role.staff,
      societyId: AppConstants.defaultSocietyId,
      societyName: 'Shyam Heights',
      profilePhotoUrl: null,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    );

    _registerUser(societyAdmin, 'admin123');
    _registerUser(superAdmin, 'super123');
    _registerUser(resident, 'resident123');
    _registerUser(committee, 'committee123');
    _registerUser(security, 'security123');
    _registerUser(staff, 'staff123');
  }

  void _registerUser(User user, String password) {
    _users[user.id] = user;
    _passwords[user.email.toLowerCase()] = password;
    _passwords[user.mobile] = password;
  }

  @override
  Future<AuthSession> login({
    required String emailOrMobile,
    required String password,
  }) async {
    // Realistic simulation of network delay
    await Future.delayed(const Duration(milliseconds: 350));

    final normalizedInput = emailOrMobile.trim().toLowerCase();
    User? matchedUser;

    for (final user in _users.values) {
      if (user.email.toLowerCase() == normalizedInput || user.mobile == normalizedInput) {
        matchedUser = user;
        break;
      }
    }

    if (matchedUser == null) {
      throw const AuthFailure('No account found with this email or mobile number.');
    }

    final storedPassword = _passwords[normalizedInput];
    if (storedPassword != password) {
      throw const AuthFailure('Invalid credentials. Please check your password.');
    }

    final token = 'mock_jwt_token_${matchedUser.id}_${DateTime.now().millisecondsSinceEpoch}';
    return AuthSession(token: token, user: matchedUser);
  }

  @override
  Future<void> sendPasswordReset({required String emailOrMobile}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final normalizedInput = emailOrMobile.trim().toLowerCase();

    final userExists = _users.values.any((u) =>
        u.email.toLowerCase() == normalizedInput || u.mobile == normalizedInput);

    if (!userExists) {
      throw const AuthFailure('No account registered with this email or mobile number.');
    }
  }

  @override
  Future<User> updateProfile({
    required String userId,
    required String name,
    required String mobile,
    String? profilePhotoUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final existingUser = _users[userId];
    if (existingUser == null) {
      throw const NotFoundFailure('User not found');
    }

    final updated = existingUser.copyWith(
      name: name,
      mobile: mobile,
      profilePhotoUrl: profilePhotoUrl ?? existingUser.profilePhotoUrl,
    );
    _users[userId] = updated;
    return updated;
  }

  @override
  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final existingUser = _users[userId];
    if (existingUser == null) {
      throw const NotFoundFailure('User not found');
    }

    final currentStored = _passwords[existingUser.email.toLowerCase()];
    if (currentStored != currentPassword) {
      throw const AuthFailure('Current password does not match');
    }

    _passwords[existingUser.email.toLowerCase()] = newPassword;
    _passwords[existingUser.mobile] = newPassword;
  }
}
