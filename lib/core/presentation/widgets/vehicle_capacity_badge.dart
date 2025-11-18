import 'package:flutter/material.dart';
import 'package:edulift/core/domain/entities/schedule/vehicle_assignment.dart';
import '../utils/responsive_breakpoints.dart';

/// Badge compact affichant la capacité du véhicule (X/Y)
///
/// Extrait du dashboard pour réutilisation dans Schedule
/// Partagé entre Dashboard et Schedule
///
/// Schéma de couleurs Material 3:
/// - < 80%: primary (disponible)
/// - 80-99%: secondary (limité)
/// - 100%+: error (plein/surchargé)
///
/// Usage:
/// ```dart
/// // Mode normal (desktop/tablet)
/// VehicleCapacityBadge(assigned: 3, capacity: 4)
///
/// // Mode compact (mobile)
/// VehicleCapacityBadge(assigned: 3, capacity: 4, compact: true)
///
/// // Avec status explicite
/// VehicleCapacityBadge(
///   assigned: 5,
///   capacity: 4,
///   capacityStatus: CapacityStatus.overcapacity,
/// )
/// ```
class VehicleCapacityBadge extends StatelessWidget {
  /// Nombre de places assignées
  final int assigned;

  /// Capacité totale du véhicule
  final int capacity;

  /// Status de capacité (calculé automatiquement si null)
  final CapacityStatus? capacityStatus;

  /// Mode compact pour affichage mobile réduit
  final bool compact;

  const VehicleCapacityBadge({
    Key? key,
    required this.assigned,
    required this.capacity,
    this.capacityStatus,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = capacityStatus ?? _calculateCapacityStatus();
    final backgroundColor = _getCapacityStatusColor(context, status);
    final textColor = _getContrastColor(context, status);

    return Container(
      key: const Key('vehicle_capacity_badge'),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(compact ? 4 : 6),
        border: Border.all(color: backgroundColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCapacityStatusIcon(status),
            size: compact
                ? context.getAdaptiveIconSize(
                    mobile: 10,
                    tablet: 12,
                    desktop: 14,
                  )
                : context.getAdaptiveIconSize(
                    mobile: 12,
                    tablet: 14,
                    desktop: 16,
                  ),
            color: backgroundColor,
          ),
          SizedBox(width: compact ? 3 : 4),
          Text(
            '$assigned/$capacity',
            key: const Key('capacity_text'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
              fontSize: compact
                  ? context.getAdaptiveFontSize(
                      mobile: 10,
                      tablet: 11,
                      desktop: 12,
                    )
                  : context.getAdaptiveFontSize(
                      mobile: 11,
                      tablet: 12,
                      desktop: 13,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Calcule automatiquement le status de capacité
  CapacityStatus _calculateCapacityStatus() {
    final percentage = (assigned / capacity) * 100;
    if (percentage > 100) return CapacityStatus.overcapacity;
    if (percentage >= 100) return CapacityStatus.full;
    if (percentage >= 80) return CapacityStatus.limited;
    return CapacityStatus.available;
  }

  /// Retourne la couleur Material 3 pour le status de capacité
  Color _getCapacityStatusColor(BuildContext context, CapacityStatus status) {
    switch (status) {
      case CapacityStatus.available:
        return Theme.of(context).colorScheme.primary;
      case CapacityStatus.limited:
        return Theme.of(context).colorScheme.secondary;
      case CapacityStatus.full:
        return Theme.of(context).colorScheme.error;
      case CapacityStatus.overcapacity:
        return Theme.of(context).colorScheme.error;
    }
  }

  /// Retourne la couleur de texte contrastée
  Color _getContrastColor(BuildContext context, CapacityStatus status) {
    switch (status) {
      case CapacityStatus.available:
        return Theme.of(context).colorScheme.primary;
      case CapacityStatus.limited:
        return Theme.of(context).colorScheme.secondary;
      case CapacityStatus.full:
        return Theme.of(context).colorScheme.error;
      case CapacityStatus.overcapacity:
        return Theme.of(context).colorScheme.error;
    }
  }

  /// Retourne l'icône appropriée pour le status
  IconData _getCapacityStatusIcon(CapacityStatus status) {
    switch (status) {
      case CapacityStatus.available:
        return Icons.check_circle;
      case CapacityStatus.limited:
        return Icons.warning;
      case CapacityStatus.full:
        return Icons.error;
      case CapacityStatus.overcapacity:
        return Icons.error;
    }
  }
}
