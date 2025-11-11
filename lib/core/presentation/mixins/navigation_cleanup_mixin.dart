// EduLift Mobile - Navigation Cleanup Mixin
// Mixin to automatically clear navigation state when a page is displayed
// Use this on destination pages that are targets of declarative navigation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../navigation/navigation_state.dart';

/// Mixin that automatically clears pending navigation state when a page is displayed.
///
/// **When to use:**
/// - Pages that are destinations of `navigationStateProvider.navigateTo()`
/// - Final pages in a navigation flow
/// - Pages accessible from global navigation (menu, shortcuts)
///
/// **When NOT to use:**
/// - Intermediate pages in a multi-step wizard/flow
/// - Modal dialogs or bottom sheets
/// - Pages using imperative navigation (Navigator.push)
///
/// **Example:**
/// ```dart
/// class DashboardPage extends ConsumerStatefulWidget {
///   const DashboardPage({super.key});
///
///   @override
///   ConsumerState<DashboardPage> createState() => _DashboardPageState();
/// }
///
/// class _DashboardPageState extends ConsumerState<DashboardPage>
///     with NavigationCleanupMixin {
///
///   @override
///   Widget build(BuildContext context) {
///     // Your page content
///   }
/// }
/// ```
mixin NavigationCleanupMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _scheduleNavigationClear();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Remove automatic clearing in didChangeDependencies to prevent navigation loops
    // Only clear navigation state in initState when page first loads
    // This allows normal navigation away from the page without interference
    if (!_hasInitialized) {
      _hasInitialized = true;
    }
  }

  void _scheduleNavigationClear() {
    // Clear navigation state after page is displayed
    // Using addPostFrameCallback ensures the navigation is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(navigationStateProvider.notifier).clearNavigation();
      }
    });
  }
}
