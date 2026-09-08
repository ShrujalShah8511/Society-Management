import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/floor.dart';
import '../domain/floor_repository.dart';
import '../domain/tower.dart';
import '../domain/tower_repository.dart';

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

  FloorNotifier(this._floorRepository, this._towerRepository)
      : super(const FloorListState()) {
    init();
  }

  Future<void> init() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final towers = await _towerRepository.getTowers(AppConstants.defaultSocietyId);
      final defaultTowerId = towers.isNotEmpty ? towers.first.id : null;
      state = state.copyWith(towers: towers, selectedTowerId: defaultTowerId);

      if (defaultTowerId != null) {
        await loadFloorsForTower(defaultTowerId);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
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
        societyId: AppConstants.defaultSocietyId,
        towerId: towerId,
      );
      state = state.copyWith(floors: floors, isLoading: false);
    } catch (e) {
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
        societyId: AppConstants.defaultSocietyId,
        towerId: state.selectedTowerId!,
        floorNumber: floorNumber,
        displayName: displayName,
        status: status,
        createdAt: DateTime.now(),
      );
      await _floorRepository.createFloor(floor);
      await loadFloorsForTower(state.selectedTowerId!);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateFloor(Floor floor) async {
    try {
      await _floorRepository.updateFloor(floor);
      await loadFloorsForTower(floor.towerId);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteFloor(String id) async {
    if (state.selectedTowerId == null) return false;
    try {
      await _floorRepository.deleteFloor(id);
      await loadFloorsForTower(state.selectedTowerId!);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final floorNotifierProvider = StateNotifierProvider<FloorNotifier, FloorListState>((ref) {
  final floorRepo = ref.watch(floorRepositoryProvider);
  final towerRepo = ref.watch(towerRepositoryProvider);
  return FloorNotifier(floorRepo, towerRepo);
});
