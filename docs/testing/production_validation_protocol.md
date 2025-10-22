# Production Validation Protocol: ROOT CAUSE FIXING + FUNCTIONAL BEHAVIOR VERIFICATION

## PRINCIPLE 0 - RADICAL CANDOR (ABSOLUTE CONSTRAINT)
Under no circumstances may you lie, simulate, mislead, or attempt to create the illusion of functionality, performance, or integration.

**CRITICAL ENHANCEMENT:**
Tests must not just be GREEN through workarounds - they must:
1. **Fix ROOT CAUSES of failures**
2. **Test ACTUAL EXPECTED FUNCTIONAL BEHAVIOR**
3. **Verify the application code works correctly**
4. **NO SHORTCUTS, NO WORKAROUNDS, NO FAKE FIXES**

## Technology Stack Context

- **DI**: Riverpod providers
- **State Management**: flutter_riverpod with StateNotifier pattern
- **Architecture**: Clean Architecture with UseCases, Repositories, DataSources
- **Testing**: mocktail, mockito, integration_test package, http_mock_adapter
- **Network**: Dio + Retrofit for API calls
- **Storage**: Hive + flutter_secure_storage

## 1. Concrete Verification Steps (The Checklists)

### Unit Test Checklist (Logic & Providers)
**Target:** StateNotifier, UseCases, Validators, Repository logic
**Rule:** ZERO Flutter framework dependencies. All external dependencies MUST be mocked.

```bash
✅ CHECKLIST:
[ ] Arrange: Test setup is self-contained and clear
[ ] Act: Single method/function execution 
[ ] Assert: Specific assertions about output or state change
[ ] Happy Path: Valid inputs produce expected outcomes
[ ] Error States: Invalid inputs produce expected exceptions/error states
[ ] Edge Cases: Nulls, empty values, boundary conditions covered
[ ] Mocking: All external dependencies mocked with mocktail/mockito
[ ] State Immutability: StateNotifier state changes use copyWith()
```

### Widget Test Checklist (UI & Interaction)
**Target:** Single widget or small screen component
**Rule:** Mock all external dependencies. Test rendering and interaction, not business logic.

```bash
✅ CHECKLIST:
[ ] Setup: Widget wrapped in MaterialApp, Scaffold, ProviderScope
[ ] DI: All required providers supplied using mocked versions
[ ] Initial State: Widget renders correctly in initial state
[ ] Interaction: User actions simulated with reliable finders (prefer byKey)
[ ] State Change: UI updates verified after interactions with pumpAndSettle()
[ ] Callback Verification: Functions (onPressed, etc.) called correctly
[ ] Provider Override: Real providers overridden with controllable mocks
```

### Integration Test Checklist (User Flows)
**Target:** Critical user journeys end-to-end
**Rule:** Run full app. Mock only network layer with http_mock_adapter.

```bash
✅ CHECKLIST:
[ ] Test Entry Point: App starts from clean state with test DI container
[ ] Network Mocking: HTTP requests intercepted with realistic responses
[ ] User Flow: Navigate through multiple screens as real user would
[ ] Asynchronicity: Correct await tester.pumpAndSettle() usage
[ ] End-to-End Assertion: Final assertion verifies ultimate flow goal
[ ] Cleanup: State reset between tests
[ ] Performance: Test completes within reasonable time limits
```

## 2. Root Cause Decision Trees

### StateNotifier State Not Updating

```
Test Fails: UI doesn't reflect expected state
├── Unit Test?
│   ├── Did you await the notifier method? → FIX TEST: Add await
│   ├── Is state class immutable? → FIX APP: Use copyWith(), not direct mutation
│   └── Check notifier logic with debugger → FIX APP: Correct state calculation
└── Widget Test?
    ├── Used pumpAndSettle() after action? → FIX TEST: Add pumpAndSettle()
    ├── ProviderScope override correct? → FIX TEST: Match exact provider params
    └── Widget using ref.watch() not ref.read()? → FIX APP: Use ref.watch()
```

### Repository/UseCase Call Fails

```
Integration Test Fails: Network Error
├── DioError/HttpException?
│   ├── http_mock_adapter configured? → FIX TEST: Add correct mock response
│   ├── Same Dio instance? → FIX TEST: Ensure providers provide mocked Dio
│   └── Request mismatch → FIX APP: Request logic bug found
├── Deserialization Error?
│   └── Invalid mock JSON → FIX TEST: Match real API response format
└── Result.Err() state?
    └── Unexpected error path → FIX APP: Error handling logic bug
```

## 3. Mandatory Test Patterns

### A. StateNotifier Unit Test Pattern

```dart
// TEMPLATE: test/features/family/presentation/providers/vehicle_form_provider_test.dart

class MockVehiclesRepository extends Mock implements VehiclesRepository {}

void main() {
  late MockVehiclesRepository mockRepository;
  late VehicleFormNotifier notifier;

  setUp(() {
    mockRepository = MockVehiclesRepository();
    notifier = VehicleFormNotifier(
      vehiclesRepository: mockRepository,
      mode: VehicleFormMode.add,
    );
  });

  group('VehicleFormNotifier', () {
    test('submitForm successfully adds vehicle and updates state', () async {
      // Arrange
      const vehicle = Vehicle(id: '1', name: 'Test Car', capacity: 5);
      when(() => mockRepository.addVehicle(
        name: any(named: 'name'),
        capacity: any(named: 'capacity'),
        description: any(named: 'description'),
      )).thenAnswer((_) async => Ok(vehicle));

      // Act
      final result = await notifier.submitForm(
        name: 'Test Car',
        capacity: 5,
        description: 'Test Description',
      );

      // Assert
      expect(result, isTrue);
      expect(notifier.state.isSubmitting, isFalse);
      expect(notifier.state.vehicle, equals(vehicle));
      expect(notifier.state.error, isNull);
      
      verify(() => mockRepository.addVehicle(
        name: 'Test Car',
        capacity: 5,
        description: 'Test Description',
      )).called(1);
    });

    test('submitForm handles validation errors correctly', () async {
      // Act
      final result = await notifier.submitForm(
        name: '', // Invalid empty name
        capacity: 5,
      );

      // Assert
      expect(result, isFalse);
      expect(notifier.state.error, isNotNull);
      expect(notifier.state.error, contains('Vehicle name is required'));
      verifyNever(() => mockRepository.addVehicle(
        name: any(named: 'name'),
        capacity: any(named: 'capacity'),
        description: any(named: 'description'),
      ));
    });
  });
}
```

### B. Widget Test Pattern

```dart
// TEMPLATE: test/features/family/presentation/pages/vehicle_form_page_test.dart

class MockVehicleFormNotifier extends StateNotifier<VehicleFormState> 
    with Mock implements VehicleFormNotifier {
  MockVehicleFormNotifier(VehicleFormState state) : super(state);
}

void main() {
  late MockVehicleFormNotifier mockNotifier;

  Widget createTestWidget({VehicleFormState? state}) {
    mockNotifier = MockVehicleFormNotifier(
      state ?? const VehicleFormState(mode: VehicleFormMode.add),
    );

    return ProviderScope(
      overrides: [
        vehicleFormProvider(const (mode: VehicleFormMode.add, vehicle: null))
          .overrideWithValue(mockNotifier),
      ],
      child: const MaterialApp(
        home: VehicleFormPage(mode: VehicleFormMode.add),
      ),
    );
  }

  testWidgets('shows loading indicator when submitting', (tester) async {
    // Arrange
    await tester.pumpWidget(createTestWidget(
      state: const VehicleFormState(
        mode: VehicleFormMode.add,
        isSubmitting: true,
      ),
    ));

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byKey(const Key('save_button')), findsNothing);
  });

  testWidgets('calls submitForm when save button tapped', (tester) async {
    // Arrange
    when(() => mockNotifier.submitForm(
      name: any(named: 'name'),
      capacity: any(named: 'capacity'),
      description: any(named: 'description'),
    )).thenAnswer((_) async => true);

    await tester.pumpWidget(createTestWidget());

    // Fill form
    await tester.enterText(find.byKey(const Key('name_field')), 'Test Car');
    await tester.enterText(find.byKey(const Key('capacity_field')), '5');
    await tester.pumpAndSettle();

    // Act
    await tester.tap(find.byKey(const Key('save_button')));
    await tester.pump();

    // Assert
    verify(() => mockNotifier.submitForm(
      name: 'Test Car',
      capacity: 5,
      description: any(named: 'description'),
    )).called(1);
  });
}
```

### C. Integration Test Pattern

```dart
// TEMPLATE: integration_test/vehicle_management_flow_test.dart

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late DioAdapter dioAdapter;

  setUp(() async {
    // Reset test container
    
    final dio = Dio();
    dioAdapter = DioAdapter(dio: dio);
    
    // Setup test container with mocked Dio
    testContainer = ProviderContainer(overrides: [
      apiDioProvider.overrideWithValue(dio),
    ]);
    // Riverpod providers auto-initialize
    
    runApp(const MyApp());
  });

  testWidgets('User adds vehicle and sees it in list', (tester) async {
    // Arrange: Mock network responses
    dioAdapter.onPost(
      '/api/vehicles',
      (server) => server.reply(201, {
        'id': 'vehicle-123',
        'name': 'My Test Car',
        'capacity': 5,
        'description': 'Test vehicle',
      }),
    );

    dioAdapter.onGet(
      '/api/vehicles',
      (server) => server.reply(200, [
        {
          'id': 'vehicle-123',
          'name': 'My Test Car',
          'capacity': 5,
          'description': 'Test vehicle',
        }
      ]),
    );

    // Act: Start the flow
    await tester.pumpAndSettle();
    
    // Navigate to add vehicle
    await tester.tap(find.byKey(const Key('add_vehicle_fab')));
    await tester.pumpAndSettle();

    // Fill the form
    await tester.enterText(find.byKey(const Key('name_field')), 'My Test Car');
    await tester.enterText(find.byKey(const Key('capacity_field')), '5');
    await tester.enterText(
      find.byKey(const Key('description_field')), 
      'Test vehicle',
    );
    await tester.pumpAndSettle();

    // Submit the form
    await tester.tap(find.byKey(const Key('save_button')));
    await tester.pumpAndSettle();

    // Assert: Verify end-to-end result
    expect(find.text('My Test Car'), findsOneWidget);
    expect(find.text('5 seats'), findsOneWidget);
  });
}
```

## 4. Pre-Commit and CI/CD Enforcement

### GitHub Branch Protection Rules
```yaml
# Required status checks:
- flutter-analyze
- flutter-format-check  
- unit-tests
- widget-tests
- integration-tests
- build-verification
- coverage-gate (minimum 80%)
```

### Pre-commit Hook
```bash
#!/bin/sh
# .git/hooks/pre-commit

echo "Running Flutter pre-commit checks..."

# Format check
if ! flutter format --set-exit-if-changed .; then
  echo "❌ Code formatting failed. Run 'flutter format .' to fix."
  exit 1
fi

# Analysis
if ! flutter analyze; then
  echo "❌ Static analysis failed. Fix the issues above."
  exit 1
fi

echo "✅ Pre-commit checks passed!"
```

## 5. Enforcement Mechanisms

### Pull Request Template
```markdown
<!-- .github/PULL_REQUEST_TEMPLATE.md -->

## Testing Checklist

### Root Cause Analysis
- [ ] If tests were failing, I identified the root cause
- [ ] I fixed APPLICATION code (not test workarounds) for app bugs
- [ ] I fixed TEST code (not app workarounds) for test bugs
- [ ] No commented-out assertions or weakened expectations

### Test Coverage
- [ ] Unit tests cover new business logic
- [ ] Widget tests verify UI behavior 
- [ ] Integration tests validate critical user flows
- [ ] All tests use proper mocking strategies

### Manual Verification  
- [ ] I manually tested the feature in the app
- [ ] The behavior matches what the tests expect
- [ ] No shortcuts or workarounds were used

## Changes Made
- **Application Code Changes:** [Describe fixes to business logic]
- **Test Code Changes:** [Describe test improvements/additions]
```

### Code Review Checklist
1. **No Test Workarounds:** Reviewer must verify no commented assertions, weakened expectations, or overly permissive mocks
2. **Real Behavior Testing:** Tests must validate actual expected business behavior
3. **Root Cause Fixes:** Changes must address underlying issues, not symptoms
4. **Manual Verification:** PR author must confirm manual testing was performed

## 6. Common Anti-Patterns (FORBIDDEN)

### ❌ FORBIDDEN TEST PATTERNS:
```dart
// DON'T: Comment out failing assertions
// expect(result.isSuccess, isTrue);

// DON'T: Weaken assertions to make tests pass  
expect(result.data, isNotNull); // Instead of checking actual values

// DON'T: Use overly permissive mocks
when(() => mockRepo.getData()).thenReturn(any()); // Should return specific data

// DON'T: Catch and ignore test exceptions
try {
  await widget.submitForm();
} catch (e) {
  // Ignoring error to make test pass
}
```

### ✅ REQUIRED PATTERNS:
```dart
// DO: Fix the application code to match test expectations
await notifier.submitForm();
expect(notifier.state.isSubmitting, isFalse);
expect(notifier.state.vehicle?.name, equals('Test Car'));

// DO: Use specific, realistic mock responses
when(() => mockRepo.addVehicle(any())).thenAnswer(
  (_) async => Ok(const Vehicle(id: '1', name: 'Test Car', capacity: 5)),
);

// DO: Test actual business behavior
expect(VehicleFormValidator.validateName(''), equals('Vehicle name is required'));
expect(VehicleFormValidator.validateName('Valid Name'), isNull);
```

## 7. Success Metrics

- **Zero Workaround Fixes**: All test failures resolved by fixing root causes
- **High Confidence**: Tests accurately reflect application behavior  
- **Fast Feedback**: Developers can trust failing tests indicate real issues
- **Production Quality**: Applications behave exactly as tested
- **Team Velocity**: Time spent on genuine bug fixes, not test maintenance

---

**REMEMBER**: The goal is ensuring when applications reach production, they work exactly as tested - no surprises, no mock implementations, no fake data dependencies.