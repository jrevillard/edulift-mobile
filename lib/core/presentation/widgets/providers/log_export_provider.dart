import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_logs/flutter_logs.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/storage/log_config.dart';

class LogExportState {
  final bool isExporting;
  final String? error;
  final DateTime? lastExportTime;
  final int logSizeBytes;

  const LogExportState({
    this.isExporting = false,
    this.error,
    this.lastExportTime,
    this.logSizeBytes = 0,
  });

  LogExportState copyWith({
    bool? isExporting,
    String? error,
    DateTime? lastExportTime,
    int? logSizeBytes,
  }) {
    return LogExportState(
      isExporting: isExporting ?? this.isExporting,
      error: error,
      lastExportTime: lastExportTime ?? this.lastExportTime,
      logSizeBytes: logSizeBytes ?? this.logSizeBytes,
    );
  }
}

class LogExportNotifier extends AsyncNotifier<LogExportState> {
  @override
  Future<LogExportState> build() async {
    final logSize = await _estimateLogSize();
    return LogExportState(logSizeBytes: logSize);
  }

  Future<void> exportLogs() async {
    state = AsyncValue.data(
      state.value?.copyWith(isExporting: true) ??
          const LogExportState(isExporting: true),
    );

    try {
      AppLogger.info('Starting log export');

      // Check if platform is supported
      if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        throw UnsupportedError('LOG_EXPORT_UNSUPPORTED_PLATFORM');
      }

      // FlutterLogs.exportLogs() returns void and creates a ZIP file
      await FlutterLogs.exportLogs();

      // Mobile only: Use application documents directory
      final baseDir = await getApplicationDocumentsDirectory();
      final exportPath = p.join(
        baseDir.path,
        LogConfig.logsExportDirectoryName,
      );

      var exportDirectory = Directory(exportPath);
      if (!await exportDirectory.exists()) {
        // Try alternative export locations
        final alternativeExportPaths = [
          p.join(baseDir.path, 'logs'),
          p.join(baseDir.path, 'FlutterLogs', 'Exported'),
          p.join(baseDir.path, 'app_logs'),
          baseDir.path, // Check base directory itself
        ];

        var foundDirectory = false;
        for (final altPath in alternativeExportPaths) {
          final altDir = Directory(altPath);
          if (await altDir.exists()) {
            exportDirectory = altDir;
            foundDirectory = true;
            break;
          }
        }

        if (!foundDirectory) {
          throw Exception('LOG_EXPORT_NO_DIRECTORY');
        }
      }

      final zipFiles = await exportDirectory
          .list()
          .where((file) => file.path.endsWith('.zip'))
          .cast<File>()
          .toList();

      if (zipFiles.isEmpty) {
        throw Exception('LOG_EXPORT_NO_FILES');
      }

      // Get the most recent ZIP file
      zipFiles.sort((a, b) {
        final statA = a.statSync();
        final statB = b.statSync();
        return statB.modified.compareTo(statA.modified);
      });
      final zipFile = zipFiles.first;

      await _shareLogFile(zipFile);
      AppLogger.info('Log export completed successfully');

      final zipFileSize = await zipFile.length();
      state = AsyncValue.data(
        LogExportState(
          lastExportTime: DateTime.now(),
          logSizeBytes: zipFileSize,
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.error('Log export failed', error, stackTrace);

      try {
        await FirebaseCrashlytics.instance.recordError(error, stackTrace);
      } catch (e) {
        // Firebase not initialized (e.g., in tests) - silently continue
        AppLogger.warning('Could not record error to Firebase Crashlytics', e);
      }

      state = AsyncValue.data(
        LogExportState(
          error: error.toString(),
          lastExportTime: state.value?.lastExportTime,
          logSizeBytes: state.value?.logSizeBytes ?? 0,
        ),
      );
    }
  }

  Future<String> getCurrentLogLevel() async {
    final level = await LogConfig.getLogLevel();
    return level.name.toUpperCase();
  }

  Future<void> setLogLevel(String levelName) async {
    try {
      final level = LogConfig.availableLevels.values.firstWhere(
        (l) => l.name.toLowerCase() == levelName.toLowerCase(),
      );
      await LogConfig.setLogLevel(level);
      AppLogger.info('Log level changed to: ${level.name}');
    } catch (e) {
      AppLogger.error('Failed to set log level: $levelName', e);
      rethrow;
    }
  }

  Future<String> _buildSupportInfo() async {
    final appInfo = await PackageInfo.fromPlatform();
    final deviceInfo = await _getDeviceInfo();
    final timestamp = DateTime.now().toIso8601String();

    return '''
=== EDULIFT SUPPORT EXPORT ===
Timestamp: $timestamp
App: ${appInfo.appName} v${appInfo.version} (${appInfo.buildNumber})
Platform: ${Platform.operatingSystem}
Device: ${deviceInfo['Device'] ?? deviceInfo['Device Model'] ?? 'Unknown'}

For support assistance, attach this file to your support request.
Email: support@edulift.app
''';
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        'Device Model': '${androidInfo.manufacturer} ${androidInfo.model}',
        'Android Version':
            'API ${androidInfo.version.sdkInt} (${androidInfo.version.release})',
        'Brand': androidInfo.brand,
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        'Device': '${iosInfo.name} (${iosInfo.model})',
        'iOS Version': '${iosInfo.systemName} ${iosInfo.systemVersion}',
      };
    }

    return {'Platform': Platform.operatingSystem};
  }

  Future<int> _estimateLogSize() async {
    try {
      // Check if platform is supported
      if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        return 0; // Desktop not supported
      }

      // flutter_logs.exportLogs() creates a ZIP of the last 24h of logs only
      // We need to estimate the size of TODAY's logs that will be exported
      final baseDir = await getApplicationDocumentsDirectory();
      final logsDirectoryPath = p.join(
        baseDir.path,
        LogConfig.logsWriteDirectoryName,
      );
      final logsDirectory = Directory(logsDirectoryPath);

      if (!await logsDirectory.exists()) {
        return 0; // No logs = 0 bytes (PRINCIPLE ZERO - no fake fallback)
      }

      // Calculate size of today's logs only (what flutter_logs will export)
      return await _calculateTodayLogsSize(logsDirectory);
    } catch (e) {
      AppLogger.warning('Failed to estimate log size', e);
      return 0; // Error = 0 bytes estimate (PRINCIPLE ZERO)
    }
  }

  Future<int> _calculateTodayLogsSize(Directory directory) async {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    var totalSize = 0;
    try {
      await for (final entity in directory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File) {
          try {
            final fileStat = await entity.stat();
            // Only count files modified today (last 24h that flutter_logs exports)
            if (fileStat.modified.isAfter(todayStart) &&
                fileStat.modified.isBefore(tomorrowStart)) {
              totalSize += await entity.length();
            }
          } catch (e) {
            // Skip files we can't read
            continue;
          }
        }
      }
    } catch (e) {
      AppLogger.warning(
        'Error calculating today logs size: ${directory.path}',
        e,
      );
    }

    return totalSize; // Return REAL size, even if 0
  }

  Future<void> _shareLogFile(File logFile) async {
    try {
      final supportInfo = await _buildSupportInfo();
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(logFile.path)],
          subject:
              'EduLift Support Logs - ${DateTime.now().toIso8601String().split('T')[0]}',
          text: 'EduLift app logs for support analysis.\n\n$supportInfo',
        ),
      );
    } on UnimplementedError catch (e) {
      if (e.message?.contains('not supported') == true) {
        AppLogger.info(
          'Platform does not support sharing, copying path to clipboard',
        );
        await Clipboard.setData(
          ClipboardData(
            text:
                'EduLift Support Logs\nLocation: ${logFile.path}\nGenerated: ${DateTime.now().toLocal()}',
          ),
        );
        AppLogger.info('Log file path copied to clipboard: ${logFile.path}');
      } else {
        rethrow;
      }
    }
  }
}

final logExportProvider =
    AsyncNotifierProvider<LogExportNotifier, LogExportState>(
      LogExportNotifier.new,
    );

final currentLogLevelProvider = FutureProvider<String>((ref) async {
  final level = await LogConfig.getLogLevel();
  return level.name.toUpperCase();
});
