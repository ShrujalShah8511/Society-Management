enum Role {
  superAdmin('SUPER_ADMIN', 'Super Administrator'),
  societyAdmin('SOCIETY_ADMIN', 'Society Administrator'),
  committeeMember('COMMITTEE_MEMBER', 'Committee Member'),
  resident('RESIDENT', 'Resident'),
  security('SECURITY', 'Security Officer'),
  staff('STAFF', 'Staff Member');

  final String code;
  final String displayName;

  const Role(this.code, this.displayName);

  static Role fromString(String? code) {
    if (code == null) return Role.resident;
    final normalized = code.trim().toUpperCase();
    return Role.values.firstWhere(
      (r) => r.code == normalized,
      orElse: () => Role.resident,
    );
  }
}

enum Permission {
  // Society management & Multi-Tenant Platform
  viewSociety('view_society'),
  editSociety('edit_society'),
  manageAllSocieties('manage_all_societies'),
  createSociety('create_society'),
  switchSociety('switch_society'),

  // Towers
  viewTowers('view_towers'),
  manageTowers('manage_towers'),

  // Floors
  viewFloors('view_floors'),
  manageFloors('manage_floors'),

  // Flats
  viewFlats('view_flats'),
  manageFlats('manage_flats'),

  // Dashboard
  viewDashboard('view_dashboard'),
  viewFullAnalytics('view_full_analytics'),

  // Profile & Settings
  editOwnProfile('edit_own_profile'),
  manageSettings('manage_settings');

  final String key;
  const Permission(this.key);
}

class RolePermissions {
  RolePermissions._();

  static const Map<Role, Set<Permission>> _rolePermissionMap = {
    Role.superAdmin: {
      Permission.viewSociety,
      Permission.editSociety,
      Permission.manageAllSocieties,
      Permission.createSociety,
      Permission.switchSociety,
      Permission.viewTowers,
      Permission.manageTowers,
      Permission.viewFloors,
      Permission.manageFloors,
      Permission.viewFlats,
      Permission.manageFlats,
      Permission.viewDashboard,
      Permission.viewFullAnalytics,
      Permission.editOwnProfile,
      Permission.manageSettings,
    },
    Role.societyAdmin: {
      Permission.viewSociety,
      Permission.editSociety,
      Permission.manageAllSocieties,
      Permission.createSociety,
      Permission.switchSociety,
      Permission.viewTowers,
      Permission.manageTowers,
      Permission.viewFloors,
      Permission.manageFloors,
      Permission.viewFlats,
      Permission.manageFlats,
      Permission.viewDashboard,
      Permission.viewFullAnalytics,
      Permission.editOwnProfile,
      Permission.manageSettings,
    },
    Role.committeeMember: {
      Permission.viewSociety,
      Permission.viewTowers,
      Permission.manageTowers,
      Permission.viewFloors,
      Permission.manageFloors,
      Permission.viewFlats,
      Permission.manageFlats,
      Permission.viewDashboard,
      Permission.editOwnProfile,
      Permission.manageSettings,
    },
    Role.resident: {
      Permission.viewSociety,
      Permission.viewTowers,
      Permission.viewFloors,
      Permission.viewFlats,
      Permission.viewDashboard,
      Permission.editOwnProfile,
      Permission.manageSettings,
    },
    Role.security: {
      Permission.viewSociety,
      Permission.viewTowers,
      Permission.viewFloors,
      Permission.viewFlats,
      Permission.viewDashboard,
      Permission.editOwnProfile,
    },
    Role.staff: {
      Permission.viewSociety,
      Permission.viewTowers,
      Permission.viewFloors,
      Permission.viewFlats,
      Permission.viewDashboard,
      Permission.editOwnProfile,
    },
  };

  static bool hasPermission(Role role, Permission permission) {
    return _rolePermissionMap[role]?.contains(permission) ?? false;
  }

  static bool canManageSociety(Role role) =>
      hasPermission(role, Permission.editSociety);

  static bool canManageTowers(Role role) =>
      hasPermission(role, Permission.manageTowers);

  static bool canManageFloors(Role role) =>
      hasPermission(role, Permission.manageFloors);

  static bool canManageFlats(Role role) =>
      hasPermission(role, Permission.manageFlats);

  static bool canManageAllSocieties(Role role) =>
      hasPermission(role, Permission.manageAllSocieties);

  static bool canCreateSociety(Role role) =>
      hasPermission(role, Permission.createSociety);
}
