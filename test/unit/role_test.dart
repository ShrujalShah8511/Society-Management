import 'package:flutter_test/flutter_test.dart';
import 'package:society_management/features/role/domain/role.dart';

void main() {
  group('Role & Permission Logic Tests', () {
    test('Role.fromString parses valid strings correctly', () {
      expect(Role.fromString('SUPER_ADMIN'), Role.superAdmin);
      expect(Role.fromString('SOCIETY_ADMIN'), Role.societyAdmin);
      expect(Role.fromString('COMMITTEE_MEMBER'), Role.committeeMember);
      expect(Role.fromString('RESIDENT'), Role.resident);
      expect(Role.fromString('SECURITY'), Role.security);
      expect(Role.fromString('STAFF'), Role.staff);
    });

    test('Role.fromString defaults to resident on invalid or null string', () {
      expect(Role.fromString(null), Role.resident);
      expect(Role.fromString('UNKNOWN_ROLE'), Role.resident);
      expect(Role.fromString(''), Role.resident);
    });

    test('Super Admin has all permissions', () {
      for (final permission in Permission.values) {
        expect(
          RolePermissions.hasPermission(Role.superAdmin, permission),
          isTrue,
          reason: 'Super admin should have ${permission.key}',
        );
      }
    });

    test('Society Admin has management permissions', () {
      expect(RolePermissions.canManageSociety(Role.societyAdmin), isTrue);
      expect(RolePermissions.canManageTowers(Role.societyAdmin), isTrue);
      expect(RolePermissions.canManageFloors(Role.societyAdmin), isTrue);
      expect(RolePermissions.canManageFlats(Role.societyAdmin), isTrue);
    });

    test('Resident has view-only permissions and cannot manage inventory', () {
      expect(RolePermissions.hasPermission(Role.resident, Permission.viewDashboard), isTrue);
      expect(RolePermissions.hasPermission(Role.resident, Permission.viewFlats), isTrue);
      expect(RolePermissions.hasPermission(Role.resident, Permission.viewTowers), isTrue);

      expect(RolePermissions.canManageSociety(Role.resident), isFalse);
      expect(RolePermissions.canManageTowers(Role.resident), isFalse);
      expect(RolePermissions.canManageFloors(Role.resident), isFalse);
      expect(RolePermissions.canManageFlats(Role.resident), isFalse);
    });

    test('Security has appropriate limited view permissions', () {
      expect(RolePermissions.hasPermission(Role.security, Permission.viewFlats), isTrue);
      expect(RolePermissions.canManageFlats(Role.security), isFalse);
      expect(RolePermissions.canManageSociety(Role.security), isFalse);
    });
  });
}
