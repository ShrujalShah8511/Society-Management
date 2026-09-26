import '../../society/data/society_data_source.dart';
import '../../society/domain/flat.dart';
import '../domain/dashboard_repository.dart';
import '../domain/dashboard_stats.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final SocietyDataSource _societyDataSource;

  DashboardRepositoryImpl(this._societyDataSource);

  @override
  Future<DashboardStats> getStats(String societyId) async {
    // Computes statistics directly from live society state
    try {
      final towers = await _societyDataSource.getTowers(societyId);
      final floors = await _societyDataSource.getFloors(societyId: societyId);
      final flats = await _societyDataSource.getFlats(societyId: societyId);

      int occupied = 0;
      int vacant = 0;
      int underMaintenance = 0;
      for (final f in flats) {
        if (f.occupancyStatus == OccupancyStatus.occupied) occupied++;
        if (f.occupancyStatus == OccupancyStatus.vacant) vacant++;
        if (f.occupancyStatus == OccupancyStatus.underMaintenance) underMaintenance++;
      }

      int totalFloors = floors.length;
      if (totalFloors == 0 && towers.isNotEmpty) {
        totalFloors = towers.fold<int>(0, (sum, t) => sum + t.floorCount);
      }

      return DashboardStats(
        totalTowers: towers.length,
        totalFloors: totalFloors,
        totalFlats: flats.length,
        occupiedFlats: occupied,
        vacantFlats: vacant,
        underMaintenanceFlats: underMaintenance,
      );
    } catch (_) {
      return const DashboardStats(
        totalTowers: 0,
        totalFloors: 0,
        totalFlats: 0,
        occupiedFlats: 0,
        vacantFlats: 0,
        underMaintenanceFlats: 0,
      );
    }
  }
}
