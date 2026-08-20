import '../domain/care_interaction.dart';
import '../ports/care_history_repository.dart';

class InMemoryCareHistoryRepository implements CareHistoryRepository {
  final List<CareInteraction> _items = [];

  @override
  Future<void> add(CareInteraction interaction) async {
    _items.add(interaction);
  }

  @override
  Future<void> clear() async => _items.clear();

  @override
  Future<List<CareInteraction>> list() async => List.unmodifiable(_items);
}
