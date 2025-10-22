import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:edulift/core/network/network_info.dart';

import '../../../test_mocks/test_mocks.mocks.dart';

void main() {
  group('NetworkInfo Mock Tests - TDD London', () {
    late MockConnectivity mockConnectivity;
    late NetworkInfoImpl networkInfo;

    setUp(() {
      mockConnectivity = MockConnectivity();
      networkInfo = NetworkInfoImpl(connectivity: mockConnectivity);
    });

    group('Connection Status - Mock Scenarios', () {
      test('should return true when connected to wifi', () async {
        // Arrange
        when(
          mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.wifi]);

        // Act
        final isConnected = await networkInfo.isConnected;

        // Assert
        expect(isConnected, true);
        verify(mockConnectivity.checkConnectivity()).called(1);
      });

      test('should return true when connected to mobile', () async {
        // Arrange
        when(
          mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.mobile]);

        // Act
        final isConnected = await networkInfo.isConnected;

        // Assert
        expect(isConnected, true);
        verify(mockConnectivity.checkConnectivity()).called(1);
      });

      test('should return false when not connected', () async {
        // Arrange
        when(
          mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.none]);

        // Act
        final isConnected = await networkInfo.isConnected;

        // Assert
        expect(isConnected, false);
        verify(mockConnectivity.checkConnectivity()).called(1);
      });

      test('should return true when connected to ethernet', () async {
        // Arrange
        when(
          mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.ethernet]);

        // Act
        final isConnected = await networkInfo.isConnected;

        // Assert
        expect(isConnected, true);
        verify(mockConnectivity.checkConnectivity()).called(1);
      });

      test('should handle multiple connectivity results', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity()).thenAnswer(
          (_) async => [ConnectivityResult.wifi, ConnectivityResult.mobile],
        );

        // Act
        final isConnected = await networkInfo.isConnected;

        // Assert
        expect(isConnected, true);
        verify(mockConnectivity.checkConnectivity()).called(1);
      });
    });

    group('Connection Stream - Mock Scenarios', () {
      test('should emit true when connectivity changes to connected', () async {
        // Arrange
        final streamController = Stream<List<ConnectivityResult>>.fromIterable([
          [ConnectivityResult.wifi],
          [ConnectivityResult.mobile],
        ]);

        when(
          mockConnectivity.onConnectivityChanged,
        ).thenAnswer((_) => streamController);

        // Act
        final connectionStream = networkInfo.connectionStream;
        final results = await connectionStream.take(2).toList();

        // Assert
        expect(results, [true, true]);
      });

      test(
        'should emit false when connectivity changes to disconnected',
        () async {
          // Arrange
          final streamController =
              Stream<List<ConnectivityResult>>.fromIterable([
                [ConnectivityResult.none],
              ]);

          when(
            mockConnectivity.onConnectivityChanged,
          ).thenAnswer((_) => streamController);

          // Act
          final connectionStream = networkInfo.connectionStream;
          final results = await connectionStream.take(1).toList();

          // Assert
          expect(results, [false]);
        },
      );

      test('should handle connectivity state transitions', () async {
        // Arrange
        final streamController = Stream<List<ConnectivityResult>>.fromIterable([
          [ConnectivityResult.none],
          [ConnectivityResult.wifi],
          [ConnectivityResult.mobile],
          [ConnectivityResult.none],
        ]);

        when(
          mockConnectivity.onConnectivityChanged,
        ).thenAnswer((_) => streamController);

        // Act
        final connectionStream = networkInfo.connectionStream;
        final results = await connectionStream.take(4).toList();

        // Assert
        expect(results, [false, true, true, false]);
      });
    });

    group('Error Handling', () {
      test('should handle connectivity check errors gracefully', () async {
        // Arrange
        when(
          mockConnectivity.checkConnectivity(),
        ).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(() => networkInfo.isConnected, throwsException);
      });

      test('should handle stream errors gracefully', () async {
        // Arrange
        when(
          mockConnectivity.onConnectivityChanged,
        ).thenAnswer((_) => Stream.error(Exception('Stream error')));

        // Act
        final connectionStream = networkInfo.connectionStream;

        // Assert
        expect(connectionStream, emitsError(isA<Exception>()));
      });
    });
  });
}
