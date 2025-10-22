# EduLift Mobile App - AI Agent Instructions

This file provides specific instructions for AI coding agents working on the EduLift Flutter mobile application.

## 🛠️ Technology Stack

- **Framework**: Flutter with Dart
- **State Management**: Riverpod
- **Architecture**: Clean Architecture with Feature-first organization
- **Networking**: Dio HTTP client
- **Local Storage**: Hive
- **Testing**: Flutter test (unit, widget, integration)
- **Internationalization**: Flutter gen-l10n
- **Code Generation**: Freezed, JsonSerializable

## 📁 Project Structure

```
lib/
├── main.dart           - Application entry point
├── edulift_app.dart    - Main app widget
├── bootstrap.dart      - App initialization
├── core/               - Core utilities, constants, exceptions
├── data/               - Data layer (repositories, data sources)
├── features/           - Feature modules
│   ├── auth/           - Authentication
│   ├── family/         - Family management
│   ├── groups/         - Group coordination
│   ├── schedule/       - Schedule management
│   ├── dashboard/      - Main dashboard
│   ├── onboarding/     - User onboarding
│   └── settings/       - App settings
└── generated/          - Generated code (freezed, json_serializable)

test/
├── unit/               - Unit tests
├── presentation/       - Widget tests
├── integration/        - Integration tests
├── support/            - Test helpers and mocks
└── fixtures/           - Test data

integration_test/       - Patrol E2E tests
```

## ▶️ Development Commands

- **Run Development App**: `flutter run`
- **Run on Specific Device**: `flutter run -d <device_name>`
- **Hot Reload**: `r` (in flutter run terminal)
- **Hot Restart**: `R` (in flutter run terminal)

## 🧪 Testing Commands

- **Run All Tests**: `flutter test`
- **Run Unit Tests**: `flutter test test/unit/`
- **Run Widget Tests**: `flutter test test/presentation/`
- **Run Integration Tests**: `flutter test test/integration/`
- **Run Specific Test**: `flutter test path/to/test_file.dart`
- **Run with Coverage**: `flutter test --coverage`
- **Run E2E Tests**: `patrol test --target integration_test/test_file.dart`

## 📝 Code Style Guidelines

- Follow existing Dart and Flutter patterns
- Use Riverpod for state management
- Implement Clean Architecture principles
- Use Freezed for data classes and unions
- Use JsonSerializable for JSON serialization
- Write unit tests for business logic
- Write widget tests for UI components
- Use keys for widget testing (see test/AGENTS.md)
- Follow existing folder and file naming conventions

## 🔄 Common Workflows

1. **Creating New Features**:
   - Create new feature directory under `lib/features/`
   - Follow existing feature structure (data, domain, presentation)
   - Implement Riverpod providers for state management
   - Add unit and widget tests

2. **Adding New Screens**:
   - Create in appropriate feature's presentation/widgets
   - Use existing widget patterns and styles
   - Add proper error handling and loading states
   - Include widget tests

3. **API Integration**:
   - Add models in feature's data/models
   - Implement repositories in feature's data/repositories
   - Use existing Dio client patterns
   - Add unit tests for repositories

4. **State Management**:
   - Use Riverpod providers in feature's presentation/providers
   - Follow existing provider patterns
   - Implement proper loading and error states

## ⚠️ Important Notes

- Always add unique keys to interactive widgets for testing
- Follow accessibility guidelines (WCAG 2.1 AA)
- Maintain performance - avoid unnecessary rebuilds
- Use proper error handling and user feedback
- Update tests when modifying existing functionality
- Follow the existing internationalization patterns
- Respect the feature-first architecture organization

## 🎯 Testing Guidelines

For detailed testing guidelines, see [test/AGENTS.md](./test/AGENTS.md) which contains specific instructions for:
- Widget testing with keys
- Test directory structure
- Efficient test commands
- JSON test result analysis
- Common testing patterns and anti-patterns