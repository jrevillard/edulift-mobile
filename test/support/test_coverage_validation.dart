// EduLift Mobile - Test Coverage Validation Script
// Following FLUTTER_TESTING_RESEARCH_2025.md - Coverage Requirements
// Validates 90%+ test coverage for enhanced deeplink system

import 'dart:io';

/// Test coverage validation and reporting
class TestCoverageValidator {
  static const int minimumCoveragePercent = 90;
  static const String lcovFilePath = 'coverage/lcov.info';

  /// Validate test coverage meets requirements
  static Future<bool> validateCoverage() async {
    // ignore: avoid_print
    print('🔍 Validating test coverage for enhanced deeplink system...');

    // Check if coverage file exists
    final lcovFile = File(lcovFilePath);
    if (!await lcovFile.exists()) {
      // ignore: avoid_print
      print('❌ Coverage file not found. Run: flutter test --coverage');
      return false;
    }

    // Parse coverage data
    final coverageData = await parseLcovFile(lcovFile);

    // Validate overall coverage
    final overallCoverage = calculateOverallCoverage(coverageData);
    // ignore: avoid_print
    print('📊 Overall Coverage: ${overallCoverage.toStringAsFixed(1)}%');

    if (overallCoverage < minimumCoveragePercent) {
      // ignore: avoid_print
      print(
        '❌ Coverage below minimum requirement of ${minimumCoveragePercent}%',
      );
      return false;
    }

    // Validate specific component coverage
    final componentCoverages = validateComponentCoverage(coverageData);
    var allComponentsPass = true;

    for (final entry in componentCoverages.entries) {
      final component = entry.key;
      final coverage = entry.value;

      if (coverage < minimumCoveragePercent) {
        // ignore: avoid_print
        print(
          '❌ ${component}: ${coverage.toStringAsFixed(1)}% (below ${minimumCoveragePercent}%)',
        );
        allComponentsPass = false;
      } else {
        // ignore: avoid_print
        print('✅ ${component}: ${coverage.toStringAsFixed(1)}%');
      }
    }

    if (!allComponentsPass) {
      // ignore: avoid_print
      print('❌ Some components below coverage requirements');
      return false;
    }

    // ignore: avoid_print
    print('✅ All coverage requirements met!');
    return true;
  }

  /// Parse LCOV coverage file
  static Future<Map<String, FileCoverage>> parseLcovFile(File lcovFile) async {
    final contents = await lcovFile.readAsString();
    final lines = contents.split('\n');

    final coverageData = <String, FileCoverage>{};
    String? currentFile;
    int? linesFound;
    int? linesHit;
    int? functionsFound;
    int? functionsHit;
    int? branchesFound;
    int? branchesHit;

    for (final line in lines) {
      if (line.startsWith('SF:')) {
        currentFile = line.substring(3);
      } else if (line.startsWith('LF:')) {
        linesFound = int.tryParse(line.substring(3));
      } else if (line.startsWith('LH:')) {
        linesHit = int.tryParse(line.substring(3));
      } else if (line.startsWith('FNF:')) {
        functionsFound = int.tryParse(line.substring(4));
      } else if (line.startsWith('FNH:')) {
        functionsHit = int.tryParse(line.substring(4));
      } else if (line.startsWith('BRF:')) {
        branchesFound = int.tryParse(line.substring(4));
      } else if (line.startsWith('BRH:')) {
        branchesHit = int.tryParse(line.substring(4));
      } else if (line == 'end_of_record' && currentFile != null) {
        coverageData[currentFile] = FileCoverage(
          filePath: currentFile,
          linesFound: linesFound ?? 0,
          linesHit: linesHit ?? 0,
          functionsFound: functionsFound ?? 0,
          functionsHit: functionsHit ?? 0,
          branchesFound: branchesFound ?? 0,
          branchesHit: branchesHit ?? 0,
        );

        // Reset for next file
        currentFile = null;
        linesFound = null;
        linesHit = null;
        functionsFound = null;
        functionsHit = null;
        branchesFound = null;
        branchesHit = null;
      }
    }

    return coverageData;
  }

  /// Calculate overall coverage percentage
  static double calculateOverallCoverage(
    Map<String, FileCoverage> coverageData,
  ) {
    var totalLinesFound = 0;
    var totalLinesHit = 0;

    for (final coverage in coverageData.values) {
      totalLinesFound += coverage.linesFound;
      totalLinesHit += coverage.linesHit;
    }

    if (totalLinesFound == 0) return 0.0;
    return (totalLinesHit / totalLinesFound) * 100;
  }

  /// Validate coverage for specific components
  static Map<String, double> validateComponentCoverage(
    Map<String, FileCoverage> coverageData,
  ) {
    final componentCoverages = <String, double>{};

    // Group files by component
    final components = <String, List<FileCoverage>>{
      'DeepLink Service': [],
      'DeepLink Result Entity': [],
      'Router Integration': [],
      'Auth Pages': [],
      'Family Pages': [],
      'Group Pages': [],
      'Integration Tests': [],
    };

    for (final entry in coverageData.entries) {
      final filePath = entry.key;
      final coverage = entry.value;

      if (filePath.contains('deep_link_service')) {
        components['DeepLink Service']!.add(coverage);
      } else if (filePath.contains('deeplink_result') ||
          filePath.contains('DeepLinkResult')) {
        components['DeepLink Result Entity']!.add(coverage);
      } else if (filePath.contains('app_router') ||
          filePath.contains('router')) {
        components['Router Integration']!.add(coverage);
      } else if (filePath.contains('auth') && filePath.contains('pages')) {
        components['Auth Pages']!.add(coverage);
      } else if (filePath.contains('family') && filePath.contains('pages')) {
        components['Family Pages']!.add(coverage);
      } else if (filePath.contains('groups') && filePath.contains('pages')) {
        components['Group Pages']!.add(coverage);
      } else if (filePath.contains('integration')) {
        components['Integration Tests']!.add(coverage);
      }
    }

    // Calculate coverage for each component
    for (final entry in components.entries) {
      final component = entry.key;
      final coverages = entry.value;

      if (coverages.isNotEmpty) {
        var totalLines = 0;
        var hitLines = 0;

        for (final coverage in coverages) {
          totalLines += coverage.linesFound;
          hitLines += coverage.linesHit;
        }

        final coveragePercent =
            totalLines > 0 ? (hitLines / totalLines) * 100 : 0.0;
        componentCoverages[component] = coveragePercent;
      }
    }

    return componentCoverages;
  }

  /// Generate detailed coverage report
  static Future<void> generateCoverageReport() async {
    final lcovFile = File(lcovFilePath);
    if (!await lcovFile.exists()) {
      // ignore: avoid_print
      print('❌ Coverage file not found. Run: flutter test --coverage');
      return;
    }

    final coverageData = await parseLcovFile(lcovFile);
    final overallCoverage = calculateOverallCoverage(coverageData);

    final report = StringBuffer();
    report.writeln('# Test Coverage Report - Enhanced DeepLink System');
    report.writeln('Generated: ${DateTime.now()}');
    report.writeln();
    report.writeln(
      '## Overall Coverage: ${overallCoverage.toStringAsFixed(1)}%',
    );
    report.writeln();

    // Component coverage
    final componentCoverages = validateComponentCoverage(coverageData);
    report.writeln('## Component Coverage');
    for (final entry in componentCoverages.entries) {
      final component = entry.key;
      final coverage = entry.value;
      final status = coverage >= minimumCoveragePercent ? '✅' : '❌';
      report.writeln(
        '- ${status} **${component}**: ${coverage.toStringAsFixed(1)}%',
      );
    }

    report.writeln();
    report.writeln('## Detailed File Coverage');

    // Sort files by coverage (lowest first)
    final sortedFiles = coverageData.entries.toList()
      ..sort((a, b) {
        final aCoverage = a.value.linesFound > 0
            ? (a.value.linesHit / a.value.linesFound) * 100
            : 0.0;
        final bCoverage = b.value.linesFound > 0
            ? (b.value.linesHit / b.value.linesFound) * 100
            : 0.0;
        return aCoverage.compareTo(bCoverage);
      });

    for (final entry in sortedFiles) {
      final filePath = entry.key;
      final coverage = entry.value;
      final coveragePercent = coverage.linesFound > 0
          ? (coverage.linesHit / coverage.linesFound) * 100
          : 0.0;

      final fileName = filePath.split('/').last;
      final status = coveragePercent >= minimumCoveragePercent ? '✅' : '❌';
      report.writeln(
        '- ${status} **${fileName}**: ${coveragePercent.toStringAsFixed(1)}% (${coverage.linesHit}/${coverage.linesFound} lines)',
      );
    }

    // Write report to file
    final reportFile = File('coverage/coverage_report.md');
    await reportFile.writeAsString(report.toString());

    // ignore: avoid_print
    print('📄 Coverage report generated: ${reportFile.path}');
  }

  /// Run coverage validation command
  static Future<void> runCoverageValidation() async {
    // ignore: avoid_print
    print('🧪 Running test coverage validation...');

    // Run tests with coverage
    // ignore: avoid_print
    print('Running tests with coverage...');
    final testResult = await Process.run('flutter', ['test', '--coverage']);

    if (testResult.exitCode != 0) {
      // ignore: avoid_print
      print('❌ Tests failed:');
      // ignore: avoid_print
      print(testResult.stderr);
      return;
    }

    // ignore: avoid_print
    print('✅ Tests completed successfully');

    // Validate coverage
    final coverageValid = await validateCoverage();

    // Generate report
    await generateCoverageReport();

    if (!coverageValid) {
      // ignore: avoid_print
      print('❌ Coverage validation failed');
      exit(1);
    } else {
      // ignore: avoid_print
      print('🎉 Coverage validation passed!');
    }
  }
}

/// File coverage data structure
class FileCoverage {
  final String filePath;
  final int linesFound;
  final int linesHit;
  final int functionsFound;
  final int functionsHit;
  final int branchesFound;
  final int branchesHit;

  FileCoverage({
    required this.filePath,
    required this.linesFound,
    required this.linesHit,
    required this.functionsFound,
    required this.functionsHit,
    required this.branchesFound,
    required this.branchesHit,
  });

  double get lineCoverage =>
      linesFound > 0 ? (linesHit / linesFound) * 100 : 0.0;
  double get functionCoverage =>
      functionsFound > 0 ? (functionsHit / functionsFound) * 100 : 0.0;
  double get branchCoverage =>
      branchesFound > 0 ? (branchesHit / branchesFound) * 100 : 0.0;
}

/// Entry point for coverage validation script
Future<void> main(List<String> args) async {
  if (args.contains('--help')) {
    // ignore: avoid_print
    print('Test Coverage Validation Script');
    // ignore: avoid_print
    print('');
    // ignore: avoid_print
    print('Usage:');
    // ignore: avoid_print
    print('  dart test/support/test_coverage_validation.dart [options]');
    // ignore: avoid_print
    print('');
    // ignore: avoid_print
    print('Options:');
    // ignore: avoid_print
    print('  --help          Show this help message');
    // ignore: avoid_print
    print('  --report-only   Generate report without running tests');
    // ignore: avoid_print
    print('  --validate-only Validate existing coverage without running tests');
    // ignore: avoid_print
    print('');
    // ignore: avoid_print
    print('Examples:');
    // ignore: avoid_print
    print('  dart test/support/test_coverage_validation.dart');
    // ignore: avoid_print
    print('  dart test/support/test_coverage_validation.dart --report-only');
    return;
  }

  if (args.contains('--report-only')) {
    await TestCoverageValidator.generateCoverageReport();
  } else if (args.contains('--validate-only')) {
    final isValid = await TestCoverageValidator.validateCoverage();
    exit(isValid ? 0 : 1);
  } else {
    await TestCoverageValidator.runCoverageValidation();
  }
}
