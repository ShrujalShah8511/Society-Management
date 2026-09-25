import 'package:flutter_test/flutter_test.dart';
import 'package:society_management/core/constants/app_constants.dart';
import 'package:society_management/core/errors/app_errors.dart';
import 'package:society_management/features/society/data/floor_repository_impl.dart';
import 'package:society_management/features/society/data/society_mock_data_source.dart';
import 'package:society_management/features/society/data/society_repository_impl.dart';
import 'package:society_management/features/society/data/tower_repository_impl.dart';
import 'package:society_management/features/society/domain/floor.dart';
import 'package:society_management/features/society/domain/tower.dart';

import 'package:society_management/features/society/domain/society.dart';
import 'package:society_management/features/society/presentation/active_society_provider.dart';

void main() {
  late SocietyMockDataSource dataSource;
  late SocietyRepositoryImpl societyRepo;
  late TowerRepositoryImpl towerRepo;
  late FloorRepositoryImpl floorRepo;

  setUp(() {
    dataSource = SocietyMockDataSource();
    societyRepo = SocietyRepositoryImpl(dataSource);
    towerRepo = TowerRepositoryImpl(dataSource);
    floorRepo = FloorRepositoryImpl(dataSource);
  });

  group('Society & Tower/Floor Unit Tests', () {
    test('Get all societies, create new society, and delete society', () async {
      final list = await societyRepo.getSocieties();
      expect(list.length, greaterThanOrEqualTo(2));
      expect(list.any((s) => s.name == 'Shyam Heights'), isTrue);

      final newSoc = Society(
        id: 'soc-test-new',
        name: 'Royal Orchid Enclave',
        logoUrl: null,
        address: 'Sector 7',
        city: 'Gandhinagar',
        state: 'Gujarat',
        country: 'India',
        pinCode: '382007',
        contactNumber: '+91 9998881122',
        email: 'info@royalorchid.in',
        registrationNumber: 'GUJ/GNR/2026/99',
        updatedAt: DateTime.now(),
      );

      final created = await societyRepo.createSociety(newSoc);
      expect(created.name, 'Royal Orchid Enclave');

      final updatedList = await societyRepo.getSocieties();
      expect(updatedList.any((s) => s.id == 'soc-test-new'), isTrue);

      await societyRepo.deleteSociety('soc-test-new');
      final afterDelete = await societyRepo.getSocieties();
      expect(afterDelete.any((s) => s.id == 'soc-test-new'), isFalse);
    });

    test('Super admin can delete any society including the default seed society', () async {
      final initialList = await societyRepo.getSocieties();
      expect(initialList.any((s) => s.id == AppConstants.defaultSocietyId), isTrue);

      await societyRepo.deleteSociety(AppConstants.defaultSocietyId);
      final afterDelete = await societyRepo.getSocieties();
      expect(afterDelete.any((s) => s.id == AppConstants.defaultSocietyId), isFalse);
    });

    test('ActiveSocietyNotifier falls back to next available society when active society is deleted', () async {
      final notifier = ActiveSocietyNotifier(societyRepo);
      // Wait for initial load
      await notifier.loadSocieties();
      expect(notifier.state.activeSociety?.id, AppConstants.defaultSocietyId);

      // Create a secondary society
      final secondary = await notifier.createSociety(
        Society(
          id: 'soc-temp-del',
          name: 'Temporary Residency',
          logoUrl: null,
          address: 'Main Road',
          city: 'Ahmedabad',
          state: 'Gujarat',
          country: 'India',
          pinCode: '380015',
          contactNumber: '+91 9988776655',
          email: 'temp@residency.com',
          registrationNumber: 'GUJ/AHM/2026/888',
          updatedAt: DateTime.now(),
        ),
      );
      expect(secondary, isNotNull);
      expect(notifier.state.activeSociety?.id, 'soc-temp-del');

      // Delete the currently active society
      final deleted = await notifier.deleteSociety('soc-temp-del');
      expect(deleted, isTrue);

      // Verify active society automatically fell back to next available society
      expect(notifier.state.activeSociety?.id, AppConstants.defaultSocietyId);
      expect(notifier.state.allSocieties.any((s) => s.id == 'soc-temp-del'), isFalse);

      // Now delete the default society as well to verify fallback to remaining society
      final deletedDefault = await notifier.deleteSociety(AppConstants.defaultSocietyId);
      expect(deletedDefault, isTrue);
      expect(notifier.state.activeSociety?.id, isNot(AppConstants.defaultSocietyId));
      expect(notifier.state.activeSociety, isNotNull);
    });

    test('Get and Update Society Profile', () async {
      final initial = await societyRepo.getSocietyProfile(AppConstants.defaultSocietyId);
      expect(initial.name, contains('Shyam Heights'));

      final updated = initial.copyWith(
        name: 'Shyam Heights Cooperative',
        city: 'Pune',
      );
      final saved = await societyRepo.updateSocietyProfile(updated);

      expect(saved.name, 'Shyam Heights Cooperative');
      expect(saved.city, 'Pune');
    });

    test('Tower CRUD operations', () async {
      final initialTowers = await towerRepo.getTowers(AppConstants.defaultSocietyId);
      final countBefore = initialTowers.length;

      // Create
      final newTower = Tower(
        id: 'tow-new-01',
        societyId: AppConstants.defaultSocietyId,
        name: 'Tower D (Dahlia)',
        description: 'New eco tower',
        floorCount: 8,
        status: TowerStatus.active,
        createdAt: DateTime.now(),
      );
      await towerRepo.createTower(newTower);

      final towersAfterAdd = await towerRepo.getTowers(AppConstants.defaultSocietyId);
      expect(towersAfterAdd.length, countBefore + 1);

      // Read by ID
      final fetched = await towerRepo.getTowerById('tow-new-01');
      expect(fetched.name, 'Tower D (Dahlia)');

      // Update
      final updated = fetched.copyWith(description: 'Updated description');
      await towerRepo.updateTower(updated);
      final fetchedUpdated = await towerRepo.getTowerById('tow-new-01');
      expect(fetchedUpdated.description, 'Updated description');

      // Delete (Tower D has no floors, so deletion should succeed)
      await towerRepo.deleteTower('tow-new-01');
      expect(
        () => towerRepo.getTowerById('tow-new-01'),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('Deleting tower with active floors throws ValidationFailure', () async {
      // tow-001 has child floors in the seeded mock data
      expect(
        () => towerRepo.deleteTower('tow-001'),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('Floor CRUD and relational association to tower', () async {
      final floorsForTowerA = await floorRepo.getFloors(
        societyId: AppConstants.defaultSocietyId,
        towerId: 'tow-001',
      );
      expect(floorsForTowerA, isNotEmpty);

      // Create a new floor for Tower C (which has no flats)
      final newFloor = Floor(
        id: 'flr-c-01',
        societyId: AppConstants.defaultSocietyId,
        towerId: 'tow-003',
        floorNumber: 1,
        displayName: 'Ground Floor',
        status: TowerStatus.active,
        createdAt: DateTime.now(),
      );
      await floorRepo.createFloor(newFloor);

      final floorsC = await floorRepo.getFloors(
        societyId: AppConstants.defaultSocietyId,
        towerId: 'tow-003',
      );
      expect(floorsC.length, 1);
      expect(floorsC.first.displayName, 'Ground Floor');

      // Delete newFloor (has no flats)
      await floorRepo.deleteFloor('flr-c-01');
      final floorsCAfterDelete = await floorRepo.getFloors(
        societyId: AppConstants.defaultSocietyId,
        towerId: 'tow-003',
      );
      expect(floorsCAfterDelete, isEmpty);
    });

    test('Deleting floor with child flats throws ValidationFailure', () async {
      // flr-001 has child flats in the seeded mock data
      expect(
        () => floorRepo.deleteFloor('flr-001'),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('Initial seed society Shyam Heights has null logo (no default logo)', () async {
      final shyam = await societyRepo.getSocietyProfile(AppConstants.defaultSocietyId);
      expect(shyam.logoUrl, isNull);
    });

    test('Registering new society with optional logo preserves logoUrl', () async {
      final socWithLogo = Society(
        id: 'soc-with-logo-101',
        name: 'Sapphire Heights',
        logoUrl: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJ',
        address: 'Science City Road',
        city: 'Ahmedabad',
        state: 'Gujarat',
        country: 'India',
        pinCode: '380060',
        contactNumber: '+91 9123456780',
        email: 'info@sapphire.in',
        registrationNumber: 'REG/AHM/2026/101',
        updatedAt: DateTime.now(),
      );

      final created = await societyRepo.createSociety(socWithLogo);
      expect(created.logoUrl, startsWith('data:image/png;base64,'));

      final fetched = await societyRepo.getSocietyProfile('soc-with-logo-101');
      expect(fetched.logoUrl, startsWith('data:image/png;base64,'));
    });

    test('Updating society profile logo persists new logo or removes it', () async {
      final shyam = await societyRepo.getSocietyProfile(AppConstants.defaultSocietyId);
      expect(shyam.logoUrl, isNull);

      // Add logo
      final withLogo = shyam.copyWith(logoUrl: 'https://example.com/shyam_logo.png');
      final updated = await societyRepo.updateSocietyProfile(withLogo);
      expect(updated.logoUrl, 'https://example.com/shyam_logo.png');

      // Remove logo (make none)
      final withoutLogo = Society(
        id: updated.id,
        name: updated.name,
        logoUrl: null,
        address: updated.address,
        city: updated.city,
        state: updated.state,
        country: updated.country,
        pinCode: updated.pinCode,
        contactNumber: updated.contactNumber,
        email: updated.email,
        registrationNumber: updated.registrationNumber,
        updatedAt: DateTime.now(),
      );
      final reset = await societyRepo.updateSocietyProfile(withoutLogo);
      expect(reset.logoUrl, isNull);
    });

    test('ActiveSocietyNotifier switches society reactively', () async {
      final notifier = ActiveSocietyNotifier(societyRepo);
      await notifier.loadSocieties();

      expect(notifier.state.activeSociety?.id, AppConstants.defaultSocietyId);

      // Switch to Palm Oasis
      await notifier.selectSociety('soc-palm-002');
      expect(notifier.state.activeSociety?.name, 'Palm Oasis Residency');
      expect(notifier.state.activeSociety?.logoUrl, isNull);
    });
  });
}
