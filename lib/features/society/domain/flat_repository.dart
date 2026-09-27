import 'flat.dart';

abstract class FlatRepository {
  Future<List<Flat>> getFlats({
    required String societyId,
    String? towerId,
    String? floorId,
    FlatType? flatType,
    OccupancyStatus? occupancyStatus,
    String? searchQuery,
    String? sortBy,
    bool ascending = true,
  });

  Future<Flat> getFlatById(String id);
  Future<Flat> createFlat(Flat flat);
  Future<List<Flat>> createFlats(List<Flat> flats);
  Future<Flat> updateFlat(Flat flat);
  Future<void> deleteFlat(String id);
}
