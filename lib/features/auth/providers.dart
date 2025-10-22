// Feature-level composition root for Auth feature
// This file acts as the composition root according to Clean Architecture principles.
// Presentation layer imports ONLY from this file, never directly from data layer.

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ALLOWED: Composition root can import from data and domain layers
import 'data/providers/repository_providers.dart';
// Removed redundant wrapper services - using core AuthService directly
import 'domain/usecases/send_magic_link_usecase.dart';
import 'domain/usecases/verify_magic_link_usecase.dart';
// REMOVED: get_current_user_usecase.dart and logout_usecase.dart per consolidation plan
import 'domain/usecases/refresh_token_usecase.dart';
// Import core providers for authServiceProvider
import '../../core/di/providers/providers.dart' as core;

// === REPOSITORY PROVIDERS ===
// Re-export repository provider for composition root access
final authRepositoryComposedProvider = authRepositoryProvider;

// === SERVICE PROVIDERS ===
// Use core AuthService directly - no wrapper needed
final featureAuthServiceProvider = core.authServiceProvider;

// === USE CASE PROVIDERS ===
final sendMagicLinkUsecaseProvider = Provider<SendMagicLinkUsecase>((ref) {
  final authService = ref.watch(featureAuthServiceProvider);
  return SendMagicLinkUsecase(authService);
});

final verifyMagicLinkUsecaseProvider = Provider<VerifyMagicLinkUsecase>((ref) {
  final authService = ref.watch(featureAuthServiceProvider);
  return VerifyMagicLinkUsecase(authService);
});

// REMOVED: getCurrentUserUsecaseProvider and logoutUsecaseProvider per consolidation plan
// Use featureAuthServiceProvider directly for getCurrentUser() and logout() methods

final refreshTokenUsecaseProvider = Provider<RefreshTokenUsecase>((ref) {
  final authService = ref.watch(featureAuthServiceProvider);
  return RefreshTokenUsecase(authService);
});
