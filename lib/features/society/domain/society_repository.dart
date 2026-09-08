import 'society.dart';

abstract class SocietyRepository {
  Future<Society> getSocietyProfile(String societyId);
  Future<Society> updateSocietyProfile(Society society);
}
