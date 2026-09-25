import 'package:flutter_test/flutter_test.dart';
import 'package:society_management/features/role/domain/role.dart';
import 'package:society_management/features/society/data/flat_repository_impl.dart';
import 'package:society_management/features/society/data/floor_repository_impl.dart';
import 'package:society_management/features/society/data/society_mock_data_source.dart';
import 'package:society_management/features/society/data/society_repository_impl.dart';
import 'package:society_management/features/society/data/tower_repository_impl.dart';
import 'package:society_management/features/society/domain/flat.dart';
import 'package:society_management/features/society/domain/floor.dart';
import 'package:society_management/features/society/domain/society.dart';
import 'package:society_management/features/society/domain/tower.dart';
import 'package:society_management/features/society/presentation/active_society_provider.dart';

void main() {
  group('15-Year Architect Scalability & Load Tests', () {
    late SocietyMockDataSource dataSource;
    late SocietyRepositoryImpl societyRepo;
    late TowerRepositoryImpl towerRepo;
    late FloorRepositoryImpl floorRepo;
    late FlatRepositoryImpl flatRepo;

    setUp(() {
      dataSource = SocietyMockDataSource();
      societyRepo = SocietyRepositoryImpl(dataSource);
      towerRepo = TowerRepositoryImpl(dataSource);
      floorRepo = FloorRepositoryImpl(dataSource);
      flatRepo = FlatRepositoryImpl(dataSource);
    });

    test('1. High-Density Tenant Creation & Retrieval Load Test (50 Societies)', () async {
      final stopwatch = Stopwatch()..start();

      // Bulk generate 50 societies
      final futures = <Future<Society>>[];
      for (int i = 1; i <= 50; i++) {
        final soc = Society(
          id: 'soc-stress-$i',
          name: 'Stress Test Enclave $i',
          logoUrl: null,
          address: 'Highway $i, Tech Zone',
          city: i % 2 == 0 ? 'Ahmedabad' : 'Gandhinagar',
          state: 'Gujarat',
          country: 'India',
          pinCode: '38000$i',
          contactNumber: '+91 98000000${i.toString().padLeft(2, '0')}',
          email: 'admin$i@stresstest.in',
          registrationNumber: 'GUJ/STR/2026/$i',
          updatedAt: DateTime.now(),
        );
        futures.add(societyRepo.createSociety(soc));
      }

      final createdSocieties = await Future.wait(futures);
      expect(createdSocieties.length, 50);

      // Verify all are queryable and properly sorted
      final allSocieties = await societyRepo.getSocieties();
      expect(allSocieties.length, greaterThanOrEqualTo(52)); // 50 + 2 pre-seeded

      stopwatch.stop();
      // Ensure high-density throughput executes efficiently
      expect(stopwatch.elapsedMilliseconds, lessThan(15000));
    });

    test('2. Deep Relational Hierarchy & Inventory Scale Test (500 Flats across 50 Floors)', () async {
      const targetSocId = 'soc-deep-scale';
      await societyRepo.createSociety(
        Society(
          id: targetSocId,
          name: 'Megacity Towers',
          logoUrl: null,
          address: 'Boulevard 101',
          city: 'Ahmedabad',
          state: 'Gujarat',
          country: 'India',
          pinCode: '380015',
          contactNumber: '+91 9999900000',
          email: 'scale@megacity.in',
          registrationNumber: 'GUJ/MEGA/2026/01',
          updatedAt: DateTime.now(),
        ),
      );

      // Create 5 Towers
      final towerIds = <String>[];
      for (int t = 1; t <= 5; t++) {
        final tId = 'tow-scale-$t';
        towerIds.add(tId);
        await towerRepo.createTower(
          Tower(
            id: tId,
            societyId: targetSocId,
            name: 'Tower $t',
            description: 'Scale Tower $t',
            floorCount: 10,
            status: TowerStatus.active,
            createdAt: DateTime.now(),
          ),
        );
      }

      // Create 10 floors per tower = 50 floors total
      final floorIds = <String>[];
      for (final tId in towerIds) {
        for (int fl = 1; fl <= 10; fl++) {
          final fId = 'flr-$tId-$fl';
          floorIds.add(fId);
          await floorRepo.createFloor(
            Floor(
              id: fId,
              societyId: targetSocId,
              towerId: tId,
              floorNumber: fl,
              displayName: 'Floor $fl',
              status: TowerStatus.active,
              createdAt: DateTime.now(),
            ),
          );
        }
      }
      expect(floorIds.length, 50);

      // Create 10 flats per floor = 500 flats total
      final flatFutures = <Future<Flat>>[];
      for (int i = 0; i < floorIds.length; i++) {
        final fId = floorIds[i];
        final tId = towerIds[i ~/ 10];
        for (int flt = 1; flt <= 10; flt++) {
          final flatNum = '${(i % 10) + 1}0$flt';
          flatFutures.add(
            flatRepo.createFlat(
              Flat(
                id: 'flt-$fId-$flt',
                societyId: targetSocId,
                towerId: tId,
                floorId: fId,
                flatNumber: flatNum,
                flatType: flt % 2 == 0 ? FlatType.twoBhk : FlatType.threeBhk,
                areaSqFt: 1200.0 + (flt * 50),
                occupancyStatus: flt % 3 == 0 ? OccupancyStatus.occupied : OccupancyStatus.vacant,
                createdAt: DateTime.now(),
              ),
            ),
          );
        }
      }

      await Future.wait(flatFutures);

      // Verify querying full inventory
      final allFlats = await flatRepo.getFlats(societyId: targetSocId);
      expect(allFlats.length, 500);

      // Test filtered search performance
      final occupiedFlats = await flatRepo.getFlats(
        societyId: targetSocId,
        occupancyStatus: OccupancyStatus.occupied,
      );
      expect(occupiedFlats.isNotEmpty, isTrue);

      final twoBhkFlats = await flatRepo.getFlats(
        societyId: targetSocId,
        flatType: FlatType.twoBhk,
      );
      expect(twoBhkFlats.length, 250);
    });

    test('3. Atomic Cascade Purge Benchmark Under High Entity Count', () async {
      const purgeSocId = 'soc-purge-test';
      await societyRepo.createSociety(
        Society(
          id: purgeSocId,
          name: 'Purge Candidate Society',
          logoUrl: null,
          address: 'Test Rd',
          city: 'Surat',
          state: 'Gujarat',
          country: 'India',
          pinCode: '395001',
          contactNumber: '+91 9112233445',
          email: 'purge@test.com',
          registrationNumber: 'GUJ/SUR/2026/99',
          updatedAt: DateTime.now(),
        ),
      );

      // Create infrastructure under this society
      await towerRepo.createTower(
        Tower(
          id: 'tow-purge-01',
          societyId: purgeSocId,
          name: 'Tower Alpha',
          description: 'To be purged',
          floorCount: 2,
          status: TowerStatus.active,
          createdAt: DateTime.now(),
        ),
      );

      await floorRepo.createFloor(
        Floor(
          id: 'flr-purge-01',
          societyId: purgeSocId,
          towerId: 'tow-purge-01',
          floorNumber: 1,
          displayName: 'Floor 1',
          status: TowerStatus.active,
          createdAt: DateTime.now(),
        ),
      );

      for (int i = 1; i <= 4; i++) {
        await flatRepo.createFlat(
          Flat(
            id: 'flt-purge-0$i',
            societyId: purgeSocId,
            towerId: 'tow-purge-01',
            floorId: 'flr-purge-01',
            flatNumber: '10$i',
            flatType: FlatType.twoBhk,
            areaSqFt: 1100.0,
            occupancyStatus: OccupancyStatus.vacant,
            createdAt: DateTime.now(),
          ),
        );
      }

      // Verify entities exist before purge
      expect((await towerRepo.getTowers(purgeSocId)).length, 1);
      expect((await floorRepo.getFloors(societyId: purgeSocId, towerId: 'tow-purge-01')).length, 1);
      expect((await flatRepo.getFlats(societyId: purgeSocId)).length, 4);

      // Execute Cascade Deletion
      final stopwatch = Stopwatch()..start();
      await societyRepo.deleteSociety(purgeSocId);
      stopwatch.stop();

      // Cascade must complete sub-second
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      // Assert complete atomic purge across all tiers
      expect((await towerRepo.getTowers(purgeSocId)), isEmpty);
      expect((await floorRepo.getFloors(societyId: purgeSocId, towerId: 'tow-purge-01')), isEmpty);
      expect((await flatRepo.getFlats(societyId: purgeSocId)), isEmpty);
      final remainingSocieties = await societyRepo.getSocieties();
      expect(remainingSocieties.any((s) => s.id == purgeSocId), isFalse);
    });

    test('4. Concurrent Rapid Society Context Switching Stability', () async {
      final notifier = ActiveSocietyNotifier(societyRepo);
      await notifier.loadSocieties();

      // Create 5 temporary societies
      for (int i = 1; i <= 5; i++) {
        await notifier.createSociety(
          Society(
            id: 'soc-switch-$i',
            name: 'Switch Test $i',
            logoUrl: null,
            address: 'Addr $i',
            city: 'Ahmedabad',
            state: 'Gujarat',
            country: 'India',
            pinCode: '38000$i',
            contactNumber: '+91 900000000$i',
            email: 'switch$i@test.com',
            registrationNumber: 'GUJ/SW/2026/$i',
            updatedAt: DateTime.now(),
          ),
        );
      }

      // Rapidly switch active society 20 times in sequence
      for (int cycle = 0; cycle < 20; cycle++) {
        final targetId = 'soc-switch-${(cycle % 5) + 1}';
        await notifier.selectSociety(targetId);
        expect(notifier.state.activeSociety?.id, targetId);
        expect(notifier.state.errorMessage, isNull);
      }

      // Delete active society and ensure immediate fallback without race condition
      final currentActiveId = notifier.state.activeSociety!.id;
      final deleted = await notifier.deleteSociety(currentActiveId);
      expect(deleted, isTrue);
      expect(notifier.state.activeSociety?.id, isNot(currentActiveId));
      expect(notifier.state.activeSociety, isNotNull);
    });

    test('5. RBAC Permission Matrix Comprehensive Enforcement', () {
      // 1. Super Admin: full sovereign access
      expect(RolePermissions.canDeleteSociety(Role.superAdmin), isTrue);
      expect(RolePermissions.canCreateSociety(Role.superAdmin), isTrue);
      expect(RolePermissions.canManageSociety(Role.superAdmin), isTrue);
      expect(RolePermissions.canManageTowers(Role.superAdmin), isTrue);
      expect(RolePermissions.canManageFlats(Role.superAdmin), isTrue);

      // 2. Society Admin: scoped to building operations only
      expect(RolePermissions.canDeleteSociety(Role.societyAdmin), isFalse);
      expect(RolePermissions.canCreateSociety(Role.societyAdmin), isFalse);
      expect(RolePermissions.canManageSociety(Role.societyAdmin), isTrue);
      expect(RolePermissions.canManageTowers(Role.societyAdmin), isTrue);
      expect(RolePermissions.canManageFlats(Role.societyAdmin), isTrue);

      // 3. Resident: strictly read-only
      expect(RolePermissions.canDeleteSociety(Role.resident), isFalse);
      expect(RolePermissions.canCreateSociety(Role.resident), isFalse);
      expect(RolePermissions.canManageSociety(Role.resident), isFalse);
      expect(RolePermissions.canManageTowers(Role.resident), isFalse);
      expect(RolePermissions.canManageFlats(Role.resident), isFalse);

      // 4. Security & Staff: domain-restricted
      expect(RolePermissions.canDeleteSociety(Role.security), isFalse);
      expect(RolePermissions.canCreateSociety(Role.security), isFalse);
      expect(RolePermissions.canDeleteSociety(Role.staff), isFalse);
      expect(RolePermissions.canCreateSociety(Role.staff), isFalse);
    });
  });
}
