import '../../society/data/society_mock_data_source.dart';
import '../domain/dashboard_repository.dart';
import '../domain/dashboard_stats.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final SocietyMockDataSource _societyDataSource;

  DashboardRepositoryImpl(this._societyDataSource);

  @override
  Future<DashboardStats> getStats(String societyId) async {
    // Computes statistics directly from live society state
    await Future.delayed(const Duration(milliseconds: 200));
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
