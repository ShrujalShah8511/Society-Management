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
      final flats = await _societyDataSource.getFlats(societyId: societyId);

      int occupied = 0;
      int vacant = 0;
      int underMaintenance = 0;
      for (final f in flats) {
        if (f.occupancyStatus == OccupancyStatus.occupied) occupied++;
        if (f.occupancyStatus == OccupancyStatus.vacant) vacant++;
        if (f.occupancyStatus == OccupancyStatus.underMaintenance) underMaintenance++;
      }

      final floorsCount = _societyDataSource.getTotalFloors(societyId);

      return DashboardStats(
        totalTowers: towers.isNotEmpty ? towers.length : _societyDataSource.getTotalTowers(societyId),
        totalFloors: floorsCount > 0 ? floorsCount : 2,
        totalFlats: flats.length,
        occupiedFlats: occupied,
        vacantFlats: vacant,
        underMaintenanceFlats: underMaintenance,
      );
    } catch (_) {
      return DashboardStats(
        totalTowers: _societyDataSource.getTotalTowers(societyId),
        totalFloors: _societyDataSource.getTotalFloors(societyId),
        totalFlats: _societyDataSource.getTotalFlats(societyId),
        occupiedFlats: _societyDataSource.getOccupiedFlats(societyId),
        vacantFlats: _societyDataSource.getVacantFlats(societyId),
        underMaintenanceFlats: _societyDataSource.getUnderMaintenanceFlats(societyId),
      );
    }
  }
}
