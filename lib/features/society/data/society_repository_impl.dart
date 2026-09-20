import '../domain/society.dart';
import '../domain/society_repository.dart';
import 'society_mock_data_source.dart';

class SocietyRepositoryImpl implements SocietyRepository {
  final SocietyMockDataSource _dataSource;

  SocietyRepositoryImpl(this._dataSource);

  @override
  Future<List<Society>> getSocieties() {
    return _dataSource.getSocieties();
  }

  @override
  Future<Society> getSocietyProfile(String societyId) {
    return _dataSource.getSocietyProfile(societyId);
  }

  @override
  Future<Society> createSociety(Society society) {
    return _dataSource.createSociety(society);
  }

  @override
  Future<Society> updateSocietyProfile(Society society) {
    return _dataSource.updateSocietyProfile(society);
  }

  @override
  Future<void> deleteSociety(String societyId) {
    return _dataSource.deleteSociety(societyId);
  }
}
