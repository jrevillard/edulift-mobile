// EduLift - Tolerant Golden File Comparator
// Implements pixel tolerance for golden tests to reduce false failures
// Based on Google's recommended approach

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Custom golden file comparator with configurable pixel tolerance
/// This comparator provides a simple tolerance-based comparison
class TolerantGoldenFileComparator extends LocalFileComparator {
  TolerantGoldenFileComparator(super.testFile, {required this.tolerance});

  /// Tolerance as percentage (0.0 to 1.0)
  /// 0.005 = 0.5% tolerance
  final double tolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    try {
      final goldenBytes = await getGoldenBytes(golden);

      final result = await GoldenFileComparator.compareLists(
        imageBytes,
        Uint8List.fromList(goldenBytes),
      );

      if (result.passed) {
        result.dispose();
        return true;
      }

      // Check if difference is within tolerance threshold
      if (result.diffPercent <= tolerance) {
        debugPrint(
          'Golden test passed with ${result.diffPercent}% diff (threshold: ${tolerance}%)',
        );
        result.dispose();
        return true;
      }

      // Test failed - let it fail normally
      final error = await generateFailureOutput(result, golden, basedir);
      result.dispose();
      throw FlutterError(error);
    } catch (e) {
      debugPrint('TolerantGoldenComparator error, falling back to default: $e');
      return super.compare(imageBytes, golden);
    }
  }
}
