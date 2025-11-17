import 'package:flutter/material.dart';
import 'package:edulift/core/domain/entities/schedule/vehicle_assignment.dart';

/// Widget de barre de progression de capacité - Material 3
///
/// Extrait et amélioré depuis VehicleAssignmentRow (dashboard)
/// Partagé entre Dashboard et Schedule pour cohérence visuelle
///
/// Schéma de couleurs Material 3:
/// - < 80%: primary (disponible)
/// - 80-99%: secondary (limité)
/// - 100%+: error (plein/surchargé)
///
/// Usage:
/// ```dart
/// // Basique
/// CapacityProgressBar(assigned: 3, capacity: 4)
///
/// // Compact pour mobile
/// CapacityProgressBar(assigned: 3, capacity: 4, compact: true)
///
/// // Avec status explicite
/// CapacityProgressBar(
///   assigned: 5,
///   capacity: 4,
///   capacityStatus: CapacityStatus.overcapacity,
/// )
/// ```
class CapacityProgressBar extends StatelessWidget {
  /// Nombre de places assignées
  final int assigned;

  /// Capacité totale du véhicule
  final int capacity;

  /// Status de capacité (calculé automatiquement si null)
  final CapacityStatus? capacityStatus;

  /// Mode compact pour affichage mobile réduit
  final bool compact;

  /// Afficher le label avec icône et texte
  final bool showLabel;

  /// Afficher le pourcentage
  final bool showPercentage;

  const CapacityProgressBar({
    Key? key,
    required this.assigned,
    required this.capacity,
    this.capacityStatus,
    this.compact = false,
    this.showLabel = true,
    this.showPercentage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = capacityStatus ?? _calculateCapacityStatus();
    final percentage = ((assigned / capacity) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getCapacityStatusIcon(status),
                size: compact ? 14 : 16,
                color: _getCapacityStatusColor(context, status),
              ),
              const SizedBox(width: 4),
              Text(
                '$assigned/$capacity',
                key: const Key('capacity_label'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: _getCapacityStatusColor(context, status),
                  fontSize: compact ? 11 : 12,
                ),
              ),
              if (showPercentage) ...[
                const SizedBox(width: 6),
                Text(
                  '($percentage%)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: compact ? 10 : 11,
                  ),
                ),
              ],
            ],
          ),
        if (showLabel) const SizedBox(height: 4),
        SizedBox(
          width: compact ? 50 : 60,
          height: compact ? 3 : 4,
          child: LinearProgressIndicator(
            key: const Key('capacity_progress'),
            value: (assigned / capacity).clamp(0.0, 1.0),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getCapacityStatusColor(context, status),
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
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
