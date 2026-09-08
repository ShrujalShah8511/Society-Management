import 'floor.dart';

abstract class FloorRepository {
  Future<List<Floor>> getFloors({required String societyId, required String towerId});
  Future<Floor> createFloor(Floor floor);
  Future<Floor> updateFloor(Floor floor);
  Future<void> deleteFloor(String id);
}
