import 'package:flutter/material.dart';
import 'package:diabetes_tracker/models/reading.dart';
import 'package:diabetes_tracker/models/insulin_dose.dart'; // Added import
import 'package:diabetes_tracker/models/user_settings.dart';
import 'package:diabetes_tracker/services/insulin_calculator_service.dart';
import 'package:diabetes_tracker/database/reading_repository.dart';
import 'package:diabetes_tracker/database/insulin_dose_repository.dart';
import 'package:diabetes_tracker/services/user_settings_service.dart';

class AddReadingPage extends StatefulWidget {
  const AddReadingPage({super.key});

  @override
  State<AddReadingPage> createState() => _AddReadingPageState();
}

class _AddReadingPageState extends State<AddReadingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _sugarLevelController = TextEditingController();
  ReadingType? _selectedReadingType;
  int? _lantusDoseSuggestion;
  int? _fiaspDoseSuggestion;

  final InsulinCalculatorService _insulinCalculatorService =
      InsulinCalculatorService();
  final ReadingRepository _readingRepository = ReadingRepository();
  final InsulinDoseRepository _insulinDoseRepository = InsulinDoseRepository();
  final UserSettingsService _userSettingsService = UserSettingsService();

  UserSettings? _currentUserSettings;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    _currentUserSettings = await _userSettingsService.loadUserSettings();
    setState(() {});
  }

  void _calculateInsulinDose() async {
    if (_formKey.currentState!.validate() &&
        _selectedReadingType != null &&
        _currentUserSettings != null) {
      final sugarLevel = int.parse(_sugarLevelController.text);

      if (_selectedReadingType == ReadingType.fasting) {
        // For Lantus, we need previous day's Lantus units
        // For now, we'll use the default from settings. In a real app, this would come from historical data.
        final previousDayLantusUnits =
            _currentUserSettings!.defaultPreviousLantus;
        _lantusDoseSuggestion = _insulinCalculatorService.calculateLantusDose(
          fastingSugarLevel: sugarLevel,
          previousDayLantusUnits: previousDayLantusUnits,
        );
        _fiaspDoseSuggestion = null; // Fiasp is not taken with fasting reading
      } else {
        _fiaspDoseSuggestion = _insulinCalculatorService.calculateFiaspDose(
          currentSugarLevel: sugarLevel,
          mealType: _selectedReadingType!,
          userSettings: _currentUserSettings!,
        );
        _lantusDoseSuggestion = null; // Lantus is not taken with meal readings
      }
      setState(() {});
    }
  }

  Future<void> _saveReadingAndDose() async {
    if (_formKey.currentState!.validate() && _selectedReadingType != null) {
      final sugarLevel = int.parse(_sugarLevelController.text);
      final now = DateTime.now();

      final reading = Reading(
        sugarLevel: sugarLevel,
        type: _selectedReadingType!,
        timestamp: now,
      );
      await _readingRepository.addReading(reading);

      if (_lantusDoseSuggestion != null) {
        final lantusDose = InsulinDose(
          units: _lantusDoseSuggestion!,
          type: InsulinType.lantus,
          timestamp: now,
        );
        await _insulinDoseRepository.addInsulinDose(lantusDose);
        await _userSettingsService.saveUserSettings(
          UserSettings(
            fiaspBreakfastBase: _currentUserSettings!.fiaspBreakfastBase,
            fiaspLunchBase: _currentUserSettings!.fiaspLunchBase,
            fiaspDinnerBase: _currentUserSettings!.fiaspDinnerBase,
            defaultPreviousLantus: _lantusDoseSuggestion!,
          ),
        );
      } else if (_fiaspDoseSuggestion != null) {
        final fiaspDose = InsulinDose(
          units: _fiaspDoseSuggestion!,
          type: InsulinType.fiasp,
          timestamp: now,
        );
        await _insulinDoseRepository.addInsulinDose(fiaspDose);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reading and dose saved!')));
      // Navigator.pop(context); // Go back to home page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Reading')),
      body: _currentUserSettings == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _sugarLevelController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Blood Sugar Level',
                        hintText: 'Enter sugar level (e.g., 120)',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a sugar level';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<ReadingType>(
                      initialValue: _selectedReadingType,
                      decoration: const InputDecoration(
                        labelText: 'Reading Type',
                      ),
                      items: ReadingType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: (type) {
                        setState(() {
                          _selectedReadingType = type;
                          _lantusDoseSuggestion = null;
                          _fiaspDoseSuggestion = null;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a reading type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _calculateInsulinDose,
                      child: const Text('Calculate Insulin Dose'),
                    ),
                    const SizedBox(height: 20),
                    if (_lantusDoseSuggestion != null)
                      Text(
                        'Suggested Lantus Dose: $_lantusDoseSuggestion units',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (_fiaspDoseSuggestion != null)
                      Text(
                        'Suggested Fiasp Dose: $_fiaspDoseSuggestion units',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 20),
                    if (_lantusDoseSuggestion != null ||
                        _fiaspDoseSuggestion != null)
                      ElevatedButton(
                        onPressed: _saveReadingAndDose,
                        child: const Text('Save Reading and Dose'),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
