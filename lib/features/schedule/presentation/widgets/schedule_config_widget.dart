import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import 'per_day_time_slot_config.dart';
import 'package:edulift/core/domain/entities/schedule.dart';
import '../../../groups/presentation/providers/group_schedule_config_provider.dart';
import '../../../../core/constants/schedule_constants.dart';
import '../../../../core/utils/schedule_utils.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/presentation/widgets/accessibility/accessible_button.dart';
import '../../../../core/utils/timezone_utils.dart';
import '../../../../core/services/providers/auth_provider.dart';
import '../../../../core/utils/weekday_localization.dart';

/// Widget for managing group schedule configuration (admin only)
class ScheduleConfigWidget extends ConsumerStatefulWidget {
  final String groupId;
  final VoidCallback? onConfigUpdated;
  final void Function(
    VoidCallback? saveCallback,
    VoidCallback? cancelCallback,
    bool hasChanges,
  )? onActionsChanged;

  const ScheduleConfigWidget({
    super.key,
    required this.groupId,
    this.onConfigUpdated,
    this.onActionsChanged,
  });

  @override
  ConsumerState<ScheduleConfigWidget> createState() =>
      _ScheduleConfigWidgetState();
}

class _ScheduleConfigWidgetState extends ConsumerState<ScheduleConfigWidget>
    with TickerProviderStateMixin {
  late ScheduleConfig _workingConfig;
  ScheduleConfig?
      _originalConfig; // Track original state for proper Cancel functionality
  bool _hasChanges = false;
  String? _validationError;
  int _selectedDayIndex = 0;
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  final List<GlobalKey> _dayConfigKeys = List.generate(
    7,
    (index) => GlobalKey(),
  );

  List<String> _getWeekdayLabels(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return getLocalizedWeekdayLabels(l10n);
  }

  List<String> _getWeekdayShortLabels(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return getLocalizedWeekdayShortLabels(l10n);
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _workingConfig = ScheduleConfig(
      groupId: widget.groupId,
      scheduleHours: ScheduleUtils.createEmptyWeekdayMap(),
      createdAt: now,
      updatedAt: now,
    );

    // Don't call loadConfig here - the provider already loads it in its constructor
    // This prevents duplicate loading and potential race conditions
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Updates working configuration and tracks changes from original state
  void _updateDayTimeSlots(String weekday, List<String> timeSlots) {
    setState(() {
      _workingConfig = _workingConfig.copyWith(
        scheduleHours: {..._workingConfig.scheduleHours, weekday: timeSlots},
      );
      _updateChangesStatus();
      _validateConfiguration();
    });
  }

  /// Updates _hasChanges based on comparison with original config
  void _updateChangesStatus() {
    if (_originalConfig == null) {
      // New configuration case - has changes if any time slots configured
      _hasChanges = _workingConfig.scheduleHours.values.any(
        (slots) => slots.isNotEmpty,
      );
    } else {
      // Existing configuration case - compare with original
      _hasChanges = !_isConfigEqual(_workingConfig, _originalConfig!);
    }

    // Use post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Notify parent of actions availability
      widget.onActionsChanged?.call(
        _validationError == null ? _saveConfiguration : null,
        _hasChanges ? _cancelChanges : null,
        _hasChanges,
      );
    });
  }

  /// Deep equality check for schedule configurations
  bool _isConfigEqual(ScheduleConfig a, ScheduleConfig b) {
    // Compare schedule hours deeply
    for (final weekday in ScheduleConstants.weekdays) {
      final aSlots = a.scheduleHours[weekday] ?? [];
      final bSlots = b.scheduleHours[weekday] ?? [];

      if (aSlots.length != bSlots.length) return false;

      for (var i = 0; i < aSlots.length; i++) {
        if (aSlots[i] != bSlots[i]) return false;
      }
    }

    return true;
  }

  void _validateConfiguration() {
    var error = null as String?;
    var hasTimeSlots = false;
    for (final daySlots in _workingConfig.scheduleHours.values) {
      if (daySlots.isNotEmpty) {
        hasTimeSlots = true;
        break;
      }
    }

    if (!hasTimeSlots) {
      error =
          'At least one departure hour must be configured for at least one day';
    }

    setState(() {
      _validationError = error;
    });
  }

  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) {
      AppLogger.warning(
        'ScheduleConfigWidget._saveConfiguration: Form validation failed',
      );
      return;
    }

    AppLogger.info(
      'ScheduleConfigWidget._saveConfiguration: Starting save for groupId: ${widget.groupId}',
    );

    // Get l10n BEFORE any await to avoid async gap
    final l10n = AppLocalizations.of(context);

    // Get user timezone
    final authState = ref.read(authStateProvider);
    final userTimezone = authState.user?.timezone ?? 'UTC';

    try {
      // TIMEZONE CONVERSION: Convert local scheduleHours to UTC before sending to backend
      AppLogger.info(
        'ScheduleConfigWidget._saveConfiguration: Converting local scheduleHours to UTC ($userTimezone)',
      );
      final utcScheduleHours = convertScheduleHoursToUtc(
        _workingConfig.scheduleHours,
        userTimezone,
      );
      final utcConfig = _workingConfig.copyWith(
        scheduleHours: utcScheduleHours,
      );

      // Call the provider's updateConfig method with UTC times
      AppLogger.debug(
        'ScheduleConfigWidget._saveConfiguration: Calling provider updateConfig with UTC times',
      );
      await ref
          .read(groupScheduleConfigProvider(widget.groupId).notifier)
          .updateConfig(utcConfig);

      // Wait for the provider state to update and check for success
      final currentState = ref.read(
        groupScheduleConfigProvider(widget.groupId),
      );
      AppLogger.debug(
        'ScheduleConfigWidget._saveConfiguration: Provider state after save - hasValue: ${currentState.hasValue}, hasError: ${currentState.hasError}',
      );

      // Only show success if the provider state indicates success
      if (currentState.hasValue && !currentState.hasError) {
        AppLogger.info(
          'ScheduleConfigWidget._saveConfiguration: Save successful, updating UI state',
        );
        setState(() {
          // Update original config to current working config after successful save
          _originalConfig = _workingConfig;
          _hasChanges = false;
          // Stay on current day - preserve user context after save
        });

        _showSuccessSnackBar(l10n.scheduleConfigSavedSuccess);
        widget.onConfigUpdated?.call();

        // Update changes status after successful save
        _updateChangesStatus();
      } else if (currentState.hasError) {
        AppLogger.error(
          'ScheduleConfigWidget._saveConfiguration: Provider returned error',
          currentState.error,
        );
        _showErrorSnackBar(
          l10n.scheduleConfigSaveFailed(currentState.error.toString()),
        );
      } else {
        AppLogger.warning(
          'ScheduleConfigWidget._saveConfiguration: Save operation did not complete successfully',
        );
        _showErrorSnackBar(l10n.saveOperationFailed);
      }
    } catch (e) {
      AppLogger.error(
        'ScheduleConfigWidget._saveConfiguration: Exception during save',
        e,
      );
      _showErrorSnackBar(l10n.scheduleConfigSaveFailed(e.toString()));
    }
  }

  /// Cancels all changes and reverts to original configuration state
  void _cancelChanges() {
    setState(() {
      if (_originalConfig != null) {
        // Revert to original configuration
        _workingConfig = _originalConfig!;
      } else {
        // New group case - revert to empty configuration
        final now = DateTime.now();
        _workingConfig = ScheduleConfig(
          groupId: widget.groupId,
          scheduleHours: ScheduleUtils.createEmptyWeekdayMap(),
          createdAt: now,
          updatedAt: now,
        );
      }

      _hasChanges = false;
      _validationError = null;
    });

    final l10n = AppLocalizations.of(context);
    _showSuccessSnackBar(l10n.changesCanceledReverted);
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final configAsync = ref.watch(groupScheduleConfigProvider(widget.groupId));
    final authState = ref.watch(authStateProvider);

    // Get user timezone, fallback to UTC
    final userTimezone = authState.user?.timezone ?? 'UTC';

    return configAsync.when(
      data: (config) {
        // DEBUG: Log what we received
        AppLogger.info(
          'ScheduleConfigWidget: Received config data - isNull: ${config == null}',
        );
        if (config != null) {
          AppLogger.info(
            'ScheduleConfigWidget: Config has ${config.scheduleHours.keys.length} days (UTC)',
          );
          for (final entry in config.scheduleHours.entries) {
            AppLogger.info(
              'ScheduleConfigWidget: ${entry.key}: ${entry.value.length} slots (UTC)',
            );
          }
        }

        // Set original config when first loaded, but don't overwrite working config if user has changes
        // TIMEZONE CONVERSION: Convert UTC scheduleHours from backend to local timezone for display
        if (config != null && _originalConfig == null) {
          AppLogger.info(
            'ScheduleConfigWidget: Converting UTC scheduleHours to local timezone ($userTimezone)',
          );
          final localScheduleHours = convertScheduleHoursToLocal(
            config.scheduleHours,
            userTimezone,
          );
          final localConfig = config.copyWith(
            scheduleHours: localScheduleHours,
          );

          AppLogger.info(
            'ScheduleConfigWidget: Setting original and working config from provider',
          );
          _originalConfig = localConfig;
          _workingConfig = localConfig;
          // Schedule status update after build completes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateChangesStatus();
          });
        } else if (config != null && _originalConfig != null && !_hasChanges) {
          // Only update if no local changes exist (avoid overwriting user work)
          AppLogger.info(
            'ScheduleConfigWidget: Updating working config from provider (no local changes)',
          );
          final localScheduleHours = convertScheduleHoursToLocal(
            config.scheduleHours,
            userTimezone,
          );
          final localConfig = config.copyWith(
            scheduleHours: localScheduleHours,
          );

          _originalConfig = localConfig;
          _workingConfig = localConfig;
        }

        final isDefaultConfig = config == null;
        final weekdayLabels = _getWeekdayLabels(context);

        return Form(
          key: _formKey,
          child: Column(
            children: [
              // Timezone indicator
              _buildTimezoneIndicator(theme, userTimezone),
              if (_validationError != null) _buildValidationError(theme),
              if (isDefaultConfig && !_hasChanges)
                _buildDefaultConfigInfo(theme),
              Expanded(
                child: Column(
                  children: [
                    _buildDaySelector(theme, weekdayLabels),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _selectedDayIndex = index;
                          });
                        },
                        itemCount: 7,
                        itemBuilder: (context, index) {
                          final weekday = ScheduleConstants.weekdays[index];
                          final weekdayLabel = weekdayLabels[index];
                          final timeSlots =
                              _workingConfig.scheduleHours[weekday] ?? [];

                          return PerDayTimeSlotConfig(
                            key: _dayConfigKeys[index],
                            weekday: weekday,
                            weekdayLabel: weekdayLabel,
                            timeSlots: timeSlots,
                            onTimeSlotsChanged: (slots) =>
                                _updateDayTimeSlots(weekday, slots),
                            onAddTimeSlotRequested: () {
                              // Access the per-day widget state to add departure hour
                              final keyState =
                                  _dayConfigKeys[index].currentState;
                              if (keyState != null) {
                                // Call the public addDepartureHour method through reflection
                                // Since we can't import the private state class, we use a try-catch
                                try {
                                  (keyState as dynamic).addDepartureHour();
                                } catch (e) {
                                  // Method not available, ignore
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildErrorState(error.toString()),
    );
  }

  /// Build the FAB for the parent page to use
  Widget buildFloatingActionButton(BuildContext context) {
    final theme = Theme.of(context);
    return _buildContextAwareFAB(context, theme);
  }

  Widget _buildTimezoneIndicator(ThemeData theme, String userTimezone) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue.shade700,
            size: 20,
            semanticLabel: 'Information',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).timesShownInYourTimezone,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppLocalizations.of(context).timezoneLabel} : $userTimezone',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationError(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: 20,
            semanticLabel: 'Error',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _validationError!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultConfigInfo(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: theme.colorScheme.primary,
            size: 20,
            semanticLabel: 'Information',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(context).defaultGroupConfigInfo,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector(ThemeData theme, List<String> weekdayLabels) {
    final weekdayShortLabels = _getWeekdayShortLabels(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < ScheduleConstants.weekdays.length; i++) ...[
              _buildDayChip(i, theme, weekdayShortLabels),
              if (i < ScheduleConstants.weekdays.length - 1)
                const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDayChip(
    int index,
    ThemeData theme,
    List<String> weekdayShortLabels,
  ) {
    final isSelected = _selectedDayIndex == index;
    final slotCount = _workingConfig
            .scheduleHours[ScheduleConstants.weekdays[index]]?.length ??
        0;
    final dayAbbrev = weekdayShortLabels[index];

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Switch to $dayAbbrev configuration',
      hint: slotCount > 0
          ? '$slotCount departure hours configured'
          : 'No departure hours configured',
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDayIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 56,
            minHeight: 48,
          ), // WCAG AA compliance
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dayAbbrev,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (slotCount > 0) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.onPrimary.withValues(alpha: 0.2)
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    slotCount.toString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContextAwareFAB(BuildContext context, ThemeData theme) {
    final currentWeekday = ScheduleConstants.weekdays[_selectedDayIndex];
    final currentDaySlots = _workingConfig.scheduleHours[currentWeekday] ?? [];
    final canAddSlots =
        currentDaySlots.length < ScheduleConstants.maxTimeSlotsPerDay;
    final weekdayLabel = _getWeekdayLabels(context)[_selectedDayIndex];

    return AccessibleFloatingActionButton(
      onPressed: canAddSlots
          ? () {
              // Access the per-day widget state to add departure hour
              final keyState = _dayConfigKeys[_selectedDayIndex].currentState;
              if (keyState != null) {
                // Call the public addDepartureHour method through reflection
                // Since we can't import the private state class, we use a try-catch
                try {
                  (keyState as dynamic).addDepartureHour();
                } catch (e) {
                  // Method not available, ignore
                }
              }
            }
          : null,
      semanticLabel: canAddSlots
          ? 'Add departure hour to $weekdayLabel'
          : 'Maximum departure hours reached for $weekdayLabel',
      semanticHint: canAddSlots
          ? 'Opens time picker to add a new departure hour for $weekdayLabel'
          : 'Cannot add more departure hours, maximum limit of ${ScheduleConstants.maxTimeSlotsPerDay} reached',
      tooltip: canAddSlots
          ? 'Add departure hour to $weekdayLabel'
          : 'Maximum hours reached',
      backgroundColor: canAddSlots
          ? theme.colorScheme.primary
          : theme.colorScheme.onSurface.withValues(alpha: 0.12),
      foregroundColor: canAddSlots
          ? theme.colorScheme.onPrimary
          : theme.colorScheme.onSurface.withValues(alpha: 0.38),
      elevation: canAddSlots ? 6 : 0,
      child: Icon(canAddSlots ? Icons.add : Icons.block, size: 24),
    );
  }

  Widget _buildErrorState(String error) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: theme.colorScheme.error.withValues(alpha: 0.7),
              semanticLabel: 'Error occurred',
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Configuration',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            AccessibleButton(
              key: const Key('schedule_config_try_again_button'),
              onPressed: () {
                ref
                    .read(groupScheduleConfigProvider(widget.groupId).notifier)
                    .loadConfig();
              },
              semanticLabel: 'Try loading configuration again',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context).tryAgain),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
