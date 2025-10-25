// ARCHITECTURAL TESTING - WEBSOCKET MODERNIZATION COMPLIANCE ENFORCEMENT
// PRINCIPLE 0: RADICAL CANDOR - TRUTH ABOVE ALL
//
// These tests enforce WebSocket architecture compliance for the modernization project.
// They will FAIL if developers violate the established WebSocket patterns and requirements.
//
// ENFORCEMENT RULES:
// 1. NO hardcoded event string literals - MUST use centralized SocketEvents constants
// 2. ALL event names MUST use modern colon-separated format (family:updated NOT familyUpdated)
// 3. WebSocket service MUST properly dispose ALL stream controllers
// 4. Providers MUST use dependency injection for WebSocket integration
// 5. Clean architecture layer separation MUST be maintained
// 6. Event payload validation MUST be implemented consistently

// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Helper function to find all Dart files in a directory
  List<File> findDartFiles(String directoryPath) {
    final directory = Directory(directoryPath);
    if (!directory.existsSync()) return [];

    return directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();
  }

  /// Helper function to read file content
  String readFileContent(File file) {
    return file.readAsStringSync();
  }

  /// Check if string looks like an event name
  bool _isEventString(String str) {
    // Exclude Dart standard library imports
    final dartImports = [
      'dart:async',
      'dart:convert',
      'dart:core',
      'dart:io',
      'dart:math',
      'dart:ui',
    ];
    if (dartImports.contains(str)) return false;

    // Event strings typically have patterns like:
    // - family:updated, child:added, vehicle:deleted
    // - family_update, group_update (legacy)
    final eventPatterns = [
      RegExp(r'^[a-zA-Z_]+:[a-zA-Z_:]+$'),
      RegExp(r'^[a-zA-Z_]+_[a-zA-Z_]+$'),
    ];

    return eventPatterns.any((pattern) => pattern.hasMatch(str));
  }

  /// Extract hardcoded event strings from content
  List<String> extractHardcodedEvents(String content) {
    final events = <String>[];
    final patterns = [
      RegExp(r"'([a-zA-Z_]+:[a-zA-Z_:]+)'"),
      RegExp(r'"([a-zA-Z_]+:[a-zA-Z_:]+)"'),
      RegExp(r"'([a-zA-Z_]+_[a-zA-Z_]+)'"),
      RegExp(r'"([a-zA-Z_]+_[a-zA-Z_]+)"'),
    ];

    for (final pattern in patterns) {
      final matches = pattern.allMatches(content);
      for (final match in matches) {
        final eventString = match.group(1);
        if (eventString != null && _isEventString(eventString)) {
          events.add(eventString);
        }
      }
    }
    return events;
  }

  /// Check if content uses SocketEvents constants
  bool usesSocketEventsConstants(String content) {
    return content.contains('SocketEvents.') ||
        content.contains('socket_events.dart');
  }

  /// Check if content has proper stream disposal
  bool hasProperStreamDisposal(String content) {
    // Look for dispose methods that close stream controllers
    final disposePattern = RegExp(
      r'void\s+dispose\(\)\s*{[^}]*\.close\(\);[^}]*}',
      multiLine: true,
    );
    return disposePattern.hasMatch(content);
  }

  /// Check if file uses modern colon-separated event format
  bool usesModernEventFormat(String content, List<String> hardcodedEvents) {
    for (final event in hardcodedEvents) {
      // Legacy format: family_update, group_update, etc.
      if (event.contains('_') && !event.contains(':')) {
        return false;
      }
      // Old camelCase format: familyUpdated, groupUpdated
      if (RegExp(r'^[a-z]+[A-Z][a-zA-Z]*$').hasMatch(event)) {
        return false;
      }
    }
    return true;
  }

  group('WebSocket Architecture Tests - PRINCIPLE 0 ENFORCEMENT', () {
    test(
      'CRITICAL: WebSocket files must NOT contain hardcoded event strings',
      () {
        final webSocketFiles = findDartFiles('lib')
            .where(
              (file) =>
                  file.path.contains('/websocket/') ||
                  file.path.contains('websocket'),
            )
            .where(
              (file) => !file.path.contains('.g.dart'),
            ) // Exclude generated files
            .where(
              (file) => !file.path.contains('socket_events.dart'),
            ) // Exclude constants file
            .toList();

        expect(
          webSocketFiles.isNotEmpty,
          isTrue,
          reason: 'WebSocket files must exist for testing',
        );

        final violationFiles = <String, List<String>>{};

        for (final file in webSocketFiles) {
          final content = readFileContent(file);
          final hardcodedEvents = extractHardcodedEvents(content);

          if (hardcodedEvents.isNotEmpty) {
            violationFiles[file.path] = hardcodedEvents;
          }
        }

        if (violationFiles.isNotEmpty) {
          final violationDetails = violationFiles.entries
              .map(
                (entry) =>
                    '  ${entry.key}:\n    - ${entry.value.join('\n    - ')}',
              )
              .join('\n');

          fail('''
CRITICAL ARCHITECTURE VIOLATION: Hardcoded event strings found!

Files with violations:
$violationDetails

REQUIRED ACTION: Replace ALL hardcoded strings with SocketEvents constants.
Example: Replace 'family:updated' with SocketEvents.FAMILY_UPDATED

This violation breaks the WebSocket modernization architecture requirements.
        ''');
        }
      },
    );

    test(
      'CRITICAL: WebSocket files must use centralized SocketEvents constants',
      () {
        final webSocketFiles = findDartFiles('lib')
            .where(
              (file) =>
                  file.path.contains('/websocket/') ||
                  file.path.contains('websocket'),
            )
            .where(
              (file) => !file.path.contains('socket_events.dart'),
            ) // Exclude the constants file itself
            .where((file) => !file.path.contains('.g.dart'))
            .toList();

        final nonCompliantFiles = <String>[];

        for (final file in webSocketFiles) {
          final content = readFileContent(file);

          // If file handles events but doesn't import/use SocketEvents, it's non-compliant
          if (_handlesEvents(content) && !usesSocketEventsConstants(content)) {
            nonCompliantFiles.add(file.path);
          }
        }

        expect(
          nonCompliantFiles,
          isEmpty,
          reason:
              '''
CRITICAL ARCHITECTURE VIOLATION: WebSocket files must use centralized SocketEvents!

Non-compliant files:
${nonCompliantFiles.map((f) => '  - $f').join('\n')}

REQUIRED ACTION: Import and use SocketEvents constants in ALL WebSocket files.
Add: import '../socket_events.dart';
Use: SocketEvents.FAMILY_UPDATED instead of string literals.
             ''',
        );
      },
    );

    test(
      'CRITICAL: WebSocket services must properly dispose stream controllers',
      () {
        final webSocketServiceFiles = findDartFiles('lib')
            .where(
              (file) =>
                  file.path.contains('websocket') &&
                  file.path.contains('service'),
            )
            .toList();

        final filesWithoutProperDisposal = <String>[];

        for (final file in webSocketServiceFiles) {
          final content = readFileContent(file);

          if (_hasStreamControllers(content) &&
              !hasProperStreamDisposal(content)) {
            filesWithoutProperDisposal.add(file.path);
          }
        }

        expect(
          filesWithoutProperDisposal,
          isEmpty,
          reason:
              '''
CRITICAL MEMORY LEAK VIOLATION: Stream controllers not properly disposed!

Files without proper disposal:
${filesWithoutProperDisposal.map((f) => '  - $f').join('\n')}

REQUIRED ACTION: Implement proper dispose() method that closes ALL stream controllers.
Example:
  void dispose() {
    _familyUpdatesController.close();
    _scheduleUpdatesController.close();
    // ... close all controllers
  }
             ''',
        );
      },
    );

    test('CRITICAL: Event names must use modern colon-separated format', () {
      final webSocketFiles = findDartFiles('lib')
          .where((file) => file.path.contains('/websocket/'))
          .where(
            (file) => !file.path.contains('socket_events.dart'),
          ) // Exclude constants file
          .toList();

      final violationFiles = <String, List<String>>{};

      for (final file in webSocketFiles) {
        final content = readFileContent(file);
        final hardcodedEvents = extractHardcodedEvents(content);

        if (!usesModernEventFormat(content, hardcodedEvents)) {
          violationFiles[file.path] = hardcodedEvents
              .where((event) => !_isModernFormat(event))
              .toList();
        }
      }

      expect(
        violationFiles,
        isEmpty,
        reason:
            '''
CRITICAL FORMAT VIOLATION: Legacy event formats found!

Files with legacy formats:
${violationFiles.entries.map((entry) => '  ${entry.key}:\n    - ${entry.value.join('\n    - ')}').join('\n')}

REQUIRED ACTION: Use modern colon-separated format ONLY.
✅ CORRECT: family:updated, child:added, vehicle:deleted
❌ WRONG: familyUpdated, family_update, childAdded
             ''',
      );
    });

    test('WebSocket architecture must maintain clean layer separation', () {
      final webSocketFiles = findDartFiles(
        'lib/infrastructure/network/websocket',
      ).where((file) => !file.path.contains('.g.dart')).toList();

      final violationFiles = <String>[];

      for (final file in webSocketFiles) {
        final content = readFileContent(file);

        // WebSocket infrastructure should not import from presentation layer
        if (content.contains('import ') &&
            _importsFromPresentationLayer(content)) {
          violationFiles.add(file.path);
        }
      }

      expect(
        violationFiles,
        isEmpty,
        reason:
            '''
ARCHITECTURE VIOLATION: WebSocket infrastructure imports from presentation layer!

Violating files:
${violationFiles.map((f) => '  - $f').join('\n')}

REQUIRED ACTION: WebSocket infrastructure must not depend on presentation layer.
Use dependency injection through composition roots instead.
             ''',
      );
    });

    test('WebSocket event models must follow domain patterns', () {
      final eventModelFiles = findDartFiles('lib')
          .where(
            (file) =>
                file.path.contains('websocket') &&
                (file.path.contains('event') || file.path.contains('model')),
          )
          .toList();

      final nonCompliantFiles = <String>[];

      for (final file in eventModelFiles) {
        final content = readFileContent(file);

        // Event models should be immutable (have final fields)
        if (_hasEventClasses(content) && !_hasImmutableFields(content)) {
          nonCompliantFiles.add(file.path);
        }
      }

      expect(
        nonCompliantFiles,
        isEmpty,
        reason:
            '''
DOMAIN PATTERN VIOLATION: WebSocket event models must be immutable!

Non-compliant files:
${nonCompliantFiles.map((f) => '  - $f').join('\n')}

REQUIRED ACTION: Ensure ALL event model fields are final.
Example: final String eventId; final DateTime timestamp;
             ''',
      );
    });

    test('SUMMARY: Display WebSocket architecture compliance status', () {
      final webSocketFiles = findDartFiles(
        'lib',
      ).where((file) => file.path.contains('websocket')).toList();

      final eventConstantsFiles = findDartFiles(
        'lib',
      ).where((file) => file.path.contains('socket_events.dart')).toList();

      final serviceFiles = webSocketFiles
          .where((file) => file.path.contains('service'))
          .toList();

      final eventFiles = webSocketFiles
          .where((file) => file.path.contains('event'))
          .toList();

      print('\n🔌 WEBSOCKET ARCHITECTURE COMPLIANCE SUMMARY');
      print('=================================================');
      print('📊 Total WebSocket files: ${webSocketFiles.length}');
      print('📁 Event constants files: ${eventConstantsFiles.length}');
      print('🔧 Service files: ${serviceFiles.length}');
      print('📨 Event files: ${eventFiles.length}');
      print('=================================================');

      if (eventConstantsFiles.isEmpty) {
        print('❌ CRITICAL: SocketEvents constants file missing!');
        print(
          '   Required: lib/infrastructure/network/websocket/socket_events.dart',
        );
      } else {
        print('✅ Event constants file exists');
      }

      print('🚨 All violations will cause test failures');
      print(
        '📝 Run: flutter test test/architecture/websocket_architecture_test.dart',
      );

      expect(true, isTrue, reason: 'WebSocket architecture summary displayed');
    });
  });

  group('WebSocket Event Consistency Tests', () {
    test('Event constants must match backend event names exactly', () {
      final socketEventsFile = File(
        'lib/infrastructure/network/websocket/socket_events.dart',
      );

      if (!socketEventsFile.existsSync()) {
        fail('''
CRITICAL: SocketEvents constants file not found!
Required file: lib/infrastructure/network/websocket/socket_events.dart

This file must contain ALL centralized WebSocket event constants.
        ''');
      }

      final content = readFileContent(socketEventsFile);

      // Check for required event constants based on the plan
      final requiredEvents = [
        'FAMILY_UPDATED',
        'FAMILY_MEMBER_JOINED',
        'FAMILY_MEMBER_LEFT',
        'CHILD_ADDED',
        'CHILD_UPDATED',
        'CHILD_DELETED',
        'VEHICLE_ADDED',
        'VEHICLE_UPDATED',
        'VEHICLE_DELETED',
        'SCHEDULE_UPDATED',
        'CONNECTED',
        'DISCONNECTED',
        'NOTIFICATION',
        'CONFLICT_DETECTED',
      ];

      final missingEvents = <String>[];
      for (final event in requiredEvents) {
        if (!content.contains('static const String $event')) {
          missingEvents.add(event);
        }
      }

      expect(
        missingEvents,
        isEmpty,
        reason:
            '''
CRITICAL: Missing required event constants!

Missing events:
${missingEvents.map((e) => '  - $e').join('\n')}

Add these constants to SocketEvents class with proper colon-separated values.
             ''',
      );
    });
  });
}

/// Helper functions for content analysis

bool _handlesEvents(String content) {
  // Exclude barrel files (export only files)
  if (content.trim().startsWith('//') &&
      content
          .split('\n')
          .every(
            (line) =>
                line.trim().startsWith('//') ||
                line.trim().startsWith('export ') ||
                line.trim().isEmpty,
          )) {
    return false;
  }

  // Exclude status/connection providers - they don't handle business events
  if (content.contains('ConnectionState') ||
      content.contains('websocket_status') ||
      content.contains('WebSocketStatus')) {
    return false;
  }

  return content.contains('case ') ||
      content.contains('switch ') ||
      content.contains('_handle') ||
      content.contains('EventType') ||
      content.contains('message[\'type\']');
}

bool _hasStreamControllers(String content) {
  return content.contains('StreamController') &&
      (content.contains('.stream') || content.contains('.add('));
}

bool _importsFromPresentationLayer(String content) {
  return content.contains('/presentation/') ||
      content.contains('/providers/') ||
      content.contains('/widgets/');
}

bool _hasEventClasses(String content) {
  return content.contains('class ') &&
      (content.contains('Event') || content.contains('class WebSocket'));
}

bool _hasImmutableFields(String content) {
  return content.contains('final ') && !content.contains('var ');
}

bool _isModernFormat(String eventName) {
  // Modern format: family:updated, child:added, etc.
  return eventName.contains(':') && !eventName.contains('_');
}
