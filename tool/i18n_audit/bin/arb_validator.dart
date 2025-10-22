#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';
import 'package:args/args.dart';

/// ARB File Parser and Validator
/// Validates ARB files for key consistency and ICU pluralization
class ArbFileValidator {
  final bool _verbose;
  final String _outputFormat;

  ArbFileValidator({
    bool verbose = false,
    String outputFormat = 'console',
  })  : _verbose = verbose,
        _outputFormat = outputFormat;

  /// Run the validator
  Future<void> run(List<String> files) async {
    print('🔍 Starting ARB file validation...');
    
    if (files.isEmpty) {
      print('❌ No files provided for validation.');
      return;
    }
    
    final findings = <ValidationFinding>[];
    
    for (final file in files) {
      if (_verbose) print('Validating $file...');
      final fileFindings = await _validateFile(file);
      findings.addAll(fileFindings);
    }
    
    _outputFindings(findings);
    print('✅ Validation complete. Found ${findings.length} issues.');
  }

  /// Validate a single ARB file
  Future<List<ValidationFinding>> _validateFile(String filePath) async {
    final findings = <ValidationFinding>[];
    final file = File(filePath);
    
    if (!await file.exists()) {
      findings.add(ValidationFinding(
        filePath: filePath,
        lineNumber: 0,
        message: 'File does not exist',
        severity: 'error',
      ));
      return findings;
    }
    
    try {
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      
      // Validate structure
      final structureFindings = _validateStructure(json, filePath);
      findings.addAll(structureFindings);
      
      // Validate keys
      final keyFindings = _validateKeys(json, filePath);
      findings.addAll(keyFindings);
      
      // Validate ICU pluralization
      final pluralizationFindings = _validatePluralization(json, filePath);
      findings.addAll(pluralizationFindings);
      
    } catch (e) {
      findings.add(ValidationFinding(
        filePath: filePath,
        lineNumber: 0,
        message: 'Invalid JSON: $e',
        severity: 'error',
      ));
    }
    
    return findings;
  }

  /// Validate ARB file structure
  List<ValidationFinding> _validateStructure(Map<String, dynamic> json, String filePath) {
    final findings = <ValidationFinding>[];
    
    // Check for required metadata
    if (!json.containsKey('@@locale')) {
      findings.add(ValidationFinding(
        filePath: filePath,
        lineNumber: 0,
        message: 'Missing required @@locale field',
        severity: 'error',
      ));
    }
    
    return findings;
  }

  /// Validate keys consistency
  List<ValidationFinding> _validateKeys(Map<String, dynamic> json, String filePath) {
    final findings = <ValidationFinding>[];
    
    final keys = <String>[];
    final metadataKeys = <String>[];
    
    // Separate regular keys from metadata keys
    json.forEach((key, value) {
      if (key.startsWith('@')) {
        metadataKeys.add(key.substring(1)); // Remove @ prefix
      } else {
        keys.add(key);
      }
    });
    
    // Check for missing metadata
    for (final key in keys) {
      if (!metadataKeys.contains(key) && !key.startsWith('@@')) {
        findings.add(ValidationFinding(
          filePath: filePath,
          lineNumber: 0,
          message: 'Missing metadata for key: $key',
          severity: 'warning',
        ));
      }
    }
    
    // Check for orphaned metadata
    for (final metadataKey in metadataKeys) {
      if (!keys.contains(metadataKey) && !metadataKey.startsWith('@')) {
        findings.add(ValidationFinding(
          filePath: filePath,
          lineNumber: 0,
          message: 'Orphaned metadata for key: $metadataKey',
          severity: 'warning',
        ));
      }
    }
    
    return findings;
  }

  /// Validate ICU pluralization syntax
  List<ValidationFinding> _validatePluralization(Map<String, dynamic> json, String filePath) {
    final findings = <ValidationFinding>[];
    
    json.forEach((key, value) {
      if (value is String && value.contains('{count, plural')) {
        final isValid = _validatePluralSyntax(value);
        if (!isValid) {
          findings.add(ValidationFinding(
            filePath: filePath,
            lineNumber: 0,
            message: 'Invalid ICU pluralization syntax in key: $key',
            severity: 'error',
          ));
        }
      }
    });
    
    return findings;
  }

  /// Validate plural syntax
  bool _validatePluralSyntax(String value) {
    // Basic validation for ICU plural syntax
    // This is a simplified validation - a full implementation would be more complex
    final pluralRegex = RegExp(r'\{[^}]*, plural, [^}]*\}');
    return pluralRegex.hasMatch(value);
  }

  /// Output findings
  void _outputFindings(List<ValidationFinding> findings) {
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
  void _outputConsole(List<ValidationFinding> findings) {
    if (findings.isEmpty) {
      print('✅ No validation issues found.');
      return;
    }
    
    print('\n🔍 ARB Validation Findings:');
    print('=' * 50);
    
    for (final finding in findings) {
      print('${finding.severity.toUpperCase()}: ${finding.filePath}');
      print('  ${finding.message}');
      print('');
    }
  }

  /// Output to JSON
  void _outputJson(List<ValidationFinding> findings) {
    final jsonFindings = findings.map((f) => f.toJson()).toList();
    final result = {
      'timestamp': DateTime.now().toIso8601String(),
      'findings': jsonFindings,
      'total': findings.length,
    };
    print(const JsonEncoder.withIndent('  ').convert(result));
  }

  /// Output to CSV
  void _outputCsv(List<ValidationFinding> findings) {
    print('File,Line,Message,Severity');
    for (final finding in findings) {
      print('${finding.filePath},${finding.lineNumber},"${finding.message}",${finding.severity}');
    }
  }
}

/// Represents a validation finding
class ValidationFinding {
  final String filePath;
  final int lineNumber;
  final String message;
  final String severity;

  ValidationFinding({
    required this.filePath,
    required this.lineNumber,
    required this.message,
    required this.severity,
  });

  Map<String, dynamic> toJson() {
    return {
      'file': filePath,
      'line': lineNumber,
      'message': message,
      'severity': severity,
    };
  }
}

/// Main function
Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('verbose', abbr: 'v', help: 'Enable verbose output')
    ..addOption('format', abbr: 'f', 
        allowed: ['console', 'json', 'csv'], 
        defaultsTo: 'console',
        help: 'Output format')
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
    print('ARB File Validator for Flutter/Dart Applications');
    print(parser.usage);
    exit(0);
  }

  final validator = ArbFileValidator(
    verbose: results['verbose'] as bool,
    outputFormat: results['format'] as String,
  );

  final files = results.rest;
  await validator.run(files);
}