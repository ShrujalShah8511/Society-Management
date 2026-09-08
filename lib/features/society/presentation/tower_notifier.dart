import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/tower.dart';
import '../domain/tower_repository.dart';

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

  TowerNotifier(this._repository) : super(const TowerListState()) {
    loadTowers();
  }

  Future<void> loadTowers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getTowers(AppConstants.defaultSocietyId);
      state = state.copyWith(towers: list, isLoading: false);
    } catch (e) {
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
  }) async {
    try {
      final newTower = Tower(
        id: 'tow-${DateTime.now().millisecondsSinceEpoch}',
        societyId: AppConstants.defaultSocietyId,
        name: name,
        description: description,
        floorCount: floorCount,
        status: status,
        createdAt: DateTime.now(),
      );
      await _repository.createTower(newTower);
      await loadTowers();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateTower(Tower tower) async {
    try {
      await _repository.updateTower(tower);
      await loadTowers();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteTower(String id) async {
    try {
      await _repository.deleteTower(id);
      await loadTowers();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final towerNotifierProvider = StateNotifierProvider<TowerNotifier, TowerListState>((ref) {
  final repository = ref.watch(towerRepositoryProvider);
  return TowerNotifier(repository);
});
