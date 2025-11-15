import 'package:csv/csv.dart';
import 'package:diabetes_tracker/models/history_entry.dart';
import 'package:diabetes_tracker/models/reading.dart';
import 'package:diabetes_tracker/models/insulin_dose.dart';

class ExportService {
  Future<String> generateCsv(List<HistoryEntry> history) async {
    final List<List<dynamic>> rows = [];
    rows.add([
      'Date',
      'Time',
      'Type',
      'Value',
      'Reading Type',
      'Insulin Type',
      'Units',
    ]);

    for (final entry in history) {
      if (entry is Reading) {
        rows.add([
          entry.timestamp.toIso8601String().split('T').first,
          entry.timestamp.toIso8601String().split('T').last.substring(0, 8),
          'Reading',
          entry.sugarLevel,
          entry.type.toString().split('.').last,
          '',
          '',
        ]);
      } else if (entry is InsulinDose) {
        rows.add([
          entry.timestamp.toIso8601String().split('T').first,
          entry.timestamp.toIso8601String().split('T').last.substring(0, 8),
          'Insulin Dose',
          '',
          '',
          entry.type.toString().split('.').last,
          entry.units,
        ]);
      }
    }

    return const ListToCsvConverter().convert(rows);
  }
}
