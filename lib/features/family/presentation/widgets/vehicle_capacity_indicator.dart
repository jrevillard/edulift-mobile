// EduLift Mobile - Vehicle Capacity Indicator Widget
// Visual indicator for vehicle capacity and usage

import 'package:flutter/material.dart';

import 'package:edulift/core/presentation/themes/app_colors.dart';
import '../../../../generated/l10n/app_localizations.dart';
import 'package:edulift/core/presentation/themes/app_text_styles.dart';

/// Visual indicator showing vehicle capacity usage
class VehicleCapacityIndicator extends StatefulWidget {
  final int usedSeats;
  final int totalSeats;
  final bool showOverrideIndicator;
  final bool isOverride;
  final int? originalCapacity;
  final bool animated;
  final double size;
  final bool showLabels;
  final VoidCallback? onTap;

  const VehicleCapacityIndicator({
    super.key,
    required this.usedSeats,
    required this.totalSeats,
    this.showOverrideIndicator = false,
    this.isOverride = false,
    this.originalCapacity,
    this.animated = true,
    this.size = 80,
    this.showLabels = true,
    this.onTap,
  });

  @override
  State<VehicleCapacityIndicator> createState() =>
      _VehicleCapacityIndicatorState();
}

class _VehicleCapacityIndicatorState extends State<VehicleCapacityIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.usedSeats / widget.totalSeats,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.animated) {
      _animationController.forward();
    }

    if (widget.isOverride) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(VehicleCapacityIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.usedSeats != oldWidget.usedSeats ||
        widget.totalSeats != oldWidget.totalSeats) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.usedSeats / widget.totalSeats,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        ),
      );

      if (widget.animated) {
        _animationController.forward(from: 0.0);
      }
    }

    if (widget.isOverride != oldWidget.isOverride) {
      if (widget.isOverride) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.usedSeats / widget.totalSeats;
    final isOverCapacity = widget.usedSeats > widget.totalSeats;
    final isNearCapacity = progress >= 0.8;

    Color statusColor;
    if (isOverCapacity) {
      statusColor = AppColors.error;
    } else if (isNearCapacity) {
      statusColor = AppColors.warning;
    } else {
      statusColor = AppColors.success;
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_animationController, _pulseController]),
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isOverride ? _pulseAnimation.value : 1.0,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor.withValues(alpha: 0.1),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                  ),

                  // Progress circle
                  SizedBox(
                    width: widget.size - 8,
                    height: widget.size - 8,
                    child: CircularProgressIndicator(
                      value:
                          widget.animated ? _progressAnimation.value : progress,
                      strokeWidth: 4,
                      backgroundColor: statusColor.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),

                  // Center content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${widget.usedSeats}',
                        style: AppTextStyles.h2.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '/${widget.totalSeats}',
                        style: AppTextStyles.caption.copyWith(
                          color: statusColor.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.showLabels) ...[
                        const SizedBox(height: 2),
                        Text(
                          AppLocalizations.of(context).seats,
                          style: AppTextStyles.caption.copyWith(
                            color: statusColor.withValues(alpha: 0.6),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Override indicator
                  if (widget.showOverrideIndicator && widget.isOverride)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.warning,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.surface,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 10,
                          color: Theme.of(context).colorScheme.onPrimary,
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
}
