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
      totalTowers: _societyDataSource.totalTowers,
      totalFloors: _societyDataSource.totalFloors,
      totalFlats: _societyDataSource.totalFlats,
      occupiedFlats: _societyDataSource.occupiedFlats,
      vacantFlats: _societyDataSource.vacantFlats,
      underMaintenanceFlats: _societyDataSource.underMaintenanceFlats,
    );
  }
}
