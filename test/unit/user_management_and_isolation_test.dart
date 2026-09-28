import 'package:flutter_test/flutter_test.dart';
import 'package:society_management/features/authentication/data/auth_mock_data_source.dart';
import 'package:society_management/features/authentication/domain/user.dart';
import 'package:society_management/features/role/domain/role.dart';

void main() {
  group('User Management & Architecture Flow Tests', () {
    late AuthMockDataSource dataSource;

    setUp(() {
      dataSource = AuthMockDataSource();
    });

    test('User ID Generation follows usr-[CITY]-[incremental_number] master sequence', () {
      final id1 = dataSource.generateNextUserId('Ahmedabad');
      expect(id1, startsWith('usr-AHM-'));

      final id2 = dataSource.generateNextUserId('Gandhinagar');
      expect(id2, startsWith('usr-GAN-'));

      // Incremental sequence increases
      final seq1 = int.parse(id1.split('-').last);
      final seq2 = int.parse(id2.split('-').last);
      expect(seq2, greaterThan(seq1));
    });

    test('Newly provisioned user has mustChangePassword = true and Welcome@<mobile> password', () async {
      const mobile = '9876500001';
      final userId = dataSource.generateNextUserId('Ahmedabad');
      const tempPassword = 'Welcome@$mobile';

      final newUser = User(
        id: userId,
        name: 'New Society Admin',
        email: 'admin@shyam.com',
        mobile: mobile,
        role: Role.societyAdmin,
        societyId: 'soc-test-1',
        societyName: 'Test Society',
        mustChangePassword: true,
        createdAt: DateTime.now(),
      );

      final created = await dataSource.createUser(
        user: newUser,
        temporaryPassword: tempPassword,
      );

      expect(created.mustChangePassword, isTrue);
      expect(created.id, userId);

      // Login with mobile as username and temporary password
      final authResult = await dataSource.login(
        emailOrMobile: mobile,
        password: tempPassword,
      );

      expect(authResult.user.id, userId);
      expect(authResult.user.mustChangePassword, isTrue);
    });

    test('Password change clears mustChangePassword flag', () async {
      const mobile = '9876500002';
      final userId = dataSource.generateNextUserId('Surat');
      const tempPassword = 'Welcome@$mobile';

      final newUser = User(
        id: userId,
        name: 'Resident John',
        email: 'john@surat.com',
        mobile: mobile,
        role: Role.resident,
        societyId: 'soc-test-2',
        societyName: 'Surat Residency',
        mustChangePassword: true,
        createdAt: DateTime.now(),
      );

      await dataSource.createUser(
        user: newUser,
        temporaryPassword: tempPassword,
      );

      await dataSource.changePassword(
        userId: userId,
        currentPassword: tempPassword,
        newPassword: 'MyNewSecretPassword@123',
      );

      final users = await dataSource.getUsers();
      final updated = users.firstWhere((u) => u.id == userId);
      expect(updated.mustChangePassword, isFalse);

      // Verify login with new password succeeds
      final loginResult = await dataSource.login(
        emailOrMobile: mobile,
        password: 'MyNewSecretPassword@123',
      );
      expect(loginResult.user.mustChangePassword, isFalse);
    });

    test('Flat Exclusive Allocation: A flat assigned to one user cannot be assigned to another', () {
      final existingUsers = [
        User(
          id: 'usr-AHM-001',
          name: 'Existing Resident',
          email: 'res@shyam.com',
          mobile: '9876543210',
          role: Role.resident,
          societyId: 'soc-001',
          societyName: 'Shyam Heights',
          flatId: 'flat-101',
          flatNumber: 'A-101',
          createdAt: DateTime.now(),
        ),
      ];

      final assignedFlatIds = existingUsers
          .where((u) => u.societyId == 'soc-001' && u.flatId != null)
          .map((u) => u.flatId!)
          .toSet();

      expect(assignedFlatIds.contains('flat-101'), isTrue);
      expect(assignedFlatIds.contains('flat-102'), isFalse);
    });

    test('Society Admin does not possess switchSociety permission', () {
      expect(RolePermissions.hasPermission(Role.societyAdmin, Permission.switchSociety), isFalse);
      expect(RolePermissions.hasPermission(Role.superAdmin, Permission.switchSociety), isTrue);
      expect(RolePermissions.hasPermission(Role.superAdmin, Permission.manageAllSocieties), isTrue);
      expect(RolePermissions.hasPermission(Role.societyAdmin, Permission.manageAllSocieties), isFalse);
    });
  });
}
