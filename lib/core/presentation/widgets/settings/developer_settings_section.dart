import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import '../../../../core/storage/log_config.dart';
import '../providers/log_export_provider.dart';

/// 2025 State-of-the-Art Developer Settings Section
/// Features modern Material Design 3, proper state management, and accessibility
class DeveloperSettingsSection extends ConsumerWidget {
  const DeveloperSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final logExportState = ref.watch(logExportProvider);
    final currentLogLevel = ref.watch(currentLogLevelProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Icon(Icons.developer_mode, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.developerTools,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Log Level Selection
            _buildLogLevelSection(context, ref, currentLogLevel),

            const SizedBox(height: 16),

            // Log Export Section
            _buildLogExportSection(context, ref, logExportState, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildLogLevelSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<String> currentLogLevel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.tune,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).logLevel,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: currentLogLevel.when(
            data: (level) => _buildLogLevelDropdown(context, ref, level),
            loading: () => const CircularProgressIndicator.adaptive(),
            error: (_, __) => Text(
              AppLocalizations.of(context).errorLoadingLogLevel,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context).logLevelDescription,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildLogLevelDropdown(
    BuildContext context,
    WidgetRef ref,
    String currentLevel,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: currentLevel,
      isExpanded: true,
      decoration: InputDecoration(
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: LogConfig.availableLevels.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.value.name.toUpperCase(),
          child: Text(entry.key, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: (newLevel) async {
        if (newLevel != null) {
          try {
            await ref.read(logExportProvider.notifier).setLogLevel(newLevel);
            // Refresh the current log level
            ref.invalidate(currentLogLevelProvider);

            if (context.mounted) {
              final l10n = AppLocalizations.of(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.logLevelChanged(newLevel)),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              final l10n = AppLocalizations.of(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.logLevelChangeFailed(e.toString())),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        }
      },
    );
  }

  Widget _buildLogExportSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<LogExportState> logExportState,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.file_download,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).logExport,
              style: theme.textTheme.titleSmall,
            ),
          ],
        ),
        const SizedBox(height: 8),

        logExportState.when(
          data: (state) => _buildExportButton(context, ref, state, theme),
          loading: () => _buildLoadingButton(context, theme),
          error: (error, _) => _buildErrorButton(context, ref, error, theme),
        ),

        const SizedBox(height: 8),

        // Export info and last export time
        logExportState.when(
          data: (state) => _buildExportInfo(context, state, theme),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildExportButton(
    BuildContext context,
    WidgetRef ref,
    LogExportState state,
    ThemeData theme,
  ) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: state.isExporting
            ? null
            : () => _handleLogExport(context, ref),
        icon: Icon(state.isExporting ? Icons.hourglass_empty : Icons.share),
        label: Text(
          state.isExporting
              ? AppLocalizations.of(context).exporting
              : AppLocalizations.of(context).exportLogsForSupport,
        ),
      ),
    );
  }

  Widget _buildLoadingButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: null,
        icon: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        label: Text(AppLocalizations.of(context).exporting),
      ),
    );
  }

  Widget _buildErrorButton(
    BuildContext context,
    WidgetRef ref,
    Object error,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () => _handleLogExport(context, ref),
          icon: const Icon(Icons.refresh),
          label: Text(AppLocalizations.of(context).retryExport),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(
            context,
          ).errorFailedToExportLogs(error.toString()),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      ],
    );
  }

  Widget _buildExportInfo(
    BuildContext context,
    LogExportState state,
    ThemeData theme,
  ) {
    final infoItems = <String>[];

    if (state.logSizeBytes > 0) {
      final sizeMB = (state.logSizeBytes / (1024 * 1024)).toStringAsFixed(1);
      infoItems.add(AppLocalizations.of(context).estimatedLogSize(sizeMB));
    }

    if (state.lastExportTime != null) {
      final timeAgo = _formatTimeAgo(context, state.lastExportTime!);
      infoItems.add(AppLocalizations.of(context).lastExported(timeAgo));
    }

    if (infoItems.isEmpty) {
      return Text(
        AppLocalizations.of(context).exportIncludesInfo,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...infoItems.map(
          (info) => Text(
            info,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context).exportIncludesComprehensive,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _translateLogError(BuildContext context, String error) {
    final l10n = AppLocalizations.of(context);

    if (error.contains('LOG_EXPORT_UNSUPPORTED_PLATFORM')) {
      return l10n.logExportUnsupportedPlatform;
    } else if (error.contains('LOG_EXPORT_NO_DIRECTORY')) {
      return l10n.logExportNoDirectory;
    } else if (error.contains('LOG_EXPORT_NO_FILES')) {
      return l10n.logExportNoFiles;
    }

    // Fallback: retourne l'erreur originale
    return error;
  }

  Future<void> _handleLogExport(BuildContext context, WidgetRef ref) async {
    await ref.read(logExportProvider.notifier).exportLogs();

    if (context.mounted) {
      final l10n = AppLocalizations.of(context);
      final state = ref.read(logExportProvider);

      // Check if export succeeded by verifying state has no error
      final hasError = state.value?.error != null;

      if (hasError) {
        final translatedError = _translateLogError(
          context,
          state.value!.error!,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToExportLogs(translatedError)),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.logsExportedSuccess),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatTimeAgo(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return l10n.timeAgoDays(
        difference.inDays,
        difference.inDays == 1 ? '' : 's',
      );
    } else if (difference.inHours > 0) {
      return l10n.timeAgoHours(
        difference.inHours,
        difference.inHours == 1 ? '' : 's',
      );
    } else if (difference.inMinutes > 0) {
      return l10n.timeAgoMinutes(
        difference.inMinutes,
        difference.inMinutes == 1 ? '' : 's',
      );
    } else {
      return l10n.justNow;
    }
  }
}
