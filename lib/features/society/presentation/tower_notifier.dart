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

class TowerListState {
  final List<Tower> towers;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;

  const TowerListState({
    this.towers = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
  });

  List<Tower> get filteredTowers {
    if (searchQuery.isEmpty) return towers;
    final query = searchQuery.toLowerCase();
    return towers.where((t) {
      return t.name.toLowerCase().contains(query) ||
          t.description.toLowerCase().contains(query);
    }).toList();
  }

  TowerListState copyWith({
    List<Tower>? towers,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
  }) {
    return TowerListState(
      towers: towers ?? this.towers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class TowerNotifier extends StateNotifier<TowerListState> {
  final TowerRepository _repository;
  final FloorRepository? _floorRepository;
  final FlatRepository? _flatRepository;
  final String _societyId;

  TowerNotifier(
    this._repository, [
    this._floorRepository,
    this._flatRepository,
    String? societyId,
  ])  : _societyId = societyId ?? AppConstants.defaultSocietyId,
        super(const TowerListState()) {
    loadTowers();
  }

  Future<void> loadTowers([String? societyId]) async {
    final sId = societyId ?? _societyId;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getTowers(sId);
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      if (!mounted) return;
      state = state.copyWith(towers: list, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<bool> createTower({
    required String name,
    required String description,
    required int floorCount,
    required TowerStatus status,
    bool autogenerateFlats = false,
    int flatsPerFloor = 0,
    FlatType defaultFlatType = FlatType.twoBhk,
    String flatPrefix = '',
    double areaSqFt = 0.0,
  }) async {
    try {
      final now = DateTime.now();
      final newTower = Tower(
        id: 'tow-${now.millisecondsSinceEpoch}',
        societyId: _societyId,
        name: name,
        description: description,
        floorCount: floorCount,
        flatsPerFloor: flatsPerFloor > 0 ? flatsPerFloor : 3,
        status: status,
        createdAt: now,
      );
      final createdTower = await _repository.createTower(newTower);

      // Automatically generate floors Floor 1 .. Floor N
      if (_floorRepository != null && floorCount > 0) {
        final targetTowerId = createdTower.id.isNotEmpty ? createdTower.id : newTower.id;
        final targetSocietyId = createdTower.societyId.isNotEmpty ? createdTower.societyId : _societyId;
        final floorsToCreate = <Floor>[];
        for (int i = 1; i <= floorCount; i++) {
          floorsToCreate.add(Floor(
            id: 'flr-${now.millisecondsSinceEpoch}-$i',
            societyId: targetSocietyId,
            towerId: targetTowerId,
            floorNumber: i,
            displayName: 'Floor $i',
            status: status,
            createdAt: now.add(Duration(milliseconds: i)),
          ));
        }
        List<Floor> createdFloors = [];
        try {
          createdFloors = await _floorRepository!.createFloors(floorsToCreate);
        } catch (_) {}

        // Autogenerate flats per floor if requested
        if (autogenerateFlats && flatsPerFloor > 0 && _flatRepository != null) {
          final effectiveFloors = createdFloors.isNotEmpty ? createdFloors : floorsToCreate;
          final flatsToCreate = <Flat>[];
          final prefix = flatPrefix.trim();
          for (final floor in effectiveFloors) {
            final fNum = floor.floorNumber;
            for (int j = 1; j <= flatsPerFloor; j++) {
              final flatNumber = '$prefix${fNum * 100 + j}';
              flatsToCreate.add(Flat(
                id: 'flt-${now.millisecondsSinceEpoch}-${floor.id}-$j',
                societyId: targetSocietyId,
                towerId: targetTowerId,
                floorId: floor.id,
                flatNumber: flatNumber,
                flatType: defaultFlatType,
                areaSqFt: areaSqFt,
                occupancyStatus: OccupancyStatus.vacant,
                createdAt: now.add(Duration(milliseconds: fNum * 10 + j)),
              ));
            }
          }
          if (flatsToCreate.isNotEmpty) {
            try {
              await _flatRepository!.createFlats(flatsToCreate);
            } catch (_) {}
          }
        }
      }

      if (!mounted) return true;
      await loadTowers();
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateTower(Tower tower) async {
    try {
      await _repository.updateTower(tower);
      if (!mounted) return true;
      await loadTowers();
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteTower(String id) async {
    try {
      await _repository.deleteTower(id);
      if (!mounted) return true;
      await loadTowers();
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final towerNotifierProvider = StateNotifierProvider<TowerNotifier, TowerListState>((ref) {
  final repository = ref.watch(towerRepositoryProvider);
  final floorRepository = ref.watch(floorRepositoryProvider);
  final flatRepository = ref.watch(flatRepositoryProvider);
  final activeSociety = ref.watch(activeSocietyProvider).activeSociety;
  final sId = activeSociety?.id ?? AppConstants.defaultSocietyId;
  return TowerNotifier(repository, floorRepository, flatRepository, sId);
});
