import 'package:flutter_test/flutter_test.dart';
import 'package:society_management/core/errors/app_errors.dart';
import 'package:society_management/core/storage/session_storage.dart';
import 'package:society_management/features/authentication/data/auth_mock_data_source.dart';
import 'package:society_management/features/authentication/data/auth_repository_impl.dart';
import 'package:society_management/features/role/domain/role.dart';

void main() {
  late AuthMockDataSource mockDataSource;
  late SessionStorage inMemoryStorage;
  late AuthRepositoryImpl authRepository;

  setUp(() {
    mockDataSource = AuthMockDataSource();
    inMemoryStorage = InMemorySessionStorage();
    authRepository = AuthRepositoryImpl(
      dataSource: mockDataSource,
      sessionStorage: inMemoryStorage,
    );
  });

  group('Authentication Repository & Logic Tests', () {
    test('Successful login with email returns valid session and stores token', () async {
      final session = await authRepository.login(
        emailOrMobile: 'admin@society.com',
        password: 'admin123',
      );

      expect(session.token, isNotEmpty);
      expect(session.user.email, 'admin@society.com');
      expect(session.user.role, Role.societyAdmin);

      // Verify token persisted in storage
      final storedToken = await inMemoryStorage.getToken();
      expect(storedToken, equals(session.token));
    });

    test('Successful login with mobile number returns valid session', () async {
      final session = await authRepository.login(
        emailOrMobile: '9876543210',
        password: 'admin123',
      );

      expect(session.user.mobile, '9876543210');
      expect(session.user.role, Role.societyAdmin);
    });

    test('Successful login as Super Admin returns superAdmin role', () async {
      final session = await authRepository.login(
        emailOrMobile: 'superadmin@society.com',
        password: 'super123',
      );

      expect(session.user.role, Role.superAdmin);
      expect(session.user.name, 'Shrujal Shah');
    });

    test('Login with incorrect password throws AuthFailure', () async {
      expect(
        () => authRepository.login(
          emailOrMobile: 'admin@society.com',
          password: 'wrongpassword',
        ),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('Login with unregistered email throws AuthFailure', () async {
      expect(
        () => authRepository.login(
          emailOrMobile: 'unregistered@example.com',
          password: 'password123',
        ),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('Restore session returns null when storage is empty', () async {
      final user = await authRepository.restoreSession();
      expect(user, isNull);
    });

    test('Restore session returns valid user after login', () async {
      await authRepository.login(
        emailOrMobile: 'resident@society.com',
        password: 'resident123',
      );

      final restored = await authRepository.restoreSession();
      expect(restored, isNotNull);
      expect(restored!.email, 'resident@society.com');
      expect(restored.role, Role.resident);
    });

    test('Logout clears stored session', () async {
      await authRepository.login(
        emailOrMobile: 'admin@society.com',
        password: 'admin123',
      );
      expect(await inMemoryStorage.getToken(), isNotNull);

      await authRepository.logout();
      expect(await inMemoryStorage.getToken(), isNull);
      expect(await authRepository.restoreSession(), isNull);
    });

    test('Password reset succeeds for registered account', () async {
      expect(
        () => authRepository.sendPasswordReset(emailOrMobile: 'admin@society.com'),
        returnsNormally,
      );
    });

    test('Password reset throws AuthFailure for unregistered account', () async {
      expect(
        () => authRepository.sendPasswordReset(emailOrMobile: 'ghost@society.com'),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('Update profile alters name and mobile', () async {
      final session = await authRepository.login(
        emailOrMobile: 'admin@society.com',
        password: 'admin123',
      );

      final updated = await authRepository.updateProfile(
        userId: session.user.id,
        name: 'Shrujal Shah Updated',
        mobile: '9876543299',
      );

      expect(updated.name, 'Shrujal Shah Updated');
      expect(updated.mobile, '9876543299');
    });
  });
}
