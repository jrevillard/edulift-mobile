import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/core/domain/entities/schedule.dart';
import '../../../schedule/domain/usecases/manage_schedule_config.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/network/error_handler_service.dart';
import '../../../../core/di/providers/providers.dart';
import '../../../../core/di/providers/service_providers.dart';
import '../../../schedule/providers.dart' as schedule_providers;

/// Provider for group schedule configuration
///
/// This provider manages schedule configuration for a specific group.
/// Group schedule config is a GROUP responsibility, not a generic schedule responsibility.
final groupScheduleConfigProvider = StateNotifierProvider.family<
    GroupScheduleConfigNotifier,
    AsyncValue<ScheduleConfig?>,
    String>((ref, groupId) {
  return GroupScheduleConfigNotifier(
    groupId,
    ref.read(schedule_providers.getScheduleConfigUsecaseProvider),
    ref.read(schedule_providers.updateScheduleConfigUsecaseProvider),
    ref.read(schedule_providers.resetScheduleConfigUsecaseProvider),
    ref.read(coreErrorHandlerServiceProvider),
  );
});

/// Notifier for group schedule configuration state
class GroupScheduleConfigNotifier
    extends StateNotifier<AsyncValue<ScheduleConfig?>> {
  final GetScheduleConfig? _getConfigUseCase;
  final UpdateScheduleConfig _updateConfigUseCase;
  final ResetScheduleConfig? _resetConfigUseCase;
  final ErrorHandlerService _errorHandlerService;
  final String groupId;

  GroupScheduleConfigNotifier(
    this.groupId,
    this._getConfigUseCase,
    this._updateConfigUseCase,
    this._resetConfigUseCase,
    this._errorHandlerService,
  ) : super(const AsyncValue.loading()) {
    loadConfig();
  }

  /// Load schedule config for the group
  ///
  /// IMPORTANT: 404 is NOT an error - it means no config exists yet.
  /// This follows the same pattern as GetCurrentFamily for 404 handling.
  Future<void> loadConfig() async {
    state = const AsyncValue.loading();
    try {
      if (_getConfigUseCase == null) {
        // Return null config if use case is not available (stub implementation)
        state = const AsyncValue.data(null);
        return;
      }

      final result = await _getConfigUseCase.call(
        GetScheduleConfigParams(groupId: groupId),
      );

      if (result.isOk) {
        final config = result.value!;
        // DEBUG: Log the keys received from backend
        final debugInfo = StringBuffer(
          'Schedule config loaded for group $groupId\n',
        );
        debugInfo.writeln(
          '  Schedule hours keys: ${config.scheduleHours.keys.toList()}',
        );
        for (final entry in config.scheduleHours.entries) {
          debugInfo.writeln(
            '  ${entry.key}: ${entry.value.length} slots - ${entry.value}',
          );
        }
        debugInfo.writeln(
          'Provider state set successfully - hasValue: ${state.hasValue}, isLoading: ${state.isLoading}',
        );
        AppLogger.info(debugInfo.toString().trim());
        state = AsyncValue.data(config);
      } else {
        final failure = result.error!;

        // CRITICAL: Handle 404 as a normal state, NOT an error
        // 404 means no config exists - return null to show unconfigured state
        // This is the same pattern used in family_remote_datasource_impl.dart
        if (failure.statusCode == 404) {
          // No config exists - this is NORMAL, not an error
          // User must explicitly create/initialize config
          state = const AsyncValue.data(null);
          // DO NOT log errors for 404 - this is expected
          return; // Early return to avoid any error handling
        }

        // For other errors, propagate the error to the UI
        AppLogger.error('Error loading group schedule config: $failure');
        final errorResult = await _errorHandlerService.handleError(
          failure,
          ErrorContext.scheduleOperation('load_config'),
        );
        state = AsyncValue.error(
          errorResult.userMessage.messageKey,
          StackTrace.current,
        );
      }
    } catch (e) {
      final errorResult = await _errorHandlerService.handleError(
        e,
        ErrorContext.scheduleOperation('load_config'),
      );
      state = AsyncValue.error(
        errorResult.userMessage.messageKey,
        StackTrace.current,
      );
    }
  }

  /// Update schedule config for the group
  Future<void> updateConfig(ScheduleConfig config) async {
    AppLogger.info(
      'GroupScheduleConfigProvider.updateConfig called for groupId: $groupId',
    );
    state = const AsyncValue.loading();
    try {
      final result = await _updateConfigUseCase.call(
        UpdateScheduleConfigParams(groupId: groupId, config: config),
      );
      if (result.isOk) {
        final updatedConfig = result.value!;
        AppLogger.info(
          'Group schedule config update successful for groupId: $groupId',
        );
        state = AsyncValue.data(updatedConfig);
      } else {
        final failure = result.error!;

        AppLogger.error(
          'Group schedule config update failed for groupId: $groupId',
          failure,
        );
        final errorResult = await _errorHandlerService.handleError(
          failure,
          ErrorContext.scheduleOperation('update_config'),
        );
        state = AsyncValue.error(
          errorResult.userMessage.messageKey,
          StackTrace.current,
        );
      }
    } catch (e) {
      AppLogger.error(
        'Group schedule config update exception for groupId: $groupId',
        e,
      );
      final errorResult = await _errorHandlerService.handleError(
        e,
        ErrorContext.scheduleOperation('update_config'),
      );
      state = AsyncValue.error(
        errorResult.userMessage.messageKey,
        StackTrace.current,
      );
    }
  }

  /// Reset schedule config to defaults for the group
  Future<void> resetConfig() async {
    state = const AsyncValue.loading();
    try {
      if (_resetConfigUseCase == null) {
        // Return null config if use case is not available
        state = const AsyncValue.data(null);
        return;
      }

      final result = await _resetConfigUseCase.call(
        ResetScheduleConfigParams(groupId: groupId),
      );
      if (result.isOk) {
        final resetConfig = result.value!;
        state = AsyncValue.data(resetConfig);
      } else {
        final failure = result.error!;
        final errorResult = await _errorHandlerService.handleError(
          failure,
          ErrorContext.scheduleOperation('reset_config'),
        );
        state = AsyncValue.error(
          errorResult.userMessage.messageKey,
          StackTrace.current,
        );
      }
    } catch (e) {
      final errorResult = await _errorHandlerService.handleError(
        e,
        ErrorContext.scheduleOperation('reset_config'),
      );
      state = AsyncValue.error(
        errorResult.userMessage.messageKey,
        StackTrace.current,
      );
    }
  }

  /// Get current config value
  ScheduleConfig? get currentConfig => state.value;

  /// Check if config is valid
  bool get isConfigValid {
    final config = currentConfig;
    if (config == null) return false;

    return config.scheduleHours.values.any((slots) => slots.isNotEmpty);
  }

  /// Get validation issues with current config
  List<String> get validationIssues {
    final config = currentConfig;
    if (config == null) return ['No configuration loaded'];

    final issues = <String>[];

    final activeDays = config.scheduleHours.entries
        .where((entry) => entry.value.isNotEmpty)
        .length;

    if (activeDays == 0) {
      issues.add('At least one active day must be selected');
    }

    final totalTimeSlots = config.scheduleHours.values.fold(
      0,
      (sum, slots) => sum + slots.length,
    );
    if (totalTimeSlots == 0) {
      issues.add('At least one time slot must be configured');
    }

    return issues;
  }

  /// Refresh config from backend
  Future<void> refresh() async {
    await loadConfig();
  }

  /// Clear config state
  void clear() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for checking schedule config access permissions
final hasGroupScheduleConfigAccessProvider = Provider.family<bool, String>((
  ref,
  groupId,
) {
  // For now, assume all users have config access
  // In a real app, this would check user permissions
  return true;
});

/// Provider for schedule config statistics
final groupScheduleConfigStatsProvider =
    Provider.family<GroupScheduleConfigStats?, String>((ref, groupId) {
  final configState = ref.watch(groupScheduleConfigProvider(groupId));
  return configState.when(
    data: (config) {
      if (config == null) return null;
      return GroupScheduleConfigStats(
        activeDays: config.scheduleHours.values
            .where((slots) => slots.isNotEmpty)
            .length,
        totalDays: config.scheduleHours.length,
        activeTimeSlots: config.scheduleHours.values.fold(
          0,
          (sum, slots) => sum + slots.length,
        ),
        totalTimeSlots: config.scheduleHours.values.fold(
          0,
          (sum, slots) => sum + slots.length,
        ),
      );
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Statistics for group schedule configuration
class GroupScheduleConfigStats {
  final int activeDays;
  final int totalDays;
  final int activeTimeSlots;
  final int totalTimeSlots;

  GroupScheduleConfigStats({
    required this.activeDays,
    required this.totalDays,
    required this.activeTimeSlots,
    required this.totalTimeSlots,
  });

  double get activeDaysPercentage =>
      totalDays > 0 ? activeDays / totalDays : 0.0;

  double get activeTimeSlotsPercentage =>
      totalTimeSlots > 0 ? activeTimeSlots / totalTimeSlots : 0.0;

  bool get isConfigured => activeDays > 0 && activeTimeSlots > 0;

  bool get isOptimal =>
      activeDaysPercentage >= 0.7 && activeTimeSlotsPercentage >= 0.5;
}
