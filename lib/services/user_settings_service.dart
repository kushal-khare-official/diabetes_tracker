import 'package:shared_preferences/shared_preferences.dart';
import 'package:diabetes_tracker/models/user_settings.dart';

class UserSettingsService {
  static const _baseFiaspUnitsKey = 'baseFiaspUnits';
  static const _defaultPreviousLantusKey = 'defaultPreviousLantus';

  Future<void> saveUserSettings(UserSettings userSettings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_baseFiaspUnitsKey, userSettings.baseFiaspUnits);
    await prefs.setInt(
      _defaultPreviousLantusKey,
      userSettings.defaultPreviousLantus,
    );
  }

  Future<UserSettings> loadUserSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final baseFiaspUnits = prefs.getInt(_baseFiaspUnitsKey) ?? 8;
    final defaultPreviousLantus = prefs.getInt(_defaultPreviousLantusKey) ?? 20;

    return UserSettings(
      baseFiaspUnits: baseFiaspUnits,
      defaultPreviousLantus: defaultPreviousLantus,
    );
  }
}
