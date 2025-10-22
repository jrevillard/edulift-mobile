# Repository Pattern Architecture Design
## FamilyRepositoryImpl - Offline-First Coordination Strategy

> **System Architecture Document** 🏗️  
> **Generated with [Claude Code](https://claude.ai/code)**  
> **Co-Authored-By: Claude <noreply@anthropic.com>**

## 🎯 ARCHITECTURAL OVERVIEW

The `FamilyRepositoryImpl` implements a sophisticated **Repository Pattern** with **offline-first** capabilities using **composition over inheritance**. This design provides robust data coordination between remote APIs and local storage with comprehensive error recovery.

### Core Design Principles

1. **Clean Architecture Compliance**: Domain → Data dependency flow
2. **Composition Over Inheritance**: Specialized repository delegation
3. **Offline-First Strategy**: Local data precedence with sync
4. **Defensive Programming**: Comprehensive error handling
5. **TDD London Approach**: Mock all dependencies for isolated testing

## 🏗️ ARCHITECTURE COMPONENTS

### Repository Composition Structure

```
FamilyRepositoryImpl (Orchestrator)
├── FamilyRepositoryCore (Core operations)
├── FamilyMembersRepository (Member management)  
├── FamilyInvitationsRepository (Invitation handling)
├── FamilyOfflineSyncRepository (Sync coordination)
├── ChildrenRepository (Child operations)
└── VehiclesRepository (Vehicle operations)
```

### Datasource Coordination Pattern

```
[Repository Layer]
     ↓
[Remote Datasource] ←→ [Local Datasource]
     ↓                       ↓
[HTTP/API Client]      [SQLite/Cache]
     ↓                       ↓
[External API]          [Device Storage]
```

## 📋 COORDINATION STRATEGIES

### 1. **Try Remote → Cache Locally → Return Data**

```dart
Future<Result<T, Failure>> coordinatedFetch<T>() async {
  try {
    // Step 1: Attempt remote fetch
    final remoteData = await remoteDataSource.fetch();
    
    // Step 2: Cache successful result
    await localDataSource.cache(remoteData);
    
    // Step 3: Return fresh data
    return Result.ok(remoteData);
  } catch (e) {
    // Fall back to cached data (Strategy 2)
    return await fallbackToCached();
  }
}
```

### 2. **Remote Fails → Return Cached Data**

```dart
Future<Result<T, Failure>> fallbackToCached<T>() async {
  try {
    final cachedData = await localDataSource.getCached();
    if (cachedData != null) {
      return Result.ok(cachedData);
    } else {
      return Result.err(ApiFailure.cacheError(
        message: 'No cached data available'
      ));
    }
  } catch (e) {
    return Result.err(ApiFailure.cacheError(
      message: 'Cache retrieval failed: $e'
    ));
  }
}
```

### 3. **No Cache → Return Appropriate Failure**

```dart
Future<Result<T, Failure>> handleNoCacheScenario<T>() async {
  return Result.err(ApiFailure.networkError(
    message: 'No network connection and no cached data available'
  ));
}
```

### 4. **Sync Conflicts → Resolution Strategy**

```dart
Future<Result<T, Failure>> resolveConflicts<T>(
  T localData, 
  T remoteData
) async {
  // Conflict Resolution Strategies:
  
  // 1. Last Write Wins (timestamp-based)
  if (remoteData.updatedAt.isAfter(localData.updatedAt)) {
    await localDataSource.cache(remoteData);
    return Result.ok(remoteData);
  }
  
  // 2. Manual Resolution Required
  if (hasConflicts(localData, remoteData)) {
    return Result.err(ApiFailure.conflictError(
      message: 'Manual conflict resolution required',
      localData: localData,
      remoteData: remoteData,
    ));
  }
  
  // 3. Merge Strategy (field-level)
  final mergedData = mergeData(localData, remoteData);
  await localDataSource.cache(mergedData);
  return Result.ok(mergedData);
}
```

## 🧪 TDD LONDON TESTING STRATEGY

### Test Structure Philosophy

**TDD London (Mockist)** approach ensures:
- ✅ **Isolated Unit Tests**: Mock ALL external dependencies
- ✅ **Behavior Verification**: Test coordination logic, not implementation
- ✅ **Fast Execution**: No real network or database calls
- ✅ **Deterministic Results**: Predictable test outcomes

### Mock Strategy

```dart
class MockFamilyLocalDataSource extends Mock implements FamilyLocalDataSource {}
class MockFamilyRemoteDataSource extends Mock implements FamilyRemoteDataSource {}

void main() {
  group('FamilyRepositoryImpl - Coordination Tests', () {
    late FamilyRepositoryImpl repository;
    late MockFamilyLocalDataSource mockLocalDataSource;
    late MockFamilyRemoteDataSource mockRemoteDataSource;
    
    setUp(() {
      mockLocalDataSource = MockFamilyLocalDataSource();
      mockRemoteDataSource = MockFamilyRemoteDataSource();
      
      repository = FamilyRepositoryImpl(
        localDataSource: mockLocalDataSource,
        remoteDataSource: mockRemoteDataSource,
      );
    });
    
    // Test coordination patterns...
  });
}
```

### Critical Test Scenarios

#### 1. **Happy Path - Remote Success + Local Cache**

```dart
test('should fetch from remote and cache locally on success', () async {
  // Arrange
  when(() => mockRemoteDataSource.getCurrentFamily())
      .thenAnswer((_) async => testFamily);
  when(() => mockLocalDataSource.cacheFamily(any()))
      .thenAnswer((_) async {});
  
  // Act
  final result = await repository.getCurrentFamily();
  
  // Assert
  expect(result.isRight(), true);
  verify(() => mockRemoteDataSource.getCurrentFamily()).called(1);
  verify(() => mockLocalDataSource.cacheFamily(testFamily)).called(1);
});
```

#### 2. **Network Failure - Fallback to Cache**

```dart
test('should fallback to cached data when remote fails', () async {
  // Arrange
  when(() => mockRemoteDataSource.getCurrentFamily())
      .thenThrow(NetworkException('No internet'));
  when(() => mockLocalDataSource.getCachedFamily())
      .thenAnswer((_) async => testFamily);
  
  // Act
  final result = await repository.getCurrentFamily();
  
  // Assert
  expect(result.isRight(), true);
  verify(() => mockRemoteDataSource.getCurrentFamily()).called(1);
  verify(() => mockLocalDataSource.getCachedFamily()).called(1);
});
```

#### 3. **Complete Failure - No Cache Available**

```dart
test('should return failure when both remote and cache fail', () async {
  // Arrange
  when(() => mockRemoteDataSource.getCurrentFamily())
      .thenThrow(NetworkException('No internet'));
  when(() => mockLocalDataSource.getCachedFamily())
      .thenAnswer((_) async => null);
  
  // Act
  final result = await repository.getCurrentFamily();
  
  // Assert
  expect(result.isLeft(), true);
  result.fold(
    (failure) => expect(failure, isA<ApiFailure>()),
    (_) => fail('Should return failure'),
  );
});
```

#### 4. **Sync Conflict Resolution**

```dart
test('should resolve conflicts using last-write-wins strategy', () async {
  // Arrange
  final localFamily = testFamily.copyWith(
    name: 'Local Name',
    updatedAt: DateTime.now().subtract(Duration(hours: 1)),
  );
  final remoteFamily = testFamily.copyWith(
    name: 'Remote Name',
    updatedAt: DateTime.now(),
  );
  
  when(() => mockRemoteDataSource.getCurrentFamily())
      .thenAnswer((_) async => remoteFamily);
  when(() => mockLocalDataSource.getCachedFamily())
      .thenAnswer((_) async => localFamily);
  when(() => mockLocalDataSource.cacheFamily(any()))
      .thenAnswer((_) async {});
  
  // Act
  final result = await repository.getCurrentFamily();
  
  // Assert
  expect(result.isRight(), true);
  result.fold(
    (_) => fail('Should succeed'),
    (family) => expect(family.name, 'Remote Name'), // Remote wins
  );
  verify(() => mockLocalDataSource.cacheFamily(remoteFamily)).called(1);
});
```

## 🔄 OFFLINE SYNC PATTERNS

### Pending Changes Queue

```dart
class PendingChange {
  final String id;
  final ChangeType type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;
  
  const PendingChange({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });
}

enum ChangeType {
  createFamily,
  updateFamily,
  deleteFamily,
  createChild,
  updateChild,
  deleteChild,
  // ... other change types
}
```

### Optimistic Updates

```dart
Future<Result<Family, ApiFailure>> updateFamilyName({
  required String name,
}) async {
  // Step 1: Optimistic local update
  final optimisticFamily = currentFamily.copyWith(
    name: name,
    updatedAt: DateTime.now(),
  );
  await localDataSource.cacheFamily(optimisticFamily);
  
  try {
    // Step 2: Attempt remote update
    final updatedFamily = await remoteDataSource.updateFamilyName(name: name);
    
    // Step 3: Confirm with server response
    await localDataSource.cacheFamily(updatedFamily);
    
    return Result.ok(updatedFamily);
  } catch (e) {
    // Step 4: Store for later sync
    await localDataSource.storePendingChange(
      PendingChange(
        id: uuid.v4(),
        type: ChangeType.updateFamily,
        data: {'name': name},
        createdAt: DateTime.now(),
      ),
    );
    
    // Return optimistic result
    return Result.ok(optimisticFamily);
  }
}
```

## 🛡️ ERROR RECOVERY STRATEGIES

### 1. **Retry with Exponential Backoff**

```dart
Future<T> retryWithBackoff<T>(
  Future<T> Function() operation,
  {int maxRetries = 3}
) async {
  for (int attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await operation();
    } catch (e) {
      if (attempt == maxRetries - 1) rethrow;
      
      final delay = Duration(seconds: math.pow(2, attempt).toInt());
      await Future.delayed(delay);
    }
  }
  throw Exception('Max retries exceeded');
}
```

### 2. **Circuit Breaker Pattern**

```dart
class CircuitBreaker {
  int _failureCount = 0;
  DateTime? _lastFailureTime;
  final int failureThreshold;
  final Duration recoveryTimeout;
  
  bool get isOpen => _failureCount >= failureThreshold &&
    _lastFailureTime != null &&
    DateTime.now().difference(_lastFailureTime!) < recoveryTimeout;
    
  Future<T> execute<T>(Future<T> Function() operation) async {
    if (isOpen) {
      throw CircuitBreakerOpenException();
    }
    
    try {
      final result = await operation();
      _reset();
      return result;
    } catch (e) {
      _recordFailure();
      rethrow;
    }
  }
}
```

## 📊 PERFORMANCE CONSIDERATIONS

### Caching Strategy

- **TTL-based expiration**: Auto-expire stale data
- **LRU eviction**: Remove least recently used items
- **Partial updates**: Update only changed fields
- **Batch operations**: Group multiple changes

### Memory Management

- **Lazy loading**: Load data on demand
- **Weak references**: Prevent memory leaks
- **Disposal patterns**: Clean up resources
- **Background cleanup**: Periodic cache maintenance

## 🔍 TESTING CHECKLIST

### Repository Coordination Tests

- [ ] **Remote success → Local cache → Return data**
- [ ] **Remote failure → Cached fallback → Return cached**
- [ ] **Both fail → Appropriate error → User feedback**
- [ ] **Sync conflicts → Resolution strategy → Consistent state**
- [ ] **Optimistic updates → Background sync → Eventual consistency**
- [ ] **Network recovery → Retry pending → Sync completion**
- [ ] **Cache expiration → Fresh fetch → Updated cache**
- [ ] **Concurrent requests → Deduplication → Single API call**

### Error Handling Tests

- [ ] **Network timeouts → Graceful degradation**
- [ ] **Authentication errors → Re-auth flow**
- [ ] **Server errors → Retry with backoff**
- [ ] **Validation errors → User feedback**
- [ ] **Cache corruption → Recovery mechanism**

### Performance Tests

- [ ] **Response times → Under acceptable limits**
- [ ] **Memory usage → No memory leaks**
- [ ] **Cache hit rates → Efficient caching**
- [ ] **Background sync → Non-blocking UI**

## 🚀 IMPLEMENTATION GUIDANCE

### Step 1: Mock Setup
Create comprehensive mocks for all datasources

### Step 2: Coordination Logic
Implement try-remote-cache-fallback pattern

### Step 3: Error Handling  
Add defensive programming with proper error types

### Step 4: Offline Support
Implement pending changes queue and optimistic updates

### Step 5: Conflict Resolution
Add timestamp-based or manual conflict resolution

### Step 6: Performance Optimization
Add caching, batching, and background sync

### Step 7: Comprehensive Testing
Cover all coordination scenarios with TDD London approach

---

**Architecture Decision Records (ADR)**
- ADR-001: Repository Pattern with Composition
- ADR-002: Offline-First Strategy
- ADR-003: TDD London Testing Approach
- ADR-004: Conflict Resolution Strategy