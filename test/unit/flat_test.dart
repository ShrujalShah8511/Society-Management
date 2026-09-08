import 'package:flutter_test/flutter_test.dart';
import 'package:society_management/core/constants/app_constants.dart';
import 'package:society_management/features/society/data/flat_repository_impl.dart';
import 'package:society_management/features/society/data/society_mock_data_source.dart';
import 'package:society_management/features/society/domain/flat.dart';

void main() {
  late SocietyMockDataSource dataSource;
  late FlatRepositoryImpl flatRepo;

  setUp(() {
    dataSource = SocietyMockDataSource();
    flatRepo = FlatRepositoryImpl(dataSource);
  });

  group('Flat Inventory & Filtering Logic Tests', () {
    test('Enums parse and format correctly', () {
      expect(FlatType.fromString('1_BHK'), FlatType.oneBhk);
      expect(FlatType.fromString('2 BHK'), FlatType.twoBhk);
      expect(FlatType.fromString('3_BHK'), FlatType.threeBhk);
      expect(FlatType.fromString('4_BHK'), FlatType.fourBhk);
      expect(FlatType.fromString('OTHER'), FlatType.other);

      expect(OccupancyStatus.fromString('VACANT'), OccupancyStatus.vacant);
      expect(OccupancyStatus.fromString('OCCUPIED'), OccupancyStatus.occupied);
      expect(OccupancyStatus.fromString('UNDER_MAINTENANCE'), OccupancyStatus.underMaintenance);
    });

    test('Fetch all flats for society returns populated list', () async {
      final flats = await flatRepo.getFlats(societyId: AppConstants.defaultSocietyId);
      expect(flats, isNotEmpty);
      expect(flats.length, greaterThanOrEqualTo(8));
    });

    test('Filter flats by towerId returns only flats in that tower', () async {
      final towerAFlats = await flatRepo.getFlats(
        societyId: AppConstants.defaultSocietyId,
        towerId: 'tow-001',
      );
      expect(towerAFlats.every((f) => f.towerId == 'tow-001'), isTrue);
    });

    test('Filter flats by occupancyStatus returns correct subset', () async {
      final vacantFlats = await flatRepo.getFlats(
        societyId: AppConstants.defaultSocietyId,
        occupancyStatus: OccupancyStatus.vacant,
      );
      expect(vacantFlats.every((f) => f.occupancyStatus == OccupancyStatus.vacant), isTrue);

      final occupiedFlats = await flatRepo.getFlats(
        societyId: AppConstants.defaultSocietyId,
        occupancyStatus: OccupancyStatus.occupied,
      );
      expect(occupiedFlats.every((f) => f.occupancyStatus == OccupancyStatus.occupied), isTrue);
    });

    test('Filter flats by flatType returns matching types', () async {
      final threeBhkFlats = await flatRepo.getFlats(
        societyId: AppConstants.defaultSocietyId,
        flatType: FlatType.threeBhk,
      );
      expect(threeBhkFlats.every((f) => f.flatType == FlatType.threeBhk), isTrue);
    });

    test('Search flats by flat number query', () async {
      final searchResults = await flatRepo.getFlats(
        societyId: AppConstants.defaultSocietyId,
        searchQuery: 'A-101',
      );
      expect(searchResults.length, 1);
      expect(searchResults.first.flatNumber, 'A-101');
    });

    test('Sort flats by area ascending and descending', () async {
      final ascList = await flatRepo.getFlats(
        societyId: AppConstants.defaultSocietyId,
        sortBy: 'area',
        ascending: true,
      );
      for (int i = 0; i < ascList.length - 1; i++) {
        expect(ascList[i].areaSqFt <= ascList[i + 1].areaSqFt, isTrue);
      }

      final descList = await flatRepo.getFlats(
        societyId: AppConstants.defaultSocietyId,
        sortBy: 'area',
        ascending: false,
      );
      for (int i = 0; i < descList.length - 1; i++) {
        expect(descList[i].areaSqFt >= descList[i + 1].areaSqFt, isTrue);
      }
    });

    test('Create, update, and delete flat lifecycle', () async {
      final newFlat = Flat(
        id: 'flt-test-99',
        societyId: AppConstants.defaultSocietyId,
        towerId: 'tow-001',
        floorId: 'flr-001',
        flatNumber: 'A-103',
        flatType: FlatType.twoBhk,
        areaSqFt: 1050.0,
        occupancyStatus: OccupancyStatus.vacant,
        createdAt: DateTime.now(),
      );
      await flatRepo.createFlat(newFlat);

      final fetched = await flatRepo.getFlatById('flt-test-99');
      expect(fetched.flatNumber, 'A-103');

      // Update occupancy
      final updated = fetched.copyWith(occupancyStatus: OccupancyStatus.occupied);
      await flatRepo.updateFlat(updated);
      final fetchedUpdated = await flatRepo.getFlatById('flt-test-99');
      expect(fetchedUpdated.occupancyStatus, OccupancyStatus.occupied);

      // Delete
      await flatRepo.deleteFlat('flt-test-99');
      expect(
        () => flatRepo.getFlatById('flt-test-99'),
        throwsException,
      );
    });
  });
}
