import 'package:diabetes_tracker/models/reading.dart';
import 'package:diabetes_tracker/models/insulin_dose.dart';

enum EntryType { reading, insulinDose }

class DiabetesEntry {
  final int? id;
  final EntryType entryType;
  
  // Reading fields
  final int? sugarLevel;
  final ReadingType? readingType;
  
  // Insulin dose fields
  final int? units;
  final InsulinType? insulinType;
  
  final DateTime timestamp;

  DiabetesEntry({
    this.id,
    required this.entryType,
    this.sugarLevel,
    this.readingType,
    this.units,
    this.insulinType,
    required this.timestamp,
  });

  // Factory constructor from Reading
  factory DiabetesEntry.fromReading(Reading reading) {
    return DiabetesEntry(
      id: reading.id,
      entryType: EntryType.reading,
      sugarLevel: reading.sugarLevel,
      readingType: reading.type,
      timestamp: reading.timestamp,
    );
  }

  // Factory constructor from InsulinDose
  factory DiabetesEntry.fromInsulinDose(InsulinDose dose) {
    return DiabetesEntry(
      id: dose.id,
      entryType: EntryType.insulinDose,
      units: dose.units,
      insulinType: dose.type,
      timestamp: dose.timestamp,
    );
  }

  // Convert to Reading (if applicable)
  Reading? toReading() {
    if (entryType == EntryType.reading && sugarLevel != null && readingType != null) {
      return Reading(
        id: id,
        sugarLevel: sugarLevel!,
        type: readingType!,
        timestamp: timestamp,
      );
    }
    return null;
  }

  // Convert to InsulinDose (if applicable)
  InsulinDose? toInsulinDose() {
    if (entryType == EntryType.insulinDose && units != null && insulinType != null) {
      return InsulinDose(
        id: id,
        units: units!,
        type: insulinType!,
        timestamp: timestamp,
      );
    }
    return null;
  }
}

