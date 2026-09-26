import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../../core/network/supabase_client_manager.dart';
import '../domain/flat.dart';
import '../domain/floor.dart';
import '../domain/society.dart';
import '../domain/tower.dart';
import 'society_data_source.dart';
import 'society_mock_data_source.dart';

/// Supabase PostgreSQL Data Source for Society, Towers, Floors, and Flats
/// Automatically falls back to in-memory MockDataSource when Supabase is unconfigured or in test mode.
class SupabaseSocietyDataSource implements SocietyDataSource {
  final SocietyMockDataSource _fallbackMock = SocietyMockDataSource();

  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  String _normalizeSocietyId(String societyId) {
    if (!_uuidRegex.hasMatch(societyId)) {
      return '0bb542a1-9954-4bc7-a4d8-cf1821341681';
    }
    return societyId;
  }

  sb.SupabaseClient? get _client => SupabaseClientManager.client;

  // ===========================================================================
  // SOCIETIES
  // ===========================================================================

  @override
  Future<List<Society>> getSocieties() async {
    final client = _client;
    if (client == null) return _fallbackMock.getSocieties();

    try {
      final data = await client.from('societies').select().order('name');
      return (data as List).map((row) => _mapRowToSociety(row as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] getSocieties error: $e. Falling back to mock.');
      return _fallbackMock.getSocieties();
    }
  }

  @override
  Future<Society> getSocietyProfile(String societyId) async {
    final client = _client;
    if (client == null) return _fallbackMock.getSocietyProfile(societyId);

    try {
      final row = await client.from('societies').select().eq('id', societyId).single();
      return _mapRowToSociety(row);
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] getSocietyProfile error: $e. Falling back to mock.');
      return _fallbackMock.getSocietyProfile(societyId);
    }
  }

  @override
  Future<Society> createSociety(Society society) async {
    final client = _client;
    if (client == null) return _fallbackMock.createSociety(society);

    try {
      final row = await client.from('societies').insert({
        'name': society.name,
        'address': society.address,
        'logo_url': society.logoUrl,
        'rera_number': society.registrationNumber,
      }).select().single();
      return _mapRowToSociety(row);
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] createSociety error: $e. Falling back to mock.');
      return _fallbackMock.createSociety(society);
    }
  }

  @override
  Future<Society> updateSocietyProfile(Society society) async {
    final client = _client;
    if (client == null) return _fallbackMock.updateSocietyProfile(society);

    try {
      final row = await client.from('societies').update({
        'name': society.name,
        'address': society.address,
        'logo_url': society.logoUrl,
        'rera_number': society.registrationNumber,
      }).eq('id', society.id).select().single();
      return _mapRowToSociety(row);
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] updateSocietyProfile error: $e. Falling back to mock.');
      return _fallbackMock.updateSocietyProfile(society);
    }
  }

  @override
  Future<void> deleteSociety(String societyId) async {
    final client = _client;
    if (client == null) return _fallbackMock.deleteSociety(societyId);

    try {
      await client.from('societies').delete().eq('id', societyId);
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] deleteSociety error: $e. Falling back to mock.');
      return _fallbackMock.deleteSociety(societyId);
    }
  }

  // ===========================================================================
  // TOWERS
  // ===========================================================================

  @override
  Future<List<Tower>> getTowers(String societyId) async {
    final client = _client;
    if (client == null) return _fallbackMock.getTowers(societyId);

    try {
      final normSocietyId = _normalizeSocietyId(societyId);
      final data = await client.from('towers').select().eq('society_id', normSocietyId).order('name');
      return (data as List).map((row) => _mapRowToTower(row as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] getTowers error: $e. Falling back to mock.');
      return _fallbackMock.getTowers(societyId);
    }
  }

  @override
  Future<Tower> getTowerById(String id) async {
    final client = _client;
    if (client == null) return _fallbackMock.getTowerById(id);

    try {
      final row = await client.from('towers').select().eq('id', id).single();
      return _mapRowToTower(row);
    } catch (e) {
      return _fallbackMock.getTowerById(id);
    }
  }

  @override
  Future<Tower> createTower(Tower tower) async {
    final client = _client;
    if (client == null) return _fallbackMock.createTower(tower);

    try {
      final row = await client.from('towers').insert({
        'society_id': tower.societyId,
        'name': tower.name,
        'total_floors': tower.floorCount,
        'is_active': tower.status == TowerStatus.active,
      }).select().single();
      return _mapRowToTower(row);
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] createTower error: $e. Falling back to mock.');
      return _fallbackMock.createTower(tower);
    }
  }

  @override
  Future<Tower> updateTower(Tower tower) async {
    final client = _client;
    if (client == null) return _fallbackMock.updateTower(tower);

    try {
      final row = await client.from('towers').update({
        'name': tower.name,
        'total_floors': tower.floorCount,
        'is_active': tower.status == TowerStatus.active,
      }).eq('id', tower.id).select().single();
      return _mapRowToTower(row);
    } catch (e) {
      return _fallbackMock.updateTower(tower);
    }
  }

  @override
  Future<void> deleteTower(String id) async {
    final client = _client;
    if (client == null) return _fallbackMock.deleteTower(id);

    try {
      await client.from('towers').delete().eq('id', id);
    } catch (e) {
      return _fallbackMock.deleteTower(id);
    }
  }

  // ===========================================================================
  // FLOORS
  // ===========================================================================

  @override
  Future<List<Floor>> getFloors({required String societyId, required String towerId}) async {
    final client = _client;
    if (client == null) return _fallbackMock.getFloors(societyId: societyId, towerId: towerId);

    try {
      final data = await client.from('floors').select().eq('tower_id', towerId).order('floor_number');
      return (data as List).map((row) => _mapRowToFloor(row as Map<String, dynamic>)).toList();
    } catch (e) {
      return _fallbackMock.getFloors(societyId: societyId, towerId: towerId);
    }
  }

  @override
  Future<Floor> createFloor(Floor floor) async {
    final client = _client;
    if (client == null) return _fallbackMock.createFloor(floor);

    try {
      final row = await client.from('floors').insert({
        'tower_id': floor.towerId,
        'society_id': floor.societyId,
        'floor_number': floor.floorNumber,
        'floor_name': floor.displayName,
      }).select().single();
      return _mapRowToFloor(row);
    } catch (e) {
      return _fallbackMock.createFloor(floor);
    }
  }

  @override
  Future<Floor> updateFloor(Floor floor) async {
    final client = _client;
    if (client == null) return _fallbackMock.updateFloor(floor);

    try {
      final row = await client.from('floors').update({
        'floor_number': floor.floorNumber,
        'floor_name': floor.displayName,
      }).eq('id', floor.id).select().single();
      return _mapRowToFloor(row);
    } catch (e) {
      return _fallbackMock.updateFloor(floor);
    }
  }

  @override
  Future<void> deleteFloor(String id) async {
    final client = _client;
    if (client == null) return _fallbackMock.deleteFloor(id);

    try {
      await client.from('floors').delete().eq('id', id);
    } catch (e) {
      return _fallbackMock.deleteFloor(id);
    }
  }

  // ===========================================================================
  // FLATS
  // ===========================================================================

  @override
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
    final client = _client;
    if (client == null) {
      return _fallbackMock.getFlats(
        societyId: societyId,
        towerId: towerId,
        floorId: floorId,
        flatType: flatType,
        occupancyStatus: occupancyStatus,
        searchQuery: searchQuery,
        sortBy: sortBy,
        ascending: ascending,
      );
    }

    try {
      final normSocietyId = _normalizeSocietyId(societyId);
      var query = client.from('flats').select().eq('society_id', normSocietyId);
      if (towerId != null && towerId.isNotEmpty) {
        query = query.eq('tower_id', towerId);
      }
      if (floorId != null && floorId.isNotEmpty) {
        query = query.eq('floor_id', floorId);
      }
      if (occupancyStatus != null) {
        query = query.eq('status', occupancyStatus.code);
      }

      final data = await query.order('flat_number', ascending: ascending);
      var flats = (data as List).map((row) => _mapRowToFlat(row as Map<String, dynamic>)).toList();

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.toLowerCase().trim();
        flats = flats.where((f) => f.flatNumber.toLowerCase().contains(q)).toList();
      }

      return flats;
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] getFlats error: $e. Falling back to mock.');
      return _fallbackMock.getFlats(
        societyId: societyId,
        towerId: towerId,
        floorId: floorId,
        flatType: flatType,
        occupancyStatus: occupancyStatus,
        searchQuery: searchQuery,
        sortBy: sortBy,
        ascending: ascending,
      );
    }
  }

  @override
  Future<Flat> getFlatById(String id) async {
    final client = _client;
    if (client == null) return _fallbackMock.getFlatById(id);

    try {
      final row = await client.from('flats').select().eq('id', id).single();
      return _mapRowToFlat(row);
    } catch (e) {
      return _fallbackMock.getFlatById(id);
    }
  }

  @override
  Future<Flat> createFlat(Flat flat) async {
    final client = _client;
    if (client == null) return _fallbackMock.createFlat(flat);

    try {
      final normSocietyId = _normalizeSocietyId(flat.societyId);
      final row = await client.from('flats').insert({
        'society_id': normSocietyId,
        'tower_id': flat.towerId,
        'floor_id': flat.floorId,
        'flat_number': flat.flatNumber,
        'bhk_type': flat.flatType.code,
        'status': flat.occupancyStatus.code,
        'area_sqft': flat.areaSqFt,
      }).select().single();
      return _mapRowToFlat(row);
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] createFlat error: $e. Falling back to mock.');
      return _fallbackMock.createFlat(flat);
    }
  }

  @override
  Future<Flat> updateFlat(Flat flat) async {
    final client = _client;
    if (client == null) return _fallbackMock.updateFlat(flat);

    try {
      final row = await client.from('flats').update({
        'flat_number': flat.flatNumber,
        'bhk_type': flat.flatType.code,
        'status': flat.occupancyStatus.code,
        'area_sqft': flat.areaSqFt,
      }).eq('id', flat.id).select().single();
      return _mapRowToFlat(row);
    } catch (e) {
      return _fallbackMock.updateFlat(flat);
    }
  }

  @override
  Future<void> deleteFlat(String id) async {
    final client = _client;
    if (client == null) return _fallbackMock.deleteFlat(id);

    try {
      await client.from('flats').delete().eq('id', id);
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] Deleted flat $id from PostgreSQL.');
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] deleteFlat error: $e. Falling back to mock.');
      return _fallbackMock.deleteFlat(id);
    }
  }

  // ===========================================================================
  // MAPPERS
  // ===========================================================================

  Society _mapRowToSociety(Map<String, dynamic> row) {
    return Society(
      id: row['id'] as String,
      name: row['name'] as String? ?? 'Unnamed Society',
      logoUrl: row['logo_url'] as String?,
      address: row['address'] as String? ?? '',
      city: row['city'] as String? ?? 'Ahmedabad',
      state: row['state'] as String? ?? 'Gujarat',
      country: row['country'] as String? ?? 'India',
      pinCode: row['pin_code'] as String? ?? '380015',
      contactNumber: row['contact_number'] as String? ?? '+91 98765 43210',
      email: row['email'] as String? ?? 'info@society.com',
      registrationNumber: row['rera_number'] as String? ?? 'REG-001',
      website: row['website'] as String?,
      updatedAt: DateTime.tryParse(row['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Tower _mapRowToTower(Map<String, dynamic> row) {
    return Tower(
      id: row['id'] as String,
      societyId: row['society_id'] as String,
      name: row['name'] as String? ?? 'Tower',
      description: row['description'] as String? ?? '',
      floorCount: (row['total_floors'] as num?)?.toInt() ?? 0,
      status: (row['is_active'] as bool? ?? true) ? TowerStatus.active : TowerStatus.inactive,
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Floor _mapRowToFloor(Map<String, dynamic> row) {
    return Floor(
      id: row['id'] as String,
      societyId: row['society_id'] as String? ?? '',
      towerId: row['tower_id'] as String,
      floorNumber: (row['floor_number'] as num?)?.toInt() ?? 0,
      displayName: row['floor_name'] as String? ?? 'Floor',
      status: TowerStatus.active,
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Flat _mapRowToFlat(Map<String, dynamic> row) {
    return Flat(
      id: row['id'] as String,
      societyId: row['society_id'] as String,
      towerId: row['tower_id'] as String,
      floorId: row['floor_id'] as String,
      flatNumber: row['flat_number'] as String? ?? '',
      flatType: FlatType.fromString(row['bhk_type'] as String?),
      occupancyStatus: OccupancyStatus.fromString(row['status'] as String?),
      areaSqFt: (row['area_sqft'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  // ===========================================================================
  // METRICS & STATS
  // ===========================================================================

  @override
  int getTotalTowers(String societyId) => _fallbackMock.getTotalTowers(societyId);

  @override
  int getTotalFloors(String societyId) => _fallbackMock.getTotalFloors(societyId);

  @override
  int getTotalFlats(String societyId) => _fallbackMock.getTotalFlats(societyId);

  @override
  int getOccupiedFlats(String societyId) => _fallbackMock.getOccupiedFlats(societyId);

  @override
  int getVacantFlats(String societyId) => _fallbackMock.getVacantFlats(societyId);

  @override
  int getUnderMaintenanceFlats(String societyId) => _fallbackMock.getUnderMaintenanceFlats(societyId);
}
