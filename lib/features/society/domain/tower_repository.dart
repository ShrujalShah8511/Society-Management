import 'tower.dart';

abstract class TowerRepository {
  Future<List<Tower>> getTowers(String societyId);
  Future<Tower> getTowerById(String id);
  Future<Tower> createTower(Tower tower);
  Future<Tower> updateTower(Tower tower);
  Future<void> deleteTower(String id);
}
