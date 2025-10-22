# AI Agent Testing Guidelines

## 📁 Directory Structure
```
test/
├── unit/              # Pure logic tests (no widgets): business logic, services, repositories
├── presentation/      # Widget tests (UI components): screens, widgets, providers
├── integration/       # End-to-end scenarios: full user flows, API integration
├── support/           # Test helpers, mocks, builders
├── fixtures/          # Test data, builders
└── AGENTS.md          # This file
```

## 🎯 What to Test Where
- **unit/**: Business logic, data transformations, algorithms, validation rules
- **presentation/**: UI behavior, user interactions, state changes, navigation
- **integration/**: Complete workflows, API + UI + state working together
- **NEVER test**: Mock return values, constant variables, static data

## ⚡ Efficient Commands
- `flutter test test/unit/` - Unit tests only
- `flutter test test/presentation/` - Widget tests only  
- `flutter test path/to/specific_test.dart` - Single file
- `flutter test --name "test description"` - Specific test
- `flutter test --reporter=compact` - Less verbose output

## 📊 JSON Analysis (Most Efficient)
```bash
# Export test results to JSON for analysis
flutter test --reporter=json > test_results.json

# JSON structure: Each line is a separate JSON object
# Types: "start", "testStart", "testDone", "done"
```

```bash
# Get failed tests only
grep '"result":"error"' test_results.json | jq '.test.name'

# Count total failures
grep '"result":"error"' test_results.json | wc -l

# Get test summary
grep '"type":"done"' test_results.json | jq '{success, skipped, failed: (.failed // 0)}'

# Find specific test errors
grep '"name":"test description"' test_results.json | jq '.error'
```

## 🎯 Core Rules
1. **ALWAYS use find.byKey()** - Add Key('unique_id') to widgets, never use find.text() with ambiguous text
2. **NEVER find.text() for duplicates** - If text appears multiple times, use keys instead
3. **Keys must be unique** - Each testable widget needs a unique key
4. **findsOneWidget for keys** - Keys should always find exactly one widget

## 🔧 Widget Key Patterns
```dart
// ✅ CORRECT: Add keys to widgets
Text('Save', key: Key('save_button'))
TextButton(key: Key('cancel_button'), ...)

// ✅ CORRECT: Test with keys
expect(find.byKey(Key('save_button')), findsOneWidget);
await tester.tap(find.byKey(Key('cancel_button')));

// ❌ WRONG: Using ambiguous text
expect(find.text('Save'), findsOneWidget); // May find multiple
```

## 📋 Test Structure
```dart
testWidgets('description', (tester) async {
  // ARRANGE - Setup widget with provider overrides
  final widget = ProviderScope(child: TestWidget());
  
  // ACT - Pump widget and interact
  await tester.pumpWidget(widget);
  await tester.tap(find.byKey(Key('action_button')));
  
  // ASSERT - Verify expected state
  expect(find.byKey(Key('result')), findsOneWidget);
});
```

## 🏗️ Mock Setup Pattern
```dart
setUp(() async {
  await TestEnvironment.initialize(); // Always initialize
});

tearDown(() async {
  container?.dispose();
  await TestEnvironment.cleanup();
});
```

## 🏆 Golden Tests
```dart
// ALWAYS use simple_widget_test_helper.dart for golden generation
import '../support/simple_widget_test_helper.dart';

testWidgets('golden test', (tester) async {
  await tester.pumpWidget(SimpleWidgetTestHelper.wrapWidget(MyWidget()));
  await expectLater(find.byType(MyWidget), matchesGoldenFile('my_widget.png'));
});
```

## 🗑️ Garbage Testing (FORBIDDEN)
```dart
// GARBAGE - Testing mocks/constants
expect(mockService.returnValue, 'constant'); // Tests nothing real
expect(testData.name, 'John'); // Tests static data
when(mockRepo.get()).thenReturn(data); 
expect(mockRepo.get(), data); // Tests mock setup, not logic

// GOOD - Test real behavior
expect(service.processData(input), expectedOutput); // Tests actual logic
```

## 🚫 Forbidden Patterns
- `find.text()` when text appears multiple times
- `findsAtLeastNWidgets()` without specific reason
- `expect(find.byType(TextButton), findsNWidgets(2))` - use keys instead
- Hardcoded widget assumptions without keys
- **Silent failures**: `if (condition) return;` - always throw error instead
- **Conditional testing**: Testing only when element exists - enforce requirements
- **Fallback testing**: Testing different functionality when primary fails
- **Generic error handling**: `try/catch` without specific error handling
- **Testing mocks**: Never test mock return values or constant data

## ⚡ Quick Fixes
- **Multiple widgets error**: Add unique keys to each widget
- **Accessibility failure**: Use keys instead of semantic labels for testing
- **Widget finder issues**: Replace find.text() with find.byKey()
- **Provider errors**: Ensure TestEnvironment.initialize() is called

## 🎨 Common Widget Keys
- `Key('dialog_title')` - Dialog titles
- `Key('primary_button')` - Main action buttons
- `Key('cancel_button')` - Cancel buttons
- `Key('member_name')` - User/member display names
- `Key('error_message')` - Error text widgets

## 🔬 Async/Await Testing Research Findings

### FakeAsync Techniques for Hang Detection

Previous testing approaches were incomplete because they:
1. Used regular timeouts that don't actually test async behavior
2. Mocked operations without reproducing real async timing issues
3. Failed to use FakeAsync properly to control microtask execution

### Key Findings

**Problem**: The user reports hanging at "🏠 Family ID is null, attempting to fetch family data" - specifically `_familyCacheService.cacheFamilyData()` never completes with either success or failure logs.

**Root Cause Investigation**: 
- The `GetFamilyUsecase.call()` method uses `Future.wait()` for parallel caching operations
- If any of the caching operations in the `Future.wait` hang, the entire operation hangs
- The issue is likely in one of the repository cache methods not properly completing

**FakeAsync Research**:
- FakeAsync allows manual control of microtasks and timers
- `fakeAsync.flushMicrotasks()` can expose incomplete async operations
- `fakeAsync.elapse()` can advance time to expose hanging Futures
- Proper TDD requires tests that FAIL with buggy code and PASS with fixed code

### Proper Test Strategy

1. Use FakeAsync to control async execution
2. Test each caching operation individually to isolate the hanging operation
3. Use manual microtask pumping to expose incomplete Futures
4. Create tests that actually reproduce the hang behavior

### Previous Test Issues

The existing tests were ineffective because they:
- Used mocks that always succeeded quickly
- Didn't test real async timing behavior  
- Couldn't reproduce the actual hang condition
- Passed even with buggy code, making them useless for TDD

### FakeAsync Pattern for Hang Detection

```dart
testWidgets('should not hang on Future.wait operations', (tester) async {
  await tester.runAsync(() async {
    fakeAsync((async) {
      // Setup mocks with controlled delays
      when(mockRepo.cacheChildren(any)).thenAnswer((_) async {
        // Simulate operation that never completes
        return Completer<Result<void, ApiFailure>>().future;
      });
      
      // Start the operation
      final future = usecase.call(NoParams());
      
      // Flush microtasks - this will expose hanging operations
      async.flushMicrotasks();
      
      // Advance time - hanging operations won't complete
      async.elapse(Duration(seconds: 5));
      
      // The operation should complete or we can detect it's hanging
      expect(future, completion(anything)); // This will fail if hanging
    });
  });
});
```

### Next Steps

Create a proper TDD test using FakeAsync that:
- Actually fails with the current buggy code
- Tests the exact hang scenario from user logs
- Uses manual microtask control to expose incomplete operations
- Passes only after applying the proper fix