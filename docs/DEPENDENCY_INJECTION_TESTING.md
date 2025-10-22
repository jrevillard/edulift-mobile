# Dependency Injection Testing Guide 🔧

> **Best practices for testing with dependency injection and platform channel abstractions**

## 🎯 Overview

This guide demonstrates how to properly test services that depend on platform channels using dependency injection and the **Fake Pattern** - the officially recommended approach by Flutter documentation.

## 🏗️ Architecture Pattern

### The Problem: Platform Channel Dependencies

```dart
// ❌ Hard to test - platform channel dependency
class BadEncryptionService {
  static const _storage = FlutterSecureStorage(); // Platform dependency
  
  static Future<String> encrypt(String data) async {
    final key = await _storage.read(key: 'key'); // Fails in tests
    // ... encryption logic
  }
}
```

### The Solution: Dependency Injection + Abstractions

```dart
// ✅ Easy to test - dependency injection
abstract class SecureStorage {
  Future<String?> read({required String key});
  Future<void> write({required String key, required String value});
}

class EncryptionService {
  final SecureStorage _storage;
  EncryptionService(this._storage); // Dependency injection
  
  Future<String> encrypt(String data) async {
    final key = await _storage.read(key: 'key');
    // ... encryption logic
  }
}
```

## 📁 File Structure

```
lib/core/
├── storage/
│   ├── secure_storage.dart              # Abstract interface
│   └── flutter_secure_storage_adapter.dart  # Production implementation

test/fakes/
└── fake_secure_storage.dart             # Test implementation
```

## 🏭 Implementation Patterns

### 1. Abstract Interface

```dart
// lib/core/storage/secure_storage.dart
abstract class SecureStorage {
  Future<String?> read({required String key});
  Future<void> write({required String key, required String value});
  Future<void> delete({required String key});
}
```

### 2. Production Adapter

```dart
// lib/core/storage/flutter_secure_storage_adapter.dart
class FlutterSecureStorageAdapter implements SecureStorage {
  final FlutterSecureStorage _storage;
  
  FlutterSecureStorageAdapter({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();
  
  @override
  Future<String?> read({required String key}) => _storage.read(key: key);
  
  @override
  Future<void> write({required String key, required String value}) =>
      _storage.write(key: key, value: value);
}
```

### 3. Fake for Testing

```dart
// test/fakes/fake_secure_storage.dart
class FakeSecureStorage implements SecureStorage {
  final Map<String, String> _storage = {};
  Exception? _simulatedError;
  
  @override
  Future<String?> read({required String key}) async {
    if (_simulatedError != null) throw _simulatedError!;
    return _storage[key];
  }
  
  @override
  Future<void> write({required String key, required String value}) async {
    if (_simulatedError != null) throw _simulatedError!;
    _storage[key] = value;
  }
  
  // Test helpers
  void simulateError(Exception error) => _simulatedError = error;
  void clear() => _storage.clear();
  bool containsKey(String key) => _storage.containsKey(key);
}
```

### 4. Service with Dependency Injection

```dart
// lib/core/security/encryption_service.dart
@provider
class EncryptionService {
  final SecureStorage _storage;
  
  EncryptionService(this._storage);
  
  factory EncryptionService.production() => 
      EncryptionService(FlutterSecureStorageAdapter());
      
  Future<String> encrypt(String data) async {
    final key = await _getOrCreateKey();
    // ... encryption logic using key
    return 'encrypted:$data';
  }
  
  Future<String> _getOrCreateKey() async {
    final existingKey = await _storage.read(key: 'encryption_key');
    if (existingKey != null) return existingKey;
    
    final newKey = 'generated-${DateTime.now().millisecondsSinceEpoch}';
    await _storage.write(key: 'encryption_key', value: newKey);
    return newKey;
  }
}
```

## 🧪 Testing Implementation

### Test Setup

```dart
// test/core/security/encryption_service_test.dart
void main() {
  late FakeSecureStorage fakeStorage;
  late EncryptionService encryptionService;
  
  setUp(() {
    fakeStorage = FakeSecureStorage();
    encryptionService = EncryptionService(fakeStorage);
  });
  
  tearDown(() {
    fakeStorage.clear();
  });
```

### Success Path Testing

```dart
test('should encrypt data successfully', () async {
  // Arrange
  const testData = 'sensitive information';
  
  // Act
  final encryptedData = await encryptionService.encrypt(testData);
  
  // Assert
  expect(encryptedData, isA<String>());
  expect(encryptedData, isNotEmpty);
  expect(encryptedData, isNot(equals(testData)));
  
  // Verify storage interaction
  expect(fakeStorage.containsKey('encryption_key'), isTrue);
});
```

### Error Path Testing

```dart
test('should handle storage errors gracefully', () async {
  // Arrange
  fakeStorage.simulateError(Exception('Storage unavailable'));
  
  // Act & Assert
  expect(
    () => encryptionService.encrypt('test'),
    throwsA(isA<CryptographyException>()),
  );
});
```

### Key Reuse Testing

```dart
test('should reuse existing encryption key', () async {
  // Arrange - Pre-populate storage
  await fakeStorage.write(key: 'encryption_key', value: 'existing-key');
  
  // Act
  await encryptionService.encrypt('test1');
  await encryptionService.encrypt('test2');
  
  // Assert - Key should remain the same
  final storedKey = await fakeStorage.read(key: 'encryption_key');
  expect(storedKey, equals('existing-key'));
});
```

## ✅ Benefits of This Approach

### 1. **Test Reliability**
- **100% reliable**: No platform channel failures in CI/CD
- **Fast execution**: In-memory operations vs platform calls
- **Deterministic**: Consistent behavior across environments

### 2. **Business Logic Testing**
- **Success paths**: Test actual encryption/decryption logic
- **Error scenarios**: Simulate storage failures and edge cases
- **State management**: Verify key creation, reuse, and cleanup

### 3. **Maintainable Architecture**
- **Clean separation**: Business logic separate from platform concerns
- **Easy refactoring**: Change implementations without breaking tests
- **Platform agnostic**: Same interface works across iOS, Android, Desktop

### 4. **Official Flutter Recommendation**

> "In most cases, the best approach is to wrap plugin calls in your own API, and provide a way of mocking your own API in tests." - Flutter Documentation

## 🚫 Anti-Patterns to Avoid

### ❌ Static Dependencies
```dart
class BadService {
  static final _storage = FlutterSecureStorage(); // Hard to test
  static Future<void> save() => _storage.write(key: 'key', value: 'value');
}
```

### ❌ Platform Channel Mocking
```dart
// Brittle - breaks when plugin internals change
TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
    .setMockMethodCallHandler(channel, handler);
```

### ❌ Try-Catch Testing
```dart
test('should handle platform failure', () async {
  try {
    await serviceWithPlatformDependency.encrypt('test');
    // This won't run in CI
  } catch (e) {
    // This always runs in CI - not testing business logic
    expect(e, isA<Exception>());
  }
});
```

## 📊 Performance Comparison

| Approach | Test Speed | Reliability | Business Logic Coverage |
|----------|------------|-------------|-------------------------|
| Platform Channel Mocking | Slow | 60% (CI failures) | Limited |
| Try-Catch Pattern | Medium | 70% (inconsistent) | Error paths only |
| **Dependency Injection** | **Fast** | **100%** | **Complete** |

## 🎯 Best Practices Summary

1. **Create abstractions** for all platform dependencies
2. **Use dependency injection** instead of static dependencies  
3. **Implement fakes** (not mocks) for stateful dependencies
4. **Test business logic** comprehensively with reliable fakes
5. **Keep integration tests** for actual platform validation
6. **Follow Flutter documentation** recommendations for plugin testing

This approach ensures your tests are fast, reliable, and thoroughly validate your business logic while maintaining clean architecture principles.