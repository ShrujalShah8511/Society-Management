import '../domain/floor.dart';
import '../domain/floor_repository.dart';
import 'society_mock_data_source.dart';

class FloorRepositoryImpl implements FloorRepository {
  final SocietyMockDataSource _dataSource;

  FloorRepositoryImpl(this._dataSource);

  @override
  Future<List<Floor>> getFloors({required String societyId, required String towerId}) {
    return _dataSource.getFloors(societyId: societyId, towerId: towerId);
  }

  @override
  Future<Floor> createFloor(Floor floor) {
    return _dataSource.createFloor(floor);
  }

  @override
  Future<Floor> updateFloor(Floor floor) {
    return _dataSource.updateFloor(floor);
  }

  @override
  Future<void> deleteFloor(String id) {
    return _dataSource.deleteFloor(id);
  }
}
