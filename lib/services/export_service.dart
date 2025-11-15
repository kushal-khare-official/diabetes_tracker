import 'package:diabetes_tracker/models/history_entry.dart';
import 'package:diabetes_tracker/models/reading.dart';
import 'package:diabetes_tracker/models/insulin_dose.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ExportService {
  Future<void> generateAndSharePdf(List<HistoryEntry> history) async {
    final pdf = pw.Document();

    // Group entries by date
    final Map<String, List<HistoryEntry>> groupedByDate = {};
    for (final entry in history) {
      final dateKey = entry.timestamp.toLocal().toString().split(' ')[0];
      groupedByDate.putIfAbsent(dateKey, () => []).add(entry);
    }

    // Sort dates
    final sortedDates = groupedByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        orientation: pw.PageOrientation.landscape,
        build: (pw.Context context) {
          return [
            // Title
            pw.Header(
              level: 0,
              child: pw.Text(
                'Diabetes Tracker History',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            // Table with one row per date
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.2),
                1: const pw.FlexColumnWidth(1.0),
                2: const pw.FlexColumnWidth(1.0),
                3: const pw.FlexColumnWidth(1.0),
                4: const pw.FlexColumnWidth(1.0),
                5: const pw.FlexColumnWidth(1.0),
                6: const pw.FlexColumnWidth(1.0),
                7: const pw.FlexColumnWidth(1.0),
                8: const pw.FlexColumnWidth(1.0),
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  children: [
                    _buildHeaderCell('Date'),
                    _buildHeaderCell('Fasting Sugar'),
                    _buildHeaderCell('Breakfast Sugar'),
                    _buildHeaderCell('Breakfast Insulin Dose'),
                    _buildHeaderCell('Lunch Sugar'),
                    _buildHeaderCell('Lunch Insulin Dose'),
                    _buildHeaderCell('Dinner Sugar'),
                    _buildHeaderCell('Dinner Insulin Dose'),
                    _buildHeaderCell('Night Insulin Dose'),
                  ],
                ),
                // Data rows - one per date
                ...sortedDates.map((dateKey) {
                  final entries = groupedByDate[dateKey]!;
                  final rowData = _buildRowDataForDate(dateKey, entries);
                  return pw.TableRow(
                    children: [
                      _buildCell(rowData.date),
                      _buildCell(rowData.fastingSugar),
                      _buildCell(rowData.breakfastSugar),
                      _buildCell(rowData.breakfastInsulin),
                      _buildCell(rowData.lunchSugar),
                      _buildCell(rowData.lunchInsulin),
                      _buildCell(rowData.dinnerSugar),
                      _buildCell(rowData.dinnerInsulin),
                      _buildCell(rowData.nightInsulin),
                    ],
                  );
                }),
              ],
            ),
          ];
        },
      ),
    );

    // Share the PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text.isEmpty ? '-' : text,
        style: const pw.TextStyle(fontSize: 9),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  _DateRowData _buildRowDataForDate(String dateKey, List<HistoryEntry> entries) {
    // Separate readings and insulin doses
    final List<Reading> readings = [];
    final List<InsulinDose> insulinDoses = [];
    
    for (final entry in entries) {
      if (entry is Reading) {
        readings.add(entry);
      } else if (entry is InsulinDose) {
        insulinDoses.add(entry);
      }
    }

    // Find readings by type
    Reading? fastingReading;
    Reading? breakfastReading;
    Reading? lunchReading;
    Reading? dinnerReading;

    for (final reading in readings) {
      switch (reading.type) {
        case ReadingType.fasting:
          fastingReading = reading;
          break;
        case ReadingType.breakfast:
          breakfastReading = reading;
          break;
        case ReadingType.lunch:
          lunchReading = reading;
          break;
        case ReadingType.dinner:
          dinnerReading = reading;
          break;
      }
    }

    // Match insulin doses to meals by time proximity (within 2 hours)
    // Fiasp doses are matched to meals, Lantus is the night dose
    InsulinDose? breakfastInsulin;
    InsulinDose? lunchInsulin;
    InsulinDose? dinnerInsulin;
    InsulinDose? nightInsulin;

    for (final dose in insulinDoses) {
      if (dose.type == InsulinType.lantus) {
        // Lantus is the night/long-acting insulin - take the latest one if multiple
        if (nightInsulin == null || dose.timestamp.isAfter(nightInsulin.timestamp)) {
          nightInsulin = dose;
        }
      } else if (dose.type == InsulinType.fiasp) {
        // Match Fiasp to the closest meal reading within 2 hours
        int? closestMealType; // 0=breakfast, 1=lunch, 2=dinner
        Duration? closestTimeDiff;
        
        // Find the closest meal
        if (breakfastReading != null) {
          final timeDiff = dose.timestamp.difference(breakfastReading.timestamp).abs();
          if (timeDiff.inHours <= 2 && (closestTimeDiff == null || timeDiff < closestTimeDiff)) {
            closestMealType = 0;
            closestTimeDiff = timeDiff;
          }
        }
        
        if (lunchReading != null) {
          final timeDiff = dose.timestamp.difference(lunchReading.timestamp).abs();
          if (timeDiff.inHours <= 2 && (closestTimeDiff == null || timeDiff < closestTimeDiff)) {
            closestMealType = 1;
            closestTimeDiff = timeDiff;
          }
        }
        
        if (dinnerReading != null) {
          final timeDiff = dose.timestamp.difference(dinnerReading.timestamp).abs();
          if (timeDiff.inHours <= 2 && (closestTimeDiff == null || timeDiff < closestTimeDiff)) {
            closestMealType = 2;
            closestTimeDiff = timeDiff;
          }
        }
        
        // Assign to the closest meal
        if (closestMealType == 0) {
          breakfastInsulin = dose;
        } else if (closestMealType == 1) {
          lunchInsulin = dose;
        } else if (closestMealType == 2) {
          dinnerInsulin = dose;
        }
      }
    }

    // Format date
    final parts = dateKey.split('-');
    final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    final formattedDate = '${date.month}/${date.day}/${date.year}';

    return _DateRowData(
      date: formattedDate,
      fastingSugar: fastingReading != null ? '${fastingReading.sugarLevel} mg/dL' : '',
      breakfastSugar: breakfastReading != null ? '${breakfastReading.sugarLevel} mg/dL' : '',
      breakfastInsulin: breakfastInsulin != null ? '${breakfastInsulin.units} units' : '',
      lunchSugar: lunchReading != null ? '${lunchReading.sugarLevel} mg/dL' : '',
      lunchInsulin: lunchInsulin != null ? '${lunchInsulin.units} units' : '',
      dinnerSugar: dinnerReading != null ? '${dinnerReading.sugarLevel} mg/dL' : '',
      dinnerInsulin: dinnerInsulin != null ? '${dinnerInsulin.units} units' : '',
      nightInsulin: nightInsulin != null ? '${nightInsulin.units} units' : '',
    );
  }

}

class _DateRowData {
  final String date;
  final String fastingSugar;
  final String breakfastSugar;
  final String breakfastInsulin;
  final String lunchSugar;
  final String lunchInsulin;
  final String dinnerSugar;
  final String dinnerInsulin;
  final String nightInsulin;

  _DateRowData({
    required this.date,
    required this.fastingSugar,
    required this.breakfastSugar,
    required this.breakfastInsulin,
    required this.lunchSugar,
    required this.lunchInsulin,
    required this.dinnerSugar,
    required this.dinnerInsulin,
    required this.nightInsulin,
  });
}
