import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_errors.dart';
import '../domain/flat.dart';
import '../domain/floor.dart';
import '../domain/society.dart';
import '../domain/tower.dart';

class SocietyMockDataSource {
  late Society _society;
  final Map<String, Tower> _towers = {};
  final Map<String, Floor> _floors = {};
  final Map<String, Flat> _flats = {};

  SocietyMockDataSource() {
    _seedData();
  }

  void _seedData() {
    // 1. Seed Society
    _society = Society(
      id: AppConstants.defaultSocietyId,
      name: 'Grand Palm Heights Society',
      logoUrl: null,
      address: 'Plot 42, Palm Avenue, Sector 15',
      city: 'Mumbai',
      state: 'Maharashtra',
      country: 'India',
      pinCode: '400001',
      contactNumber: '+91 9876543210',
      email: 'contact@palmheights.org',
      registrationNumber: 'MAH/MUM/2021/4891',
      website: 'https://grandpalmheights.org',
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
    );

    // 2. Seed Towers
    final towerA = Tower(
      id: 'tow-001',
      societyId: AppConstants.defaultSocietyId,
      name: 'Tower A (Aster)',
      description: 'Main residential tower facing central park',
      floorCount: 5,
      status: TowerStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 100)),
    );

    final towerB = Tower(
      id: 'tow-002',
      societyId: AppConstants.defaultSocietyId,
      name: 'Tower B (Begonia)',
      description: 'Residential tower overlooking sports courts',
      floorCount: 4,
      status: TowerStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 95)),
    );

    final towerC = Tower(
      id: 'tow-003',
      societyId: AppConstants.defaultSocietyId,
      name: 'Tower C (Carnation)',
      description: 'North wing annex',
      floorCount: 3,
      status: TowerStatus.inactive,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    );

    _towers[towerA.id] = towerA;
    _towers[towerB.id] = towerB;
    _towers[towerC.id] = towerC;

    // 3. Seed Floors for Tower A
    final flrA1 = Floor(
      id: 'flr-001',
      societyId: AppConstants.defaultSocietyId,
      towerId: towerA.id,
      floorNumber: 1,
      displayName: 'Floor 1',
      status: TowerStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    );
    final flrA2 = Floor(
      id: 'flr-002',
      societyId: AppConstants.defaultSocietyId,
      towerId: towerA.id,
      floorNumber: 2,
      displayName: 'Floor 2',
      status: TowerStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    );
    final flrA3 = Floor(
      id: 'flr-003',
      societyId: AppConstants.defaultSocietyId,
      towerId: towerA.id,
      floorNumber: 3,
      displayName: 'Floor 3',
      status: TowerStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    );

    // Seed Floors for Tower B
    final flrB1 = Floor(
      id: 'flr-101',
      societyId: AppConstants.defaultSocietyId,
      towerId: towerB.id,
      floorNumber: 1,
      displayName: 'Floor 1',
      status: TowerStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 85)),
    );
    final flrB2 = Floor(
      id: 'flr-102',
      societyId: AppConstants.defaultSocietyId,
      towerId: towerB.id,
      floorNumber: 2,
      displayName: 'Floor 2',
      status: TowerStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 85)),
    );

    _floors[flrA1.id] = flrA1;
    _floors[flrA2.id] = flrA2;
    _floors[flrA3.id] = flrA3;
    _floors[flrB1.id] = flrB1;
    _floors[flrB2.id] = flrB2;

    // 4. Seed Flats
    final flatsList = [
      Flat(
        id: 'flt-001',
        societyId: AppConstants.defaultSocietyId,
        towerId: towerA.id,
        floorId: flrA1.id,
        flatNumber: 'A-101',
        flatType: FlatType.twoBhk,
        areaSqFt: 1100.0,
        occupancyStatus: OccupancyStatus.occupied,
        createdAt: DateTime.now().subtract(const Duration(days: 80)),
      ),
      Flat(
        id: 'flt-002',
        societyId: AppConstants.defaultSocietyId,
        towerId: towerA.id,
        floorId: flrA1.id,
        flatNumber: 'A-102',
        flatType: FlatType.threeBhk,
        areaSqFt: 1550.0,
        occupancyStatus: OccupancyStatus.vacant,
        createdAt: DateTime.now().subtract(const Duration(days: 80)),
      ),
      Flat(
        id: 'flt-003',
        societyId: AppConstants.defaultSocietyId,
        towerId: towerA.id,
        floorId: flrA2.id,
        flatNumber: 'A-201',
        flatType: FlatType.twoBhk,
        areaSqFt: 1100.0,
        occupancyStatus: OccupancyStatus.occupied,
        createdAt: DateTime.now().subtract(const Duration(days: 75)),
      ),
      Flat(
        id: 'flt-004',
        societyId: AppConstants.defaultSocietyId,
        towerId: towerA.id,
        floorId: flrA2.id,
        flatNumber: 'A-202',
        flatType: FlatType.oneBhk,
        areaSqFt: 680.0,
        occupancyStatus: OccupancyStatus.underMaintenance,
        createdAt: DateTime.now().subtract(const Duration(days: 75)),
      ),
      Flat(
        id: 'flt-005',
        societyId: AppConstants.defaultSocietyId,
        towerId: towerA.id,
        floorId: flrA3.id,
        flatNumber: 'A-301',
        flatType: FlatType.fourBhk,
        areaSqFt: 2200.0,
        occupancyStatus: OccupancyStatus.occupied,
        createdAt: DateTime.now().subtract(const Duration(days: 70)),
      ),
      Flat(
        id: 'flt-006',
        societyId: AppConstants.defaultSocietyId,
        towerId: towerB.id,
        floorId: flrB1.id,
        flatNumber: 'B-101',
        flatType: FlatType.twoBhk,
        areaSqFt: 1050.0,
        occupancyStatus: OccupancyStatus.occupied,
        createdAt: DateTime.now().subtract(const Duration(days: 65)),
      ),
      Flat(
        id: 'flt-007',
        societyId: AppConstants.defaultSocietyId,
        towerId: towerB.id,
        floorId: flrB1.id,
        flatNumber: 'B-102',
        flatType: FlatType.threeBhk,
        areaSqFt: 1480.0,
        occupancyStatus: OccupancyStatus.vacant,
        createdAt: DateTime.now().subtract(const Duration(days: 65)),
      ),
      Flat(
        id: 'flt-008',
        societyId: AppConstants.defaultSocietyId,
        towerId: towerB.id,
        floorId: flrB2.id,
        flatNumber: 'B-201',
        flatType: FlatType.twoBhk,
        areaSqFt: 1050.0,
        occupancyStatus: OccupancyStatus.vacant,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ];

    for (final flat in flatsList) {
      _flats[flat.id] = flat;
    }
  }

  // --- Society Operations ---
  Future<Society> getSocietyProfile(String societyId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _society;
  }

  Future<Society> updateSocietyProfile(Society society) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _society = society.copyWith(updatedAt: DateTime.now());
    return _society;
  }

  // --- Tower Operations ---
  Future<List<Tower>> getTowers(String societyId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _towers.values.where((t) => t.societyId == societyId).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<Tower> getTowerById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final tower = _towers[id];
    if (tower == null) throw const NotFoundFailure('Tower not found');
    return tower;
  }

  Future<Tower> createTower(Tower tower) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _towers[tower.id] = tower;
    return tower;
  }

  Future<Tower> updateTower(Tower tower) async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (!_towers.containsKey(tower.id)) throw const NotFoundFailure('Tower not found');
    _towers[tower.id] = tower;
    return tower;
  }

  Future<void> deleteTower(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    // Data integrity constraint: check if tower has child floors
    final hasFloors = _floors.values.any((f) => f.towerId == id);
    if (hasFloors) {
      throw const ValidationFailure('Cannot delete tower while it has active floors. Delete floors first.');
    }
    _towers.remove(id);
  }

  // --- Floor Operations ---
  Future<List<Floor>> getFloors({required String societyId, required String towerId}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _floors.values
        .where((f) => f.societyId == societyId && f.towerId == towerId)
        .toList()
      ..sort((a, b) => a.floorNumber.compareTo(b.floorNumber));
  }

  Future<Floor> createFloor(Floor floor) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _floors[floor.id] = floor;
    return floor;
  }

  Future<Floor> updateFloor(Floor floor) async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (!_floors.containsKey(floor.id)) throw const NotFoundFailure('Floor not found');
    _floors[floor.id] = floor;
    return floor;
  }

  Future<void> deleteFloor(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    // Data integrity constraint: check if floor has child flats
    final hasFlats = _flats.values.any((f) => f.floorId == id);
    if (hasFlats) {
      throw const ValidationFailure('Cannot delete floor while it has flats. Delete or reassign flats first.');
    }
    _floors.remove(id);
  }

  // --- Flat Operations ---
  Future<List<Flat>> getFlats({
    required String societyId,
    String? towerId,
    String? floorId,
    FlatType? flatType,
    OccupancyStatus? occupancyStatus,
    String? searchQuery,
    String? sortBy,
    bool ascending = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    var results = _flats.values.where((f) => f.societyId == societyId).toList();

    if (towerId != null && towerId.isNotEmpty) {
      results = results.where((f) => f.towerId == towerId).toList();
    }
    if (floorId != null && floorId.isNotEmpty) {
      results = results.where((f) => f.floorId == floorId).toList();
    }
    if (flatType != null) {
      results = results.where((f) => f.flatType == flatType).toList();
    }
    if (occupancyStatus != null) {
      results = results.where((f) => f.occupancyStatus == occupancyStatus).toList();
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      results = results.where((f) => f.flatNumber.toLowerCase().contains(query)).toList();
    }

    if (sortBy != null) {
      if (sortBy == 'area') {
        results.sort((a, b) => ascending
            ? a.areaSqFt.compareTo(b.areaSqFt)
            : b.areaSqFt.compareTo(a.areaSqFt));
      } else {
        // default sort by flatNumber
        results.sort((a, b) => ascending
            ? a.flatNumber.compareTo(b.flatNumber)
            : b.flatNumber.compareTo(a.flatNumber));
      }
    } else {
      results.sort((a, b) => a.flatNumber.compareTo(b.flatNumber));
    }

    return results;
  }

  Future<Flat> getFlatById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final flat = _flats[id];
    if (flat == null) throw const NotFoundFailure('Flat not found');
    return flat;
  }

  Future<Flat> createFlat(Flat flat) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _flats[flat.id] = flat;
    return flat;
  }

  Future<Flat> updateFlat(Flat flat) async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (!_flats.containsKey(flat.id)) throw const NotFoundFailure('Flat not found');
    _flats[flat.id] = flat;
    return flat;
  }

  Future<void> deleteFlat(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _flats.remove(id);
  }

  // --- Statistics helper for Dashboard ---
  int get totalTowers => _towers.values.where((t) => t.societyId == _society.id).length;
  int get totalFloors => _floors.values.where((f) => f.societyId == _society.id).length;
  int get totalFlats => _flats.values.where((f) => f.societyId == _society.id).length;
  int get occupiedFlats => _flats.values.where((f) => f.societyId == _society.id && f.occupancyStatus == OccupancyStatus.occupied).length;
  int get vacantFlats => _flats.values.where((f) => f.societyId == _society.id && f.occupancyStatus == OccupancyStatus.vacant).length;
  int get underMaintenanceFlats => _flats.values.where((f) => f.societyId == _society.id && f.occupancyStatus == OccupancyStatus.underMaintenance).length;
}
