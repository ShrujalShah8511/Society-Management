import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/push_notification_service.dart';
import '../../../core/utils/browser_branding_service.dart';
import '../domain/society.dart';
import '../domain/society_repository.dart';

const Object _sentinel = Object();

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
    Object? activeSociety = _sentinel,
    List<Society>? allSocieties,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ActiveSocietyState(
      activeSociety: identical(activeSociety, _sentinel)
          ? this.activeSociety
          : activeSociety as Society?,
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
      list.sort((a, b) => (a.createdAt ?? a.updatedAt).compareTo(b.createdAt ?? b.updatedAt));
      Society? currentActive;

      if (preferredActiveId != null) {
        final matches = list.where((s) => s.id == preferredActiveId);
        currentActive = matches.isNotEmpty ? matches.first : (list.isNotEmpty ? list.first : null);
      } else if (state.activeSociety != null && list.any((s) => s.id == state.activeSociety!.id)) {
        currentActive = list.firstWhere((s) => s.id == state.activeSociety!.id);
      } else if (list.any((s) => s.id == AppConstants.defaultSocietyId)) {
        currentActive = list.firstWhere((s) => s.id == AppConstants.defaultSocietyId);
      } else if (list.isNotEmpty) {
        currentActive = list.first;
      } else {
        currentActive = null;
      }

      state = state.copyWith(
        allSocieties: list,
        activeSociety: currentActive,
        isLoading: false,
      );
      _syncBranding(currentActive);
      if (currentActive != null) {
        unawaited(PushNotificationService.instance.subscribeToSociety(currentActive.id));
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> selectSociety(String societyId) async {
    final matches = state.allSocieties.where((s) => s.id == societyId);
    final matched = matches.isNotEmpty
        ? matches.first
        : (state.allSocieties.isNotEmpty ? state.allSocieties.first : null);
    state = state.copyWith(activeSociety: matched);
    _syncBranding(matched);
    if (matched != null) {
      unawaited(PushNotificationService.instance.subscribeToSociety(matched.id));
    }
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
