import 'society.dart';

abstract class SocietyRepository {
  Future<List<Society>> getSocieties();
  Future<Society> getSocietyProfile(String societyId);
  Future<Society> createSociety(Society society);
  Future<Society> updateSocietyProfile(Society society);
  Future<void> deleteSociety(String societyId);
}
