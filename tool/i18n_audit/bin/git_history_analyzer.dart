#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';
import 'package:args/args.dart';

/// Git History Analyzer for Reverted Internationalized Strings
/// Detects when previously internationalized strings were reverted to hardcoded
class GitHistoryAnalyzer {
  final bool _verbose;
  final String _outputFormat;
  final int _historyDepth;

  GitHistoryAnalyzer({
    bool verbose = false,
    String outputFormat = 'console',
    int historyDepth = 100,
  })  : _verbose = verbose,
        _outputFormat = outputFormat,
        _historyDepth = historyDepth;

  /// Run the analyzer
  Future<void> run() async {
    print('🔍 Starting git history analysis for reverted internationalized strings...');
    
    final findings = <ReversionFinding>[];
    
    // Get git history
    final commits = await _getGitCommits();
    
    // Analyze each commit for reversion patterns
    for (final commit in commits) {
      if (_verbose) print('Analyzing commit ${commit.hash}...');
      final commitFindings = await _analyzeCommit(commit);
      findings.addAll(commitFindings);
    }
    
    _outputFindings(findings);
    print('✅ Analysis complete. Found ${findings.length} reversion issues.');
  }

  /// Get git commits
  Future<List<GitCommit>> _getGitCommits() async {
    final commits = <GitCommit>[];
    
    try {
      final result = await Process.run('git', [
        'log',
        '--oneline',
        '--pretty=format:%H|%an|%ae|%ad|%s',
        '-n',
        _historyDepth.toString(),
      ]);
      
      if (result.exitCode == 0) {
        final lines = (result.stdout as String).split('\n');
        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          
          final parts = line.split('|');
          if (parts.length >= 5) {
            commits.add(GitCommit(
              hash: parts[0],
              authorName: parts[1],
              authorEmail: parts[2],
              date: parts[3],
              message: parts.sublist(4).join('|'),
            ));
          }
        }
      }
    } catch (e) {
      print('Warning: Could not fetch git history: $e');
    }
    
    return commits;
  }

  /// Analyze a single commit for reversion patterns
  Future<List<ReversionFinding>> _analyzeCommit(GitCommit commit) async {
    final findings = <ReversionFinding>[];
    
    // Get diff for this commit
    try {
      final result = await Process.run('git', [
        'show',
        '--unified=0',
        commit.hash,
      ]);
      
      if (result.exitCode == 0) {
        final diff = result.stdout as String;
        final diffFindings = _analyzeDiff(diff, commit);
        findings.addAll(diffFindings);
      }
    } catch (e) {
      if (_verbose) print('Warning: Could not analyze commit ${commit.hash}: $e');
    }
    
    return findings;
  }

  /// Analyze diff for reversion patterns
  List<ReversionFinding> _analyzeDiff(String diff, GitCommit commit) {
    final findings = <ReversionFinding>[];
    
    // Look for patterns indicating reversion from internationalized to hardcoded
    final lines = diff.split('\n');
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      // Look for removal of S.of(context) or AppLocalizations.of(context) calls
      if (line.startsWith('-') && 
          (line.contains('S.of(context)') || 
           line.contains('AppLocalizations.of(context)'))) {
        
        // Check if the next line adds a hardcoded string
        if (i + 1 < lines.length) {
          final nextLine = lines[i + 1];
          if (nextLine.startsWith('+') && nextLine.contains('Text(') && nextLine.contains('"')) {
            findings.add(ReversionFinding(
              commit: commit,
              removedLine: line.substring(1), // Remove the '-' prefix
              addedLine: nextLine.substring(1), // Remove the '+' prefix
              message: 'Possible reversion from internationalized to hardcoded string',
              severity: 'warning',
            ));
          }
        }
      }
      
      // Look for removal of import statements related to localization
      if (line.startsWith('-') && line.contains('import') && line.contains('l10n')) {
        findings.add(ReversionFinding(
          commit: commit,
          removedLine: line.substring(1),
          addedLine: '',
          message: 'Removed localization import statement',
          severity: 'warning',
        ));
      }
    }
    
    return findings;
  }

  /// Output findings
  void _outputFindings(List<ReversionFinding> findings) {
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
  void _outputConsole(List<ReversionFinding> findings) {
    if (findings.isEmpty) {
      print('✅ No reversion issues found.');
      return;
    }
    
    print('\n🔍 Git History Reversion Findings:');
    print('=' * 50);
    
    for (final finding in findings) {
      print('${finding.severity.toUpperCase()}: ${finding.commit.hash.substring(0, 8)} - ${finding.commit.message}');
      print('  Author: ${finding.commit.authorName} <${finding.commit.authorEmail}>');
      print('  Date: ${finding.commit.date}');
      print('  Removed: ${finding.removedLine}');
      if (finding.addedLine.isNotEmpty) {
        print('  Added: ${finding.addedLine}');
      }
      print('  ${finding.message}');
      print('');
    }
  }

  /// Output to JSON
  void _outputJson(List<ReversionFinding> findings) {
    final jsonFindings = findings.map((f) => f.toJson()).toList();
    final result = {
      'timestamp': DateTime.now().toIso8601String(),
      'findings': jsonFindings,
      'total': findings.length,
    };
    print(const JsonEncoder.withIndent('  ').convert(result));
  }

  /// Output to CSV
  void _outputCsv(List<ReversionFinding> findings) {
    print('CommitHash,Author,Message,RemovedLine,AddedLine,Severity');
    for (final finding in findings) {
      print('${finding.commit.hash},${finding.commit.authorName},"${finding.commit.message}","${finding.removedLine}","${finding.addedLine}",${finding.severity}');
    }
  }
}

/// Represents a git commit
class GitCommit {
  final String hash;
  final String authorName;
  final String authorEmail;
  final String date;
  final String message;

  GitCommit({
    required this.hash,
    required this.authorName,
    required this.authorEmail,
    required this.date,
    required this.message,
  });
}

/// Represents a reversion finding
class ReversionFinding {
  final GitCommit commit;
  final String removedLine;
  final String addedLine;
  final String message;
  final String severity;

  ReversionFinding({
    required this.commit,
    required this.removedLine,
    required this.addedLine,
    required this.message,
    required this.severity,
  });

  Map<String, dynamic> toJson() {
    return {
      'commit': {
        'hash': commit.hash,
        'authorName': commit.authorName,
        'authorEmail': commit.authorEmail,
        'date': commit.date,
        'message': commit.message,
      },
      'removedLine': removedLine,
      'addedLine': addedLine,
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
    ..addOption('depth', abbr: 'd',
        defaultsTo: '100',
        help: 'History depth to analyze')
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
    print('Git History Analyzer for Reverted Internationalized Strings');
    print(parser.usage);
    exit(0);
  }

  final analyzer = GitHistoryAnalyzer(
    verbose: results['verbose'] as bool,
    outputFormat: results['format'] as String,
    historyDepth: int.parse(results['depth'] as String),
  );

  await analyzer.run();
}