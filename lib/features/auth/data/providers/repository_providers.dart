import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';

/// Auth repository provider for dependency injection and testing
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // AuthRepository implementation not yet migrated to Riverpod
  // TODO: Implement proper AuthRepository provider
  throw UnimplementedError('AuthRepository provider not implemented');
});