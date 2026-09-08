import 'dashboard_stats.dart';

abstract class DashboardRepository {
  Future<DashboardStats> getStats(String societyId);
}
