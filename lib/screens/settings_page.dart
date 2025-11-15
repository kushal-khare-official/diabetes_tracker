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
  late TextEditingController _fiaspBreakfastBaseController;
  late TextEditingController _fiaspLunchBaseController;
  late TextEditingController _fiaspDinnerBaseController;
  late TextEditingController _defaultPreviousLantusController;

  UserSettings? _currentUserSettings;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    _currentUserSettings = await _userSettingsService.loadUserSettings();
    _fiaspBreakfastBaseController = TextEditingController(
      text: _currentUserSettings?.fiaspBreakfastBase.toString() ?? '',
    );
    _fiaspLunchBaseController = TextEditingController(
      text: _currentUserSettings?.fiaspLunchBase.toString() ?? '',
    );
    _fiaspDinnerBaseController = TextEditingController(
      text: _currentUserSettings?.fiaspDinnerBase.toString() ?? '',
    );
    _defaultPreviousLantusController = TextEditingController(
      text: _currentUserSettings?.defaultPreviousLantus.toString() ?? '',
    );
    setState(() {});
  }

  Future<void> _saveUserSettings() async {
    if (_formKey.currentState!.validate()) {
      final newSettings = UserSettings(
        fiaspBreakfastBase: int.parse(_fiaspBreakfastBaseController.text),
        fiaspLunchBase: int.parse(_fiaspLunchBaseController.text),
        fiaspDinnerBase: int.parse(_fiaspDinnerBaseController.text),
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
    _fiaspBreakfastBaseController.dispose();
    _fiaspLunchBaseController.dispose();
    _fiaspDinnerBaseController.dispose();
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
                    Text(
                      'Fiasp Base Units',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _fiaspBreakfastBaseController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Breakfast Base Units',
                        hintText: 'Enter breakfast base Fiasp units (e.g., 8)',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter breakfast base Fiasp units';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _fiaspLunchBaseController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Lunch Base Units',
                        hintText: 'Enter lunch base Fiasp units (e.g., 8)',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter lunch base Fiasp units';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _fiaspDinnerBaseController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Dinner Base Units',
                        hintText: 'Enter dinner base Fiasp units (e.g., 8)',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter dinner base Fiasp units';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Lantus Settings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveUserSettings,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Save Settings'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
