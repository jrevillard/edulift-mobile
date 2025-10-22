// EduLift Mobile - Deep Link Service Interface (Domain Layer)
// Abstract interface for deep link processing

import '../../errors/failures.dart';
import '../../utils/result.dart';
import '../entities/auth_entities.dart';

/// Deep link service interface
/// This belongs in the domain layer as it defines business rules for deep linking
abstract class DeepLinkService {
  Future<Result<void, Failure>> initialize();
  Future<DeepLinkResult?> getInitialDeepLink();
  void setDeepLinkHandler(Function(DeepLinkResult)? handler);
  DeepLinkResult? parseDeepLink(String url);
  String generateNativeDeepLink(String token, {String? inviteCode});
  void dispose();
}
