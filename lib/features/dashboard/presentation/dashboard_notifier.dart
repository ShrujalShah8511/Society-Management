import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/dashboard_repository.dart';
import '../domain/dashboard_stats.dart';

import '../../society/presentation/active_society_provider.dart';

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
  String? _currentSocietyId;

  DashboardNotifier(this._repository, [String? initialSocietyId])
      : _currentSocietyId = initialSocietyId,
        super(const DashboardState()) {
    loadStats(initialSocietyId);
  }

  Future<void> loadStats([String? societyId]) async {
    if (societyId != null && societyId.isNotEmpty) {
      _currentSocietyId = societyId;
    }
    final sId = (_currentSocietyId != null && _currentSocietyId!.isNotEmpty)
        ? _currentSocietyId!
        : AppConstants.defaultSocietyId;

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final stats = await _repository.getStats(sId);
      if (!mounted) return;
      state = state.copyWith(stats: stats, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final dashboardNotifierProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  final activeSociety = ref.watch(activeSocietyProvider).activeSociety;
  return DashboardNotifier(repository, activeSociety?.id);
});
