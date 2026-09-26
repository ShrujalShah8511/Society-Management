import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../core/storage/file_storage_service.dart';
import '../domain/society.dart';
import '../domain/society_repository.dart';
import 'active_society_provider.dart';

const Object _profileSentinel = Object();

class SocietyProfileState {
  final Society? society;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  const SocietyProfileState({
    this.society,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  SocietyProfileState copyWith({
    Object? society = _profileSentinel,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
  }) {
    return SocietyProfileState(
      society: identical(society, _profileSentinel) ? this.society : society as Society?,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class SocietyProfileNotifier extends StateNotifier<SocietyProfileState> {
  final SocietyRepository _repository;
  final FileStorageService _fileStorageService;

  SocietyProfileNotifier(
    this._repository,
    this._fileStorageService, [
    Society? initialSociety,
  ]) : super(SocietyProfileState(society: initialSociety)) {
    if (initialSociety != null) {
      loadProfile(initialSociety.id);
    }
  }

  Future<void> loadProfile([String? societyId]) async {
    final targetId = (societyId != null && societyId.isNotEmpty)
        ? societyId
        : state.society?.id;
    if (targetId == null) {
      state = state.copyWith(society: null, isLoading: false);
      return;
    }
    state = state.copyWith(isLoading: state.society == null, errorMessage: null);
    try {
      final society = await _repository.getSocietyProfile(targetId);
      state = state.copyWith(society: society, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> updateProfile(Society updatedSociety) async {
    state = state.copyWith(isSaving: true, errorMessage: null, successMessage: null);
    try {
      final saved = await _repository.updateSocietyProfile(updatedSociety);
      state = state.copyWith(
        society: saved,
        isSaving: false,
        successMessage: 'Society profile updated successfully.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }

  FileStorageService get fileStorageService => _fileStorageService;
}

final societyProfileNotifierProvider =
    StateNotifierProvider<SocietyProfileNotifier, SocietyProfileState>((ref) {
  final repository = ref.watch(societyRepositoryProvider);
  final fileStorage = ref.watch(fileStorageServiceProvider);
  final activeSociety = ref.watch(activeSocietyProvider).activeSociety;
  return SocietyProfileNotifier(repository, fileStorage, activeSociety);
});
