// DEPENDENCY CYCLE DETECTION - CRITICAL ARCHITECTURAL HEALTH CHECK
// PRINCIPLE 0: RADICAL CANDOR - TRUTH ABOVE ALL
//
// This test prevents architectural decay by detecting dependency cycles
// between layers and features that would undermine clean architecture.

// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Helper to extract imports from a Dart file
  List<String> extractImports(File file) {
    final content = file.readAsStringSync();
    final lines = content.split('\n');
    final imports = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('import ')) {
        final singleQuoteMatch = RegExp(
          r"import\s+'([^']+)'",
        ).firstMatch(trimmed);
        final doubleQuoteMatch = RegExp(
          r'import\s+"([^"]+)"',
        ).firstMatch(trimmed);

        if (singleQuoteMatch != null) {
          imports.add(singleQuoteMatch.group(1)!);
        } else if (doubleQuoteMatch != null) {
          imports.add(doubleQuoteMatch.group(1)!);
        }
      }
    }

    return imports;
  }

  /// Build dependency graph between features
  Map<String, Set<String>> buildFeatureDependencyGraph() {
    final features = ['family', 'groups', 'schedule', 'auth'];
    final dependencies = <String, Set<String>>{};

    // Initialize empty dependency sets
    for (final feature in features) {
      dependencies[feature] = <String>{};
    }

    // Scan all feature files for cross-feature dependencies
    for (final feature in features) {
      final featureDir = Directory('lib/features/$feature');
      if (!featureDir.existsSync()) continue;

      final featureFiles = featureDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .where(
            (file) => !file.path.endsWith('providers.dart'),
          ) // Exclude composition roots
          .toList();

      for (final file in featureFiles) {
        final imports = extractImports(file);

        for (final import in imports) {
          // Check if this import points to another feature
          for (final otherFeature in features) {
            if (otherFeature != feature &&
                import.contains('/features/$otherFeature/')) {
              dependencies[feature]!.add(otherFeature);
              break;
            }
          }
        }
      }
    }

    return dependencies;
  }

  /// Detect cycles in dependency graph using DFS
  bool hasCycles(Map<String, Set<String>> graph) {
    final visited = <String>{};
    final recursionStack = <String>{};

    bool dfsHasCycle(String node) {
      if (recursionStack.contains(node)) {
        return true; // Back edge found - cycle detected
      }

      if (visited.contains(node)) {
        return false; // Already processed
      }

      visited.add(node);
      recursionStack.add(node);

      for (final neighbor in graph[node] ?? <String>{}) {
        if (dfsHasCycle(neighbor)) {
          return true;
        }
      }

      recursionStack.remove(node);
      return false;
    }

    for (final node in graph.keys) {
      if (!visited.contains(node)) {
        if (dfsHasCycle(node)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Find and return all cycles for detailed reporting
  List<List<String>> findAllCycles(Map<String, Set<String>> graph) {
    final cycles = <List<String>>[];
    final visited = <String>{};
    final path = <String>[];

    void dfsFindCycles(String node) {
      if (path.contains(node)) {
        // Found a cycle - extract the cycle
        final cycleStart = path.indexOf(node);
        final cycle = path.sublist(cycleStart)..add(node);
        cycles.add(List.from(cycle));
        return;
      }

      if (visited.contains(node)) return;

      visited.add(node);
      path.add(node);

      for (final neighbor in graph[node] ?? <String>{}) {
        dfsFindCycles(neighbor);
      }

      path.remove(node);
    }

    for (final node in graph.keys) {
      visited.clear();
      path.clear();
      dfsFindCycles(node);
    }

    return cycles;
  }

  group('Dependency Cycle Detection - CRITICAL ARCHITECTURAL HEALTH', () {
    test('No dependency cycles between features', () {
      final dependencyGraph = buildFeatureDependencyGraph();
      final cyclesExist = hasCycles(dependencyGraph);

      if (cyclesExist) {
        final cycles = findAllCycles(dependencyGraph);
        final cycleDescriptions =
            cycles.map((cycle) => cycle.join(' -> ')).join('\n');

        fail(
          'CRITICAL: Dependency cycles detected between features!\n'
          'Cycles found:\n$cycleDescriptions\n\n'
          'Dependency graph:\n${dependencyGraph.entries.map((e) => '${e.key} -> [${e.value.join(', ')}]').join('\n')}\n\n'
          'Fix: Remove direct imports between features. Use shared core utilities or composition roots.',
        );
      }

      expect(
        cyclesExist,
        isFalse,
        reason: 'No dependency cycles should exist between features',
      );
    });

    test('Display feature dependency analysis', () {
      final dependencyGraph = buildFeatureDependencyGraph();
      final totalDependencies = dependencyGraph.values
          .map((deps) => deps.length)
          .fold(0, (sum, count) => sum + count);

      print('\n🔄 FEATURE DEPENDENCY ANALYSIS');
      print('===============================');
      print('📊 Total cross-feature dependencies: $totalDependencies');

      for (final entry in dependencyGraph.entries) {
        final feature = entry.key;
        final dependencies = entry.value;

        if (dependencies.isEmpty) {
          print('✅ $feature: No external dependencies (isolated)');
        } else {
          print('⚠️  $feature: Depends on [${dependencies.join(', ')}]');
        }
      }

      print('===============================');
      if (totalDependencies == 0) {
        print('🎯 EXCELLENT: All features are properly isolated');
      } else {
        print('💡 Consider reducing cross-feature dependencies');
        print('   Use shared core utilities instead of direct imports');
      }

      expect(true, isTrue, reason: 'Feature dependency analysis completed');
    });

    test('Schedule feature cross-dependencies are documented exceptions', () {
      final dependencyGraph = buildFeatureDependencyGraph();
      final scheduleDeps = dependencyGraph['schedule'] ?? <String>{};

      // Schedule is allowed to depend on family and groups (documented exception)
      final allowedDeps = {'family', 'groups'};
      final unauthorizedDeps = scheduleDeps.difference(allowedDeps);

      expect(
        unauthorizedDeps.isEmpty,
        isTrue,
        reason:
            'Schedule feature has unauthorized dependencies: ${unauthorizedDeps.join(', ')}. '
            'Only family and groups are allowed.',
      );

      if (scheduleDeps.isNotEmpty) {
        print('\n📋 SCHEDULE FEATURE EXCEPTIONS:');
        print('Allowed dependencies: ${scheduleDeps.join(', ')}');
        print('Reason: Schedule coordinates family members and groups');
      }
    });
  });

  group('Layer Dependency Cycles - FUNDAMENTAL ARCHITECTURE', () {
    test('No cycles between architectural layers', () {
      final layers = ['domain', 'data', 'presentation'];
      final layerFiles = <String, List<File>>{};
      final layerDependencies = <String, Set<String>>{};

      // Find files in each layer
      for (final layer in layers) {
        layerFiles[layer] = Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'))
            .where((file) => file.path.contains('/$layer/'))
            .toList();

        layerDependencies[layer] = <String>{};
      }

      // Analyze layer dependencies
      for (final entry in layerFiles.entries) {
        final currentLayer = entry.key;
        final files = entry.value;

        for (final file in files) {
          final imports = extractImports(file);

          for (final import in imports) {
            for (final otherLayer in layers) {
              if (otherLayer != currentLayer &&
                  import.contains('/$otherLayer/')) {
                layerDependencies[currentLayer]!.add(otherLayer);
                break;
              }
            }
          }
        }
      }

      // Check for cycles
      final cyclesExist = hasCycles(layerDependencies);

      if (cyclesExist) {
        final cycles = findAllCycles(layerDependencies);
        final cycleDescriptions =
            cycles.map((cycle) => cycle.join(' -> ')).join('\n');

        fail(
          'CRITICAL: Layer dependency cycles detected!\n'
          'This completely undermines clean architecture principles.\n'
          'Cycles found:\n$cycleDescriptions\n\n'
          'Expected flow: Presentation -> Domain <- Data\n'
          'Fix: Remove imports that create cycles between layers.',
        );
      }

      expect(
        cyclesExist,
        isFalse,
        reason: 'Architectural layers must be acyclic',
      );
    });
  });
}
