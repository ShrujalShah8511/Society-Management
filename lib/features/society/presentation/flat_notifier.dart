import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/flat.dart';
import '../domain/flat_repository.dart';
import '../domain/floor.dart';
import '../domain/floor_repository.dart';
import '../domain/tower.dart';
import '../domain/tower_repository.dart';
import 'active_society_provider.dart';

class FlatFilterState {
  final String? selectedTowerId;
  final String? selectedFloorId;
  final FlatType? selectedFlatType;
  final OccupancyStatus? selectedOccupancyStatus;
  final String searchQuery;
  final String sortBy; // 'number' or 'area'
  final bool ascending;

  const FlatFilterState({
    this.selectedTowerId,
    this.selectedFloorId,
    this.selectedFlatType,
    this.selectedOccupancyStatus,
    this.searchQuery = '',
    this.sortBy = 'number',
    this.ascending = true,
  });

  FlatFilterState copyWith({
    String? selectedTowerId,
    bool clearTower = false,
    String? selectedFloorId,
    bool clearFloor = false,
    FlatType? selectedFlatType,
    bool clearType = false,
    OccupancyStatus? selectedOccupancyStatus,
    bool clearStatus = false,
    String? searchQuery,
    String? sortBy,
    bool? ascending,
  }) {
    return FlatFilterState(
      selectedTowerId: clearTower ? null : (selectedTowerId ?? this.selectedTowerId),
      selectedFloorId: clearFloor ? null : (selectedFloorId ?? this.selectedFloorId),
      selectedFlatType: clearType ? null : (selectedFlatType ?? this.selectedFlatType),
      selectedOccupancyStatus: clearStatus ? null : (selectedOccupancyStatus ?? this.selectedOccupancyStatus),
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }
}

class FlatListState {
  final List<Flat> flats;
  final List<Tower> towers;
  final List<Floor> floors;
  final FlatFilterState filters;
  final bool isLoading;
  final String? errorMessage;

  const FlatListState({
    this.flats = const [],
    this.towers = const [],
    this.floors = const [],
    this.filters = const FlatFilterState(),
    this.isLoading = false,
    this.errorMessage,
  });

  FlatListState copyWith({
    List<Flat>? flats,
    List<Tower>? towers,
    List<Floor>? floors,
    FlatFilterState? filters,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FlatListState(
      flats: flats ?? this.flats,
      towers: towers ?? this.towers,
      floors: floors ?? this.floors,
      filters: filters ?? this.filters,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class FlatNotifier extends StateNotifier<FlatListState> {
  final FlatRepository _flatRepository;
  final TowerRepository _towerRepository;
  final FloorRepository _floorRepository;
  final String _societyId;

  FlatNotifier(
    this._flatRepository,
    this._towerRepository,
    this._floorRepository, [
    String? societyId,
  ])  : _societyId = societyId ?? AppConstants.defaultSocietyId,
        super(const FlatListState()) {
    init();
  }

  Future<void> init() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final towers = await _towerRepository.getTowers(_societyId);
      final List<Floor> allFloors = [];
      for (final tower in towers) {
        final towerFloors = await _floorRepository.getFloors(
          societyId: _societyId,
          towerId: tower.id,
        );
        allFloors.addAll(towerFloors);
      }
      if (!mounted) return;
      state = state.copyWith(towers: towers, floors: allFloors);
      await loadFlats();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadFlats() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final flats = await _flatRepository.getFlats(
        societyId: _societyId,
        towerId: state.filters.selectedTowerId,
        floorId: state.filters.selectedFloorId,
        flatType: state.filters.selectedFlatType,
        occupancyStatus: state.filters.selectedOccupancyStatus,
        searchQuery: state.filters.searchQuery,
        sortBy: state.filters.sortBy,
        ascending: state.filters.ascending,
      );
      if (!mounted) return;
      state = state.copyWith(flats: flats, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void updateFilters(FlatFilterState newFilters) {
    state = state.copyWith(filters: newFilters);
    loadFlats();
  }

  Future<bool> createFlat(Flat flat) async {
    try {
      final flatWithSociety = flat.copyWith(societyId: _societyId);
      await _flatRepository.createFlat(flatWithSociety);
      if (!mounted) return true;
      await loadFlats();
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateFlat(Flat flat) async {
    try {
      await _flatRepository.updateFlat(flat);
      if (!mounted) return true;
      await loadFlats();
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteFlat(String id) async {
    try {
      await _flatRepository.deleteFlat(id);
      if (!mounted) return true;
      await loadFlats();
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final flatNotifierProvider = StateNotifierProvider<FlatNotifier, FlatListState>((ref) {
  final flatRepo = ref.watch(flatRepositoryProvider);
  final towerRepo = ref.watch(towerRepositoryProvider);
  final floorRepo = ref.watch(floorRepositoryProvider);
  final activeSociety = ref.watch(activeSocietyProvider).activeSociety;
  final sId = activeSociety?.id ?? AppConstants.defaultSocietyId;
  return FlatNotifier(flatRepo, towerRepo, floorRepo, sId);
});
