import 'floor.dart';

abstract class FloorRepository {
  Future<List<Floor>> getFloors({required String societyId, String? towerId});
  Future<Floor> createFloor(Floor floor);
  Future<List<Floor>> createFloors(List<Floor> floors);
  Future<Floor> updateFloor(Floor floor);
  Future<void> deleteFloor(String id);
}
