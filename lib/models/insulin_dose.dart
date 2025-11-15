import 'package:diabetes_tracker/models/history_entry.dart';

enum InsulinType { lantus, fiasp }

class InsulinDose extends HistoryEntry {
  final int? id;
  final int units;
  final InsulinType type;
  @override
  final DateTime timestamp;

  InsulinDose({
    this.id,
    required this.units,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'units': units,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory InsulinDose.fromMap(Map<String, dynamic> map) {
    return InsulinDose(
      id: map['id'],
      units: map['units'],
      type: InsulinType.values.firstWhere((e) => e.toString() == map['type']),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
