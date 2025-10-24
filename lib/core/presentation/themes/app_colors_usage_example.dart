/// USAGE EXAMPLES for AppColors (Material 3)
///
/// This file demonstrates how to use the semantic color tokens from AppColors
/// in different contexts: Schedule, Groups, Family modules.
///
/// DO NOT import this file in production code - it's for reference only.

// ignore_for_file: unused_element, unused_local_variable

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Example 1: Schedule slot colors (status semantics)
class _ScheduleSlotExample extends StatelessWidget {
  const _ScheduleSlotExample();

  @override
  Widget build(BuildContext context) {
    return Container(
      // Use status semantics for slot states
      color: AppColors.statusAvailable(context),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Driver badge
          Container(
            color: AppColors.driverBadge(context),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'Driver',
              style: TextStyle(color: AppColors.onPrimaryContainer(context)),
            ),
          ),
          const SizedBox(height: 8),
          // Child badge
          Container(
            color: AppColors.childBadge(context),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'Child',
              style: TextStyle(color: AppColors.onSecondaryContainer(context)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 2: Day colors with colorblind-friendly icons
class _DayIndicatorExample extends StatelessWidget {
  const _DayIndicatorExample();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildDayChip('monday'),
        _buildDayChip('tuesday'),
        _buildDayChip('wednesday'),
        _buildDayChip('thursday'),
        _buildDayChip('friday'),
      ],
    );
  }

  Widget _buildDayChip(String day) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: [
          Icon(
            AppColors.getDayIcon(day), // Colorblind-friendly shape
            color: AppColors.getDayColor(day),
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(day),
        ],
      ),
    );
  }
}

/// Example 3: Capacity indicators (Groups/Family resource planning)
class _CapacityIndicatorExample extends StatelessWidget {
  const _CapacityIndicatorExample();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // OK capacity (0-70%)
        _buildCapacityBar(context, 'Vehicle A', 0.5, AppColors.capacityOk),
        // Warning capacity (70-90%)
        _buildCapacityBar(
          context,
          'Vehicle B',
          0.85,
          AppColors.capacityWarning,
        ),
        // Error capacity (90-100%+)
        _buildCapacityBar(
          context,
          'Vehicle C',
          1.1,
          AppColors.capacityError(context),
        ),
      ],
    );
  }

  Widget _buildCapacityBar(
    BuildContext context,
    String name,
    double ratio,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$name: ${(ratio * 100).toInt()}%',
            style: TextStyle(color: AppColors.textPrimaryThemed(context)),
          ),
          const SizedBox(height: 4),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariantThemed(context),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              widthFactor: ratio.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 4: Resource status states (Groups/Family)
class _ResourceStatusExample extends StatelessWidget {
  const _ResourceStatusExample();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildResourceCard(
          context,
          'Vehicle 1',
          'Empty',
          AppColors.statusEmpty(context),
        ),
        _buildResourceCard(
          context,
          'Vehicle 2',
          'Available',
          AppColors.statusAvailable(context),
        ),
        _buildResourceCard(
          context,
          'Vehicle 3',
          'Partial',
          AppColors.statusPartial(context),
        ),
        _buildResourceCard(
          context,
          'Vehicle 4',
          'Full',
          AppColors.statusFull(context),
        ),
        _buildResourceCard(
          context,
          'Vehicle 5',
          'Conflict',
          AppColors.statusConflict(context),
        ),
      ],
    );
  }

  Widget _buildResourceCard(
    BuildContext context,
    String name,
    String status,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderThemed(context)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              color: AppColors.textPrimaryThemed(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            status,
            style: TextStyle(color: AppColors.textSecondaryThemed(context)),
          ),
        ],
      ),
    );
  }
}

/// Example 5: French/English day support
class _BilingualDayExample extends StatelessWidget {
  const _BilingualDayExample();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // English days
        Row(
          children: [
            _buildDayIcon('monday'),
            _buildDayIcon('tuesday'),
            _buildDayIcon('wednesday'),
          ],
        ),
        // French days (same colors and icons)
        Row(
          children: [
            _buildDayIcon('lundi'),
            _buildDayIcon('mardi'),
            _buildDayIcon('mercredi'),
          ],
        ),
      ],
    );
  }

  Widget _buildDayIcon(String day) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Icon(
        AppColors.getDayIcon(day),
        color: AppColors.getDayColor(day),
        size: 32,
      ),
    );
  }
}
