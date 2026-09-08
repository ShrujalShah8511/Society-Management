class AppConstants {
  AppConstants._();

  static const String appName = 'Society Management';
  static const String appVersion = '1.0.0 (Phase 1)';
  static const String appTagline = 'Apartment & Flat Administration System';

  // Default Tenant/Society identifier for Phase 1
  static const String defaultSocietyId = 'soc-palm-heights-001';

  // Timeouts & Networking
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Pagination & Lists
  static const int defaultPageSize = 20;
}
