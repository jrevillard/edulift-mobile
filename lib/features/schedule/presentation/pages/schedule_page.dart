import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../../../core/navigation/navigation_state.dart';
import '../providers/schedule_providers.dart';
import '../providers/displayable_slots_provider.dart';
import '../../providers.dart';
import '../../domain/usecases/remove_vehicle_from_slot.dart';
import '../models/displayable_time_slot.dart';
import '../widgets/mobile/schedule_week_cards.dart';
import '../widgets/vehicle_selection_sheet.dart';
import '../widgets/child_assignment_sheet.dart';
import '../../../groups/providers.dart';
import '../../../groups/presentation/providers/group_schedule_config_provider.dart';
import '../../../../core/domain/entities/groups/group.dart';
import 'package:edulift/core/domain/entities/family.dart';
import 'package:edulift/core/domain/entities/family/vehicle.dart';
import '../../../family/presentation/providers/family_provider.dart';
import '../../domain/services/schedule_datetime_service.dart';
// REMOVED: realtime_schedule_indicators.dart - feature simplified (no invitation lists)
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/presentation/mixins/navigation_cleanup_mixin.dart';
import '../../../groups/presentation/widgets/unified_group_card.dart';
import '../../../../core/presentation/themes/app_colors.dart';
import 'package:edulift/core/domain/entities/schedule.dart';
import 'package:edulift/core/utils/date/iso_week_utils.dart';
import 'package:edulift/core/utils/date/date_utils.dart' as app_date_utils;
import '../../../../core/utils/app_logger.dart';
import '../../../../core/services/providers/auth_provider.dart';
import '../../../../core/presentation/utils/responsive_breakpoints.dart';

class SchedulePage extends ConsumerStatefulWidget {
  final String? groupId;

  const SchedulePage({super.key, this.groupId});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage>
    with NavigationCleanupMixin, WidgetsBindingObserver {
  String? _selectedGroupId;
  late String _currentWeek;
  late String _currentDisplayedWeek;
  final ScheduleDateTimeService _dateTimeService =
      const ScheduleDateTimeService();
  Timer? _pastSlotRefreshTimer;
  DateTime _currentTime =
      DateTime.now(); // Track current time for past slot detection

  @override
  void initState() {
    super.initState();
    // NavigationCleanupMixin automatically clears navigation state
    _selectedGroupId = widget.groupId;
    _initializeCurrentWeek();
    // Start with the current week
    _currentDisplayedWeek = _currentWeek;

    // Load data when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(groupsComposedProvider.notifier).loadUserGroups();
      if (_selectedGroupId != null) {
        _loadScheduleData();
      }

      // Start timer to refresh past slot status every minute
      _startPastSlotRefreshTimer();
    });

    // Listen for app lifecycle changes to restart timer when app becomes active
    WidgetsBinding.instance.addObserver(this);
  }

  void _initializeCurrentWeek() {
    final now = DateTime.now();
    _currentWeek = getISOWeekString(now);
  }

  void _loadScheduleData() {
    // ✅ FIX: Invalidate the auto-dispose providers to trigger reload
    // This ensures the UI fetches fresh data using the modern provider system
    if (_selectedGroupId != null) {
      ref.invalidate(
        weeklyScheduleProvider(_selectedGroupId!, _currentDisplayedWeek),
      );
      ref.invalidate(
        displayableSlotsProvider(_selectedGroupId!, _currentDisplayedWeek),
      );
      // Note: Schedule config is now handled by dedicated schedule config provider
      // and loaded when needed by specific config widgets
    }
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
    final groupsState = ref.watch(groupsComposedProvider);

    // ✅ FIX: Watch the auto-dispose provider instead of legacy StateNotifier
    // This ensures UI updates when weeklyScheduleProvider is invalidated
    final scheduleAsync = _selectedGroupId != null
        ? ref.watch(weeklyScheduleProvider(_selectedGroupId!, _currentWeek))
        : const AsyncValue<List<ScheduleSlot>>.data([]);

    final vehiclesState = ref.watch(
      familyVehiclesProvider.select((vehicles) => AsyncValue.data(vehicles)),
    );

    // ✨ NOUVEAU: Watch schedule config pour les créneaux dynamiques
    final scheduleConfigState = _selectedGroupId != null
        ? ref.watch(groupScheduleConfigProvider(_selectedGroupId!))
        : const AsyncValue<ScheduleConfig?>.data(null);

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        // Only show back button when a group is selected
        leading: _selectedGroupId != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedGroupId = null;
                  });
                },
              )
            : null,
        title: Text(AppLocalizations.of(context).weeklySchedule),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Real-time schedule conflict alert
          // REMOVED: ScheduleConflictAlert - feature simplified (no invitation lists)
          const SizedBox.shrink(),

          Expanded(
            child: groupsState.isLoading && groupsState.groups.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : groupsState.error != null && groupsState.groups.isEmpty
                ? _buildErrorState(groupsState.error!)
                : _buildMainContent(
                    groupsState.groups,
                    scheduleAsync,
                    vehiclesState,
                    scheduleConfigState,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
    List<Group> groups,
    AsyncValue<List<ScheduleSlot>> scheduleAsync,
    AsyncValue<List<Vehicle>> vehiclesState,
    AsyncValue<ScheduleConfig?> scheduleConfigState,
  ) {
    if (groups.isEmpty) {
      return _buildNoGroupsState();
    }
    if (_selectedGroupId == null) {
      return _buildGroupSelectionState(groups);
    }

    Group? selectedGroup;
    try {
      selectedGroup = groups.firstWhere(
        (group) => group.id == _selectedGroupId,
      );
    } catch (e) {
      selectedGroup = null;
    }

    if (selectedGroup == null) {
      return _buildGroupNotFoundState();
    }

    // Mobile-first layout - full width (sidebar removed per Phase 3 plan)
    return _buildMobileScheduleView(selectedGroup, scheduleConfigState);
  }

  /// NEW: Build schedule view using mobile-optimized widgets with DisplayableTimeSlot
  Widget _buildMobileScheduleView(
    Group selectedGroup,
    AsyncValue<ScheduleConfig?> scheduleConfigState,
  ) {
    // Check if config is null or error (matching web behavior)
    final hasConfigError =
        scheduleConfigState.hasError || scheduleConfigState.value == null;

    if (hasConfigError) {
      return _buildConfigRequiredState(selectedGroup);
    }

    // ✅ NEW: Use displayableSlotsProvider to get ALL configured slots
    final displayableSlotsAsync = ref.watch(
      displayableSlotsProvider(_selectedGroupId!, _currentDisplayedWeek),
    );

    return displayableSlotsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildScheduleErrorState(error.toString()),
      data: (displayableSlots) => Column(
        children: [
          _buildWeekIndicator(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // Reload current week data
                _loadScheduleData();

                // Haptic feedback
                await HapticFeedback.mediumImpact();
              },
              child: SingleChildScrollView(
                child: _buildScheduleWeekCards(displayableSlots),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build ScheduleWeekCards with DisplayableTimeSlot data
  Widget _buildScheduleWeekCards(List<DisplayableTimeSlot> displayableSlots) {
    // Get family vehicles for display
    final family = ref.read(familyProvider);
    final vehiclesMap = {
      for (final vehicle in family.vehicles) vehicle.id: vehicle,
    };

    // Get children for display
    final childrenMap = {for (final child in family.children) child.id: child};

    // Extract configured days from displayable slots
    final configuredDays = displayableSlots
        .map((slot) => slot.dayOfWeek)
        .toSet()
        .toList();

    return ScheduleWeekCards(
      displayableSlots: displayableSlots,
      configuredDays: configuredDays,
      vehicles: vehiclesMap,
      childrenMap: childrenMap,
      onSlotTap: _handleDisplayableSlotTap,
      onAddVehicle: _handleAddVehicleToDisplayableSlot,
      onVehicleAction: _handleVehicleAction,
      onVehicleTap: _handleVehicleTap,
      isSlotInPast: _isSlotInPast,
    );
  }

  Widget _buildNoGroupsState() {
    return Center(
      child: SingleChildScrollView(
        padding: context.getAdaptivePadding(
          mobileAll: 24,
          tabletAll: 32,
          desktopAll: 40,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups_outlined,
              size: context.getAdaptiveIconSize(
                mobile: 80,
                tablet: 120,
                desktop: 160,
              ),
              color: Colors.grey[400],
            ),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
            Text(
              AppLocalizations.of(context).noTransportGroups,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 8,
                tablet: 12,
                desktop: 16,
              ),
            ),
            Text(
              AppLocalizations.of(context).needGroupForSchedules,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            ),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 24,
                tablet: 32,
                desktop: 40,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => ref
                  .read(navigationStateProvider.notifier)
                  .navigateTo(
                    route: '/groups',
                    trigger: NavigationTrigger.userNavigation,
                    context: {'action': 'select_group_for_schedule'},
                  ),
              icon: const Icon(Icons.groups),
              label: Text(AppLocalizations.of(context).goToGroups),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupSelectionState(List<Group> groups) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid using max cross axis extent for better adaptation

        return Padding(
          padding: context.getAdaptivePadding(
            mobileAll: 12,
            tabletAll: 16,
            desktopAll: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLocalizations.of(context).selectGroup,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: context.getAdaptiveSpacing(mobile: 6, tablet: 8),
              ),
              Text(
                AppLocalizations.of(context).chooseGroupForSchedule,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              SizedBox(
                height: context.getAdaptiveSpacing(
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  key: const Key('schedule_groups_refreshIndicator'),
                  onRefresh: () async {
                    await ref
                        .read(groupsComposedProvider.notifier)
                        .loadUserGroups();
                    // Haptic feedback
                    await HapticFeedback.mediumImpact();
                  },
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: context.getGridColumns(
                        mobile: 2,
                        tablet: 3,
                        desktop: 4,
                      ),
                      childAspectRatio: 1.2, // More reasonable ratio for cards
                      crossAxisSpacing: context.getAdaptiveSpacing(
                        mobile: 12,
                        tablet: 16,
                        desktop: 20,
                      ),
                      mainAxisSpacing: context.getAdaptiveSpacing(
                        mobile: 12,
                        tablet: 16,
                        desktop: 20,
                      ),
                    ),
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return UnifiedGroupCard(
                        key: Key('unifiedGroupCard_${group.id}'),
                        group: group,
                        onTap: () {
                          setState(() {
                            _selectedGroupId = group.id;
                          });
                          _loadScheduleData();
                        },
                      );
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

  Widget _buildGroupNotFoundState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.orange[400]),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).groupNotFound,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.orange[600]),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).groupNotFoundMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedGroupId = null;
                });
              },
              icon: const Icon(Icons.arrow_back),
              label: Text(AppLocalizations.of(context).selectAnotherGroup),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).failedToLoadSchedule,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.red[600]),
            ),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadScheduleData,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context).tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).errorLoadingData,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.red[600]),
            ),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(groupsComposedProvider.notifier).loadUserGroups();
              },
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context).tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  /// Convert GroupMemberRole enum to API string format
  String? _roleToString(GroupMemberRole? role) {
    if (role == null) return null;
    switch (role) {
      case GroupMemberRole.owner:
        return 'OWNER';
      case GroupMemberRole.admin:
        return 'ADMIN';
      case GroupMemberRole.member:
        return 'MEMBER';
    }
  }

  Widget _buildConfigRequiredState(Group selectedGroup) {
    final l10n = AppLocalizations.of(context);
    final isAdmin = _isUserAdmin(selectedGroup);

    return Center(
      child: SingleChildScrollView(
        padding: context.getAdaptivePadding(
          mobileAll: 16,
          tabletAll: 20,
          desktopAll: 24,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon - Responsive size for all screens
            Container(
              width: context.getAdaptiveIconSize(
                mobile: 80,
                tablet: 100,
                desktop: 120,
              ),
              height: context.getAdaptiveIconSize(
                mobile: 80,
                tablet: 100,
                desktop: 120,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.settings,
                size: context.getAdaptiveIconSize(
                  mobile: 36,
                  tablet: 50,
                  desktop: 64,
                ),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),

            // Title
            Text(
              l10n.scheduleConfigurationRequired,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 8,
                tablet: 10,
                desktop: 12,
              ),
            ),

            // Description
            Text(
              l10n.setupTimeSlotsToEnableScheduling,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 20,
                tablet: 24,
                desktop: 28,
              ),
            ),

            // Actions
            if (isAdmin)
              ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(navigationStateProvider.notifier)
                      .navigateTo(
                        route: '/groups/$_selectedGroupId/manage',
                        trigger: NavigationTrigger.userNavigation,
                      );
                },
                icon: const Icon(Icons.settings),
                label: Text(l10n.configureSchedule),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(180, 48),
                ),
              )
            else
              Container(
                padding: context.getAdaptivePadding(
                  mobileAll: 10,
                  tabletAll: 14,
                  desktopAll: 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: context.getAdaptiveIconSize(
                        mobile: 16,
                        tablet: 18,
                        desktop: 20,
                      ),
                    ),
                    SizedBox(
                      width: context.getAdaptiveSpacing(mobile: 6, tablet: 8),
                    ),
                    Flexible(
                      child: Text(
                        l10n.contactAdministratorToSetupTimeSlots,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 12,
                tablet: 14,
                desktop: 16,
              ),
            ),

            // Retry button
            OutlinedButton(
              onPressed: () {
                if (_selectedGroupId != null) {
                  ref.invalidate(
                    groupScheduleConfigProvider(_selectedGroupId!),
                  );
                }
              },
              child: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  bool _isUserAdmin(Group selectedGroup) {
    final userRole = _roleToString(selectedGroup.userRole);
    return userRole == 'OWNER' || userRole == 'ADMIN';
  }

  /// Build week indicator with navigation controls
  /// Copied from schedule_grid.dart and adapted for _currentDisplayedWeek
  Widget _buildWeekIndicator() {
    final l10n = AppLocalizations.of(context);
    // Responsive: très petits écrans utilisent le breakpoint mobile
    final isVerySmallScreen = context.isMobile;

    // Calculate week dates for display using the current displayed week
    final weekDates = _getWeekDateRange(_currentDisplayedWeek);

    return Container(
      padding: context.getAdaptivePadding(
        mobileHorizontal: 12,
        mobileVertical: 10,
        tabletHorizontal: 16,
        tabletVertical: 12,
        desktopHorizontal: 20,
        desktopVertical: 14,
      ),
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
              AppLogger.debug(
                'Previous week button clicked - current week: $_currentDisplayedWeek',
              );

              // Calculate previous week directly
              final previousWeek = addWeeksToISOWeek(_currentDisplayedWeek, -1);

              AppLogger.debug(
                'Updating from $_currentDisplayedWeek to $previousWeek',
              );

              setState(() {
                _currentDisplayedWeek = previousWeek;
              });

              // Reload data for the new week
              _loadScheduleData();
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
                      size: context.getAdaptiveIconSize(
                        mobile: 14,
                        tablet: 16,
                        desktop: 18,
                      ),
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(
                      width: context.getAdaptiveSpacing(mobile: 6, tablet: 8),
                    ),
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
              AppLogger.debug(
                'Next week button clicked - current week: $_currentDisplayedWeek',
              );

              // Calculate next week directly
              final nextWeek = addWeeksToISOWeek(_currentDisplayedWeek, 1);

              AppLogger.debug(
                'Updating from $_currentDisplayedWeek to $nextWeek',
              );

              setState(() {
                _currentDisplayedWeek = nextWeek;
              });

              // Reload data for the new week
              _loadScheduleData();
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
    final l10n = AppLocalizations.of(context);

    // Use the currently displayed week as the initial date
    final currentWeekMonday = parseMondayFromISOWeek(_currentDisplayedWeek);
    if (currentWeekMonday == null) {
      AppLogger.error('Failed to parse displayed week: $_currentDisplayedWeek');
      return;
    }

    // Convert to local timezone for user display
    final currentDate = currentWeekMonday.toLocal();

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
      // Use timezone_utils for proper timezone handling
      // Get user timezone from auth service
      final authState = ref.read(authStateProvider);
      final userTimezone = authState.user?.timezone ?? 'UTC';

      AppLogger.debug(
        'DatePicker Selection: selected date=$selectedDate, user timezone=$userTimezone',
      );

      // Get ISO week string using timezone-aware method
      final selectedWeekString = getISOWeekString(selectedDate, userTimezone);

      AppLogger.debug(
        'Calculated ISO week: $selectedWeekString, current displayed week: $_currentDisplayedWeek',
      );

      // ✨ Direct week update - no more PageView complexity!
      AppLogger.debug(
        'DatePicker: updating from $_currentDisplayedWeek to $selectedWeekString',
      );

      setState(() {
        _currentDisplayedWeek = selectedWeekString;
      });

      // Reload data for the selected week
      _loadScheduleData();

      // Haptic feedback
      await HapticFeedback.lightImpact();
    }
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
      AppLogger.error('_getWeekDateRange failed for week $weekString: $e');
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
      return formatter.format(date);
    }
  }

  /// Handle tap on DisplayableTimeSlot - always use VehicleSelectionSheet
  void _handleDisplayableSlotTap(DisplayableTimeSlot displayableSlot) {
    _handleAddVehicleToDisplayableSlot(displayableSlot);
  }

  /// Check if a DisplayableTimeSlot is in the past (using DateUtils utility)
  bool _isSlotInPast(DisplayableTimeSlot displayableSlot) {
    // Calculate the actual datetime for this slot
    final slotDateTime = _dateTimeService.calculateDateTimeFromSlot(
      displayableSlot.dayOfWeek.name,
      displayableSlot.timeOfDay.toApiFormat(),
      displayableSlot.scheduleSlot?.week ?? _currentDisplayedWeek,
    );

    if (slotDateTime == null) return false;

    // Get current user timezone
    final currentUser = ref.watch(currentUserProvider);
    final userTimezone = currentUser?.timezone ?? 'UTC';

    // Use DateUtils utility with 5-minute buffer
    return app_date_utils.DateUtils.isPastInUserTimezone(
      slotDateTime,
      userTimezone,
      minutesBuffer: 5,
    );
  }

  /// Handle adding vehicle to DisplayableTimeSlot (creates slot if needed)
  void _handleAddVehicleToDisplayableSlot(
    DisplayableTimeSlot displayableSlot,
  ) async {
    try {
      if (!mounted) return;

      // Check if slot is in the past
      if (_isSlotInPast(displayableSlot)) {
        _showErrorSnackBar(
          'Impossible d\'ajouter un véhicule à un créneau horaire passé.',
        );
        return;
      }

      // Use VehicleSelectionSheet for both new and existing slots
      await _showVehicleSelectionSheet(displayableSlot);

      // Refresh the display
      _refreshDisplayableSlots();
    } catch (e) {
      _showErrorSnackBar('Impossible d\'ajouter le véhicule: $e');
    }
  }

  /// Handle vehicle tap to assign children
  void _handleVehicleTap(
    DisplayableTimeSlot displayableSlot,
    VehicleAssignment vehicleAssignment,
  ) {
    if (displayableSlot.scheduleSlot == null) return;
    if (_selectedGroupId == null) return;

    // Get family children for assignment
    final familyState = ref.read(familyProvider);
    final allChildren = familyState.children;

    // Get currently assigned child IDs for this vehicle
    final currentlyAssignedChildIds = vehicleAssignment.childAssignments
        .map((assignment) => assignment.childId)
        .toList();

    // Get child IDs already assigned to OTHER vehicles in this same slot
    final childIdsAssignedToOtherVehicles = displayableSlot
        .scheduleSlot!
        .vehicleAssignments
        .where((va) => va.id != vehicleAssignment.id) // Exclude current vehicle
        .expand((va) => va.childAssignments)
        .map((assignment) => assignment.childId)
        .toSet();

    // Filter out children already assigned to other vehicles in this slot
    final availableChildren = allChildren
        .where((child) => !childIdsAssignedToOtherVehicles.contains(child.id))
        .toList();

    // Open ChildAssignmentSheet for existing vehicle
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChildAssignmentSheet(
        groupId: _selectedGroupId!,
        week: displayableSlot.week,
        slotId: displayableSlot.scheduleSlot!.id,
        vehicleAssignment: vehicleAssignment,
        availableChildren: availableChildren,
        currentlyAssignedChildIds: currentlyAssignedChildIds,
      ),
    );
  }

  /// Handle vehicle actions for DisplayableTimeSlot
  void _handleVehicleAction(
    DisplayableTimeSlot displayableSlot,
    VehicleAssignment vehicleAssignment,
    String action,
  ) {
    if (action == 'remove') {
      _handleRemoveVehicle(displayableSlot, vehicleAssignment);
    }
  }

  /// Remove vehicle from slot
  Future<void> _handleRemoveVehicle(
    DisplayableTimeSlot displayableSlot,
    VehicleAssignment vehicleAssignment,
  ) async {
    final l10n = AppLocalizations.of(context);

    if (displayableSlot.scheduleSlot == null) return;
    if (_selectedGroupId == null) return;

    try {
      await HapticFeedback.lightImpact();

      // Extract required parameters
      final slotId = displayableSlot.scheduleSlot!.id;
      final vehicleId = vehicleAssignment.vehicleId;

      // Use the remove vehicle use case
      final useCase = ref.read(removeVehicleFromSlotUsecaseProvider);
      final result = await useCase.call(
        RemoveVehicleFromSlotParams(
          groupId: _selectedGroupId!,
          slotId: slotId,
          vehicleId: vehicleId,
        ),
      );

      if (result.isError) {
        throw Exception(result.error.toString());
      }

      // Success feedback
      await HapticFeedback.heavyImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            key: const Key('vehicle_removed_success_snackbar'),
            content: Text(
              l10n.vehicleRemovedSuccess(vehicleAssignment.vehicleName),
            ),
            backgroundColor: AppColors.successThemed(context),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );

        // Check if this was the last vehicle and provide contextual feedback
        final wasLastVehicle = displayableSlot.vehicleAssignments.length == 1;
        if (wasLastVehicle) {
          // Small delay to allow the SnackBar to show before potential UI changes
          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                key: const Key('slot_now_empty_snackbar'),
                content: Text(l10n.noVehiclesAssigned),
                backgroundColor: AppColors.infoThemed(context),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }

      // Refresh data after successful removal
      _refreshDisplayableSlots();
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(
          '${AppLocalizations.of(context).failedToLoadVehicles(vehicleAssignment.vehicleName)}: $e',
        );
      }
    }
  }

  /// Refresh displayable slots after modifications
  void _refreshDisplayableSlots() {
    if (_selectedGroupId != null) {
      AppLogger.debug(
        'Refreshing displayable slots for week: $_currentDisplayedWeek',
      );

      // Invalidate both providers to ensure fresh data flow
      ref.invalidate(
        weeklyScheduleProvider(_selectedGroupId!, _currentDisplayedWeek),
      );
      ref.invalidate(
        displayableSlotsProvider(_selectedGroupId!, _currentDisplayedWeek),
      );

      AppLogger.debug(
        'Invalidated weeklyScheduleProvider and displayableSlotsProvider',
      );
    }
  }

  /// Show VehicleSelectionSheet for both empty and existing slots
  Future<void> _showVehicleSelectionSheet(
    DisplayableTimeSlot displayableSlot,
  ) async {
    if (!mounted || _selectedGroupId == null) return;

    // Get all family vehicles
    final family = ref.read(familyProvider);
    final allFamilyVehicles = family.vehicles;

    if (allFamilyVehicles.isEmpty) {
      _showErrorSnackBar(
        'Aucun véhicule disponible. Veuillez d\'abord ajouter un véhicule à votre famille.',
      );
      return;
    }

    // Get all vehicle IDs already assigned in this slot
    final assignedVehicleIdsInSlot = displayableSlot.vehicleAssignments
        .map((assignment) => assignment.vehicleId)
        .where((id) => id.isNotEmpty)
        .toSet();

    // Available vehicles = all family vehicles - already assigned vehicles in this slot
    final availableVehicles = allFamilyVehicles
        .where((vehicle) => !assignedVehicleIdsInSlot.contains(vehicle.id))
        .toList();

    // Use the existing schedule slot if available, or create a temp one for new slots
    final scheduleSlot =
        displayableSlot.scheduleSlot ??
        ScheduleSlot(
          id: 'temp-${displayableSlot.compositeKey}',
          groupId: _selectedGroupId!,
          dayOfWeek: displayableSlot.dayOfWeek,
          timeOfDay: displayableSlot.timeOfDay,
          week: _currentDisplayedWeek, // Use displayed week, not current week
          vehicleAssignments: const [],
          maxVehicles: 5,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VehicleSelectionSheet(
        groupId: _selectedGroupId!,
        scheduleSlot: scheduleSlot,
        availableVehicles: availableVehicles,
      ),
    );
  }

  /// Start timer to refresh past slot status every minute (smart approach)
  void _startPastSlotRefreshTimer() {
    _pastSlotRefreshTimer = Timer.periodic(const Duration(seconds: 30), (
      timer,
    ) {
      if (mounted) {
        final newTime = DateTime.now();
        // Only trigger rebuild if time actually changed enough to affect past status
        if (newTime.difference(_currentTime).inSeconds >= 60) {
          setState(() {
            _currentTime = newTime;
          });
        }
      }
    });
  }

  /// Stop the past slot refresh timer
  void _stopPastSlotRefreshTimer() {
    _pastSlotRefreshTimer?.cancel();
    _pastSlotRefreshTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App became active, restart timer and refresh time
      _stopPastSlotRefreshTimer();
      setState(() {
        _currentTime = DateTime.now();
      });
      _startPastSlotRefreshTimer();
    } else if (state == AppLifecycleState.paused) {
      // App going to background, stop timer to save resources
      _stopPastSlotRefreshTimer();
    }
  }

  @override
  void dispose() {
    // Cancel any ongoing operations
    _stopPastSlotRefreshTimer();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
