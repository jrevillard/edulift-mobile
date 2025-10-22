#!/usr/bin/env dart
// Simple but effective hardcoded string detector

// ignore_for_file: avoid_print

import 'dart:io';
// Removed unused dart:isolate import

void main() async {
  print('Starting internationalization audit...');

  // Look for lib directory in current or parent directories
  Directory? findLibDirectory() {
    var current = Directory.current;
    while (current.path != current.parent.path) {
      final libDir = Directory('${current.path}/lib');
      if (libDir.existsSync()) {
        return libDir;
      }
      current = current.parent;
    }
    // Try relative to script location
    final scriptDir = File(Platform.script.toFilePath()).parent.parent;
    final libDir = Directory('${scriptDir.path}/lib');
    if (libDir.existsSync()) {
      return libDir;
    }
    return null;
  }

  final dir = findLibDirectory() ?? Directory('lib');
  if (!dir.existsSync()) {
    print('lib directory not found');
    return;
  }

  // Find all Dart files
  final files = <File>[];
  await for (final entity in dir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      // Skip localization files, generated files, and non-user-facing code
      if (!entity.path.contains('l10n/') &&
          !entity.path.contains('generated/') &&
          !entity.path.contains('.g.dart') &&
          !entity.path.contains('.freezed.dart') &&
          !entity.path.contains('firebase_options.dart') &&
          !entity.path.contains('/test/') &&
          !entity.path.contains('/integration_test/') &&
          !entity.path.contains('/routing/') && // Routes are technical
          !entity.path.contains('_route_factory.dart')) {
        files.add(entity);
      }
    }
  }

  print('Found ${files.length} Dart files');

  var totalCount = 0;
  final findings = <Map<String, dynamic>>[];

  for (final file in files) {
    try {
      final content = await file.readAsString();
      final lines = content.split('\n');

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final lineNumber = i + 1;
        final trimmed = line.trim();

        // Get context (previous and next lines for better detection)
        final prevLine = i > 0 ? lines[i - 1].trim() : '';
        final nextLine = i < lines.length - 1 ? lines[i + 1].trim() : '';

        // Skip comments and imports
        if (trimmed.startsWith('//') ||
            trimmed.startsWith('/*') ||
            trimmed.startsWith('*') ||
            trimmed.startsWith('import ') ||
            trimmed.startsWith('export ') ||
            trimmed.startsWith('part ')) {
          continue;
        }

        // Skip lines that already use l10n
        if (line.contains('l10n.') ||
            line.contains('AppLocalizations.of(context)')) {
          continue;
        }

        // Extract all quoted strings from the line
        final matches = _extractAllQuotedStrings(line);
        for (final match in matches) {
          final text = match['text'];

          // Check if this string is in a UI context (INCLUSION approach)
          if (_isInUIContext(line, prevLine, nextLine, text)) {
            findings.add({
              'file': file.path,
              'line': lineNumber,
              'column': match['start'],
              'text': text,
              'context': line.trim(),
            });
            totalCount++;
          }
        }
      }
    } catch (e) {
      // Ignore files that can't be read
    }
  }

  print(
    'Found $totalCount hardcoded strings that should be internationalized:',
  );

  // Group by file
  final findingsByFile = <String, List<Map<String, dynamic>>>{};
  for (final finding in findings) {
    final file = finding['file'];
    if (!findingsByFile.containsKey(file)) {
      findingsByFile[file] = [];
    }
    findingsByFile[file]!.add(finding);
  }

  findingsByFile.forEach((file, fileFindings) {
    print('\n$file (${fileFindings.length} issues):');
    for (final finding in fileFindings) {
      print('  Line ${finding['line']}: "${finding['text']}"');
    }
  });
}

/// Extract all quoted strings from a line (both single and double quotes)
List<Map<String, dynamic>> _extractAllQuotedStrings(String line) {
  final matches = <Map<String, dynamic>>[];

  // Pattern for double-quoted strings
  final doubleQuotePattern = RegExp(r'"([^"\\]*(\\.[^"\\]*)*)"');
  final doubleMatches = doubleQuotePattern.allMatches(line);
  for (final match in doubleMatches) {
    final text = match.group(1);
    if (text != null && text.isNotEmpty) {
      matches.add({'start': match.start, 'end': match.end, 'text': text});
    }
  }

  // Pattern for single-quoted strings
  final singleQuotePattern = RegExp(r"'([^'\\]*(\\.[^'\\]*)*)'");
  final singleMatches = singleQuotePattern.allMatches(line);
  for (final match in singleMatches) {
    final text = match.group(1);
    if (text != null && text.isNotEmpty) {
      matches.add({'start': match.start, 'end': match.end, 'text': text});
    }
  }

  return matches;
}

/// Check if a string is in a UI context that requires internationalization
bool _isInUIContext(
    String line, String prevLine, String nextLine, String text) {
  // Skip very short or empty strings
  if (text.trim().isEmpty || text.length < 3) return false;

  // Skip technical identifiers (snake_case with underscores like confirm_delete_dialog)
  if (text.contains('_') && !text.contains(' ')) return false;

  // Skip ONLY truly technical strings (not based on naming patterns)
  // Philosophy: If it's in a UI context, trust the UI context detection
  if (RegExp(r'^[A-Z_]+$').hasMatch(text)) return false; // ERROR_CODE constants
  if (RegExp(r'^\d+$').hasMatch(text)) return false; // Pure numbers
  if (text.startsWith('http') || text.contains('://')) return false; // URLs
  if (text.startsWith('/') && text.length < 20) return false; // Routes
  if (text.contains('@') && text.contains('.')) return false; // Emails
  if (RegExp(r'^error[A-Z]\w+$').hasMatch(text)) {
    return false; // errorNetworkGeneral
  }
  if (text.contains('🔍') || text.contains('🪄')) return false; // Debug emojis
  if (text == ' : ' || text == ', ') return false; // Punctuation only

  // Skip toString() patterns - strings with interpolation or debug format
  if (RegExp(r'^[A-Z][a-zA-Z]+\(')
          .hasMatch(text) || // Starts with CapitalizedWord(
      text.contains('\$')) {
    // Contains interpolation (likely debug string)
    return false;
  }

  // Skip if it's part of a technical expression (contains, error checks, JSON access, etc.)
  if (line.contains('contains(') ||
      line.contains('?.') ||
      line.contains('error?.') ||
      line.contains('.message') ||
      line.contains('.error') ||
      line.contains('[\'') || // JSON access like data['error']
      line.contains('["') || // JSON access like data["type"]
      line.contains('\': ') || // Map literal like {'type': value}
      line.contains('": ')) {
    // Map literal like {"type": value}
    return false;
  }

  // Skip WebSocket/event protocol strings (contain colons like "child:added")
  if (text.contains(':') && !text.contains(' ')) {
    return false;
  }

  // Skip if it's a const declaration (technical constants)
  if (prevLine.contains('const ') || line.contains('static const')) {
    return false;
  }

  // Check if string appears in a UI widget context
  final combined = '$prevLine $line $nextLine'.toLowerCase();

  // 1. Text widgets
  if (line.contains('Text(') ||
      line.contains('RichText(') ||
      line.contains('SelectableText(')) {
    return true;
  }

  // 2. UI property labels (title, label, hint, etc.)
  // Only detect if it's in a UI widget context, not constructor parameters or JSON
  if (line.contains('labelText:') ||
      line.contains('hintText:') ||
      line.contains('helperText:') ||
      line.contains('errorText:') ||
      line.contains('counterText:') ||
      line.contains('prefixText:') ||
      line.contains('suffixText:') ||
      line.contains('semanticsLabel:') ||
      line.contains('tooltip:')) {
    return true;
  }

  // For generic properties like 'title:' and 'label:', be more careful
  // Only detect if it's NOT in a constructor call or JSON context
  if ((line.contains('title:') || line.contains('label:')) &&
      !line.contains('json[') &&
      !line.contains('return ') &&
      !prevLine.contains('fromJson') &&
      !combined.contains('constructor')) {
    return true;
  }

  // 3. Dialogs and Snackbars
  if (combined.contains('snackbar') ||
      combined.contains('alertdialog') ||
      combined.contains('showdialog') ||
      combined.contains('scaffoldmessenger')) {
    return true;
  }

  // 4. Button labels
  if (line.contains('child: Text(') ||
      (combined.contains('button') && line.contains('Text('))) {
    return true;
  }

  // 5. Validator error messages
  if (line.contains('validator:') && line.contains('=>')) {
    return true;
  }
  if (prevLine.contains('validator:') || prevLine.contains('validator: (')) {
    return true;
  }

  // 6. AppBar/BottomNavigationBar
  if (combined.contains('appbar') ||
      combined.contains('bottomnavigationbar') ||
      combined.contains('navigationbaritem')) {
    return true;
  }

  // 7. Common UI patterns with child: or content:
  if (line.contains('child:') || line.contains('content:')) {
    // But exclude technical contexts
    if (!line.contains('AppLogger') &&
        !line.contains('description:') &&
        !line.contains('reason:')) {
      return true;
    }
  }

  // 8. Error/message variables that will be shown to user
  if (line.contains('errorMessage =') ||
      line.contains('message =') ||
      line.contains('successMessage =') ||
      line.contains('warningMessage =') ||
      line.contains('infoMessage =')) {
    // Make sure it's not a technical assignment
    if (!line.contains('AppLogger') &&
        !line.contains('.message') && // error.message is a property access
        !text.contains('\$')) {
      // Skip interpolated strings for now
      return true;
    }
  }

  // 8b. Multi-line message variable assignments
  if (prevLine.contains('errorMessage =') ||
      prevLine.contains('message =') ||
      prevLine.contains('successMessage =')) {
    // This is the continuation of the message assignment
    if (!text.contains('\$')) {
      return true;
    }
  }

  // 9. Return statements that return user messages
  // Only detect if it's a String return type (not Map<String,...> or other generics)
  if (line.contains('return ') &&
      (prevLine.contains('String ') ||
          prevLine.contains('String?') ||
          prevLine.contains('String>') &&
              !prevLine.contains('Map<String') &&
              !prevLine.contains('List<String') ||
          nextLine.contains('ScaffoldMessenger') ||
          prevLine.contains('errorMessage') ||
          prevLine.contains('message'))) {
    // Skip if it's clearly technical (toString, property access, null, fromJson/toJson, getters, storage keys)
    if (!line.contains('null') &&
        !line.contains('.message') &&
        !prevLine.contains('toString()') &&
        !prevLine.contains('fromJson') &&
        !prevLine.contains('toJson') &&
        !prevLine.contains('get domain') &&
        !prevLine.contains('get key') &&
        !prevLine.contains('get id') &&
        !prevLine.contains('get type') &&
        !combined.contains('getdata') &&
        !combined.contains('getuserdata') &&
        !combined.contains('storage') &&
        !line.contains('(\'') &&
        line.contains('return ')) {
      // Skip function calls with string params
      return true;
    }
  }

  return false;
}
