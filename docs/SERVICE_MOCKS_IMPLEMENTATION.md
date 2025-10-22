# Service Mocks Implementation - New Service Architecture

## Overview

This document outlines the implementation of mock services for the new service architecture consolidation. The consolidation plan has moved from repository-based patterns to service-based patterns, requiring updated mock implementations for testing.

## Implemented Service Mocks

### 1. GroupService Mock (`MockGroupService`)

**Location**: Auto-generated in `test/test_mocks/test_mocks.mocks.dart`

**Methods Mocked**:
- `getAll()` → `Future<Result<List<Group>, ApiFailure>>`
- `getById(String id)` → `Future<Result<Group, ApiFailure>>`  
- `create(CreateGroupCommand command)` → `Future<Result<Group, ApiFailure>>`
- `update(String id, Map<String, dynamic> updates)` → `Future<Result<Group, ApiFailure>>`
- `delete(String id)` → `Future<Result<void, ApiFailure>>`

**Usage**:
```dart
final mockGroupService = getFreshMock<MockGroupService>();
// Pre-configured with default stubs returning dummy values
```

### 2. ChildrenService Mock (`MockChildrenService`)

**Location**: Auto-generated in `test/test_mocks/test_mocks.mocks.dart`

**Methods Mocked**:
- `add(CreateChildRequest request)` → `Future<Result<Child, ApiFailure>>`
- `update(UpdateChildParams params)` → `Future<Result<Child, ApiFailure>>`
- `remove(String childId)` → `Future<Result<void, ApiFailure>>`

**Usage**:
```dart
final mockChildrenService = getFreshMock<MockChildrenService>();
// Pre-configured with default stubs returning dummy child entities
```

### 3. AuthService Mock (`MockFeatureAuthService`)

**Location**: Manually implemented in `test/test_mocks/test_specialized_mocks.dart`

**Methods Mocked**:
- `sendMagicLink(String email)` → `Future<Result<void, ApiFailure>>`
- `authenticateWithMagicLink(String token)` → `Future<Result<AuthResult, ApiFailure>>`
- `getCurrentUser()` → `Future<Result<User, ApiFailure>>`
- `enableBiometricAuth()` → `Future<Result<User, ApiFailure>>`
- `disableBiometricAuth()` → `Future<Result<User, ApiFailure>>`
- `logout()` → `Future<Result<void, ApiFailure>>`
- `isAuthenticated()` → `Future<Result<bool, ApiFailure>>`

**Usage**:
```dart
final mockAuthService = TestMockFactory.createMockFeatureAuthService();
// Can be used with Mockito's when/verify for custom behavior
```

**Note**: This mock was implemented manually due to naming conflicts between the core `AuthService` and the feature-specific `AuthService`. The feature version was given a custom name to avoid build conflicts.

## Implementation Details

### Auto-Generated Mocks

The `GroupService` and `ChildrenService` mocks are generated automatically using Mockito's `@GenerateNiceMocks` annotation:

```dart
@GenerateNiceMocks([
  // Feature Service Mocks - New Service Architecture
  MockSpec<GroupService>(),
  MockSpec<ChildrenService>(),
])
```

### Manual Mock Implementation

The `MockFeatureAuthService` was implemented manually to resolve naming conflicts:

```dart
class MockFeatureAuthService extends Mock implements feature_auth.AuthService {
  // Manual implementation with proper noSuchMethod overrides
  // Provides default return values and supports Mockito when/verify patterns
}
```

### Dummy Value Integration

All service mocks are integrated with the existing dummy value system in `_setupResultDummies()`:

```dart
// NEW SERVICE ARCHITECTURE DUMMY VALUES - Service Result patterns
// GroupService Results
provideDummy(Result<Group, ApiFailure>.ok(_createDummyGroup()));
provideDummy(const Result<List<Group>, ApiFailure>.ok([]));
provideDummy(const Result<void, ApiFailure>.ok(null));

// ChildrenService Results  
provideDummy(Result<Child, ApiFailure>.ok(_createDummyChild()));

// Feature AuthService Results
provideDummy(Result<AuthResult, ApiFailure>.ok(_createDummyAuthResult()));
provideDummy(const Result<bool, ApiFailure>.ok(true));
```

## Testing Support

### Mock Factory Integration

Service mocks are integrated into the `getFreshMock<T>()` factory function:

```dart
case MockGroupService:
  final mock = MockGroupService();
  // Pre-configured default stubs
  when(mock.getAll()).thenAnswer((_) async => const Result.ok([]));
  when(mock.getById(any)).thenAnswer((_) async => Result.ok(_createDummyGroup()));
  // ... other method stubs
  return mock as T;
```

### Result Pattern Support

All service mocks return `Result<T, ApiFailure>` types following the established error handling pattern. The `setupMockFallbacks()` function provides comprehensive dummy values for all Result patterns used by the services.

## Usage Examples

### Basic Mock Usage

```dart
void main() {
  setUpAll(() {
    setupMockFallbacks(); // Required for Result types
  });
  
  testWidgets('should use service mocks', (tester) async {
    final groupService = getFreshMock<MockGroupService>();
    final childrenService = getFreshMock<MockChildrenService>();
    final authService = TestMockFactory.createMockFeatureAuthService();
    
    // Use mocks in your tests
    final groups = await groupService.getAll();
    expect(groups.isOk, isTrue);
  });
}
```

### Custom Mock Behavior

```dart
test('should handle custom mock behavior', () async {
  final mockAuthService = TestMockFactory.createMockFeatureAuthService();
  
  // Customize behavior using Mockito
  when(mockAuthService.getCurrentUser()).thenAnswer(
    (_) async => Result.err(const ApiFailure(message: 'User not found'))
  );
  
  final result = await mockAuthService.getCurrentUser();
  expect(result.isErr, isTrue);
});
```

## Files Modified

### Core Mock Configuration
- `/test/test_mocks/test_mocks.dart` - Added service imports and @GenerateNiceMocks entries
- `/test/test_mocks/test_mocks.mocks.dart` - Auto-generated mock classes
- `/test/test_mocks/test_specialized_mocks.dart` - Manual MockFeatureAuthService implementation

### Integration Points
- `getFreshMock<T>()` factory function - Added service mock cases
- `_setupResultDummies()` - Added service Result pattern dummies
- `setupMockFallbacks()` - Integrated with existing mock setup system

## Architecture Compliance

The service mocks follow the established patterns:

1. **Result Pattern**: All service methods return `Result<T, ApiFailure>` types
2. **Dependency Injection**: Mocks integrate with the existing DI system
3. **Error Handling**: Support both success and error scenarios
4. **Test Isolation**: Each mock provides fresh instances with predictable defaults
5. **Mockito Integration**: Support when/verify patterns for custom test scenarios

## Future Maintenance

When adding new service interfaces:

1. Add the service import to `test_mocks.dart`
2. Add `MockSpec<NewService>()` to `@GenerateNiceMocks` annotation
3. Add case to `getFreshMock<T>()` function with default stubs
4. Add Result pattern dummies to `_setupResultDummies()`
5. Run `dart run build_runner build --delete-conflicting-outputs`

For naming conflicts, follow the manual implementation pattern used for `MockFeatureAuthService`.