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

  Future<void> init([String? preferredTowerId]) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final towers = await _towerRepository.getTowers(_societyId);
      final targetTowerId = (preferredTowerId != null && towers.any((t) => t.id == preferredTowerId))
          ? preferredTowerId
          : (state.selectedTowerId != null && towers.any((t) => t.id == state.selectedTowerId)
              ? state.selectedTowerId
              : (towers.isNotEmpty ? towers.first.id : null));
      if (!mounted) return;
      state = state.copyWith(towers: towers, selectedTowerId: targetTowerId);

      if (targetTowerId != null) {
        await loadFloorsForTower(targetTowerId);
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
    state = state.copyWith(isLoading: true, selectedTowerId: towerId, errorMessage: null);
    try {
      final matchingTower = state.towers.where((t) => t.id == towerId).firstOrNull;
      final effectiveSocietyId = (matchingTower != null && matchingTower.societyId.isNotEmpty)
          ? matchingTower.societyId
          : _societyId;
      final floors = await _floorRepository.getFloors(
        societyId: effectiveSocietyId,
        towerId: towerId,
      );
      floors.sort((a, b) {
        final cmp = a.floorNumber.compareTo(b.floorNumber);
        if (cmp != 0) return cmp;
        return a.createdAt.compareTo(b.createdAt);
      });
      if (!mounted) return;
      state = state.copyWith(
        selectedTowerId: towerId,
        floors: floors,
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<int> autoGenerateFloorsForTower(Tower tower) async {
    state = state.copyWith(isLoading: true, selectedTowerId: tower.id, errorMessage: null);
    try {
      final targetSocietyId = tower.societyId.isNotEmpty ? tower.societyId : _societyId;
      final currentFloors = await _floorRepository.getFloors(
        societyId: targetSocietyId,
        towerId: tower.id,
      );
      final existingNumbers = currentFloors.map((f) => f.floorNumber).toSet();
      final now = DateTime.now();
      final newFloors = <Floor>[];

      for (int i = 1; i <= tower.floorCount; i++) {
        if (!existingNumbers.contains(i)) {
          newFloors.add(Floor(
            id: 'flr-${now.millisecondsSinceEpoch}-$i',
            societyId: targetSocietyId,
            towerId: tower.id,
            floorNumber: i,
            displayName: 'Floor $i',
            status: tower.status,
            createdAt: now.add(Duration(milliseconds: i)),
          ));
        }
      }

      List<Floor> createdFloors = [];
      if (newFloors.isNotEmpty) {
        createdFloors = await _floorRepository.createFloors(newFloors);
      }

      // Refresh from repository
      final refreshed = await _floorRepository.getFloors(
        societyId: targetSocietyId,
        towerId: tower.id,
      );
      final displayFloors = refreshed.isNotEmpty
          ? refreshed
          : (createdFloors.isNotEmpty ? [...currentFloors, ...createdFloors] : [...currentFloors, ...newFloors]);
      displayFloors.sort((a, b) {
        final cmp = a.floorNumber.compareTo(b.floorNumber);
        if (cmp != 0) return cmp;
        return a.createdAt.compareTo(b.createdAt);
      });

      if (!mounted) return newFloors.length;
      state = state.copyWith(
        selectedTowerId: tower.id,
        floors: displayFloors,
        isLoading: false,
      );
      return newFloors.length;
    } catch (e) {
      if (!mounted) return 0;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return 0;
    }
  }

  Future<bool> createFloor({
    required int floorNumber,
    required String displayName,
    required TowerStatus status,
  }) async {
    if (state.selectedTowerId == null) return false;
    try {
      final matchingTower = state.towers.where((t) => t.id == state.selectedTowerId).firstOrNull;
      final effectiveSocietyId = (matchingTower != null && matchingTower.societyId.isNotEmpty)
          ? matchingTower.societyId
          : _societyId;
      final floor = Floor(
        id: 'flr-${DateTime.now().millisecondsSinceEpoch}',
        societyId: effectiveSocietyId,
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
