import '../domain/tower.dart';
import '../domain/tower_repository.dart';
import 'society_data_source.dart';

class TowerRepositoryImpl implements TowerRepository {
  final SocietyDataSource _dataSource;

  TowerRepositoryImpl(this._dataSource);

  @override
  Future<List<Tower>> getTowers(String societyId) {
    return _dataSource.getTowers(societyId);
  }

  @override
  Future<Tower> getTowerById(String id) {
    return _dataSource.getTowerById(id);
  }

  @override
  Future<Tower> createTower(Tower tower) {
    return _dataSource.createTower(tower);
  }

  @override
  Future<Tower> updateTower(Tower tower) {
    return _dataSource.updateTower(tower);
  }

  @override
  Future<void> deleteTower(String id) {
    return _dataSource.deleteTower(id);
  }
}
