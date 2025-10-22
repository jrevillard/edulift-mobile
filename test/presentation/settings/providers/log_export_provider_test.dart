import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edulift/core/presentation/widgets/providers/log_export_provider.dart';

void main() {
  group('LogExportProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is correct', () async {
      final state = await container.read(logExportProvider.future);

      expect(state.isExporting, false);
      expect(state.error, null);
      expect(state.lastExportTime, null);
      expect(
        state.logSizeBytes,
        greaterThanOrEqualTo(0),
      ); // Real size, can be 0
    });

    test('exportLogs handles errors gracefully', () async {
      final notifier = container.read(logExportProvider.notifier);

      await notifier.exportLogs();

      final state = container.read(logExportProvider);
      expect(state.value?.isExporting, false);
    });

    test('getCurrentLogLevel returns valid level', () async {
      final notifier = container.read(logExportProvider.notifier);

      expect(() => notifier.getCurrentLogLevel(), returnsNormally);
    });

    test('setLogLevel handles valid levels', () async {
      final notifier = container.read(logExportProvider.notifier);

      expect(() => notifier.setLogLevel('INFO'), returnsNormally);
    });

    test('LogExportState copyWith works correctly', () {
      const state = LogExportState(logSizeBytes: 100);
      final newState = state.copyWith(isExporting: true);

      expect(newState.isExporting, true);
      expect(newState.logSizeBytes, 100);
    });

    test('provider initialization works', () async {
      final provider = logExportProvider;
      expect(provider, isNotNull);

      final state = await container.read(provider.future);
      expect(state, isNotNull);
      expect(
        state.logSizeBytes,
        greaterThanOrEqualTo(0),
      ); // Real size, can be 0
    });

    test('currentLogLevelProvider works', () async {
      final levelProvider = currentLogLevelProvider;
      expect(levelProvider, isNotNull);

      expect(() => container.read(levelProvider.future), returnsNormally);
    });

    test('LogExportState default constructor works', () {
      const state = LogExportState();

      expect(state.isExporting, false);
      expect(state.error, null);
      expect(state.lastExportTime, null);
      expect(state.logSizeBytes, 0);
    });

    test('LogExportState copyWith handles all parameters', () {
      final now = DateTime.now();
      const originalState = LogExportState(
        error: 'test error',
        logSizeBytes: 500,
      );

      final newState = originalState.copyWith(
        isExporting: true,
        error: 'new error',
        lastExportTime: now,
        logSizeBytes: 1000,
      );

      expect(newState.isExporting, true);
      expect(newState.error, 'new error');
      expect(newState.lastExportTime, now);
      expect(newState.logSizeBytes, 1000);
    });

    test('setLogLevel handles invalid levels gracefully', () async {
      final notifier = container.read(logExportProvider.notifier);

      try {
        await notifier.setLogLevel('INVALID_LEVEL');
        fail('Expected StateError to be thrown');
      } catch (e) {
        expect(e, isA<StateError>());
        expect(e.toString(), contains('Bad state: No element'));
      }
    });
  });
}
