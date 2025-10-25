import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/navigation/navigation_state.dart';
import '../providers/schedule_providers.dart';
import '../../../groups/providers.dart';
import '../../../groups/presentation/providers/group_schedule_config_provider.dart';
import '../../../../core/domain/entities/groups/group.dart';
import 'package:edulift/core/domain/entities/family.dart';
import '../../../family/presentation/providers/family_provider.dart';
import '../widgets/vehicle_selection_modal.dart';
import '../widgets/schedule_grid.dart';
// REMOVED: realtime_schedule_indicators.dart - feature simplified (no invitation lists)
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/presentation/mixins/navigation_cleanup_mixin.dart';
import 'package:edulift/core/domain/entities/schedule.dart';
import 'package:edulift/core/utils/date/iso_week_utils.dart';

class SchedulePage extends ConsumerStatefulWidget {
  final String? groupId;

  const SchedulePage({super.key, this.groupId});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage>
    with NavigationCleanupMixin {
  String? _selectedGroupId;
  String _currentWeek = '';

  @override
  void initState() {
    super.initState();
    // NavigationCleanupMixin automatically clears navigation state
    _selectedGroupId = widget.groupId;
    _initializeCurrentWeek();
    // Load data when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(groupsComposedProvider.notifier).loadUserGroups();
      if (_selectedGroupId != null) {
        _loadScheduleData();
      }
    });
  }

  void _initializeCurrentWeek() {
    final now = DateTime.now();
    _currentWeek = getISOWeekString(now);
  }

  void _loadScheduleData() {
    // ✅ FIX: Invalidate the auto-dispose provider to trigger reload
    // This ensures the UI fetches fresh data using the modern provider system
    if (_selectedGroupId != null) {
      ref.invalidate(weeklyScheduleProvider(_selectedGroupId!, _currentWeek));
      // Note: Schedule config is now handled by dedicated schedule config provider
      // and loaded when needed by specific config widgets
    }
  }

  void _handleVehicleDrop(String day, String time, String vehicleId) async {
    try {
      // ✅ FIX: Use modern slot state notifier for mutations
      // Then invalidate the auto-dispose provider to refresh UI
      await ref
          .read(slotStateNotifierProvider.notifier)
          .upsertSlot(
            groupId: _selectedGroupId!,
            day: day,
            time: time,
            week: _currentWeek,
          );

      // Refresh is handled by invalidation in the notifier
      // No need to call _loadScheduleData() - provider will auto-refresh
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  /// Handle week navigation from PageView swipe
  /// Calculates new week based on offset from current week
  /// and reloads schedule data
  ///
  /// Note: weekOffset is the delta from _currentWeek
  /// - weekOffset = 0: stay on current week
  /// - weekOffset = 1: next week
  /// - weekOffset = -1: previous week
  void _handleWeekChanged(int weekOffset) {
    try {
      // ⚠️ CRITICAL BUG FIX: Calculate from CURRENT week, not initial week!
      // weekOffset is always relative to the week passed to ScheduleGrid (which is _currentWeek)
      // NOT relative to _initialWeek (which was set once in initState and never changes)
      //
      // Example bug scenario:
      // - Initial: W42, Current: W42
      // - Click next: offset=1 → W42+1=W43 ✓
      // - Click next: offset=2 → W42+2=W44 ✓ (WRONG! Should be W43+1=W44)
      //
      // Correct calculation:
      // - weekOffset is delta from _currentWeek (the week ScheduleGrid is displaying)
      // - So we calculate: _currentWeek + weekOffset
      final newWeek = addWeeksToISOWeek(_currentWeek, weekOffset);

      debugPrint('🔄 Week changed callback:');
      debugPrint('   Week offset: $weekOffset');
      debugPrint('   Current week (base): $_currentWeek');
      debugPrint('   New week: $newWeek');

      // Only update if different to avoid unnecessary rebuilds
      if (newWeek != _currentWeek) {
        setState(() {
          _currentWeek = newWeek;
        });

        // Reload schedule data for new week
        _loadScheduleData();
      }
    } catch (e) {
      debugPrint('ERROR: Failed to calculate week offset: $e');
    }
  }

  /// Handle manage vehicles request
  /// Opens VehicleSelectionModal with period slot data
  void _handleManageVehicles(PeriodSlotData scheduleSlot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VehicleSelectionModal(
        key: ValueKey(
          'vehicle-modal-${scheduleSlot.week}-${scheduleSlot.dayOfWeek.name}-${DateTime.now().millisecondsSinceEpoch}',
        ),
        groupId: _selectedGroupId!,
        scheduleSlot: scheduleSlot,
      ),
    ).then((_) {
      // When modal closes, force refresh of the page
      if (_selectedGroupId != null) {
        ref.invalidate(weeklyScheduleProvider(_selectedGroupId!, _currentWeek));
      }
    });
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
    return _buildScheduleContent(
      selectedGroup,
      scheduleAsync,
      scheduleConfigState,
    );
  }

  Widget _buildScheduleContent(
    Group selectedGroup,
    AsyncValue<List<ScheduleSlot>> scheduleAsync,
    AsyncValue<ScheduleConfig?> scheduleConfigState,
  ) {
    // Check if config is null or error (matching web behavior)
    final hasConfigError =
        scheduleConfigState.hasError || scheduleConfigState.value == null;

    if (hasConfigError) {
      return _buildConfigRequiredState(selectedGroup);
    }

    // ✅ FIX: Use AsyncValue.when to handle loading, data, and error states
    // This replaces the old ScheduleState pattern with modern Riverpod AsyncValue
    return scheduleAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildScheduleErrorState(error.toString()),
      data: (scheduleSlots) => RefreshIndicator(
        onRefresh: () async {
          // Invalidate current week schedule to force reload
          ref.invalidate(
            weeklyScheduleProvider(_selectedGroupId!, _currentWeek),
          );

          // Small delay for smooth animation
          await Future.delayed(const Duration(milliseconds: 300));

          // Haptic feedback on complete
          await HapticFeedback.mediumImpact();
        },
        child: ScheduleGrid(
          groupId: _selectedGroupId!,
          week: _currentWeek,
          scheduleData: scheduleSlots,
          scheduleConfig: scheduleConfigState.value,
          onManageVehicles: _handleManageVehicles,
          onVehicleDrop: _handleVehicleDrop,
          onWeekChanged: _handleWeekChanged,
        ),
      ),
    );
  }

  Widget _buildNoGroupsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups_outlined, size: 120, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context).noTransportGroups,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).needGroupForSchedules,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            ),
            const SizedBox(height: 32),
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
        final screenSize = MediaQuery.of(context).size;
        final isTablet = screenSize.width > 768;

        // Responsive grid columns
        final crossAxisCount = isTablet ? 3 : 2;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLocalizations.of(context).selectGroup,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).chooseGroupForSchedule,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    final groupId = group.id;
                    final groupName = group.name;
                    final userRole = _roleToString(group.userRole) ?? 'MEMBER';
                    final familyCount = group.familyCount;

                    return Card(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedGroupId = groupId;
                          });
                          _loadScheduleData();
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.groups,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      groupName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                AppLocalizations.of(
                                  context,
                                ).familyCount(familyCount),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                              Text(
                                AppLocalizations.of(context).userRole(userRole),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon - Reduced size for smaller screens
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.settings,
                size: 50,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              l10n.scheduleConfigurationRequired,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              l10n.setupTimeSlotsToEnableScheduling,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

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
                padding: const EdgeInsets.all(14),
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
                      size: 18,
                    ),
                    const SizedBox(width: 8),
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

            const SizedBox(height: 14),

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

  @override
  void dispose() {
    // Cancel any ongoing operations
    super.dispose();
  }
}
