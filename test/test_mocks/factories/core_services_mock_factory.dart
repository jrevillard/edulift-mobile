// EduLift Mobile - Core Services Mock Factory
// Phase 2.3: Separate factory per repository as required by execution plan

import 'package:mockito/mockito.dart';
import 'package:edulift/core/utils/result.dart';
import 'package:edulift/core/errors/failures.dart';
import 'package:edulift/core/domain/entities/auth_entities.dart';

// Generated mocks
import '../test_mocks.mocks.dart';

/// Core Services Mock Factory
/// TRUTH: Provides consistent core service mock behavior
class CoreServicesMockFactory {
  static MockDeepLinkService createDeepLinkService({
    bool shouldSucceed = true,
  }) {
    final mock = MockDeepLinkService();

    if (shouldSucceed) {
      when(mock.initialize()).thenAnswer((_) async => const Result.ok(null));
      when(
        mock.getInitialDeepLink(),
      ).thenAnswer((_) async => const DeepLinkResult(path: '/dashboard'));
    } else {
      when(mock.initialize()).thenAnswer(
        (_) async =>
            const Result.err(UnknownFailure(message: 'Deep link failed')),
      );
    }

    return mock;
  }

  static MockTieredStorageService createSecureStorageService({
    Map<String, String> initialData = const {},
  }) {
    final mock = MockTieredStorageService();

    // Setup storage behavior
    final storage = <String, String>{...initialData};

    // Setup mock methods with proper TieredStorageService API
    when(mock.store(any, any, any)).thenAnswer((_) async => null);

    when(mock.read(any, any)).thenAnswer((invocation) async {
      final key = invocation.positionalArguments[0] as String;
      return storage[key];
    });

    return mock;
  }

  static MockGoRouter createGoRouter({String initialRoute = '/'}) {
    final mock = MockGoRouter();

    when(mock.go(any, extra: anyNamed('extra'))).thenReturn(null);
    when(
      mock.push(any, extra: anyNamed('extra')),
    ).thenAnswer((_) async => null);

    return mock;
  }
}
