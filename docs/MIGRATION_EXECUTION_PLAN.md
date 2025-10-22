# Flutter Test Migration - Detailed Execution Plan

## IMMEDIATE EXECUTION ROADMAP

This document provides the exact commands, file movements, and verification steps needed to migrate from the current broken test architecture to 2025 clean architecture standards.

---

## PHASE 1: INFRASTRUCTURE REPAIR (CRITICAL - Days 1-3)

### Day 1: Fix Broken Test Infrastructure

**STEP 1.1: Repair widget_test_base.dart**
```bash
# Current file is empty - needs complete implementation
# Location: test/support/widget_test_base.dart
```

**STEP 1.2: Fix widget_test_helper.dart**  
```bash
# Current compilation errors:
# - WidgetTestBase not found
# - TestEnvironment undefined
# - AccessibilityTestHelper undefined
```

**STEP 1.3: Implement missing helper classes**
```bash
# Required files to create/fix:
test/support/accessibility_test_helper.dart  # Currently empty
test/support/golden_test_helper.dart         # Missing implementation
test/support/test_builders.dart              # Exists but incomplete
```

### Day 2: Consolidate Mock Strategy

**STEP 2.1: Create centralized mock configuration**
```bash
# Create: test/mocks/mock_config.dart
# Consolidate all @GenerateMocks annotations
```

**STEP 2.2: Move scattered mock files**
```bash
# Source files to relocate:
mv test/presentation/family/pages/create_family_page_test.mocks.dart test/mocks/
mv test/integration/family_provider_api_error_integration_test.mocks.dart test/mocks/
mv test/unit/data/schedule/providers/schedule_provider_test.mocks.dart test/mocks/
mv test/unit/data/family/repositories/family_repository_impl_test.mocks.dart test/mocks/
mv test/unit/core/network/network_info_mock_test.mocks.dart test/mocks/
mv test/unit/core/security/data_protection_service_test.mocks.dart test/mocks/
mv test/unit/domain/family/usecases/create_family_usecase_test.mocks.dart test/mocks/
mv test/presentation/family/pages/vehicles_page_test.mocks.dart test/mocks/
```

**STEP 2.3: Standardize mock generation**
```bash
# Replace all @GenerateMocks with @GenerateNiceMocks
# Update import statements in affected test files
```

### Day 3: Fix Import Dependencies

**STEP 3.1: Update all broken imports**
```bash
# Files with broken imports (verified from analysis):
test/helpers/widget_test_helper.dart
test/support/accessibility_test_helper.dart  
test/support/golden_test_helper.dart
```

**STEP 3.2: Verify infrastructure compilation**
```bash
# Run compilation check:
flutter analyze test/support/
flutter analyze test/helpers/
flutter analyze test/mocks/
```

---

## PHASE 2: DIRECTORY REORGANIZATION (Days 4-7)

### Day 4: Create Target Directory Structure

**STEP 4.1: Create new directory structure**
```bash
mkdir -p test/unit/presentation/providers
mkdir -p test/unit/presentation/family  
mkdir -p test/unit/presentation/schedule
mkdir -p test/unit/presentation/onboarding
mkdir -p test/unit/presentation/auth
mkdir -p test/unit/presentation/dashboard

mkdir -p test/widget/family/pages
mkdir -p test/widget/family/widgets
mkdir -p test/widget/schedule/widgets
mkdir -p test/widget/onboarding/pages
mkdir -p test/widget/auth/pages
mkdir -p test/widget/dashboard

mkdir -p test/mocks
mkdir -p test/fixtures
mkdir -p test/support
```

### Day 5-6: Systematic File Migration

**STEP 5.1: Move Presentation Unit Tests (16 files)**
```bash
# Provider tests (pure logic, no widgets)
mv test/presentation/providers/auth_provider_name_field_test.dart test/unit/presentation/providers/
mv test/presentation/onboarding/providers/onboarding_provider_test.dart test/unit/presentation/providers/

# NOTE: Verify each moved file still references correct imports
```

**STEP 5.2: Move Widget Tests (23 files)**
```bash
# Family widget tests
mv test/presentation/family/pages/add_child_page_test.dart test/widget/family/pages/
mv test/presentation/family/pages/vehicles_page_test.dart test/widget/family/pages/
mv test/presentation/family/pages/family_ui_error_resilience_test.dart test/widget/family/pages/
mv test/presentation/family/pages/create_family_page_test.dart test/widget/family/pages/

# Schedule widget tests  
mv test/presentation/schedule/widgets/schedule_slot_widget_test.dart test/widget/schedule/widgets/
mv test/presentation/schedule/widgets/schedule_grid_test.dart test/widget/schedule/widgets/

# Onboarding widget tests
mv test/presentation/onboarding/pages/onboarding_wizard_page_test.dart test/widget/onboarding/pages/

# Auth widget tests
mv test/presentation/auth/pages/login_page_progressive_test.dart test/widget/auth/pages/

# Dashboard widget tests
mv test/presentation/dashboard/dashboard_page_test.dart test/widget/dashboard/
```

**STEP 5.3: Consolidate Infrastructure Files**
```bash
# Move fixture files
mv test/test_fixtures/family_test_fixtures.dart test/fixtures/
mv test/test_fixtures/api_response_edge_case_fixtures.dart test/fixtures/

# Move support files (keep only unique ones)
mv test/helpers/simple_widget_test_helper.dart test/support/
# Note: widget_test_helper.dart already in test/helpers/ - verify no duplication

# Clean up empty directories
rmdir test/presentation/providers test/presentation/family/pages test/presentation/schedule/widgets
rmdir test/presentation/onboarding/providers test/presentation/onboarding/pages 
rmdir test/presentation/auth/pages test/presentation/dashboard
rmdir test/presentation/family test/presentation/schedule test/presentation/onboarding test/presentation/auth
rmdir test/presentation
rmdir test/test_fixtures test/test_mocks/storage
rmdir test/test_mocks
```

### Day 7: Update Import Statements

**STEP 7.1: Mass import path updates**
```bash
# Use find/replace to update import paths in moved files:
# OLD: import '../../../support/
# NEW: import '../../support/

# OLD: import '../test_mocks/
# NEW: import '../mocks/

# OLD: import '../fixtures/  
# NEW: import '../fixtures/

# Script to update imports:
find test/ -name "*.dart" -exec sed -i 's|import.*test_mocks/|import '../mocks/|g' {} \;
find test/ -name "*.dart" -exec sed -i 's|import.*test_fixtures/|import '../fixtures/|g' {} \;
```

---

## PHASE 3: ARCHITECTURE ENFORCEMENT (Days 8-12)

### Day 8-9: Implement Layer Separation Rules

**STEP 8.1: Create architectural test verification**
```bash
# Create: test/support/architecture_test.dart
# Verify dependency rules for each layer
```

**STEP 8.2: Domain layer cleanup**
```bash
# Verify domain tests have ZERO external dependencies
# Files to check (5 domain test files identified):
test/unit/domain/family/entities/family_member_test.dart
test/unit/domain/family/usecases/create_family_usecase_test.dart  
test/unit/domain/onboarding/entities/onboarding_state_test.dart
test/unit/domain/onboarding/usecases/coordinate_onboarding_usecase_test.dart
test/unit/domain/auth/entities/user_test.dart
```

**STEP 8.3: Data layer isolation**
```bash
# Verify data tests mock external dependencies correctly
# Review repository implementation tests for clean architecture compliance
```

### Day 10-11: Presentation Layer Separation

**STEP 10.1: Split presentation tests by type**
```bash
# Unit tests: test business logic only (providers, state management)
# Widget tests: test UI behavior only (user interactions, displays)
```

**STEP 10.2: Widget test cleanup**
```bash
# Ensure widget tests use proper TestWidgets framework
# Add accessibility testing to all widget tests
# Implement golden testing for critical UI components
```

### Day 12: Integration Test Organization

**STEP 12.1: Clean integration tests**
```bash
# Current integration tests (10 files) - verify they test end-to-end flows only:
test/integration/family_creation_navigation_test.dart
test/integration/family_provider_api_error_integration_test.dart
test/integration/profile_page_family_role_test.dart
test/integration/schedule_coordination_websocket_test.dart
test/integration/email_validation_regression_test.dart
test/integration/auth_navigation_race_condition_test.dart  
test/integration/tab_navigation_integration_test.dart
test/integration/schedule_groups_casting_test.dart
```

---

## PHASE 4: COVERAGE & QUALITY ASSURANCE (Days 13-17)

### Day 13-14: Implement Coverage Tracking

**STEP 13.1: Configure layer-specific coverage**
```bash
# Update coverage configuration in pubspec.yaml
# Add coverage exclusions for generated files
```

**STEP 13.2: Generate baseline coverage report**
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
# Analyze coverage by architectural layer
```

### Day 15-16: Fix Failing Tests

**STEP 15.1: Address 32 failing tests systematically**
```bash
# Categories of failures identified:
# - Infrastructure failures: 12 tests
# - Import resolution: 8 tests
# - Mock generation: 7 tests  
# - Widget test setup: 5 tests
```

**STEP 15.2: Implement missing tests for coverage gaps**
```bash
# Target coverage by layer:
# Domain: 95%+ 
# Data: 90%+
# Presentation: 85%+
# Widget: 80%+
```

### Day 17: Accessibility Integration

**STEP 17.1: Add accessibility testing to all widget tests**
```bash
# Implement semantic testing for all user-facing widgets
# Add screen reader compatibility verification
# Test keyboard navigation flows
```

---

## PHASE 5: VALIDATION & DOCUMENTATION (Days 18-21)

### Day 18-19: Full Test Suite Validation

**STEP 18.1: Complete test execution**
```bash
flutter test --coverage
# Verify: 0 failing tests
# Verify: 90%+ coverage achieved
# Verify: 0 compilation warnings
```

**STEP 18.2: Performance validation**
```bash
# Measure test execution time improvements
# Verify CI/CD pipeline integration
# Test discovery and execution efficiency
```

### Day 20-21: Documentation & Training

**STEP 20.1: Update testing documentation**
```bash
# Update test/README.md with new architecture
# Create layer-specific testing guidelines
# Document mock generation process
```

**STEP 20.2: Create architectural decision records**
```bash
# Document why clean architecture approach was chosen
# Record mock strategy decisions
# Explain directory structure rationale
```

---

## VERIFICATION CHECKPOINTS

### After Each Phase:
1. **All tests compile without errors**
2. **Test execution completes successfully**  
3. **Import paths resolve correctly**
4. **Directory structure matches target**
5. **Coverage reporting functions**

### Final Success Criteria:
- ✅ 0 failing tests (currently 32 failing)
- ✅ 90%+ coverage per architectural layer
- ✅ Clean directory structure following 2025 standards
- ✅ Consolidated mock generation strategy
- ✅ Accessibility testing integration
- ✅ Zero compilation warnings/errors

---

## ROLLBACK PLAN

If migration fails at any point:
1. **Git reset to pre-migration state**
2. **Restore original file locations**  
3. **Revert import statement changes**
4. **Regenerate broken mock files**

**Backup Strategy**: Create git branch before each major phase.

---

*Execution Plan Last Updated: 2025-08-14*
*Estimated Total Duration: 21 days (3 weeks)*