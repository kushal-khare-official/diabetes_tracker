import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:diabetes_tracker/database/reading_repository.dart';
import 'package:diabetes_tracker/database/insulin_dose_repository.dart';
import 'package:diabetes_tracker/models/reading.dart';
import 'package:diabetes_tracker/models/insulin_dose.dart';
import 'package:diabetes_tracker/models/history_entry.dart';
import 'package:diabetes_tracker/services/export_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ReadingRepository _readingRepository = ReadingRepository();
  final InsulinDoseRepository _insulinDoseRepository = InsulinDoseRepository();
  final ExportService _exportService = ExportService();

  List<HistoryEntry> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final readings = await _readingRepository.getAllReadings();
    final insulinDoses = await _insulinDoseRepository.getAllInsulinDoses();
    setState(() {
      _history = [...readings, ...insulinDoses]
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  Future<void> _exportHistory() async {
    final csvData = await _exportService.generateCsv(_history);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/diabetes_history.csv');
    await file.writeAsString(csvData);
    SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: 'Diabetes History'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: _history.isEmpty
          ? const Center(child: Text('No history data available.'))
          : ListView.builder(
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];

                if (item is Reading) {
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text('Blood Sugar: ${item.sugarLevel} mg/dL'),
                      subtitle: Text(
                        'Type: ${item.type.name}, Time: ${item.timestamp.toLocal().toString().split(' ')[1].substring(0, 5)}',
                      ),
                      trailing: Text(
                        item.timestamp.toLocal().toString().split(' ')[0],
                      ),
                    ),
                  );
                } else if (item is InsulinDose) {
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text('Insulin Dose: ${item.units} units'),
                      subtitle: Text(
                        'Type: ${item.type.name}, Time: ${item.timestamp.toLocal().toString().split(' ')[1].substring(0, 5)}',
                      ),
                      trailing: Text(
                        item.timestamp.toLocal().toString().split(' ')[0],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _exportHistory,
        child: const Icon(Icons.share),
      ),
    );
  }
}
