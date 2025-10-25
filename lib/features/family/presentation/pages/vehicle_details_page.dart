// EduLift Mobile - Vehicle Details Page
// Truthful implementation showing only API-backed data

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:edulift/core/navigation/navigation_state.dart';
import 'package:edulift/core/utils/timezone_formatter.dart';
import 'package:edulift/core/services/providers/auth_provider.dart';

import 'package:edulift/core/domain/entities/family.dart';
// ARCHITECTURE FIX: Use composition root instead
import '../../providers.dart';
import '../widgets/vehicle_capacity_indicator.dart';
import '../../../../core/presentation/widgets/loading_indicator.dart';

/// Vehicle details page showing only truthful API data
class VehicleDetailsPage extends ConsumerStatefulWidget {
  final String vehicleId;

  const VehicleDetailsPage({super.key, required this.vehicleId});

  @override
  ConsumerState<VehicleDetailsPage> createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends ConsumerState<VehicleDetailsPage> {
  Vehicle? _vehicle;

  @override
  void initState() {
    super.initState();
    _loadVehicle();
  }

  void _loadVehicle() {
    final familyState = ref.read(familyComposedProvider);
    final vehicle = familyState.vehicles
        .where((v) => v.id == widget.vehicleId)
        .firstOrNull;

    if (vehicle != null) {
      setState(() => _vehicle = vehicle);
    } else {
      // Load from provider if not in cache
      ref.read(familyComposedProvider.notifier).loadVehicles();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for updates to the vehicle
    ref.listen<FamilyState>(familyComposedProvider, (previous, next) {
      final updatedVehicle = next.vehicles
          .where((v) => v.id == widget.vehicleId)
          .firstOrNull;
      if (updatedVehicle != null) {
        setState(() => _vehicle = updatedVehicle);
      }
    });

    if (_vehicle == null) {
      final l10n = AppLocalizations.of(context);
      return Scaffold(
        appBar: AppBar(title: Text(l10n.vehicleDetails)),
        body: const Center(child: LoadingIndicator()),
      );
    }

    // Responsive design detection
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;
    final isSmallScreen = screenSize.width < 600;
    final isShortScreen = screenSize.height < 700;

    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_vehicle!.name),
        actions: [
          IconButton(
            key: const Key('vehicleDetails_edit_button'),
            icon: const Icon(Icons.edit),
            onPressed: () => ref
                .read(navigationStateProvider.notifier)
                .navigateTo(
                  route: '/family/vehicles/${_vehicle!.id}/edit',
                  trigger: NavigationTrigger.userNavigation,
                ),
            tooltip: l10n.editVehicleTooltip,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                // Refresh vehicle data
                await ref.read(familyComposedProvider.notifier).loadVehicles();
              },
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.all(
                      isSmallScreen || isShortScreen ? 12.0 : 16.0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints
                              .maxWidth, // Ensure bounded height for mobile screens
                          maxHeight:
                              constraints.maxHeight -
                              120, // Account for app bar
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildVehicleHeader(
                                context,
                                isTablet,
                                isSmallScreen,
                              ),
                              SizedBox(height: isSmallScreen ? 16 : 24),
                              _buildBasicInfoCard(
                                context,
                                isTablet,
                                isSmallScreen,
                              ),
                              SizedBox(height: isSmallScreen ? 12 : 16),
                              _buildCapacityCard(
                                context,
                                isTablet,
                                isSmallScreen,
                              ),
                              // Add bottom padding for safe area
                              SizedBox(height: isSmallScreen ? 16 : 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVehicleHeader(
    BuildContext context,
    bool isTablet,
    bool isSmallScreen,
  ) {
    final iconSize = isTablet ? 60.0 : (isSmallScreen ? 48.0 : 56.0);
    final cardPadding = isSmallScreen ? 12.0 : 16.0;

    return Card(
      elevation: isTablet ? 4 : 2,
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Row(
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
              ),
              child: Icon(
                Icons.directions_car,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: iconSize * 0.5,
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _vehicle!.name,
                    style:
                        (isTablet
                                ? Theme.of(context).textTheme.headlineSmall
                                : Theme.of(context).textTheme.titleLarge)
                            ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _vehicle!.displayNameWithCapacity,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(
    BuildContext context,
    bool isTablet,
    bool isSmallScreen,
  ) {
    final l10n = AppLocalizations.of(context);
    final cardPadding = isSmallScreen ? 12.0 : 16.0;
    final rowSpacing = isSmallScreen ? 6.0 : 8.0;
    final sectionSpacing = isSmallScreen ? 12.0 : 16.0;

    return Card(
      elevation: isTablet ? 4 : 2,
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: isSmallScreen
                ? 280
                : 320, // Prevent overflow on small screens
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.vehicleInformation,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: sectionSpacing),
                _buildInfoRow(
                  context,
                  l10n.vehicleId,
                  _vehicle!.id,
                  isSmallScreen,
                ),
                SizedBox(height: rowSpacing),
                _buildInfoRow(
                  context,
                  l10n.name,
                  _vehicle!.name,
                  isSmallScreen,
                ),
                SizedBox(height: rowSpacing),
                _buildInfoRow(
                  context,
                  l10n.capacity,
                  '${_vehicle!.capacity} ${l10n.seats}',
                  isSmallScreen,
                ),
                if (_vehicle!.description != null) ...[
                  SizedBox(height: rowSpacing),
                  _buildInfoRow(
                    context,
                    l10n.description,
                    _vehicle!.description!,
                    isSmallScreen,
                  ),
                ],
                SizedBox(height: rowSpacing),
                _buildInfoRow(
                  context,
                  l10n.created,
                  _formatDate(_vehicle!.createdAt, ref),
                  isSmallScreen,
                ),
                SizedBox(height: rowSpacing),
                _buildInfoRow(
                  context,
                  l10n.lastUpdated,
                  _formatDate(_vehicle!.updatedAt, ref),
                  isSmallScreen,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    bool isSmallScreen,
  ) {
    final labelWidth = isSmallScreen ? 80.0 : 100.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: labelWidth,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: isSmallScreen ? 13 : null,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: isSmallScreen ? 13 : null,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCapacityCard(
    BuildContext context,
    bool isTablet,
    bool isSmallScreen,
  ) {
    final l10n = AppLocalizations.of(context);
    final cardPadding = isSmallScreen ? 12.0 : 16.0;
    final sectionSpacing = isSmallScreen ? 12.0 : 16.0;
    final indicatorSize = isTablet ? 100.0 : (isSmallScreen ? 70.0 : 80.0);

    return Card(
      elevation: isTablet ? 4 : 2,
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: isSmallScreen
                ? 200
                : 250, // Prevent overflow on small screens
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.seatingConfiguration,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: sectionSpacing),
              // Center the capacity indicator
              Center(
                child: VehicleCapacityIndicator(
                  usedSeats: 0, // No current usage data in this view
                  totalSeats: _vehicle!.capacity,
                  size: indicatorSize,
                  showLabels:
                      !isSmallScreen, // Hide labels on very small screens
                ),
              ),
              SizedBox(height: sectionSpacing),
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                        size: isSmallScreen ? 16 : 20,
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 8),
                      Expanded(
                        child: Text(
                          l10n.childTransportCapacity(
                            _vehicle!.availablePassengerSeats,
                          ),
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSecondaryContainer,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date, WidgetRef ref) {
    // Get user timezone
    final currentUser = ref.read(currentUserProvider);
    final userTimezone = currentUser?.timezone;

    // Format date and time in user's timezone
    return TimezoneFormatter.formatDateTimeFull(date, userTimezone);
  }
}
