import '../domain/flat.dart';
import '../domain/floor.dart';
import '../domain/society.dart';
import '../domain/tower.dart';

/// Unified abstract Data Source for Society, Towers, Floors, and Flats.
/// Implemented by both [SupabaseSocietyDataSource] (production) and [SocietyMockDataSource] (offline/tests).
abstract class SocietyDataSource {
  // Societies
  Future<List<Society>> getSocieties();
  Future<Society> getSocietyProfile(String societyId);
  Future<Society> createSociety(Society society);
  Future<Society> updateSocietyProfile(Society society);
  Future<void> deleteSociety(String societyId);

  // Towers
  Future<List<Tower>> getTowers(String societyId);
  Future<Tower> getTowerById(String id);
  Future<Tower> createTower(Tower tower);
  Future<Tower> updateTower(Tower tower);
  Future<void> deleteTower(String id);

  // Floors
  Future<List<Floor>> getFloors({required String societyId, required String towerId});
  Future<Floor> createFloor(Floor floor);
  Future<Floor> updateFloor(Floor floor);
  Future<void> deleteFloor(String id);

  // Flats
  Future<List<Flat>> getFlats({
    required String societyId,
    String? towerId,
    String? floorId,
    FlatType? flatType,
    OccupancyStatus? occupancyStatus,
    String? searchQuery,
    String? sortBy,
    bool ascending = true,
  });
  Future<Flat> getFlatById(String id);
  Future<Flat> createFlat(Flat flat);
  Future<Flat> updateFlat(Flat flat);
  Future<void> deleteFlat(String id);

  // Metrics / Stats
  int getTotalTowers(String societyId);
  int getTotalFloors(String societyId);
  int getTotalFlats(String societyId);
  int getOccupiedFlats(String societyId);
  int getVacantFlats(String societyId);
  int getUnderMaintenanceFlats(String societyId);
}
