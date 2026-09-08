class DashboardStats {
  final int totalTowers;
  final int totalFloors;
  final int totalFlats;
  final int occupiedFlats;
  final int vacantFlats;
  final int underMaintenanceFlats;

  const DashboardStats({
    required this.totalTowers,
    required this.totalFloors,
    required this.totalFlats,
    required this.occupiedFlats,
    required this.vacantFlats,
    required this.underMaintenanceFlats,
  });

  double get occupancyRate =>
      totalFlats > 0 ? (occupiedFlats / totalFlats) * 100 : 0;
  double get vacancyRate =>
      totalFlats > 0 ? (vacantFlats / totalFlats) * 100 : 0;
}
