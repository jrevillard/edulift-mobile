# Test Infrastructure Documentation

## Overview

This documentation covers the comprehensive test infrastructure designed to systematically fix 55+ test failures by addressing root causes in mock configuration, widget testing, and authentication patterns.

## Key Components

### 1. TestMockConfiguration (`test_mock_configuration.dart`)

**Purpose**: Centralized mock configuration to prevent `FakeUsedError` and `MissingDummyValueError`.

**Key Features**:
- Comprehensive `provideDummy` configuration for all `Result<T, Failure>` types
- Enhanced `MockErrorHandlerService` stubbing patterns
- Entity dummy values for Vehicle, Family, Child, User, Group, etc.
- Error handling dummy values

**Usage**:
```dart
// In your test file
import 'package:flutter_test/flutter_test.dart';
import '../support/test_mock_configuration.dart';

void main() {
  setUpAll(() {
    TestMockConfiguration.setupGlobalMocks();
  });
  
  group('Your tests', () {
    late MockErrorHandlerService mockErrorHandler;
    
    setUp(() {
      mockErrorHandler = MockErrorHandlerService();
      TestMockConfiguration.setupErrorHandlerMock(mockErrorHandler);
    });
    
    testWidgets('should handle errors properly', (tester) async {
      // Your test code here - no more FakeUsedError!
    });
  });
}
```

### 2. Widget Test Helper (`widget_test_helper.dart`)

**Purpose**: Universal widget testing utilities following Gemini Pro's recommendations.

**Key Features**:
- Universal `pumpApp()` helper
- Authentication scenario support
- Provider override patterns
- Form interaction helpers
- Performance monitoring

**Usage Examples**:

#### Basic Widget Testing
```dart
import '../support/widget_test_helper.dart';

testWidgets('should render widget correctly', (tester) async {
  await WidgetTestHelper.pumpApp(
    tester,
    MyWidget(),
    useMaterialApp: true,
    includeScaffold: true,
  );
  
  expect(find.byType(MyWidget), findsOneWidget);
});
```

#### Authentication Testing
```dart
testWidgets('should handle authenticated user', (tester) async {
  final mockUser = User(
    id: 'test-user',
    email: 'test@example.com',
    name: 'Test User',
    // ... other properties
  );
  
  await WidgetTestHelper.pumpAuthApp(
    tester,
    MyAuthenticatedWidget(),
    isAuthenticated: true,
    mockUser: mockUser,
  );
  
  expect(find.text('Welcome, Test User'), findsOneWidget);
});
```

#### Provider Testing
```dart
testWidgets('should work with provider overrides', (tester) async {
  await WidgetTestHelper.pumpProviderApp(
    tester,
    MyProviderWidget(),
    providerOverrides: [
      myProvider.overrideWithValue(mockValue),
    ],
    testDescription: 'Provider override test',
  );
  
  // Test assertions
});
```

#### Form Testing
```dart
testWidgets('should handle form interactions', (tester) async {
  await WidgetTestHelper.pumpFormApp(
    tester,
    MyFormWidget(),
    includeKeyboardHandling: true,
  );
  
  // Fill form fields
  await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
  await tester.tap(find.byKey(Key('submit_button')));
  await tester.pumpAndSettle();
  
  // Assertions
});
```

### 3. Authentication Test Helper (`auth_test_helper.dart`)

**Purpose**: Comprehensive authentication testing patterns with systematic mock setup.

**Key Features**:
- Mock user creation
- Auth repository stubbing
- Magic link flow testing
- Authentication state persistence
- Logout functionality testing

**Usage Examples**:

#### Basic Auth Testing
```dart
import '../support/auth_test_helper.dart';

testWidgets('should authenticate user successfully', (tester) async {
  await AuthTestHelper.testAuthenticationFlow(
    tester,
    child: LoginPage(),
    expectSuccess: true,
    mockUser: AuthTestHelper.createMockUser(
      email: 'test@example.com',
      name: 'Test User',
    ),
  );
  
  expect(find.byType(DashboardPage), findsOneWidget);
});
```

#### Magic Link Testing
```dart
test('should handle magic link authentication', () async {
  await AuthTestHelper.testMagicLinkFlow(
    tester,
    email: 'test@example.com',
    expectSuccess: true,
  );
});
```

#### Authentication State Persistence
```dart
testWidgets('should persist auth state', (tester) async {
  final mockUser = AuthTestHelper.createMockUser();
  
  await AuthTestHelper.testAuthStatePersistence(
    tester,
    child: MyApp(),
    mockUser: mockUser,
  );
  
  // Verify user state persisted after restart
});
```

#### Custom Auth Repository Setup
```dart
testWidgets('should handle auth failures', (tester) async {
  final authRepo = AuthTestHelper.setupMockAuthRepository(
    isAuthenticated: false,
    shouldFailLogin: true,
  );
  
  await WidgetTestHelper.pumpApp(
    tester,
    LoginPage(),
    providerOverrides: AuthTestHelper.createAuthProviderOverrides(
      customAuthRepo: authRepo,
      isAuthenticated: false,
    ),
  );
  
  // Test error scenarios
});
```

## Common Test Patterns

### 1. Provider Test Pattern
```dart
void main() {
  setUpAll(() {
    TestMockConfiguration.setupGlobalMocks();
  });
  
  group('MyProvider Tests', () {
    late MockRepository mockRepo;
    late ProviderContainer container;
    
    setUp(() {
      mockRepo = MockRepository();
      container = ProviderContainer(
        overrides: [
          repositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });
    
    tearDown(() {
      container.dispose();
    });
    
    test('should handle success case', () async {
      when(mockRepo.getData()).thenAnswer(
        (_) async => TestMockConfiguration.createSuccessResult('data'),
      );
      
      final result = await container.read(myProvider.future);
      expect(result, equals('data'));
    });
  });
}
```

### 2. Widget Integration Test Pattern
```dart
testWidgets('should integrate components properly', (tester) async {
  await WidgetTestHelper.initialize();
  
  final mockRepo = MockRepository();
  when(mockRepo.getData()).thenAnswer(
    (_) async => TestMockConfiguration.createSuccessResult(['item1', 'item2']),
  );
  
  await WidgetTestHelper.pumpApp(
    tester,
    MyComplexWidget(),
    providerOverrides: [
      repositoryProvider.overrideWithValue(mockRepo),
    ],
    includeScaffold: true,
  );
  
  // Wait for loading to complete
  await WidgetTestHelper.pumpAndSettleWithTimeout(tester);
  
  // Verify UI elements
  expect(find.text('item1'), findsOneWidget);
  expect(find.text('item2'), findsOneWidget);
  
  // Test interactions
  await tester.tap(find.byKey(Key('refresh_button')));
  await WidgetTestHelper.pumpAndSettleWithTimeout(tester);
  
  // Verify refresh behavior
  verify(mockRepo.getData()).called(2);
});
```

### 3. Error Handling Test Pattern
```dart
testWidgets('should handle errors gracefully', (tester) async {
  final mockErrorHandler = MockErrorHandlerService();
  TestMockConfiguration.setupErrorHandlerMock(mockErrorHandler);
  
  final mockRepo = MockRepository();
  when(mockRepo.getData()).thenAnswer(
    (_) async => TestMockConfiguration.createErrorResult('Network error'),
  );
  
  await WidgetTestHelper.pumpApp(
    tester,
    MyWidget(),
    providerOverrides: [
      repositoryProvider.overrideWithValue(mockRepo),
      errorHandlerProvider.overrideWithValue(mockErrorHandler),
    ],
  );
  
  await WidgetTestHelper.pumpAndSettleWithTimeout(tester);
  
  // Verify error handling
  expect(find.textContaining('Network error'), findsOneWidget);
  verify(mockErrorHandler.handleError(any, any)).called(1);
});
```

## Best Practices

### 1. Always Use TestMockConfiguration
```dart
// ✅ Good - Use centralized mock configuration
setUpAll(() {
  TestMockConfiguration.setupGlobalMocks();
});

// ❌ Bad - Manual mock setup without dummy values
// This leads to MissingDummyValueError
```

### 2. Use WidgetTestHelper for All Widget Tests
```dart
// ✅ Good - Use helper for consistent setup
await WidgetTestHelper.pumpApp(tester, widget);

// ❌ Bad - Manual widget setup
await tester.pumpWidget(MaterialApp(home: widget));
```

### 3. Leverage AuthTestHelper for Auth Scenarios
```dart
// ✅ Good - Use auth helper for authentication tests
await AuthTestHelper.testAuthenticationFlow(tester, child: widget);

// ❌ Bad - Manual auth mock setup
```

### 4. Handle Timeouts Properly
```dart
// ✅ Good - Use timeout-aware methods
await WidgetTestHelper.pumpAndSettleWithTimeout(tester);

// ❌ Bad - Use default pumpAndSettle (can hang)
await tester.pumpAndSettle();
```

### 5. Clean Up Resources
```dart
tearDownAll(() {
  AuthTestHelper.cleanup();
  WidgetTestHelper.tearDown();
});
```

## Troubleshooting

### Common Issues and Solutions

1. **FakeUsedError with MockErrorHandlerService**
   - **Solution**: Use `TestMockConfiguration.setupErrorHandlerMock()`

2. **MissingDummyValueError for Result types**
   - **Solution**: Call `TestMockConfiguration.setupGlobalMocks()` in `setUpAll()`

3. **Widget tests hanging on pumpAndSettle**
   - **Solution**: Use `WidgetTestHelper.pumpAndSettleWithTimeout()`

4. **Provider tests failing with missing overrides**
   - **Solution**: Use helper methods to create comprehensive provider overrides

5. **Authentication tests not working**
   - **Solution**: Use `AuthTestHelper` for proper auth mock setup

### Performance Monitoring

Use the built-in performance monitoring:
```dart
testWidgets('performance test', (tester) async {
  WidgetTestHelper.startPerformanceTimer('widget_load');
  
  await WidgetTestHelper.pumpApp(tester, MyWidget());
  
  WidgetTestHelper.stopPerformanceTimer('widget_load');
  // Check console for timing results
});
```

## Migration Guide

### From Old Test Patterns

1. **Replace manual mock setup**:
   ```dart
   // Old
   provideDummy<Result<Vehicle, Failure>>(/* manual setup */);
   
   // New
   TestMockConfiguration.setupGlobalMocks();
   ```

2. **Replace manual widget pumping**:
   ```dart
   // Old
   await tester.pumpWidget(MaterialApp(home: widget));
   
   // New
   await WidgetTestHelper.pumpApp(tester, widget);
   ```

3. **Replace manual auth setup**:
   ```dart
   // Old
   final mockAuth = MockAuthRepository();
   when(mockAuth.getCurrentUser())...
   
   // New
   final authRepo = AuthTestHelper.setupMockAuthRepository();
   ```

This infrastructure systematically addresses the root causes of test failures and provides a maintainable foundation for future test development.