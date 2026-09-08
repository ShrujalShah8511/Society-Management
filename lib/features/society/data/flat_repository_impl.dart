import '../domain/flat.dart';
import '../domain/flat_repository.dart';
import 'society_mock_data_source.dart';

class FlatRepositoryImpl implements FlatRepository {
  final SocietyMockDataSource _dataSource;

  FlatRepositoryImpl(this._dataSource);

  @override
  Future<List<Flat>> getFlats({
    required String societyId,
    String? towerId,
    String? floorId,
    FlatType? flatType,
    OccupancyStatus? occupancyStatus,
    String? searchQuery,
    String? sortBy,
    bool ascending = true,
  }) {
    return _dataSource.getFlats(
      societyId: societyId,
      towerId: towerId,
      floorId: floorId,
      flatType: flatType,
      occupancyStatus: occupancyStatus,
      searchQuery: searchQuery,
      sortBy: sortBy,
      ascending: ascending,
    );
  }

  @override
  Future<Flat> getFlatById(String id) {
    return _dataSource.getFlatById(id);
  }

  @override
  Future<Flat> createFlat(Flat flat) {
    return _dataSource.createFlat(flat);
  }

  @override
  Future<Flat> updateFlat(Flat flat) {
    return _dataSource.updateFlat(flat);
  }

  @override
  Future<void> deleteFlat(String id) {
    return _dataSource.deleteFlat(id);
  }
}
