import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/utils/responsive_breakpoints.dart';
import '../../../../core/presentation/themes/app_colors.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../schedule/presentation/widgets/schedule_config_widget.dart';
import '../providers/group_schedule_config_provider.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';
import 'package:edulift/core/navigation/navigation_state.dart' as nav;
import '../../providers.dart';
import '../../../../core/presentation/mixins/navigation_cleanup_mixin.dart';
import '../../../../core/domain/entities/groups/group.dart';

/// Page for group administrators to configure schedule settings
class GroupScheduleConfigPage extends ConsumerStatefulWidget {
  final String groupId;
  final String groupName;

  const GroupScheduleConfigPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  ConsumerState<GroupScheduleConfigPage> createState() =>
      _GroupScheduleConfigPageState();
}

class _GroupScheduleConfigPageState
    extends ConsumerState<GroupScheduleConfigPage> with NavigationCleanupMixin {
  bool _hasUnsavedChanges = false;
  String? _resolvedGroupName;
  VoidCallback? _saveCallback;
  VoidCallback? _cancelCallback;
  final GlobalKey<State<StatefulWidget>> _scheduleWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // NavigationCleanupMixin automatically clears navigation state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Don't call loadConfig here - the provider already loads it in its constructor
      // Load group name if not provided
      if (widget.groupName.isEmpty) {
        _loadGroupName();
      } else {
        setState(() {
          _resolvedGroupName = widget.groupName;
        });
      }
    });
  }

  void _loadGroupName() {
    // Load group name from groups provider
    final groupsState = ref.read(groupsComposedProvider);
    Group? group;
    try {
      group = groupsState.groups.firstWhere((g) => g.id == widget.groupId);
    } catch (e) {
      group = null;
    }

    if (group != null) {
      final groupName = group.name;
      setState(() {
        _resolvedGroupName = groupName;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      final shouldPop = await _showUnsavedChangesDialog();
      return shouldPop ?? false;
    }
    return true;
  }

  Future<bool?> _showUnsavedChangesDialog() async {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.unsavedChangesTitle),
        content: Text(l10n.unsavedChangesScheduleMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.stayButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.leaveButton),
          ),
        ],
      ),
    );
  }

  void _onConfigurationUpdated() {
    setState(() {
      _hasUnsavedChanges = false;
    });
    // Show success and refresh parent pages
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.scheduleConfigurationUpdatedSuccessfully),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onActionsChanged(
    VoidCallback? saveCallback,
    VoidCallback? cancelCallback,
    bool hasChanges,
  ) {
    setState(() {
      _saveCallback = saveCallback;
      _cancelCallback = cancelCallback;
      _hasUnsavedChanges = hasChanges;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final hasAccess = ref.watch(
      hasGroupScheduleConfigAccessProvider(widget.groupId),
    );
    final authState = ref.watch(authStateProvider);

    // FIX: Listen to navigation state changes to intercept tab navigation
    // This handles unsaved changes confirmation for tab navigation (PopScope only handles back button)
    ref.listen(nav.navigationStateProvider, (previous, next) async {
      // Only intercept user navigation attempts when we have unsaved changes
      if (_hasUnsavedChanges &&
          next.hasPendingNavigation &&
          next.trigger == nav.NavigationTrigger.userNavigation) {
        // Show confirmation dialog
        final shouldNavigate = await _showUnsavedChangesDialog();

        if (shouldNavigate == true) {
          // User confirmed - allow navigation by keeping the navigation state
          // The router will process it
        } else {
          // User cancelled - clear the navigation state to prevent navigation
          ref.read(nav.navigationStateProvider.notifier).clearNavigation();
        }
      }
    });

    // Watch the groups provider to get updated group name
    final groupsState = ref.watch(groupsComposedProvider);
    var currentGroupName = _resolvedGroupName ?? widget.groupName;

    // Update group name from provider if available
    try {
      final group = groupsState.groups.firstWhere(
        (g) => g.id == widget.groupId,
      );
      final groupName = group.name;
      if (groupName != currentGroupName) {
        currentGroupName = groupName;
        // Update state in next frame to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _resolvedGroupName = groupName;
            });
          }
        });
      }
    } catch (e) {
      // Group not found, keep existing name
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.scheduleConfiguration,
                style: TextStyle(fontSize: 20 * context.fontScale),
              ),
              Text(
                currentGroupName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 14 * context.fontScale,
                ),
              ),
            ],
          ),
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          actions: [
            // Cancel button (only show if there are changes)
            if (_cancelCallback != null)
              IconButton(
                key: const Key('scheduleConfig_cancel_button'),
                onPressed: _cancelCallback,
                icon: const Icon(Icons.cancel_outlined),
                tooltip: l10n.cancelChanges,
              ),
            // Save button (only show if save is available)
            if (_saveCallback != null)
              IconButton(
                key: const Key('scheduleConfig_save_button'),
                onPressed: _saveCallback,
                icon: const Icon(Icons.save),
                tooltip: l10n.saveConfiguration,
              ),
          ],
        ),
        body: !authState.isAuthenticated || !hasAccess
            ? _buildAccessDeniedState(theme)
            : ScheduleConfigWidget(
                key: _scheduleWidgetKey,
                groupId: widget.groupId,
                onConfigUpdated: _onConfigurationUpdated,
                onActionsChanged: _onActionsChanged,
              ),
        floatingActionButton: !authState.isAuthenticated || !hasAccess
            ? null
            : (_scheduleWidgetKey.currentState as dynamic)
                ?.buildFloatingActionButton
                ?.call(context),
      ),
    );
  }

  Widget _buildAccessDeniedState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: context.getAdaptivePadding(
          mobileAll: 24,
          tabletAll: 32,
          desktopAll: 40,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outlined,
              size: context.getAdaptiveIconSize(
                mobile: 64,
                tablet: 72,
                desktop: 80,
              ),
              color: AppColors.warningContainer,
            ),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
            ),
            Text(
              'Access Denied',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.onWarningContainer,
                fontWeight: FontWeight.w600,
                fontSize: 24 * context.fontScale,
              ),
            ),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 6,
                tablet: 8,
                desktop: 12,
              ),
            ),
            Text(
              'Only group administrators can configure schedule settings.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 16 * context.fontScale,
              ),
            ),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 20,
                tablet: 24,
                desktop: 32,
              ),
            ),
            SizedBox(
              height: context.getAdaptiveButtonHeight(
                mobile: 48,
                tablet: 52,
                desktop: 56,
              ),
              child: ElevatedButton.icon(
                key: const Key('scheduleConfig_goBack_button'),
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
                label: Text(AppLocalizations.of(context).goBackButton),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildErrorState(String error, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.errorThemed(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Page',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.errorThemed(context),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  key: const Key('scheduleConfig_errorGoBack_button'),
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(AppLocalizations.of(context).goBackButton),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  key: const Key('scheduleConfig_tryAgain_button'),
                  onPressed: () {
                    // Retry loading the page
                    setState(() {});
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(AppLocalizations.of(context).tryAgain),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
