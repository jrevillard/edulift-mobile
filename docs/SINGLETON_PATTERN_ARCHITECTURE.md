# Singleton Pattern Architecture Guide

## Critical Architecture Fix: Preventing Multiple Service Instances

### Problem Solved

**CRITICAL ISSUE**: Multiple instances of stateful services were being created across different providers, causing:

1. **DBus Hanging Issues**: Multiple `AdaptiveSecureStorage` instances performed duplicate environment detection
2. **Connection Conflicts**: Multiple `RealtimeWebSocketService` instances created competing connections
3. **Cache Inconsistencies**: Multiple `FamilyLocalDataSourceImpl` instances caused data corruption
4. **Protocol Handler Conflicts**: Multiple `DeepLinkServiceImpl` instances registered duplicate handlers

### Architecture Solution: Mandatory Singleton Pattern

## Services Requiring Singleton Pattern

### 1. AdaptiveSecureStorage
```dart
// ❌ WRONG - Creates multiple instances
final provider = Provider<AdaptiveSecureStorage>((ref) {
  return AdaptiveSecureStorage(); // CAUSES DBUS HANGING
});

// ✅ CORRECT - Uses singleton
final provider = Provider<AdaptiveSecureStorage>((ref) {
  return AdaptiveSecureStorage.getInstance(); // PREVENTS DBUS HANGING
});
```

**Why Singleton Required**:
- Performs expensive environment detection in constructor
- Multiple instances cause duplicate DBus calls that hang the system
- Maintains shared preference instance that should be consistent

### 2. RealtimeWebSocketService
```dart
// ❌ WRONG - Creates multiple connections
final provider = Provider<RealtimeWebSocketService>((ref) {
  return RealtimeWebSocketService(); // CAUSES CONNECTION CONFLICTS
});

// ✅ CORRECT - Uses singleton
final provider = Provider<RealtimeWebSocketService>((ref) {
  return RealtimeWebSocketService.getInstance(); // SINGLE CONNECTION
});
```

**Why Singleton Required**:
- Maintains WebSocket connection state
- Manages timers for heartbeat and reconnection
- Handles stream controllers for real-time events
- Multiple instances cause duplicate connections and event conflicts

### 3. DeepLinkServiceImpl
```dart
// ❌ WRONG - Creates multiple protocol handlers
final provider = Provider<DeepLinkService>((ref) {
  return DeepLinkServiceImpl(); // CAUSES PROTOCOL CONFLICTS
});

// ✅ CORRECT - Uses singleton
final provider = Provider<DeepLinkService>((ref) {
  return DeepLinkServiceImpl.getInstance(); // SINGLE HANDLER
});
```

**Why Singleton Required**:
- Registers platform protocol handlers
- Manages file watchers for deep link files
- Maintains deep link processing state
- Multiple instances cause conflicting protocol registrations

### 4. FamilyLocalDataSourceImpl
```dart
// ❌ WRONG - Creates multiple caches
final provider = Provider<FamilyLocalDataSource>((ref) {
  return FamilyLocalDataSourceImpl(); // CAUSES CACHE INCONSISTENCY
});

// ✅ CORRECT - Uses singleton
final provider = Provider<FamilyLocalDataSource>((ref) {
  return FamilyLocalDataSourceImpl.getInstance(); // CONSISTENT CACHE
});
```

**Why Singleton Required**:
- Maintains in-memory cache for family data
- Stores pending changes and ID mappings
- Multiple instances cause data synchronization issues

## Singleton Implementation Pattern

All stateful services must follow this exact pattern:

```dart
/// Service with singleton pattern
/// 
/// SINGLETON PATTERN: Prevents multiple instances that would cause
/// [specific problems this service would have with multiple instances].
class MyStatefulService implements MyServiceInterface {
  // Service state and dependencies
  SomeState _state;
  Timer? _timer;
  
  // SINGLETON PATTERN - Prevents multiple instances
  static MyStatefulService? _instance;
  
  /// Private constructor - prevents direct instantiation
  /// CRITICAL: This prevents multiple MyStatefulService instances
  /// that cause [specific problems].
  MyStatefulService._();

  /// Singleton instance getter - ONLY way to get MyStatefulService
  /// 
  /// ARCHITECTURE REQUIREMENT: All providers MUST use this method instead 
  /// of creating new instances with MyStatefulService().
  /// This ensures [specific benefit of singleton].
  static MyStatefulService getInstance() {
    _instance ??= MyStatefulService._();
    return _instance!;
  }
  
  // Service implementation...
}
```

## Provider Implementation Requirements

### ✅ Correct Provider Pattern
```dart
/// Provider for MyStatefulService
/// 
/// SINGLETON PATTERN: Uses getInstance() to prevent multiple instances
/// that cause [specific problems].
final myServiceProvider = Provider<MyServiceInterface>((ref) {
  // SINGLETON PATTERN: Use getInstance() to prevent [specific problems]
  return MyStatefulService.getInstance();
});
```

### ❌ Prohibited Provider Patterns
```dart
// NEVER DO THIS - Creates multiple instances
final badProvider = Provider<MyService>((ref) {
  return MyService(); // ❌ VIOLATES SINGLETON PATTERN
});

// NEVER DO THIS - Factory creates new instances
final badFactoryProvider = Provider.family<MyService, String>((ref, param) {
  return MyService(); // ❌ CREATES MULTIPLE INSTANCES
});
```

## Services That DON'T Need Singletons

### Stateless Services
```dart
// ✅ OK - Stateless service can have multiple instances
class ValidationService {
  const ValidationService(); // No state, safe to create multiple
  
  bool validateEmail(String email) {
    // Pure function, no shared state
    return email.contains('@');
  }
}
```

### Immutable Configuration
```dart
// ✅ OK - Immutable configuration
class ApiConfig {
  const ApiConfig({required this.baseUrl, required this.timeout});
  
  final String baseUrl;
  final Duration timeout;
  
  // No mutable state, safe to create multiple identical instances
}
```

## Enforcement Mechanisms

### 1. Private Constructor
- Makes the constructor private with `._()` 
- Prevents accidental direct instantiation
- Forces all code to use `getInstance()`

### 2. Static Instance Management
- Static `_instance` field holds the single instance
- `getInstance()` method provides controlled access
- Lazy initialization on first access

### 3. Code Review Requirements
- All new services must be evaluated for singleton requirement
- Any service with mutable state should be singleton
- Provider implementations must use `getInstance()`

## Testing Considerations

### Singleton Reset for Tests
```dart
// In test setup - reset singletons between tests
setUp(() {
  // Reset singleton instances for clean test state
  MyStatefulService.resetInstanceForTesting(); // If provided
});
```

### Mock Implementation for Tests
```dart
// Use dependency injection for testing
final mockProvider = Provider.overrideWithValue<MyService>(
  mockService, // Mock doesn't need to be singleton in tests
);
```

## Migration Checklist

When converting a service to singleton:

1. ✅ Add private constructor `._()` 
2. ✅ Add static `_instance` field
3. ✅ Add static `getInstance()` method
4. ✅ Update all provider files to use `getInstance()`
5. ✅ Add documentation explaining why singleton is required
6. ✅ Update tests if needed
7. ✅ Verify no direct constructor calls remain

## Prevention Measures

### Code Review Checklist
- [ ] New stateful services use singleton pattern
- [ ] Providers call `getInstance()` instead of constructor
- [ ] No direct instantiation in business logic
- [ ] Documentation explains singleton rationale

### Automated Detection
```dart
// Add lint rules to detect violations
// lint: avoid_direct_service_instantiation
final service = MyService(); // Should trigger lint warning
```

## Performance Impact

### Benefits
- **Prevents Resource Conflicts**: Single WebSocket connections, protocol handlers
- **Eliminates Duplicate Initialization**: Environment detection runs once
- **Consistent State**: Shared cache prevents data corruption
- **Memory Efficiency**: One instance instead of multiple

### Considerations
- **Lifecycle Management**: Singletons persist for app lifetime
- **Testing Complexity**: May need singleton reset utilities
- **Dependency Tracking**: Ensure proper cleanup on app termination

## Conclusion

The singleton pattern is **MANDATORY** for stateful services that:
1. Maintain connections (WebSocket, Database, Protocol handlers)
2. Perform expensive initialization (Environment detection, Authentication)
3. Manage shared state (Caches, Pending operations, Event streams)

This architecture prevents critical issues like DBus hanging, connection conflicts, and data corruption while ensuring consistent behavior across the application.