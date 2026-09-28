import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../authentication/domain/user.dart';
import '../../authentication/presentation/auth_notifier.dart';
import '../../role/domain/role.dart';
import '../../society/presentation/active_society_provider.dart';

class UserManagementState {
  final List<User> users;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final Role? roleFilter;

  const UserManagementState({
    this.users = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.roleFilter,
  });

  List<User> get filteredUsers {
    return users.where((u) {
      if (roleFilter != null && u.role != roleFilter) return false;
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchesName = u.name.toLowerCase().contains(q);
        final matchesMobile = u.mobile.contains(q);
        final matchesEmail = u.email.toLowerCase().contains(q);
        final matchesId = u.id.toLowerCase().contains(q);
        final matchesFlat = (u.flatNumber ?? '').toLowerCase().contains(q);
        final matchesSociety = u.societyName.toLowerCase().contains(q);
        return matchesName || matchesMobile || matchesEmail || matchesId || matchesFlat || matchesSociety;
      }
      return true;
    }).toList();
  }

  UserManagementState copyWith({
    List<User>? users,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    Role? roleFilter,
    bool clearRoleFilter = false,
  }) {
    return UserManagementState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      roleFilter: clearRoleFilter ? null : (roleFilter ?? this.roleFilter),
    );
  }
}

class UserManagementNotifier extends StateNotifier<UserManagementState> {
  final Ref _ref;

  UserManagementNotifier(this._ref) : super(const UserManagementState()) {
    loadUsers();
    _ref.listen(authNotifierProvider, (prev, next) {
      if (prev?.user?.id != next.user?.id || prev?.user?.societyId != next.user?.societyId) {
        loadUsers();
      }
    });
  }

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final auth = _ref.read(authNotifierProvider);
      final currentUser = auth.user;
      final isSuperAdmin = auth.role == Role.superAdmin;
      final activeSociety = _ref.read(activeSocietyProvider).activeSociety;

      final societyId = isSuperAdmin ? null : (currentUser?.societyId ?? activeSociety?.id);
      final users = await _ref.read(authNotifierProvider.notifier).getUsers(societyId: societyId);

      state = state.copyWith(users: users, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setRoleFilter(Role? role) {
    if (role == null) {
      state = state.copyWith(clearRoleFilter: true);
    } else {
      state = state.copyWith(roleFilter: role);
    }
  }

  String generateUserId(String city) {
    return _ref.read(authNotifierProvider.notifier).generateNextUserId(city);
  }

  Future<User?> createUser({
    required User user,
    required String temporaryPassword,
  }) async {
    try {
      final created = await _ref.read(authNotifierProvider.notifier).createUser(
            user: user,
            temporaryPassword: temporaryPassword,
          );
      state = state.copyWith(users: [created, ...state.users]);
      return created;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _ref.read(authNotifierProvider.notifier).deleteUser(userId);
      state = state.copyWith(users: state.users.where((u) => u.id != userId).toList());
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }
}

final userManagementProvider =
    StateNotifierProvider<UserManagementNotifier, UserManagementState>((ref) {
  return UserManagementNotifier(ref);
});
