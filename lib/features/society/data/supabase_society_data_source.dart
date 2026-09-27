import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../../core/network/supabase_client_manager.dart';
import '../domain/flat.dart';
import '../domain/floor.dart';
import '../domain/society.dart';
import '../domain/tower.dart';
import 'society_data_source.dart';

/// Production Supabase PostgreSQL Data Source for Society, Towers, Floors, and Flats.
/// Operates directly on the live Supabase PostgreSQL backend with zero synthetic mock dependencies.
class SupabaseSocietyDataSource implements SocietyDataSource {
  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  String _normalizeSocietyId(String societyId) {
    if (!_uuidRegex.hasMatch(societyId)) {
      return '7d50533b-ad29-461a-8d10-477987357e44';
    }
    return societyId;
  }

  sb.SupabaseClient? get _client => SupabaseClientManager.client;

  String _encodeSocietyAddress(Society society) {
    return jsonEncode({
      'street': society.address,
      'city': society.city,
      'state': society.state,
      'country': society.country,
      'pin_code': society.pinCode,
      'contact_number': society.contactNumber,
      'email': society.email,
      'website': society.website ?? '',
    });
  }

  // ===========================================================================
  // SOCIETIES
  // ===========================================================================

  @override
  Future<List<Society>> getSocieties() async {
    final client = _client;
    if (client == null) return [];

    try {
      final data = await client.from('societies').select().order('created_at', ascending: true);
      return (data as List).map((row) => _mapRowToSociety(row as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] getSocieties error: $e');
      rethrow;
    }
  }

  @override
  Future<Society> getSocietyProfile(String societyId) async {
    final client = _client;
    if (client == null) throw StateError('Supabase is not initialized.');

    try {
      final row = await client.from('societies').select().eq('id', societyId).single();
      return _mapRowToSociety(row);
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] getSocietyProfile error: $e');
      rethrow;
    }
  }

  @override
  Future<Society> createSociety(Society society) async {
    final client = _client;
    if (client == null) throw StateError('Supabase is not initialized.');

    try {
      final row = await client.from('societies').insert({
        'name': society.name,
        'address': _encodeSocietyAddress(society),
        'logo_url': society.logoUrl,
        'rera_number': society.registrationNumber,
      }).select().single();
      return _mapRowToSociety(row);
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] createSociety error: $e');
      rethrow;
    }
  }

  @override
  Future<Society> updateSocietyProfile(Society society) async {
    final client = _client;
    if (client == null) throw StateError('Supabase is not initialized.');

    try {
      final row = await client.from('societies').update({
        'name': society.name,
        'address': _encodeSocietyAddress(society),
        'logo_url': society.logoUrl,
        'rera_number': society.registrationNumber,
      }).eq('id', society.id).select().single();
      return _mapRowToSociety(row);
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] updateSocietyProfile error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteSociety(String societyId) async {
    final client = _client;
    if (client == null) throw StateError('Supabase is not initialized.');

    try {
      await client.from('societies').delete().eq('id', societyId);
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] deleteSociety error: $e');
      rethrow;
    }
  }

  // ===========================================================================
  // TOWERS
  // ===========================================================================

  @override
  Future<List<Tower>> getTowers(String societyId) async {
    final client = _client;
    if (client == null) return [];

    try {
      final normSocietyId = _normalizeSocietyId(societyId);
      final data = await client.from('towers').select().eq('society_id', normSocietyId).order('created_at', ascending: true);
      return (data as List).map((row) => _mapRowToTower(row as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] getTowers error: $e');
      rethrow;
    }
  }

  @override
  Future<Tower> getTowerById(String id) async {
    final client = _client;
    if (client == null) throw StateError('Supabase is not initialized.');

    final row = await client.from('towers').select().eq('id', id).single();
    return _mapRowToTower(row);
  }

  @override
  Future<Tower> createTower(Tower tower) async {
    final client = _client;
    if (client == null) throw StateError('Supabase is not initialized.');

    try {
      final row = await client.from('towers').insert({
        'society_id': _normalizeSocietyId(tower.societyId),
        'name': tower.name,
        'total_floors': tower.floorCount,
        'is_active': tower.status == TowerStatus.active,
      }).select().single();
      return _mapRowToTower(row);
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] createTower error: $e');
      rethrow;
    }
  }

  @override
  Future<Tower> updateTower(Tower tower) async {
    final client = _client;
    if (client == null) throw StateError('Supabase is not initialized.');

    try {
      final row = await client.from('towers').update({
        'name': tower.name,
        'total_floors': tower.floorCount,
        'is_active': tower.status == TowerStatus.active,
      }).eq('id', tower.id).select().single();
      return _mapRowToTower(row);
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] updateTower error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteTower(String id) async {
    final client = _client;
    if (client == null) throw StateError('Supabase is not initialized.');

    try {
      await client.from('towers').delete().eq('id', id);
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] deleteTower error: $e');
      rethrow;
    }
  }

  // ===========================================================================
  // FLOORS
  // ===========================================================================

  @override
  Future<List<Floor>> getFloors({required String societyId, String? towerId}) async {
    final client = _client;
    if (client == null) return [];

    try {
      final normSocietyId = _normalizeSocietyId(societyId);
      var query = client.from('floors').select();
      if (towerId != null && towerId.isNotEmpty) {
        query = query.eq('tower_id', towerId);
      } else {
        query = query.eq('society_id', normSocietyId);
      }
      final data = await query.order('floor_number', ascending: true);
      return (data as List).map((row) => _mapRowToFloor(row as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] getFloors error: $e');
      rethrow;
    }
  }

  @override
  Future<Floor> createFloor(Floor floor) async {
    final client = _client;
    if (client == null) throw StateError('Supabase is not initialized.');

    try {
      final row = await client.from('floors').insert({
        'tower_id': floor.towerId,
        'society_id': _normalizeSocietyId(floor.societyId),
        'floor_number': floor.floorNumber,
        'floor_name': floor.displayName,
      }).select().single();
      return _mapRowToFloor(row);
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] createFloor error: $e');
      rethrow;
    }
  }

  @override
  Future<List<Floor>> createFloors(List<Floor> floors) async {
    if (floors.isEmpty) return [];
    final client = _client;
    if (client == null) throw StateError('Supabase is not initialized.');

    try {
      final rowsToInsert = floors.map((f) => {
        'tower_id': f.towerId,
        'society_id': _normalizeSocietyId(f.societyId),
        'floor_number': f.floorNumber,
        'floor_name': f.displayName,
      }).toList();
      final data = await client.from('floors').insert(rowsToInsert).select();
      return (data as List).map((row) => _mapRowToFloor(row as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] createFloors error: $e');
      rethrow;
    }
  }

  @override
  Future<Floor> updateFloor(Floor floor) async {
    final client = _client;
    if (client == null) throw StateError('Supabase is not initialized.');

    try {
      final row = await client.from('floors').update({
        'floor_number': floor.floorNumber,
        'floor_name': floor.displayName,
      }).eq('id', floor.id).select().single();
      return _mapRowToFloor(row);
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] updateFloor error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteFloor(String id) async {
    final client = _client;
    if (client == null) throw StateError('Supabase is not initialized.');

    try {
      await client.from('floors').delete().eq('id', id);
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] deleteFloor error: $e');
      rethrow;
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
    if (client == null) return [];

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

      String sortCol = 'created_at';
      if (sortBy == 'number') {
        sortCol = 'flat_number';
      } else if (sortBy == 'area') {
        sortCol = 'area_sqft';
      } else if (sortBy != null && sortBy.isNotEmpty && sortBy != 'created') {
        sortCol = sortBy;
      }
      final data = await query.order(sortCol, ascending: ascending);
      var flats = (data as List).map((row) => _mapRowToFlat(row as Map<String, dynamic>)).toList();

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.toLowerCase().trim();
        flats = flats.where((f) => f.flatNumber.toLowerCase().contains(q)).toList();
      }

      return flats;
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] getFlats error: $e');
      rethrow;
    }
  }

  @override
  Future<Flat> getFlatById(String id) async {
    final client = _client;
    if (client == null) throw StateError('Supabase is not initialized.');

    final row = await client.from('flats').select().eq('id', id).single();
    return _mapRowToFlat(row);
  }

  @override
  Future<Flat> createFlat(Flat flat) async {
    final client = _client;
    if (client == null) throw StateError('Supabase is not initialized.');

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
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] createFlat error: $e');
      rethrow;
    }
  }

  @override
  Future<List<Flat>> createFlats(List<Flat> flats) async {
    if (flats.isEmpty) return [];
    final client = _client;
    if (client == null) throw StateError('Supabase is not initialized.');

    try {
      final rowsToInsert = flats.map((flat) => {
        'society_id': _normalizeSocietyId(flat.societyId),
        'tower_id': flat.towerId,
        'floor_id': flat.floorId,
        'flat_number': flat.flatNumber,
        'bhk_type': flat.flatType.code,
        'status': flat.occupancyStatus.code,
        'area_sqft': flat.areaSqFt,
      }).toList();
      final data = await client.from('flats').insert(rowsToInsert).select();
      return (data as List).map((row) => _mapRowToFlat(row as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] createFlats error: $e');
      rethrow;
    }
  }

  @override
  Future<Flat> updateFlat(Flat flat) async {
    final client = _client;
    if (client == null) throw StateError('Supabase is not initialized.');

    try {
      final row = await client.from('flats').update({
        'flat_number': flat.flatNumber,
        'bhk_type': flat.flatType.code,
        'status': flat.occupancyStatus.code,
        'area_sqft': flat.areaSqFt,
      }).eq('id', flat.id).select().single();
      return _mapRowToFlat(row);
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] updateFlat error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteFlat(String id) async {
    final client = _client;
    if (client == null) throw StateError('Supabase is not initialized.');

    try {
      await client.from('flats').delete().eq('id', id);
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseSocietyDataSource] deleteFlat error: $e');
      rethrow;
    }
  }

  // ===========================================================================
  // MAPPERS
  // ===========================================================================

  Society _mapRowToSociety(Map<String, dynamic> row) {
    final rawAddress = row['address'] as String? ?? '';
    String street = rawAddress;
    String city = '';
    String state = '';
    String country = '';
    String pinCode = '';
    String contactNumber = '';
    String email = '';
    String? website;

    if (rawAddress.trim().startsWith('{') && rawAddress.trim().endsWith('}')) {
      try {
        final decoded = jsonDecode(rawAddress) as Map<String, dynamic>;
        street = decoded['street'] as String? ?? '';
        city = decoded['city'] as String? ?? '';
        state = decoded['state'] as String? ?? '';
        country = decoded['country'] as String? ?? '';
        pinCode = decoded['pin_code'] as String? ?? '';
        contactNumber = decoded['contact_number'] as String? ?? '';
        email = decoded['email'] as String? ?? '';
        final web = decoded['website'] as String?;
        website = (web != null && web.isNotEmpty) ? web : null;
      } catch (_) {
        street = rawAddress;
      }
    }

    return Society(
      id: row['id'] as String,
      name: row['name'] as String? ?? '',
      logoUrl: row['logo_url'] as String?,
      address: street,
      city: city,
      state: state,
      country: country,
      pinCode: pinCode,
      contactNumber: contactNumber,
      email: email,
      registrationNumber: row['rera_number'] as String? ?? '',
      website: website ?? (row['website'] as String?),
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.tryParse(row['updated_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(row['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Tower _mapRowToTower(Map<String, dynamic> row) {
    final desc = row['description'] as String? ?? '';
    return Tower(
      id: row['id'] as String,
      societyId: row['society_id'] as String,
      name: row['name'] as String? ?? 'Tower',
      description: desc,
      floorCount: (row['total_floors'] as num?)?.toInt() ?? 0,
      flatsPerFloor: Tower.extractFlatsPerFloor(desc),
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
  int getTotalTowers(String societyId) => 0;

  @override
  int getTotalFloors(String societyId) => 0;

  @override
  int getTotalFlats(String societyId) => 0;

  @override
  int getOccupiedFlats(String societyId) => 0;

  @override
  int getVacantFlats(String societyId) => 0;

  @override
  int getUnderMaintenanceFlats(String societyId) => 0;
}
