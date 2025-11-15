import 'package:flutter/material.dart';
import 'package:diabetes_tracker/models/user_settings.dart';
import 'package:diabetes_tracker/services/user_settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final UserSettingsService _userSettingsService = UserSettingsService();
  late TextEditingController _baseFiaspUnitsController;
  late TextEditingController _defaultPreviousLantusController;

  UserSettings? _currentUserSettings;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    _currentUserSettings = await _userSettingsService.loadUserSettings();
    _baseFiaspUnitsController = TextEditingController(
      text: _currentUserSettings?.baseFiaspUnits.toString() ?? '',
    );
    _defaultPreviousLantusController = TextEditingController(
      text: _currentUserSettings?.defaultPreviousLantus.toString() ?? '',
    );
    setState(() {});
  }

  Future<void> _saveUserSettings() async {
    if (_formKey.currentState!.validate()) {
      final newSettings = UserSettings(
        baseFiaspUnits: int.parse(_baseFiaspUnitsController.text),
        defaultPreviousLantus: int.parse(_defaultPreviousLantusController.text),
      );
      await _userSettingsService.saveUserSettings(newSettings);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully!')),
      );
    }
  }

  @override
  void dispose() {
    _baseFiaspUnitsController.dispose();
    _defaultPreviousLantusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
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
                      controller: _baseFiaspUnitsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Base Fiasp Units',
                        hintText: 'Enter base Fiasp units (e.g., 5)',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter base Fiasp units';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _defaultPreviousLantusController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Default Previous Lantus Units',
                        hintText:
                            'Enter default previous Lantus units (e.g., 20)',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter default previous Lantus units';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveUserSettings,
                      child: const Text('Save Settings'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
