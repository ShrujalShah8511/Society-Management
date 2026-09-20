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
  });
}
