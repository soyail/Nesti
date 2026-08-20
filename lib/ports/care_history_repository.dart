import '../domain/care_interaction.dart';

abstract interface class CareHistoryRepository {
  Future<List<CareInteraction>> list();
  Future<void> add(CareInteraction interaction);
  Future<void> clear();
}
