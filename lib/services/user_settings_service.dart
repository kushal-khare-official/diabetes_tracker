import 'package:shared_preferences/shared_preferences.dart';
import 'package:diabetes_tracker/models/user_settings.dart';

class UserSettingsService {
  static const _fiaspBreakfastBaseKey = 'fiaspBreakfastBase';
  static const _fiaspLunchBaseKey = 'fiaspLunchBase';
  static const _fiaspDinnerBaseKey = 'fiaspDinnerBase';
  static const _defaultPreviousLantusKey = 'defaultPreviousLantus';

  Future<void> saveUserSettings(UserSettings userSettings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_fiaspBreakfastBaseKey, userSettings.fiaspBreakfastBase);
    await prefs.setInt(_fiaspLunchBaseKey, userSettings.fiaspLunchBase);
    await prefs.setInt(_fiaspDinnerBaseKey, userSettings.fiaspDinnerBase);
    await prefs.setInt(
      _defaultPreviousLantusKey,
      userSettings.defaultPreviousLantus,
    );
  }

  Future<UserSettings> loadUserSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Try to load new separate values, fallback to old single value for migration
    final oldBaseFiaspUnits = prefs.getInt('baseFiaspUnits');
    final fiaspBreakfastBase = prefs.getInt(_fiaspBreakfastBaseKey) ?? oldBaseFiaspUnits ?? 8;
    final fiaspLunchBase = prefs.getInt(_fiaspLunchBaseKey) ?? oldBaseFiaspUnits ?? 8;
    final fiaspDinnerBase = prefs.getInt(_fiaspDinnerBaseKey) ?? oldBaseFiaspUnits ?? 6;
    final defaultPreviousLantus = prefs.getInt(_defaultPreviousLantusKey) ?? 20;

    return UserSettings(
      fiaspBreakfastBase: fiaspBreakfastBase,
      fiaspLunchBase: fiaspLunchBase,
      fiaspDinnerBase: fiaspDinnerBase,
      defaultPreviousLantus: defaultPreviousLantus,
    );
  }
}
