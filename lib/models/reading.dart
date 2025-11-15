import 'package:diabetes_tracker/models/history_entry.dart';

enum ReadingType { fasting, breakfast, lunch, dinner }

class Reading extends HistoryEntry {
  final int? id;
  final int sugarLevel;
  final ReadingType type;
  @override
  final DateTime timestamp;

  Reading({
    this.id,
    required this.sugarLevel,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sugar_level': sugarLevel,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Reading.fromMap(Map<String, dynamic> map) {
    return Reading(
      id: map['id'],
      sugarLevel: map['sugar_level'],
      type: ReadingType.values.firstWhere((e) => e.toString() == map['type']),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
