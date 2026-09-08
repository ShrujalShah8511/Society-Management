import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/dashboard_repository.dart';
import '../domain/dashboard_stats.dart';

class DashboardState {
  final DashboardStats? stats;
  final bool isLoading;
  final String? errorMessage;

  const DashboardState({
    this.stats,
    this.isLoading = false,
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardStats? stats,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DashboardState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;

  DashboardNotifier(this._repository) : super(const DashboardState()) {
    loadStats();
  }

  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final stats = await _repository.getStats(AppConstants.defaultSocietyId);
      state = state.copyWith(stats: stats, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final dashboardNotifierProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return DashboardNotifier(repository);
});
