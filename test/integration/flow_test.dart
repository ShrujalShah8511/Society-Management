import 'package:flutter_test/flutter_test.dart';
import 'package:society_management/core/constants/app_constants.dart';
import 'package:society_management/core/storage/session_storage.dart';
import 'package:society_management/features/authentication/data/auth_mock_data_source.dart';
import 'package:society_management/features/authentication/data/auth_repository_impl.dart';
import 'package:society_management/features/role/domain/role.dart';
import 'package:society_management/features/society/data/flat_repository_impl.dart';
import 'package:society_management/features/society/data/floor_repository_impl.dart';
import 'package:society_management/features/society/data/society_mock_data_source.dart';
import 'package:society_management/features/society/data/tower_repository_impl.dart';
import 'package:society_management/features/society/domain/flat.dart';
import 'package:society_management/features/society/domain/floor.dart';
import 'package:society_management/features/society/domain/tower.dart';

void main() {
  group('Integration / Flow Tests', () {
    test('End-to-end Sequence: Login -> Verify Role -> Create Tower -> Create Floor -> Create Flat', () async {
      // 1. Authenticate as Society Admin
      final authDataSource = AuthMockDataSource();
      final sessionStorage = InMemorySessionStorage();
      final authRepo = AuthRepositoryImpl(
        dataSource: authDataSource,
        sessionStorage: sessionStorage,
      );

      final session = await authRepo.login(
        emailOrMobile: 'admin@society.com',
        password: 'admin123',
      );

      expect(session.user.role, Role.societyAdmin);
      expect(RolePermissions.canManageTowers(session.user.role), isTrue);

      // 2. Initialize Society Infrastructure
      final societyDataSource = SocietyMockDataSource();
      final towerRepo = TowerRepositoryImpl(societyDataSource);
      final floorRepo = FloorRepositoryImpl(societyDataSource);
      final flatRepo = FlatRepositoryImpl(societyDataSource);

      // 3. Create Tower
      const newTowerId = 'tow-integration-01';
      final newTower = Tower(
        id: newTowerId,
        societyId: AppConstants.defaultSocietyId,
        name: 'Tower E (Emerald)',
        description: 'Integration test tower',
        floorCount: 5,
        status: TowerStatus.active,
        createdAt: DateTime.now(),
      );
      await towerRepo.createTower(newTower);
      final fetchedTower = await towerRepo.getTowerById(newTowerId);
      expect(fetchedTower.name, 'Tower E (Emerald)');

      // 4. Create Floor under new Tower
      const newFloorId = 'flr-integration-01';
      final newFloor = Floor(
        id: newFloorId,
        societyId: AppConstants.defaultSocietyId,
        towerId: newTowerId,
        floorNumber: 1,
        displayName: 'First Floor',
        status: TowerStatus.active,
        createdAt: DateTime.now(),
      );
      await floorRepo.createFloor(newFloor);
      final towerFloors = await floorRepo.getFloors(
        societyId: AppConstants.defaultSocietyId,
        towerId: newTowerId,
      );
      expect(towerFloors.length, 1);
      expect(towerFloors.first.id, newFloorId);

      // 5. Create Flat under new Floor & Tower
      const newFlatId = 'flt-integration-01';
      final newFlat = Flat(
        id: newFlatId,
        societyId: AppConstants.defaultSocietyId,
        towerId: newTowerId,
        floorId: newFloorId,
        flatNumber: 'E-101',
        flatType: FlatType.threeBhk,
        areaSqFt: 1450.0,
        occupancyStatus: OccupancyStatus.vacant,
        createdAt: DateTime.now(),
      );
      await flatRepo.createFlat(newFlat);

      final fetchedFlat = await flatRepo.getFlatById(newFlatId);
      expect(fetchedFlat.flatNumber, 'E-101');
      expect(fetchedFlat.flatType, FlatType.threeBhk);
      expect(fetchedFlat.occupancyStatus, OccupancyStatus.vacant);

      // 6. Relational Integrity: Attempt to delete floor while flat exists -> fails
      expect(
        () => floorRepo.deleteFloor(newFloorId),
        throwsException,
      );

      // 7. Relational Integrity: Attempt to delete tower while floor exists -> fails
      expect(
        () => towerRepo.deleteTower(newTowerId),
        throwsException,
      );

      // 8. Proper teardown sequence: Delete flat, then floor, then tower
      await flatRepo.deleteFlat(newFlatId);
      await floorRepo.deleteFloor(newFloorId);
      await towerRepo.deleteTower(newTowerId);

      // Verify tower is gone
      final finalTowers = await towerRepo.getTowers(AppConstants.defaultSocietyId);
      expect(finalTowers.any((t) => t.id == newTowerId), isFalse);
    });
  });
}
