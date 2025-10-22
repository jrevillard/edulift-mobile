# Golden Tests - EduLift Mobile App

This directory contains comprehensive golden tests for visual regression testing.

## Structure

- `screens/` - Full screen golden tests
  - dashboard_screen_golden_test.dart - Dashboard and home screens
  - family_screens_golden_test.dart - Family-related screens
  - group_screens_golden_test.dart - Group-related screens

- `widgets/` - Widget-level golden tests
  - family_widgets_golden_test.dart - Family widgets
  - group_widgets_golden_test.dart - Group widgets

## Running Tests

# Run all golden tests
flutter test test/golden_tests

# Run specific test file
flutter test test/golden_tests/screens/dashboard_screen_golden_test.dart

# Update golden files (when intentional UI changes are made)
flutter test test/golden_tests --update-goldens

# Run tests on specific device configuration
flutter test test/golden_tests --dart-define=DEVICE=iphone13

## Infrastructure

All tests use:
- Device configurations from test/support/golden/device_configurations.dart
- Theme configurations from test/support/golden/theme_configurations.dart
- Test data factories from test/support/factories/

## Data Factories

Factories generate realistic international test data:
- test_data_factory.dart - Base data with international names
- family_data_factory.dart - Family, members, children, vehicles
- group_data_factory.dart - Groups, members, families
- schedule_data_factory.dart - Schedules and assignments

All factories use fixed seed (42) for deterministic results.

## Coverage

- 10+ screen variants tested
- 10+ widget variants tested
- Multiple themes (light, dark, high contrast)
- Multiple devices (phone, tablet, various sizes)
- Accessibility testing (font scaling)
- Edge cases (long names, special characters, empty states)
- Volume testing (15-30 items per list)

## Notes

- Golden files are stored in test/goldens/
- Tests use realistic international data with special characters (é, ñ, ö, etc.)
- All tests are deterministic and reproducible
