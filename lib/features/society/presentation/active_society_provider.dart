import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/push_notification_service.dart';
import '../../../core/utils/browser_branding_service.dart';
import '../domain/society.dart';
import '../domain/society_repository.dart';

class ActiveSocietyState {
  final Society? activeSociety;
  final List<Society> allSocieties;
  final bool isLoading;
  final String? errorMessage;

  const ActiveSocietyState({
    this.activeSociety,
    this.allSocieties = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ActiveSocietyState copyWith({
    Society? activeSociety,
    List<Society>? allSocieties,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ActiveSocietyState(
      activeSociety: activeSociety ?? this.activeSociety,
      allSocieties: allSocieties ?? this.allSocieties,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ActiveSocietyNotifier extends StateNotifier<ActiveSocietyState> {
  final SocietyRepository _repository;

  ActiveSocietyNotifier(this._repository) : super(const ActiveSocietyState()) {
    loadSocieties();
  }

  void _syncBranding(Society? society) {
    if (society != null) {
      BrowserBrandingService.updateBranding(
        title: '${society.name} — Society Management',
        logoUrl: society.logoUrl,
      );
    } else {
      BrowserBrandingService.updateBranding(
        title: 'Society Management Platform',
        logoUrl: null,
      );
    }
  }

  Future<void> loadSocieties({String? preferredActiveId}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getSocieties();
      Society? currentActive = state.activeSociety;

      if (preferredActiveId != null) {
        currentActive = list.firstWhere(
          (s) => s.id == preferredActiveId,
          orElse: () => list.isNotEmpty ? list.first : null as dynamic,
        );
      } else if (currentActive == null || !list.any((s) => s.id == currentActive?.id)) {
        currentActive = list.firstWhere(
          (s) => s.id == AppConstants.defaultSocietyId,
          orElse: () => list.isNotEmpty ? list.first : null as dynamic,
        );
      } else {
        // Refresh currently active society from latest list
        currentActive = list.firstWhere(
          (s) => s.id == currentActive?.id,
          orElse: () => list.isNotEmpty ? list.first : null as dynamic,
        );
      }

      state = state.copyWith(
        allSocieties: list,
        activeSociety: currentActive,
        isLoading: false,
      );
      _syncBranding(currentActive);
      unawaited(PushNotificationService.instance.subscribeToSociety(currentActive.id));
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> selectSociety(String societyId) async {
    final matched = state.allSocieties.firstWhere(
      (s) => s.id == societyId,
      orElse: () => state.activeSociety ?? state.allSocieties.first,
    );
    state = state.copyWith(activeSociety: matched);
    _syncBranding(matched);
    unawaited(PushNotificationService.instance.subscribeToSociety(matched.id));
  }

  Future<Society?> createSociety(Society society) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final created = await _repository.createSociety(society);
      await loadSocieties(preferredActiveId: created.id);
      return created;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<bool> deleteSociety(String societyId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final wasActive = state.activeSociety?.id == societyId;
      await _repository.deleteSociety(societyId);
      await loadSocieties(
        preferredActiveId: wasActive ? null : state.activeSociety?.id,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

final activeSocietyProvider =
    StateNotifierProvider<ActiveSocietyNotifier, ActiveSocietyState>((ref) {
  final repository = ref.watch(societyRepositoryProvider);
  return ActiveSocietyNotifier(repository);
});
