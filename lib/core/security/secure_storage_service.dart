// EduLift Mobile - Secure Storage Service Implementation
// TDD London GREEN Phase - Minimal implementation

import 'dart:async';
import '../domain/services/secure_storage_service.dart';

/// Default implementation of SecureStorageService
class DefaultSecureStorageService implements SecureStorageService {
  @override
  Future<void> store(String key, String value) async {
    throw UnimplementedError(
      'SecureStorageService.store not yet implemented - GREEN phase',
    );
  }

  @override
  Future<String?> retrieve(String key) async {
    throw UnimplementedError(
      'SecureStorageService.retrieve not yet implemented - GREEN phase',
    );
  }

  @override
  Future<void> delete(String key) async {
    throw UnimplementedError(
      'SecureStorageService.delete not yet implemented - GREEN phase',
    );
  }

  @override
  Future<void> clear() async {
    throw UnimplementedError(
      'SecureStorageService.clear not yet implemented - GREEN phase',
    );
  }

  @override
  Future<bool> containsKey(String key) async {
    throw UnimplementedError(
      'SecureStorageService.containsKey not yet implemented - GREEN phase',
    );
  }
}
