#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';
import 'package:args/args.dart';

/// Cross-Language Consistency Checker
/// Checks consistency between different language ARB files
class CrossLanguageConsistencyChecker {
  final bool _verbose;
  final String _outputFormat;

  CrossLanguageConsistencyChecker({
    bool verbose = false,
    String outputFormat = 'console',
  }) : _verbose = verbose,
       _outputFormat = outputFormat;

  /// Run the consistency checker
  Future<void> run(List<String> files) async {
    print('🔍 Starting cross-language consistency check...');

    if (files.length < 2) {
      print('❌ At least two ARB files are required for comparison.');
      return;
    }

    // Load all ARB files
    final arbFiles = <String, Map<String, dynamic>>{};
    for (final file in files) {
      if (_verbose) print('Loading $file...');
      final content = await File(file).readAsString();
      arbFiles[file] = jsonDecode(content) as Map<String, dynamic>;
    }

    final findings = <ConsistencyFinding>[];

    // Get all unique keys across all files
    final allKeys = <String>{};
    for (final json in arbFiles.values) {
      json.forEach((key, value) {
        if (!key.startsWith('@') && !key.startsWith('@@')) {
          allKeys.add(key);
        }
      });
    }

    // Check each key across all files
    for (final key in allKeys) {
      final keyFindings = _checkKeyConsistency(key, arbFiles);
      findings.addAll(keyFindings);
    }

    _outputFindings(findings);
    print('✅ Consistency check complete. Found ${findings.length} issues.');
  }

  /// Check consistency for a specific key across all files
  List<ConsistencyFinding> _checkKeyConsistency(
    String key,
    Map<String, Map<String, dynamic>> arbFiles,
  ) {
    final findings = <ConsistencyFinding>[];

    final values = <String, dynamic>{};
    final missingIn = <String>[];

    arbFiles.forEach((filePath, json) {
      if (json.containsKey(key)) {
        values[filePath] = json[key];
      } else {
        missingIn.add(filePath);
      }
    });

    // Report missing keys
    if (missingIn.isNotEmpty) {
      findings.add(
        ConsistencyFinding(
          key: key,
          message: 'Missing in files: ${missingIn.join(', ')}',
          severity: 'error',
          affectedFiles: missingIn,
        ),
      );
    }

    // Check for placeholder consistency
    if (values.isNotEmpty) {
      final placeholderFindings = _checkPlaceholderConsistency(key, values);
      findings.addAll(placeholderFindings);
    }

    return findings;
  }

  /// Check placeholder consistency across translations
  List<ConsistencyFinding> _checkPlaceholderConsistency(
    String key,
    Map<String, dynamic> values,
  ) {
    final findings = <ConsistencyFinding>[];

    // Extract placeholders from each translation
    final placeholdersPerFile = <String, Set<String>>{};
    values.forEach((filePath, value) {
      if (value is String) {
        final placeholders = _extractPlaceholders(value);
        placeholdersPerFile[filePath] = placeholders;
      }
    });

    // Check if all files have the same placeholders
    if (placeholdersPerFile.isNotEmpty) {
      final firstFile = placeholdersPerFile.keys.first;
      final referencePlaceholders = placeholdersPerFile[firstFile]!;

      placeholdersPerFile.forEach((filePath, placeholders) {
        if (placeholders.length != referencePlaceholders.length ||
            !placeholders.containsAll(referencePlaceholders) ||
            !referencePlaceholders.containsAll(placeholders)) {
          findings.add(
            ConsistencyFinding(
              key: key,
              message:
                  'Inconsistent placeholders in $filePath. Expected: $referencePlaceholders, Found: $placeholders',
              severity: 'warning',
              affectedFiles: [filePath],
            ),
          );
        }
      });
    }

    return findings;
  }

  /// Extract placeholders from a string
  Set<String> _extractPlaceholders(String text) {
    final placeholders = <String>{};
    final regex = RegExp(r'\{([^}]+)\}');
    final matches = regex.allMatches(text);
    for (final match in matches) {
      placeholders.add(match.group(1)!);
    }
    return placeholders;
  }

  /// Output findings
  void _outputFindings(List<ConsistencyFinding> findings) {
    switch (_outputFormat) {
      case 'json':
        _outputJson(findings);
        break;
      case 'csv':
        _outputCsv(findings);
        break;
      default:
        _outputConsole(findings);
    }
  }

  /// Output to console
  void _outputConsole(List<ConsistencyFinding> findings) {
    if (findings.isEmpty) {
      print('✅ All translations are consistent.');
      return;
    }

    print('\n🔍 Cross-Language Consistency Findings:');
    print('=' * 50);

    for (final finding in findings) {
      print('${finding.severity.toUpperCase()}: Key "${finding.key}"');
      print('  ${finding.message}');
      if (finding.affectedFiles.isNotEmpty) {
        print('  Affected files: ${finding.affectedFiles.join(', ')}');
      }
      print('');
    }
  }

  /// Output to JSON
  void _outputJson(List<ConsistencyFinding> findings) {
    final jsonFindings = findings.map((f) => f.toJson()).toList();
    final result = {
      'timestamp': DateTime.now().toIso8601String(),
      'findings': jsonFindings,
      'total': findings.length,
    };
    print(const JsonEncoder.withIndent('  ').convert(result));
  }

  /// Output to CSV
  void _outputCsv(List<ConsistencyFinding> findings) {
    print('Key,Message,Severity,AffectedFiles');
    for (final finding in findings) {
      print(
        '"${finding.key}","${finding.message}",${finding.severity},"${finding.affectedFiles.join(';')}"',
      );
    }
  }
}

/// Represents a consistency finding
class ConsistencyFinding {
  final String key;
  final String message;
  final String severity;
  final List<String> affectedFiles;

  ConsistencyFinding({
    required this.key,
    required this.message,
    required this.severity,
    required this.affectedFiles,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'message': message,
      'severity': severity,
      'affectedFiles': affectedFiles,
    };
  }
}

/// Main function
Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('verbose', abbr: 'v', help: 'Enable verbose output')
    ..addOption(
      'format',
      abbr: 'f',
      allowed: ['console', 'json', 'csv'],
      defaultsTo: 'console',
      help: 'Output format',
    )
    ..addFlag('help', abbr: 'h', help: 'Show help');

  late final ArgResults results;
  try {
    results = parser.parse(arguments);
  } on FormatException catch (e) {
    print('Error: ${e.message}');
    print(parser.usage);
    exit(1);
  }

  if (results['help'] as bool) {
    print('Cross-Language Consistency Checker for ARB Files');
    print(parser.usage);
    exit(0);
  }

  final checker = CrossLanguageConsistencyChecker(
    verbose: results['verbose'] as bool,
    outputFormat: results['format'] as String,
  );

  final files = results.rest;
  await checker.run(files);
}
