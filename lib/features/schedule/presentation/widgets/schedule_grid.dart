import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'schedule_slot_widget.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../utils/time_slot_mapper.dart';
import 'package:edulift/core/utils/date/iso_week_utils.dart';
import '../design/schedule_design.dart';
import '../../../../core/presentation/themes/app_colors.dart';
import 'package:edulift/core/domain/entities/schedule.dart';
import '../../../../core/utils/weekday_localization.dart';

/// Simple, mobile-friendly schedule grid
/// Shows a week view with easy-to-use slots
/// Now with PageView for week navigation and dynamic time slots
class ScheduleGrid extends ConsumerStatefulWidget {
  final String groupId;
  final String week;
  final List<ScheduleSlot> scheduleData;
  final ScheduleConfig? scheduleConfig; // ✨ NOUVEAU: Configuration des créneaux
  final Function(PeriodSlotData) onManageVehicles;
  final Function(String, String, String) onVehicleDrop;
  final Function(int weekOffset)?
  onWeekChanged; // ✨ NOUVEAU: Callback pour changement de semaine

  const ScheduleGrid({
    super.key,
    required this.groupId,
    required this.week,
    required this.scheduleData,
    this.scheduleConfig, // ✨ NOUVEAU: Optionnel pour fallback
    required this.onManageVehicles,
    required this.onVehicleDrop,
    this.onWeekChanged, // ✨ NOUVEAU: Optionnel pour compatibilité
  });

  @override
  ConsumerState<ScheduleGrid> createState() => _ScheduleGridState();
}

class _ScheduleGridState extends ConsumerState<ScheduleGrid> {
  late PageController _weekPageController;
  // ✨ SIMPLE: Track the currently displayed week directly, not an offset
  late String _currentDisplayedWeek;

  @override
  void initState() {
    super.initState();
    // Initialize at center page (1000) to allow infinite scrolling in both directions
    _weekPageController = PageController(initialPage: 1000);
    // Start with the week passed from parent
    _currentDisplayedWeek = widget.week;
  }

  @override
  void didUpdateWidget(ScheduleGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If parent changes the week, update our displayed week AND reset page controller
    if (oldWidget.week != widget.week) {
      debugPrint(
        '⚠️ didUpdateWidget: week changed from ${oldWidget.week} to ${widget.week}',
      );
      debugPrint('   Resetting PageController to center (page 1000)');

      _currentDisplayedWeek = widget.week;

      // CRITICAL: Reset PageController to center (page 1000) when parent changes the week
      // This ensures page offsets are calculated correctly from the new initial week
      // Without this, the PageController stays at its current page (e.g., 1003)
      // causing all subsequent calculations to be wrong
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_weekPageController.hasClients) {
          _weekPageController.jumpToPage(1000);
        }
      });
    }
  }

  @override
  void dispose() {
    _weekPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildWeekIndicator(),
        Expanded(
          child: PageView.builder(
            controller: _weekPageController,
            onPageChanged: (page) {
              HapticFeedback.lightImpact();

              // ✨ SIMPLE: Calculate the actual week for this page
              // Pages are numbered relative to 1000 (center)
              // Page 1000 = initial week, 1001 = next week, 999 = previous week
              final pageOffset = page - 1000;

              // ⚠️ CRITICAL: Always calculate from widget.week (the INITIAL week when grid was created)
              // NOT from _currentDisplayedWeek, because page numbers are relative to initial week
              final initialWeek = widget.week;
              final newWeek = addWeeksToISOWeek(initialWeek, pageOffset);

              debugPrint('🔄 Page changed to $page (offset: $pageOffset)');
              debugPrint('   Initial week: $initialWeek');
              debugPrint('   New week: $newWeek');
              debugPrint('   Current displayed: $_currentDisplayedWeek');

              setState(() => _currentDisplayedWeek = newWeek);

              // Calculate offset from initial week for parent callback
              final weekOffset = weeksBetween(widget.week, newWeek);

              debugPrint('   Calling parent with offset: $weekOffset');

              widget.onWeekChanged?.call(weekOffset);
            },
            itemBuilder: (context, page) {
              final pageOffset = page - 1000;
              return _buildWeekView(pageOffset);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeekIndicator() {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive: très petits écrans (< 360px) → layout compact
    final isVerySmallScreen = screenWidth < 360;

    // Calculate week dates for display using the current displayed week
    final weekDates = _getWeekDateRange(_currentDisplayedWeek);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: AppColors.borderThemed(context)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              _weekPageController.previousPage(
                duration: ScheduleAnimations.getDuration(
                  context,
                  ScheduleAnimations.normal,
                ),
                curve: ScheduleAnimations.getCurve(
                  context,
                  ScheduleAnimations.standard,
                ),
              );
            },
            icon: const Icon(Icons.chevron_left),
            tooltip: l10n.previousWeek,
          ),
          // Make week indicator tappable to open date picker
          Expanded(
            child: GestureDetector(
              onTap: () => _showDatePicker(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(
                    context,
                  ).scaffoldBackgroundColor.withValues(alpha: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: isVerySmallScreen ? 14 : 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    // Date range display only (no confusing labels)
                    Flexible(
                      child: Text(
                        weekDates != null
                            ? _formatWeekDateRange(weekDates, isVerySmallScreen)
                            : l10n.selectWeekHelpText,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: isVerySmallScreen ? 14 : null,
                            ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              _weekPageController.nextPage(
                duration: ScheduleAnimations.getDuration(
                  context,
                  ScheduleAnimations.normal,
                ),
                curve: ScheduleAnimations.getCurve(
                  context,
                  ScheduleAnimations.standard,
                ),
              );
            },
            icon: const Icon(Icons.chevron_right),
            tooltip: l10n.nextWeek,
          ),
        ],
      ),
    );
  }

  /// Show week picker to jump to specific week
  /// Uses a custom dialog that highlights entire weeks (Monday-Sunday)
  /// When user selects any date, it snaps to the Monday of that week
  Future<void> _showDatePicker(BuildContext context) async {
    // ✨ SIMPLE: Use the currently displayed week, not widget.week
    // This ensures we always show the correct week in the picker
    final currentWeekMonday = parseMondayFromISOWeek(_currentDisplayedWeek);
    if (currentWeekMonday == null) {
      debugPrint(
        'ERROR: Failed to parse displayed week: $_currentDisplayedWeek',
      );
      return;
    }

    // Use the Monday of the currently displayed week as the initial date
    final currentDate = currentWeekMonday;
    final l10n = AppLocalizations.of(context);

    // ⚠️ DYNAMIC DATE RANGE: Calculate firstDate and lastDate based on current week
    // This prevents "initialDate must be on or before lastDate" errors when navigating to future weeks
    // Allow selection ±2 years from current week
    final firstDate = DateTime(currentDate.year - 2);
    final lastDate = DateTime(currentDate.year + 2, 12, 31);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: l10n.selectWeekHelpText,
      selectableDayPredicate: (date) {
        // Allow all dates, but we'll snap to Monday later
        return true;
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // Customize the date picker appearance
            datePickerTheme: const DatePickerThemeData(
              headerHelpStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add helper text above the picker
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        l10n.weekPickerHelperText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(child: child!),
            ],
          ),
        );
      },
    );

    if (selectedDate != null) {
      // Snap to Monday of the selected week (ISO 8601 week starts on Monday)
      final selectedMonday = _getMondayOfWeek(selectedDate);
      final selectedWeekString = getISOWeekString(selectedMonday);

      // 🔍 DEBUG LOGS
      debugPrint('📅 DatePicker Selection:');
      debugPrint('  Selected date: $selectedDate');
      debugPrint('  Calculated Monday: $selectedMonday');
      debugPrint('  Week string: $selectedWeekString');
      debugPrint('  Current displayed week: $_currentDisplayedWeek');
      debugPrint('  Initial week (widget.week): ${widget.week}');

      // ✨ DEAD SIMPLE calculation:
      // Calculate how many weeks from the INITIAL week (widget.week) to the selected week
      // Then jump to page 1000 + that offset
      final targetPageOffset = weeksBetween(widget.week, selectedWeekString);

      debugPrint('  Weeks between initial and selected: $targetPageOffset');
      debugPrint('  Target page: ${1000 + targetPageOffset}');
      debugPrint('  Current page: ${_weekPageController.page}');

      // Jump to the target page
      _weekPageController.jumpToPage(1000 + targetPageOffset);

      // Haptic feedback
      await HapticFeedback.lightImpact();
    }
  }

  /// Get the Monday of the week containing the given date
  /// ISO 8601 week starts on Monday (weekday = 1)
  DateTime _getMondayOfWeek(DateTime date) {
    final weekday = date.weekday; // 1 = Monday, 7 = Sunday
    final daysFromMonday = weekday - 1;
    return date.subtract(Duration(days: daysFromMonday));
  }

  /// Get the date range (Monday to Sunday) for a given ISO week string
  /// Returns null if calculation fails
  ({DateTime monday, DateTime sunday})? _getWeekDateRange(String weekString) {
    try {
      // Parse the week string (format: "2025-W41")
      final monday = parseMondayFromISOWeek(weekString);
      if (monday == null) return null;

      // Sunday is 6 days after Monday
      final sunday = monday.add(const Duration(days: 6));

      return (monday: monday, sunday: sunday);
    } catch (e) {
      debugPrint('ERROR: _getWeekDateRange failed for week $weekString: $e');
      return null;
    }
  }

  /// Format week date range for display with responsive formatting
  ///
  /// Examples:
  /// - Normal (>= 360px): "6 - 12 janv. 2025" or "30 déc. 2024 - 5 janv. 2025"
  /// - Compact (< 360px): "6-12 jan" or "30 déc-5 jan"
  String _formatWeekDateRange(
    ({DateTime monday, DateTime sunday}) weekDates,
    bool compactMode,
  ) {
    final monday = weekDates.monday;
    final sunday = weekDates.sunday;

    // Format month names (localized)
    final mondayMonth = _getMonthAbbreviation(monday.month, compactMode);
    final sundayMonth = _getMonthAbbreviation(sunday.month, compactMode);

    if (compactMode) {
      // Very compact format for small screens (< 360px)
      // Same month: "6-12 jan"
      // Different months, same year: "30 déc-5 jan"
      // Different years: "30 déc 24-5 jan 25"
      if (monday.month == sunday.month && monday.year == sunday.year) {
        return '${monday.day}-${sunday.day} $mondayMonth';
      } else if (monday.year == sunday.year) {
        return '${monday.day} $mondayMonth-${sunday.day} $sundayMonth';
      } else {
        final mondayYear = (monday.year % 100).toString().padLeft(2, '0');
        final sundayYear = (sunday.year % 100).toString().padLeft(2, '0');
        return '${monday.day} $mondayMonth $mondayYear-${sunday.day} $sundayMonth $sundayYear';
      }
    } else {
      // Normal format for regular screens (>= 360px)
      // Same month: "6 - 12 janv. 2025"
      // Different months, same year: "30 déc. - 5 janv. 2025"
      // Different years: "30 déc. 2024 - 5 janv. 2025"
      if (monday.month == sunday.month && monday.year == sunday.year) {
        return '${monday.day} - ${sunday.day} $mondayMonth ${monday.year}';
      } else if (monday.year == sunday.year) {
        return '${monday.day} $mondayMonth - ${sunday.day} $sundayMonth ${monday.year}';
      } else {
        return '${monday.day} $mondayMonth ${monday.year} - ${sunday.day} $sundayMonth ${sunday.year}';
      }
    }
  }

  /// Get localized month abbreviation using Intl
  /// Returns 3-letter abbreviation (e.g., "jan", "fév", "mars")
  ///
  /// Uses device locale for proper localization (French, English, etc.)
  String _getMonthAbbreviation(int month, bool ultraCompact) {
    // Create a date with the target month (day doesn't matter)
    final date = DateTime(2025, month);

    // Get locale from context (e.g., "fr", "en")
    final locale = Localizations.localeOf(context).toString();

    if (ultraCompact) {
      // Ultra compact: 3 letters (jan, fév, mar)
      final formatter = DateFormat('MMM', locale);
      final abbreviated = formatter.format(date);

      // Remove trailing dots if present (some locales add them)
      final cleaned = abbreviated.replaceAll('.', '');

      // Ensure max 3 characters
      return cleaned.length > 3
          ? cleaned.substring(0, 3).toLowerCase()
          : cleaned.toLowerCase();
    } else {
      // Normal mode: slightly longer abbreviation (janv., févr., etc.)
      // For French: MMM gives "janv.", "févr.", etc.
      // For English: MMM gives "Jan", "Feb", etc.
      final formatter = DateFormat('MMM', locale);
      return formatter.format(date).toLowerCase();
    }
  }

  Widget _buildWeekView(int weekOffset) {
    // Week data is now loaded dynamically via onWeekChanged callback
    // Parent component (schedule_page.dart) handles data fetching based on weekOffset
    // The grid always displays widget.scheduleData which is refreshed by the parent
    return _buildMobileScheduleGrid(context);
  }

  Widget _buildMobileScheduleGrid(BuildContext context) {
    // 🔍 DEBUG: Log all slots from API to identify orphaned slots
    debugPrint(
      '📊 _buildMobileScheduleGrid: Analyzing ${widget.scheduleData.length} API slots',
    );
    if (widget.scheduleConfig != null) {
      debugPrint(
        '   ScheduleConfig hours: ${widget.scheduleConfig!.scheduleHours}',
      );

      // Identify orphaned slots (slots with times not in scheduleConfig)
      final orphanedSlots = <ScheduleSlot>[];
      for (final slot in widget.scheduleData) {
        final dayKey = slot.dayOfWeek.fullName.toUpperCase();
        final timeStr = slot.timeOfDay.toApiFormat();
        final configuredTimes =
            widget.scheduleConfig!.scheduleHours[dayKey] ?? [];

        if (!configuredTimes.contains(timeStr)) {
          orphanedSlots.add(slot);
          debugPrint(
            '   ⚠️ ORPHANED SLOT: ${slot.dayOfWeek.fullName} @ $timeStr (not in scheduleConfig)',
          );
        }
      }

      if (orphanedSlots.isNotEmpty) {
        debugPrint(
          '   ⚠️ Found ${orphanedSlots.length} orphaned slots that will be HIDDEN',
        );
      } else {
        debugPrint('   ✅ All API slots match scheduleConfig');
      }
    } else {
      debugPrint(
        '   ⚠️ No scheduleConfig provided - showing all API slots (fallback mode)',
      );
    }

    // Responsive mobile layout with proper constraints
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;

    // Use Title Case day names to match DayOfWeek.fullName property
    // These match the domain entity format and will be mapped to localized names in _buildDayCard
    final allDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    // Filter days based on schedule configuration
    // Only show days that have at least one configured time slot
    // This saves screen space on mobile devices by hiding unused days
    // NOTE: scheduleConfig uses UPPERCASE keys (backend format), so we need to convert for lookup
    final days = widget.scheduleConfig != null
        ? allDays.where((day) {
            // Convert Title Case to UPPERCASE for scheduleConfig lookup
            final dayKey = day.toUpperCase();
            final daySlots = widget.scheduleConfig!.scheduleHours[dayKey] ?? [];
            return daySlots.isNotEmpty;
          }).toList()
        : allDays; // Fallback to all days if no config (graceful degradation)

    // ✨ GROUPED BY PERIOD: Group time slots for Level 1 compact view
    // Example: ["08:00", "09:00", "16:00"] → [{"label": "Matin", "times": ["08:00", "09:00"]}, {"label": "Après-midi", "times": ["16:00"]}]
    final l10n = AppLocalizations.of(context);
    final groupedSlots = TimeSlotMapper.getGroupedSlotsByPeriod(
      l10n,
      widget.scheduleConfig,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
          child: Column(
            children: [
              // Time slots header - Show period labels (Matin, Après-midi)
              _buildTimeHeader(
                groupedSlots.map((g) => g.label).toList(),
                isTablet,
              ),
              const SizedBox(height: 16),

              // Days with time slots - Use Flexible instead of Expanded to prevent overflow
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight:
                        constraints.maxHeight *
                        0.9, // Responsive height constraint
                  ),
                  child: ListView.builder(
                    itemCount: days.length,
                    itemBuilder: (context, dayIndex) {
                      final day = days[dayIndex];
                      // Day card now gets its own day-specific slots internally
                      return _buildDayCard(context, day, isTablet);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Get grouped slots for a SPECIFIC day only
  /// Returns empty list if day has no schedule configuration
  ///
  /// This prevents showing slots from other days on days without configuration.
  /// Example: If Monday has no config but Tuesday has ["08:00", "16:00"],
  /// this ensures Monday shows empty list instead of Tuesday's slots.
  ///
  /// @param dayKey - Title Case day name like 'Monday', 'Tuesday' (matches DayOfWeek.fullName)
  List<PeriodSlotGroup> _getGroupedSlotsForDay(String dayKey) {
    if (widget.scheduleConfig == null) {
      debugPrint(
        'DEBUG: _getGroupedSlotsForDay($dayKey) - scheduleConfig is null',
      );
      return [];
    }

    // Convert Title Case to UPPERCASE for scheduleConfig lookup (backend format)
    final dayKeyUppercase = dayKey.toUpperCase();

    // DEBUG: Show ALL keys in scheduleConfig to identify mismatch
    debugPrint('DEBUG: _getGroupedSlotsForDay($dayKey)');
    debugPrint('  Day key (Title Case): $dayKey');
    debugPrint('  Day key (UPPERCASE for config): $dayKeyUppercase');
    debugPrint(
      '  Available keys in scheduleConfig: ${widget.scheduleConfig!.scheduleHours.keys.toList()}',
    );

    // Get time slots for this specific day using UPPERCASE key
    final dayTimeSlots =
        widget.scheduleConfig!.scheduleHours[dayKeyUppercase] ?? [];

    debugPrint('  Time slots found: ${dayTimeSlots.length} - $dayTimeSlots');

    if (dayTimeSlots.isEmpty) {
      debugPrint(
        'WARNING: No slots configured for day: $dayKey (looked up as $dayKeyUppercase)',
      );
      return []; // Day has no schedule configuration
    }

    // Create temporary config with only this day's slots
    // Reuse parent config's metadata to avoid needing to pass extra parameters
    final dayOnlyConfig = widget.scheduleConfig!.copyWith(
      scheduleHours: {dayKeyUppercase: dayTimeSlots},
    );

    // Get grouped slots for this specific day
    final l10n = AppLocalizations.of(context);
    return TimeSlotMapper.getGroupedSlotsByPeriod(l10n, dayOnlyConfig);
  }

  Widget _buildTimeHeader(List<String> timeSlots, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 16 : 12,
        horizontal: isTablet ? 20 : 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Day label space - responsive width
          SizedBox(width: isTablet ? 100 : 80),
          // Time slots
          ...timeSlots.map(
            (time) => Expanded(
              child: Text(
                time,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? 18 : 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(
    BuildContext context,
    String dayKey, // Now receives Title Case key like 'Monday', 'Tuesday'
    bool isTablet,
  ) {
    final l10n = AppLocalizations.of(context);

    // Get localized day name for display
    final dayDisplayName = getLocalizedDayName(dayKey, l10n);

    // Get slots for THIS SPECIFIC day only
    final daySlotsGrouped = _getGroupedSlotsForDay(dayKey);

    return Card(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header with colorblind-friendly icon shapes
            Row(
              children: [
                Icon(
                  AppColors.getDayIcon(dayDisplayName),
                  color: AppColors.getDayColor(dayDisplayName),
                  size: isTablet ? 24 : ScheduleDimensions.iconSizeSmall,
                ),
                const SizedBox(width: ScheduleDimensions.spacingSm),
                Text(
                  dayDisplayName, // Display localized name
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.getDayColor(dayDisplayName),
                    fontSize: isTablet ? 18 : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 16 : 12),

            // Show slots ONLY if day has configuration
            if (daySlotsGrouped.isEmpty)
              _buildNoScheduleMessage(context)
            else
              _buildTimeSlotsRow(
                context,
                dayKey, // Pass constant key
                daySlotsGrouped, // Use day-specific slots
                isTablet,
              ),
          ],
        ),
      ),
    );
  }

  /// Build responsive time slots row with horizontal scroll if needed
  /// Now renders ONE slot per PERIOD (Matin, Après-midi) for Level 1 compact view
  Widget _buildTimeSlotsRow(
    BuildContext context,
    String day,
    List<PeriodSlotGroup> groupedSlots,
    bool isTablet,
  ) {
    // ✨ RESPONSIVE: Si >3 périodes sur petit écran, enable horizontal scroll
    final shouldScroll = !isTablet && groupedSlots.length > 3;

    if (shouldScroll) {
      // Scroll horizontal pour >3 périodes sur mobile
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: groupedSlots.map((periodSlot) {
            final label = periodSlot.label;
            final times = periodSlot.times;

            return Container(
              width: 140, // Fixed width pour scroll horizontal
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildPeriodSlot(context, day, label, times),
            );
          }).toList(),
        ),
      );
    } else {
      // Layout normal avec Expanded
      return Row(
        children: groupedSlots.map((periodSlot) {
          final label = periodSlot.label;
          final times = periodSlot.times;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildPeriodSlot(context, day, label, times),
            ),
          );
        }).toList(),
      );
    }
  }

  /// Build a period slot (Level 1 compact view)
  /// Displays ONE slot per PERIOD (Matin, Après-midi) with aggregated data
  ///
  /// Example: periodLabel="Matin", times=["08:00", "09:00"]
  /// → Shows single slot with badge showing total vehicles across both times
  Widget _buildPeriodSlot(
    BuildContext context,
    String day,
    String periodLabel, // "Matin", "Après-midi"
    List<String> times, // ["08:00", "09:00"] for Matin
  ) {
    // Get AGGREGATED schedule data for all times in this period
    final periodSlots = times
        .map((time) => _getScheduleSlotData(day, time))
        .whereType<ScheduleSlot>()
        .toList();

    // Calculate aggregated vehicle count across all times in period
    var totalVehicleCount = 0;
    for (final slot in periodSlots) {
      totalVehicleCount += slot.vehicleAssignments.length;
    }

    // Create aggregated slot data to pass to widget (using typed constructor)
    final aggregatedSlot = totalVehicleCount > 0
        ? PeriodSlotData(
            dayOfWeek: DayOfWeek.fromString(day),
            period: _parsePeriodFromLabel(periodLabel, times),
            times: times.map((t) => TimeOfDayValue.parse(t)).toList(),
            slots: periodSlots,
            week: widget.week,
          )
        : null;

    // ✨ NEW: Check if this period slot is in the past
    final isPast = _isPeriodSlotInPast(day, times);

    return Opacity(
      opacity: isPast ? 0.5 : 1.0, // Gray out past slots
      child: Stack(
        fit: StackFit.passthrough, // Let Stack size match its child
        children: [
          ScheduleSlotWidget(
            groupId: widget.groupId,
            day: day,
            time: periodLabel, // Display period label, not time
            week: widget.week,
            scheduleSlot: aggregatedSlot,
            onTap: isPast
                ? () => _showPastSlotWarning(context)
                : () => _handlePeriodSlotTap(
                    context,
                    day,
                    periodLabel,
                    times,
                    periodSlots,
                  ),
            onVehicleDrop: isPast
                ? (_) =>
                      _showPastSlotWarning(
                        context,
                      ) // Show warning on drop attempts
                : (vehicleId) =>
                      _handlePeriodVehicleDrop(day, times, vehicleId),
          ),
          if (isPast)
            Positioned(
              top: 4,
              right: 4,
              child: Icon(Icons.lock_clock, size: 16, color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }

  /// Handle tap on period slot (Level 1 → Level 2 transition)
  /// Opens VehicleSelectionModal with period data structure
  /// This enables Level 2 to show breakdown for all times in period
  ///
  /// Example: Tapping "Matin" → Modal shows sections for 08:00, 09:00
  void _handlePeriodSlotTap(
    BuildContext context,
    String day,
    String periodLabel,
    List<String> times,
    List<ScheduleSlot?> periodSlots,
  ) {
    // Pass period data structure to VehicleSelectionModal
    // This enables Level 2 to show breakdown for all times in period
    final typedPeriodSlots = periodSlots.whereType<ScheduleSlot>().toList();

    widget.onManageVehicles(
      PeriodSlotData(
        dayOfWeek: DayOfWeek.fromString(day),
        period: _parsePeriodFromLabel(periodLabel, times),
        times: times.map((t) => TimeOfDayValue.parse(t)).toList(),
        slots: typedPeriodSlots,
        week: widget.week,
      ),
    );
  }

  /// Handle vehicle drop on period slot
  /// When dropping vehicle on period slot, assign to FIRST time in period
  /// User can then reassign to specific times in Level 2 modal
  void _handlePeriodVehicleDrop(
    String day,
    List<String> times,
    String vehicleId,
  ) {
    if (times.isEmpty) {
      debugPrint(
        'ERROR: _handlePeriodVehicleDrop called with empty times list',
      );
      return;
    }

    // Assign to FIRST time in period by default
    // User can reassign to specific times in VehicleSelectionModal (Level 2)
    final firstTime = times.first;
    widget.onVehicleDrop(day, firstTime, vehicleId);
  }

  // REMOVED: _buildSlotOptionsSheet and _buildOptionButton
  // These methods implemented the parasitic "Options" modal that disrupted UX flow
  // Now using direct navigation: Week → Vehicle → Child (3 levels instead of 4)

  /// Build message for days without schedule configuration
  /// Displays user-friendly message when a day has no configured time slots
  Widget _buildNoScheduleMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariantThemed(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderThemed(context)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event_busy,
            color: AppColors.textSecondaryThemed(context),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.noScheduleConfigured,
              style: TextStyle(
                color: AppColors.textSecondaryThemed(context),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods

  /// Get schedule slot data for a specific day and time
  /// ✨ CRITICAL: Only returns slots whose time is configured in scheduleConfig
  /// This ensures orphaned slots (times not in config) are never displayed
  ScheduleSlot? _getScheduleSlotData(String day, String time) {
    // 🛡️ VALIDATION: Check if this time is actually configured for this day
    if (widget.scheduleConfig != null) {
      final dayKey = day.toUpperCase();
      final configuredTimes =
          widget.scheduleConfig!.scheduleHours[dayKey] ?? [];

      if (!configuredTimes.contains(time)) {
        debugPrint(
          '   🚫 _getScheduleSlotData: Rejecting slot $day @ $time (not in scheduleConfig)',
        );
        return null; // Time not configured - don't display this slot
      }
    }

    // Find the slot in API data
    try {
      final slot = widget.scheduleData.firstWhere(
        (slot) =>
            slot.dayOfWeek.fullName == day &&
            slot.timeOfDay.toApiFormat() == time,
      );

      debugPrint(
        '   ✅ _getScheduleSlotData: Found slot $day @ $time with ${slot.vehicleAssignments.length} vehicles',
      );
      return slot;
    } catch (e) {
      // No slot found in API data for this configured time - this is normal (empty slot)
      return null;
    }
  }

  /// Check if a period slot is in the past
  /// A period is considered in the past if ALL its time slots are in the past
  bool _isPeriodSlotInPast(String day, List<String> times) {
    if (times.isEmpty) return false;

    // Check if ALL times in the period are in the past
    // If even one time is in the future, the period is still accessible
    return times.every((time) => _isTimeSlotInPast(day, time));
  }

  /// Check if a specific time slot is in the past
  /// Calculates the full datetime from week, day, and time, then compares with now
  bool _isTimeSlotInPast(String day, String timeSlot) {
    try {
      // Get Monday of the currently displayed week
      final weekStart = parseMondayFromISOWeek(_currentDisplayedWeek);
      if (weekStart == null) return false;

      // Calculate day offset (MONDAY=0, TUESDAY=1, etc.)
      final dayOffset = _getDayOffset(day);

      // Parse time (HH:mm)
      final timeParts = timeSlot.split(':');
      if (timeParts.length != 2) return false;
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Build full datetime
      final slotDate = weekStart.add(Duration(days: dayOffset));
      final slotDateTime = DateTime(
        slotDate.year,
        slotDate.month,
        slotDate.day,
        hour,
        minute,
      );

      // Compare with now
      return slotDateTime.isBefore(DateTime.now());
    } catch (e) {
      debugPrint('ERROR: _isTimeSlotInPast failed: $e');
      return false; // If parsing fails, assume not in past (fail-safe)
    }
  }

  /// Get day offset for date calculation
  /// Maps day string to numeric offset from Monday (0-6)
  int _getDayOffset(String day) {
    // day is in Title Case format (e.g., "Monday", "Tuesday") to match DayOfWeek.fullName
    switch (day) {
      case 'Monday':
        return 0;
      case 'Tuesday':
        return 1;
      case 'Wednesday':
        return 2;
      case 'Thursday':
        return 3;
      case 'Friday':
        return 4;
      case 'Saturday':
        return 5;
      case 'Sunday':
        return 6;
      default:
        return 0; // Default to Monday if unknown
    }
  }

  /// Show warning when user tries to interact with a past slot
  void _showPastSlotWarning(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.cannotAddVehiclesToPastSlots),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Parse period label to SchedulePeriod for typed constructor
  /// Handles localized labels (Morning, Afternoon, etc.) and specific times
  SchedulePeriod _parsePeriodFromLabel(String periodLabel, List<String> times) {
    // Try to parse as specific time first (format: HH:mm)
    if (RegExp(r'^\d{1,2}:\d{2}$').hasMatch(periodLabel)) {
      return SpecificTimeSlot.parse(periodLabel);
    }

    // Otherwise, treat as aggregate period
    try {
      final periodType = PeriodType.fromLabel(periodLabel);
      return AggregatePeriod.fromTimeStrings(
        type: periodType,
        timeStrings: times,
      );
    } catch (e) {
      // Fallback: if period label doesn't match known types, create specific time slot
      if (times.isNotEmpty) {
        return SpecificTimeSlot.parse(times.first);
      }
      // Last resort: create morning aggregate
      return AggregatePeriod.fromTimeStrings(
        type: PeriodType.morning,
        timeStrings: times,
      );
    }
  }

  // Note: _getDayIcon and _getDayColor removed - using AppColors.getDayIcon/getDayColor
  // for centralized colorblind-friendly pattern management
}
