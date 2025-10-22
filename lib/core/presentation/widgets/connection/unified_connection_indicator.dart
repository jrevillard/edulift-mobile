// EduLift - Unified Connection Indicator
// Modern 2025 UX pattern: Subtle status indicator combining HTTP + WebSocket status
// Follows Material Design 3 principles with accessibility support

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/providers/connectivity_provider.dart';
import '../../../di/providers/presentation/websocket_status_provider.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../themes/app_colors.dart';

/// Connection status combining HTTP and WebSocket connectivity
enum ConnectionStatus {
  fullyConnected,      // Both HTTP and WebSocket connected
  limitedConnectivity, // HTTP ok, but WebSocket down (no real-time updates)
  offline,             // No HTTP connection
}

/// Provider for unified connection status
/// Prioritizes: HTTP offline > WebSocket issues > All connected
final unifiedConnectionStatusProvider = Provider<ConnectionStatus>((ref) {
  // Check HTTP connectivity (connectivityProvider returns AsyncValue<bool>)
  final httpConnected = ref.watch(connectivityProvider).when(
    data: (isConnected) => isConnected,
    loading: () => true, // Assume connected while loading
    error: (_, __) => false,
  );

  // Check WebSocket status
  final wsStatus = ref.watch(webSocketConnectionStatusNotifierProvider);

  // Priority hierarchy: HTTP offline is most critical
  if (!httpConnected) {
    return ConnectionStatus.offline;
  }

  // HTTP works but WebSocket has issues
  if (wsStatus.state == WebSocketConnectionState.disconnected ||
      wsStatus.state == WebSocketConnectionState.error) {
    return ConnectionStatus.limitedConnectivity;
  }

  // All good
  return ConnectionStatus.fullyConnected;
});

/// Unified connection status indicator widget
///
/// Shows a small dot indicating combined HTTP + WebSocket status.
/// Tap to show detailed connection info in a bottom sheet.
///
/// Best practice: Place in app bar or navigation area for consistent visibility.
class UnifiedConnectionIndicator extends ConsumerWidget {
  const UnifiedConnectionIndicator({
    super.key,
    this.size = 12.0,
    this.showWhenConnected = false,
  });

  final double size;
  final bool showWhenConnected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(unifiedConnectionStatusProvider);

    // Hide indicator when fully connected (cleaner UX)
    if (status == ConnectionStatus.fullyConnected && !showWhenConnected) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => _showConnectionDetails(context, ref),
      child: Semantics(
        label: _getSemanticLabel(context, status),
        liveRegion: true,
        button: true,
        hint: 'Tap for connection details',
        child: Tooltip(
          message: _getTooltipMessage(context, status),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getStatusColor(context, status),
              border: Border.all(
                color: _getStatusColor(context, status).withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(BuildContext context, ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.fullyConnected:
        return AppColors.success;
      case ConnectionStatus.limitedConnectivity:
        return AppColors.warning;
      case ConnectionStatus.offline:
        return AppColors.errorThemed(context);
    }
  }

  String _getSemanticLabel(BuildContext context, ConnectionStatus status) {
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case ConnectionStatus.fullyConnected:
        return 'Network status: ${l10n.connectionFullyConnected}';
      case ConnectionStatus.limitedConnectivity:
        return 'Network status: ${l10n.connectionLimitedConnectivity}';
      case ConnectionStatus.offline:
        return 'Network status: ${l10n.connectionOffline}';
    }
  }

  String _getTooltipMessage(BuildContext context, ConnectionStatus status) {
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case ConnectionStatus.fullyConnected:
        return l10n.connectionConnected;
      case ConnectionStatus.limitedConnectivity:
        return l10n.connectionLimitedConnectivity;
      case ConnectionStatus.offline:
        return l10n.connectionOffline;
    }
  }

  void _showConnectionDetails(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = ref.read(unifiedConnectionStatusProvider);
    final wsStatus = ref.read(webSocketConnectionStatusNotifierProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.connectionStatusTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildStatusRow(
              context,
              l10n.connectionHttpStatus,
              status != ConnectionStatus.offline,
              status == ConnectionStatus.offline
                  ? l10n.connectionDisconnected
                  : l10n.connectionConnected,
            ),
            const SizedBox(height: 8),
            _buildStatusRow(
              context,
              l10n.connectionWebSocketStatus,
              wsStatus.isRealTimeActive,
              wsStatus.statusText,
            ),
            if (status == ConnectionStatus.offline ||
                wsStatus.state == WebSocketConnectionState.disconnected) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(webSocketConnectionStatusNotifierProvider
                            .notifier)
                        .retryConnection();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Connection'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(
    BuildContext context,
    String label,
    bool isConnected,
    String status,
  ) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isConnected ? AppColors.success : AppColors.error,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const Spacer(),
        Text(
          status,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
