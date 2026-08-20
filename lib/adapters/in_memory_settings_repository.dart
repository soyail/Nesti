import '../domain/user_preferences.dart';
import '../ports/settings_repository.dart';

class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository([this._preferences = const UserPreferences()]);

  UserPreferences _preferences;

  @override
  Future<UserPreferences> load() async => _preferences;

  @override
  Future<void> save(UserPreferences preferences) async {
    _preferences = preferences;
  }
}
