// EduLift Mobile - Vehicles Management Page
// Complete vehicle management with CRUD operations

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:edulift/core/navigation/navigation_state.dart';
import 'package:edulift/core/presentation/themes/app_colors.dart';

// COMPOSITION ROOT: Import ONLY from feature-level composition root
import '../../providers.dart';
import 'package:edulift/core/presentation/widgets/accessibility/accessible_button.dart';
import 'package:edulift/core/presentation/widgets/offline_indicator.dart';

class VehiclesPage extends ConsumerStatefulWidget {
  const VehiclesPage({super.key});

  @override
  ConsumerState<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends ConsumerState<VehiclesPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Convert error code to user-friendly localized message
  String _getLocalizedErrorMessage(BuildContext context, String errorKey) {
    final l10n = AppLocalizations.of(context);
    // Map error keys to localized messages
    switch (errorKey) {
      case 'errorVehicleLoading':
        return l10n.failedToLoadVehicles(errorKey);
      case 'errorNetworkGeneral':
        return l10n.errorNetwork;
      case 'errorVehicleNotFound':
        return l10n.errorServerGeneral;
      case 'errorVehiclesServerError':
        return l10n.errorServerGeneral;
      case 'errorInvalidData':
        return l10n.errorValidation;
      case 'errorOfflineSync':
        return l10n.errorOfflineMessage;
      default:
        // If it's already a user-friendly message from domain failures, use it directly
        // Otherwise fall back to generic error
        return errorKey.length > 50
            ? errorKey
            : l10n.errorServerGeneral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final familyState = ref.watch(familyComposedProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.vehicles),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('vehiclesPage_refresh_button'),
            onPressed: () => _refreshVehicles(),
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline indicator
          const OfflineIndicator(),

          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshVehicles,
              child: _buildContent(context, familyState, theme),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('vehiclesPage_addVehicle_fab'),
        onPressed: () => _navigateToAddVehicle(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.add),
        tooltip: l10n.addVehicle,
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    FamilyState state,
    ThemeData theme,
  ) {
    // Need responsive variables in this scope
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;
    final isSmallScreen = screenSize.width < 600;
    final l10n = AppLocalizations.of(context);
    if (state.isLoading && state.vehicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.loadingVehicles),
          ],
        ),
      );
    }

    if (state.error != null && state.vehicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(l10n.loadingError, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              // Use localized error message instead of raw error
              _getLocalizedErrorMessage(context, state.error!),
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AccessibleButton(
              key: const Key('vehiclesPage_retry_button'),
              onPressed: _refreshVehicles,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh),
                  const SizedBox(width: 8),
                  Text(l10n.retry),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (state.vehicles.isEmpty) {
      return _buildEmptyState(context, theme);
    }

    return Column(
      children: [
        // Summary card
        _buildSummaryCard(context, state, theme, isTablet, isSmallScreen),

        // Vehicles list
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
            itemCount: state.vehicles.length,
            separatorBuilder: (context, index) => SizedBox(height: isSmallScreen ? 8 : 12),
            itemBuilder: (context, index) {
              final vehicle = state.vehicles[index];
              return _buildVehicleCard(context, vehicle, state, theme, isTablet, isSmallScreen);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined, 
              size: 120,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noVehicles,
              style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.addFirstVehicle,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              key: const Key('vehiclesPage_emptyState_addVehicle_button'),
              onPressed: () => _navigateToAddVehicle(context),
              icon: const Icon(Icons.add),
              label: Text(l10n.addVehicle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    FamilyState state,
    ThemeData theme,
    bool isTablet,
    bool isSmallScreen,
  ) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      child: Card(
        elevation: isTablet ? 4 : 2,
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
          child: Row(
            children: [
              // Vehicle count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.vehicles,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.vehiclesCount}',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Total capacity
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.totalCapacity,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.totalCapacity} ${l10n.seats}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: state.hasVehicles
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    state.hasVehicles ? l10n.active : l10n.none,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: state.hasVehicles
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  Widget _buildVehicleCard(
    BuildContext context,
    vehicle,
    FamilyState state,
    ThemeData theme,
    bool isTablet,
    bool isSmallScreen,
  ) {
    final isLoading = state.isVehicleLoading(vehicle.id);
    final isTemporary = vehicle.id.startsWith('temp_');
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading
            ? null
            : () => _navigateToVehicleDetails(context, vehicle.id),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Vehicle icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getVehicleIcon(vehicle.capacity),
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Vehicle name and status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                vehicle.name,
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isTemporary) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.tertiary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  AppLocalizations.of(context).sync,
                                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onTertiary),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${vehicle.capacity} ${AppLocalizations.of(context).seats}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),

                  // Loading indicator or actions
                  if (isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    PopupMenuButton<String>(
                      key: Key('vehiclesPage_vehicleActions_${vehicle.id}'),
                      onSelected: (value) =>
                          _handleVehicleAction(context, value, vehicle),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          key: const Key('vehiclesPage_viewDetails_action'),
                          value: 'view',
                          child: Row(
                            children: [
                              const Icon(Icons.visibility),
                              const SizedBox(width: 8),
                              Text(AppLocalizations.of(context).viewDetails),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          key: const Key('vehiclesPage_edit_action'),
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit),
                              const SizedBox(width: 8),
                              Text(AppLocalizations.of(context).edit),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          key: const Key('vehiclesPage_schedule_action'),
                          value: 'schedule',
                          child: Row(
                            children: [
                              const Icon(Icons.schedule),
                              const SizedBox(width: 8),
                              Text(AppLocalizations.of(context).schedule),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          key: const Key('vehiclesPage_delete_action'),
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete, color: AppColors.error),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context).delete,
                                style: const TextStyle(color: AppColors.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // Description
              if (vehicle.description != null &&
                  vehicle.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  vehicle.description!,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Capacity bar
              const SizedBox(height: 12),
              _buildCapacityIndicator(context, vehicle, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapacityIndicator(
    BuildContext context,
    vehicle,
    ThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context);
    // Mock current usage for demonstration
    final currentUsage = (vehicle.capacity * 0.6).round(); // 60% usage
    final usagePercentage = currentUsage / vehicle.capacity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.usage,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            Text(
              '$currentUsage/${vehicle.capacity}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: usagePercentage,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(
            usagePercentage > 0.8
                ? theme.colorScheme.error
                : usagePercentage > 0.6
                ? AppColors.warning
                : theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  IconData _getVehicleIcon(int capacity) {
    if (capacity <= 4) return Icons.directions_car;
    if (capacity <= 7) return Icons.airport_shuttle;
    return Icons.directions_bus;
  }

  Future<void> _refreshVehicles() async {
    await ref.read(familyComposedProvider.notifier).loadVehicles();
  }
  
  void _navigateToAddVehicle(BuildContext context) {
    ref.read(navigationStateProvider.notifier).navigateTo(
      route: '/vehicles/add',
      trigger: NavigationTrigger.userNavigation,
    );
  }

  void _navigateToVehicleDetails(BuildContext context, String vehicleId) {
    ref.read(navigationStateProvider.notifier).navigateTo(
      route: '/vehicles/$vehicleId',
      trigger: NavigationTrigger.userNavigation,
    );
  }

  void _navigateToEditVehicle(BuildContext context, String vehicleId) {
    ref.read(navigationStateProvider.notifier).navigateTo(
      route: '/vehicles/$vehicleId/edit',
      trigger: NavigationTrigger.userNavigation,
    );
  }

  void _handleVehicleAction(BuildContext context, String action, vehicle) {
    switch (action) {
      case 'view':
        _navigateToVehicleDetails(context, vehicle.id);
        break;
      case 'edit':
        _navigateToEditVehicle(context, vehicle.id);
        break;
      case 'delete':
        _showDeleteConfirmation(context, vehicle);
        break;
    }
  }
  
  void _showDeleteConfirmation(BuildContext context, vehicle) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteVehicle),
        content: Text(l10n.confirmVehicleDeletion(vehicle.name)),
        actions: [
          TextButton(
            key: const Key('vehiclesPage_deleteCancel_button'),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const Key('vehiclesPage_deleteConfirm_button'),
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(familyComposedProvider.notifier).deleteVehicle(vehicle.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}