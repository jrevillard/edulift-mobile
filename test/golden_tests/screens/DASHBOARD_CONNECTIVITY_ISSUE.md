# Dashboard Golden Test - Connectivity Plugin Issue

## Problem
Dashboard golden tests fail because `ConnectivityProvider` requires native plugin initialization which isn't available in golden tests.

## Error
```
MissingPluginException: No implementation found for method listen on channel dev.fluttercommunity.plus/connectivity_status
```

## Root Cause
- `ConnectivityNotifier` constructor calls `_initialize()` which uses `Connectivity().onConnectivityChanged`
- This requires the native connectivity_plus plugin
- Cannot be mocked easily without modifying production code

## Attempted Solutions
1. **Mock StateNotifier** - Type error: StateNotifier<AsyncValue<bool>> isn't compatible with ConnectivityNotifier
2. **Platform Channel Mock** - Disposal issues and subscription problems
3. **Override Constructor** - Cannot prevent parent constructor from running

## Recommended Solution
Add a test-only constructor to ConnectivityNotifier in production code:

```dart
class ConnectivityNotifier extends StateNotifier<AsyncValue<bool>> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityNotifier() : super(const AsyncValue.loading()) {
    _initialize();
  }

  // Test-only constructor
  @visibleForTesting
  ConnectivityNotifier.test(AsyncValue<bool> initialState) : super(initialState);

  // ...
}
```

Then in tests:
```dart
connectivityProvider.overrideWith((ref) => ConnectivityNotifier.test(const AsyncValue.data(true))),
```

## Status
**BLOCKED** - Requires production code changes or skip connectivity testing
