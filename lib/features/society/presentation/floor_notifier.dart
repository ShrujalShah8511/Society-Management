import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/floor.dart';
import '../domain/floor_repository.dart';
import '../domain/tower.dart';
import '../domain/tower_repository.dart';
import 'active_society_provider.dart';

class FloorListState {
  final List<Tower> towers;
  final String? selectedTowerId;
  final List<Floor> floors;
  final bool isLoading;
  final String? errorMessage;

  const FloorListState({
    this.towers = const [],
    this.selectedTowerId,
    this.floors = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  FloorListState copyWith({
    List<Tower>? towers,
    String? selectedTowerId,
    List<Floor>? floors,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FloorListState(
      towers: towers ?? this.towers,
      selectedTowerId: selectedTowerId ?? this.selectedTowerId,
      floors: floors ?? this.floors,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class FloorNotifier extends StateNotifier<FloorListState> {
  final FloorRepository _floorRepository;
  final TowerRepository _towerRepository;
  final String _societyId;

  FloorNotifier(this._floorRepository, this._towerRepository, [String? societyId])
      : _societyId = societyId ?? AppConstants.defaultSocietyId,
        super(const FloorListState()) {
    init();
  }

  Future<void> init() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final towers = await _towerRepository.getTowers(_societyId);
      final defaultTowerId = towers.isNotEmpty ? towers.first.id : null;
      if (!mounted) return;
      state = state.copyWith(towers: towers, selectedTowerId: defaultTowerId);

      if (defaultTowerId != null) {
        await loadFloorsForTower(defaultTowerId);
      } else {
        if (!mounted) return;
        state = state.copyWith(floors: [], isLoading: false);
      }
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> selectTower(String towerId) async {
    state = state.copyWith(selectedTowerId: towerId);
    await loadFloorsForTower(towerId);
  }

  Future<void> loadFloorsForTower(String towerId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final floors = await _floorRepository.getFloors(
        societyId: _societyId,
        towerId: towerId,
      );
      if (!mounted) return;
      state = state.copyWith(floors: floors, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> createFloor({
    required int floorNumber,
    required String displayName,
    required TowerStatus status,
  }) async {
    if (state.selectedTowerId == null) return false;
    try {
      final floor = Floor(
        id: 'flr-${DateTime.now().millisecondsSinceEpoch}',
        societyId: _societyId,
        towerId: state.selectedTowerId!,
        floorNumber: floorNumber,
        displayName: displayName,
        status: status,
        createdAt: DateTime.now(),
      );
      await _floorRepository.createFloor(floor);
      if (!mounted) return true;
      await loadFloorsForTower(state.selectedTowerId!);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateFloor(Floor floor) async {
    try {
      await _floorRepository.updateFloor(floor);
      if (!mounted) return true;
      await loadFloorsForTower(floor.towerId);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteFloor(String id) async {
    if (state.selectedTowerId == null) return false;
    try {
      await _floorRepository.deleteFloor(id);
      if (!mounted) return true;
      await loadFloorsForTower(state.selectedTowerId!);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final floorNotifierProvider = StateNotifierProvider<FloorNotifier, FloorListState>((ref) {
  final floorRepo = ref.watch(floorRepositoryProvider);
  final towerRepo = ref.watch(towerRepositoryProvider);
  final activeSociety = ref.watch(activeSocietyProvider).activeSociety;
  final sId = activeSociety?.id ?? AppConstants.defaultSocietyId;
  return FloorNotifier(floorRepo, towerRepo, sId);
});
