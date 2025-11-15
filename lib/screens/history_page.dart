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

class _CombinedEntry {
  final Reading? reading;
  final InsulinDose? insulinDose;
  final DateTime timestamp;

  _CombinedEntry({
    this.reading,
    this.insulinDose,
    required this.timestamp,
  });

  bool get hasReading => reading != null;
  bool get hasInsulin => insulinDose != null;
  bool get canDelete => (reading?.id != null) || (insulinDose?.id != null);
}

class _HistoryPageState extends State<HistoryPage> {
  final ReadingRepository _readingRepository = ReadingRepository();
  final InsulinDoseRepository _insulinDoseRepository = InsulinDoseRepository();
  final ExportService _exportService = ExportService();

  List<HistoryEntry> _history = [];
  Map<String, List<_CombinedEntry>> _groupedHistory = {};
  List<String> _sortedDateKeys = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final readings = await _readingRepository.getAllReadings();
    final insulinDoses = await _insulinDoseRepository.getAllInsulinDoses();
    
    // Combine readings and insulin doses that are close in time (within 2 hours)
    final List<_CombinedEntry> combinedEntries = [];
    final List<Reading> unpairedReadings = List.from(readings);
    final List<InsulinDose> unpairedDoses = List.from(insulinDoses);
    
    // Sort by timestamp
    unpairedReadings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    unpairedDoses.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    // Try to pair readings with insulin doses within 2 hours
    for (final reading in unpairedReadings) {
      InsulinDose? matchedDose;
      for (final dose in unpairedDoses) {
        final timeDiff = (reading.timestamp.difference(dose.timestamp).abs().inHours);
        if (timeDiff <= 2) {
          matchedDose = dose;
          unpairedDoses.remove(dose);
          break;
        }
      }
      
      combinedEntries.add(_CombinedEntry(
        reading: reading,
        insulinDose: matchedDose,
        timestamp: reading.timestamp,
      ));
    }
    
    // Add remaining unpaired insulin doses
    for (final dose in unpairedDoses) {
      combinedEntries.add(_CombinedEntry(
        reading: null,
        insulinDose: dose,
        timestamp: dose.timestamp,
      ));
    }
    
    // Sort all combined entries by timestamp
    combinedEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    // Group entries by date (YYYY-MM-DD)
    final Map<String, List<_CombinedEntry>> grouped = {};
    for (final entry in combinedEntries) {
      final dateKey = _getDateKey(entry.timestamp);
      grouped.putIfAbsent(dateKey, () => []).add(entry);
    }
    
    // Sort date keys in descending order (newest first)
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    
    setState(() {
      _history = [...readings, ...insulinDoses];
      _groupedHistory = grouped;
      _sortedDateKeys = sortedKeys;
    });
  }

  String _getDateKey(DateTime timestamp) {
    final local = timestamp.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }

  String _formatDate(String dateKey) {
    final parts = dateKey.split('-');
    final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else {
      return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime timestamp) {
    final local = timestamp.toLocal();
    final hour = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        elevation: 0,
      ),
      body: _groupedHistory.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No history data available.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _sortedDateKeys.length,
              itemBuilder: (context, index) {
                final dateKey = _sortedDateKeys[index];
                final entries = _groupedHistory[dateKey]!;
                
                // Sort entries by time within the same date (newest first)
                entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Text(
                        _formatDate(dateKey),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    // Entries for this date
                    ...entries.map((entry) {
                      return _buildCombinedCard(entry, theme, colorScheme);
                    }),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _exportHistory,
        child: const Icon(Icons.share),
      ),
    );
  }

  Future<void> _deleteEntry(_CombinedEntry entry) async {
    final List<String> itemsToDelete = [];
    if (entry.reading != null) {
      itemsToDelete.add('blood sugar reading (${entry.reading!.sugarLevel} mg/dL)');
    }
    if (entry.insulinDose != null) {
      itemsToDelete.add('${entry.insulinDose!.type.name} insulin dose (${entry.insulinDose!.units} units)');
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text(
          'Are you sure you want to delete ${itemsToDelete.join(' and ')}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Delete both reading and insulin dose if they exist
      if (entry.reading?.id != null) {
        await _readingRepository.deleteReading(entry.reading!.id!);
      }
      if (entry.insulinDose?.id != null) {
        await _insulinDoseRepository.deleteInsulinDose(entry.insulinDose!.id!);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry deleted')),
        );
        _loadHistory();
      }
    }
  }

  Widget _buildCombinedCard(_CombinedEntry entry, ThemeData theme, ColorScheme colorScheme) {
    final hasReading = entry.hasReading;
    final hasInsulin = entry.hasInsulin;
    
    // Use the earlier timestamp if both exist, otherwise use the available one
    final displayTime = hasReading && hasInsulin
        ? (entry.reading!.timestamp.isBefore(entry.insulinDose!.timestamp)
            ? entry.reading!.timestamp
            : entry.insulinDose!.timestamp)
        : (hasReading ? entry.reading!.timestamp : entry.insulinDose!.timestamp);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with time and delete button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(displayTime),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                Row(
                  children: [
                    if (hasReading)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          entry.reading!.type.name.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    // Single delete button
                    if (entry.canDelete)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: colorScheme.error,
                        onPressed: () => _deleteEntry(entry),
                        tooltip: 'Delete entry',
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Content row with Sugar and Insulin
            Row(
              children: [
                // Blood Sugar section
                if (hasReading)
                  Expanded(
                    child: _buildInfoSection(
                      icon: Icons.water_drop,
                      iconColor: const Color(0xFF00BCD4),
                      label: 'Blood Sugar',
                      value: '${entry.reading!.sugarLevel} mg/dL',
                      theme: theme,
                      colorScheme: colorScheme,
                    ),
                  ),
                if (hasReading && hasInsulin) const SizedBox(width: 16),
                // Insulin Dose section
                if (hasInsulin)
                  Expanded(
                    child: _buildInfoSection(
                      icon: Icons.medication,
                      iconColor: const Color(0xFF9C27B0),
                      label: 'Insulin Dose',
                      value: '${entry.insulinDose!.units} units',
                      theme: theme,
                      colorScheme: colorScheme,
                      badge: entry.insulinDose!.type.name.toUpperCase(),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required ThemeData theme,
    required ColorScheme colorScheme,
    String? badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          if (badge != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.8),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
