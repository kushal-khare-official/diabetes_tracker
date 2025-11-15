import 'package:diabetes_tracker/models/reading.dart';
import 'package:diabetes_tracker/models/user_settings.dart';

class InsulinCalculatorService {
  int calculateLantusDose({
    required int fastingSugarLevel,
    required int previousDayLantusUnits,
  }) {
    if (fastingSugarLevel < 80) {
      return previousDayLantusUnits - 4;
    } else if (fastingSugarLevel >= 180) {
      return previousDayLantusUnits + 4;
    } else if (fastingSugarLevel >= 130) {
      return previousDayLantusUnits + 2;
    } else {
      return previousDayLantusUnits;
    }
  }

  int calculateFiaspDose({
    required int currentSugarLevel,
    required ReadingType mealType,
    required UserSettings userSettings,
  }) {
    // Get the appropriate base value based on meal type
    int baseValue;
    switch (mealType) {
      case ReadingType.breakfast:
        baseValue = userSettings.fiaspBreakfastBase;
        break;
      case ReadingType.lunch:
        baseValue = userSettings.fiaspLunchBase;
        break;
      case ReadingType.dinner:
        baseValue = userSettings.fiaspDinnerBase;
        break;
      case ReadingType.fasting:
        // For fasting, use breakfast base as default
        baseValue = userSettings.fiaspBreakfastBase;
        break;
    }

    if (currentSugarLevel < 80) {
      return baseValue - 2;
    } else if (currentSugarLevel >= 260) {
      return baseValue + 4;
    } else if (currentSugarLevel >= 220) {
      return baseValue + 3;
    } else if (currentSugarLevel >= 180) {
      return baseValue + 2;
    } else if (currentSugarLevel >= 140) {
      return baseValue + 1;
    } else {
      return baseValue;
    }
  }
}
