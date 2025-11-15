import 'package:diabetes_tracker/screens/add_reading_page.dart';
import 'package:diabetes_tracker/screens/history_page.dart';
import 'package:diabetes_tracker/screens/settings_page.dart';
import 'package:diabetes_tracker/screens/export_pdf_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  'Diabetes Tracker',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              
              // 2x2 Grid of Large Boxes
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                  children: [
                    _buildActionCard(
                      context: context,
                      title: 'Add Reading',
                      icon: FontAwesomeIcons.circlePlus,
                      isFontAwesome: true,
                      color: colorScheme.primaryContainer,
                      iconColor: const Color(0xFF00BCD4), // Bright Cyan
                      textColor: colorScheme.onPrimaryContainer,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddReadingPage(),
                          ),
                        );
                      },
                    ),
                    _buildActionCard(
                      context: context,
                      title: 'History',
                      icon: FontAwesomeIcons.chartLine,
                      isFontAwesome: true,
                      color: colorScheme.secondaryContainer,
                      iconColor: const Color(0xFF9C27B0), // Vibrant Purple
                      textColor: colorScheme.onSecondaryContainer,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistoryPage(),
                          ),
                        );
                      },
                    ),
                    _buildActionCard(
                      context: context,
                      title: 'Export as PDF',
                      icon: FontAwesomeIcons.filePdf,
                      isFontAwesome: true,
                      color: colorScheme.tertiaryContainer,
                      iconColor: const Color(0xFFFF9800), // Bright Orange
                      textColor: colorScheme.onTertiaryContainer,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ExportPdfPage(),
                          ),
                        );
                      },
                    ),
                    _buildActionCard(
                      context: context,
                      title: 'Settings',
                      icon: FontAwesomeIcons.gear,
                      isFontAwesome: true,
                      color: colorScheme.surfaceContainerHighest,
                      iconColor: const Color(0xFF4CAF50), // Bright Green
                      textColor: colorScheme.onSurface,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required Color textColor,
    required VoidCallback onTap,
    bool isFontAwesome = false,
  }) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: isFontAwesome
                    ? FaIcon(
                        icon,
                        size: 64,
                        color: iconColor,
                      )
                    : Icon(
                        icon,
                        size: 64,
                        color: iconColor,
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
