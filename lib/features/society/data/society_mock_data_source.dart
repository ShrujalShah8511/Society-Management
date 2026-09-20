import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_errors.dart';
import '../domain/flat.dart';
import '../domain/floor.dart';
import '../domain/society.dart';
import '../domain/tower.dart';

class SocietyMockDataSource {
  final Map<String, Society> _societies = {};
  final Map<String, Tower> _towers = {};
  final Map<String, Floor> _floors = {};
  final Map<String, Flat> _flats = {};

  SocietyMockDataSource() {
    _seedData();
  }

  void _seedData() {
    // 1. Seed Flagship Society - Shyam Heights
    final shyamHeights = Society(
      id: AppConstants.defaultSocietyId,
      name: 'Shyam Heights',
      logoUrl: 'assets/images/shyam_heights_logo.png',
      address: 'Near Sargasan Cross Road, Sargasan',
      city: 'Gandhinagar',
      state: 'Gujarat',
      country: 'India',
      pinCode: '382421',
      contactNumber: '+91 9876543210',
      email: 'contact@shyamheights.in',
      registrationNumber: 'PR/GJ/GANDHINAGAR/GANDHINAGAR/OTHERS/MAA10020/130422',
      website: 'https://shyamheights.in',
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
    );

    // 2. Seed Second Society - Palm Oasis Residency
    final palmOasis = Society(
      id: 'soc-palm-002',
      name: 'Palm Oasis Residency',
      logoUrl: null,
      address: 'SG Highway, Bodakdev',
      city: 'Ahmedabad',
      state: 'Gujarat',
      country: 'India',
      pinCode: '380054',
      contactNumber: '+91 9822334455',
      email: 'admin@palmoasis.in',
      registrationNumber: 'GUJ/AHM/2022/3041',
      website: 'https://palmoasis.in',
      updatedAt: DateTime.now().subtract(const Duration(days: 45)),
    );

    _societies[shyamHeights.id] = shyamHeights;
    _societies[palmOasis.id] = palmOasis;

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

    // Seed Tower and Flat for Palm Oasis Residency
    final towerP1 = Tower(
      id: 'tow-p01',
      societyId: 'soc-palm-002',
      name: 'Tower 1 (Pavilion)',
      description: 'East wing residential suites',
      floorCount: 4,
      status: TowerStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 50)),
    );
    _towers[towerP1.id] = towerP1;

    final flrP1 = Floor(
      id: 'flr-p01',
      societyId: 'soc-palm-002',
      towerId: towerP1.id,
      floorNumber: 1,
      displayName: 'Floor 1',
      status: TowerStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    );
    _floors[flrP1.id] = flrP1;

    final fltP1 = Flat(
      id: 'flt-p01',
      societyId: 'soc-palm-002',
      towerId: towerP1.id,
      floorId: flrP1.id,
      flatNumber: 'P-101',
      flatType: FlatType.threeBhk,
      areaSqFt: 1650.0,
      occupancyStatus: OccupancyStatus.occupied,
      createdAt: DateTime.now().subtract(const Duration(days: 40)),
    );
    _flats[fltP1.id] = fltP1;
  }

  // --- Multi-Society Operations ---
  Future<List<Society>> getSocieties() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _societies.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<Society> getSocietyProfile(String societyId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final society = _societies[societyId] ?? _societies[AppConstants.defaultSocietyId];
    if (society == null) throw const NotFoundFailure('Society not found');
    return society;
  }

  Future<Society> createSociety(Society society) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _societies[society.id] = society;
    return society;
  }

  Future<Society> updateSocietyProfile(Society society) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _societies[society.id] = society.copyWith(updatedAt: DateTime.now());
    return _societies[society.id]!;
  }

  Future<void> deleteSociety(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (id == AppConstants.defaultSocietyId) {
      throw const ValidationFailure('Cannot delete default flagship society.');
    }
    _flats.removeWhere((_, f) => f.societyId == id);
    _floors.removeWhere((_, f) => f.societyId == id);
    _towers.removeWhere((_, t) => t.societyId == id);
    _societies.remove(id);
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

  // --- Statistics helper for Dashboard (Tenant Isolated) ---
  int getTotalTowers([String? societyId]) {
    final sId = societyId ?? AppConstants.defaultSocietyId;
    return _towers.values.where((t) => t.societyId == sId).length;
  }

  int getTotalFloors([String? societyId]) {
    final sId = societyId ?? AppConstants.defaultSocietyId;
    return _floors.values.where((f) => f.societyId == sId).length;
  }

  int getTotalFlats([String? societyId]) {
    final sId = societyId ?? AppConstants.defaultSocietyId;
    return _flats.values.where((f) => f.societyId == sId).length;
  }

  int getOccupiedFlats([String? societyId]) {
    final sId = societyId ?? AppConstants.defaultSocietyId;
    return _flats.values.where((f) => f.societyId == sId && f.occupancyStatus == OccupancyStatus.occupied).length;
  }

  int getVacantFlats([String? societyId]) {
    final sId = societyId ?? AppConstants.defaultSocietyId;
    return _flats.values.where((f) => f.societyId == sId && f.occupancyStatus == OccupancyStatus.vacant).length;
  }

  int getUnderMaintenanceFlats([String? societyId]) {
    final sId = societyId ?? AppConstants.defaultSocietyId;
    return _flats.values.where((f) => f.societyId == sId && f.occupancyStatus == OccupancyStatus.underMaintenance).length;
  }

  int get totalTowers => getTotalTowers();
  int get totalFloors => getTotalFloors();
  int get totalFlats => getTotalFlats();
  int get occupiedFlats => getOccupiedFlats();
  int get vacantFlats => getVacantFlats();
  int get underMaintenanceFlats => getUnderMaintenanceFlats();
}
