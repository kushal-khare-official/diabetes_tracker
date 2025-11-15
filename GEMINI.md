# Diabetes Tracker Application Details (for Gemini)

## Application Purpose

The Diabetes Tracker application is a Flutter-based mobile app designed to help diabetic patients manage their condition by tracking blood sugar levels and calculating insulin dosages. The app provides a simple and intuitive interface for users to record their blood sugar readings, receive insulin dosage recommendations, and view their historical data. The app also allows users to export their data as a CSV file for sharing with their healthcare providers.

## Implementation Details

The application is built using Flutter and follows a layered architecture pattern, separating the UI, business logic, and data layers.

### Key Architectural Decisions:

*   **State Management:** The app uses `setState` for managing local widget state and `shared_preferences` for persisting user settings.
*   **Database:** `sqflite` is used for local data storage of blood sugar readings and insulin doses.
*   **Navigation:** Basic Flutter navigation is used for moving between screens.
*   **Dependency Management:** `pub` is used for managing package dependencies.

### Component Breakdown:

*   **`main.dart`:** The entry point of the application, which sets up the `MaterialApp` and the `HomePage`.
*   **`HomePage`:** The main screen of the app, which displays a summary of the latest readings and provides navigation to other screens.
*   **`AddReadingPage`:** A form for users to input their blood sugar level and select the reading type. This screen also displays the recommended insulin dose.
*   **`HistoryPage`:** Displays a list of all blood sugar readings and insulin doses, sorted by date. This screen also provides the functionality to export the data as a CSV file.
*   **`SettingsPage`:** Allows users to configure their personal settings, such as the base Fiasp units and the default previous Lantus dose.
*   **`database/`:** Contains the `DatabaseHelper` for managing the SQLite database and the `ReadingRepository` and `InsulinDoseRepository` for performing CRUD operations on the data.
*   **`models/`:** Defines the data models for the application, including `Reading`, `InsulinDose`, `UserSettings`, and `HistoryEntry`.
*   **`services/`:** Contains the `InsulinCalculatorService` for calculating insulin dosages and the `ExportService` for generating the CSV file.

## File Layout

```
diabetes_tracker/
├── .dart_tool/
├── .idea/
├── android/
├── build/
├── ios/
├── lib/
│   ├── database/
│   │   ├── database_helper.dart
│   │   ├── insulin_dose_repository.dart
│   │   └── reading_repository.dart
│   ├── models/
│   │   ├── history_entry.dart
│   │   ├── insulin_dose.dart
│   │   ├── reading.dart
│   │   └── user_settings.dart
│   ├── screens/
│   │   ├── add_reading_page.dart
│   │   ├── history_page.dart
│   │   ├── home_page.dart
│   │   └── settings_page.dart
│   ├── services/
│   │   ├── export_service.dart
│   │   └── insulin_calculator_service.dart
│   └── main.dart
├── linux/
├── macos/
├── test/
│   ├── database/
│   │   ├── database_helper_test.dart
│   │   ├── insulin_dose_repository_test.dart
│   │   └── reading_repository_test.dart
│   ├── screens/
│   │   ├── add_reading_page_test.dart
│   │   ├── history_page_test.dart
│   │   └── settings_page_test.dart
│   └── services/
│       ├── export_service_test.dart
│       ├── insulin_calculator_service_test.dart
│       └── user_settings_service_test.dart
├── web/
├── windows/
├── .gitignore
├── .metadata
├── analysis_options.yaml
├── CHANGELOG.md
├── DESIGN.md
├── IMPLEMENTATION.md
├── pubspec.lock
├── pubspec.yaml
└── README.md
```
