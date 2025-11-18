import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../../generated/l10n/app_localizations.dart';
import '../../../services/providers/auth_provider.dart';
import '../../../services/timezone_service.dart';
import '../../utils/responsive_breakpoints.dart';

/// Timezone data model for dropdown
class TimezoneData {
  final String iana;
  final String city;
  final String offset;

  const TimezoneData({
    required this.iana,
    required this.city,
    required this.offset,
  });

  String get displayName => '$city ($offset)';
}

/// Comprehensive timezone database for the application
/// Organized by region for better user experience
List<TimezoneData> getAllTimezones() {
  return [
    // Universal
    const TimezoneData(iana: 'UTC', city: 'UTC', offset: 'UTC+0'),

    // North America
    const TimezoneData(
      iana: 'America/New_York',
      city: 'New York',
      offset: 'UTC-5/-4',
    ),
    const TimezoneData(
      iana: 'America/Los_Angeles',
      city: 'Los Angeles',
      offset: 'UTC-8/-7',
    ),
    const TimezoneData(
      iana: 'America/Chicago',
      city: 'Chicago',
      offset: 'UTC-6/-5',
    ),
    const TimezoneData(
      iana: 'America/Denver',
      city: 'Denver',
      offset: 'UTC-7/-6',
    ),
    const TimezoneData(
      iana: 'America/Toronto',
      city: 'Toronto',
      offset: 'UTC-5/-4',
    ),
    const TimezoneData(
      iana: 'America/Vancouver',
      city: 'Vancouver',
      offset: 'UTC-8/-7',
    ),
    const TimezoneData(
      iana: 'America/Montreal',
      city: 'Montreal',
      offset: 'UTC-5/-4',
    ),
    const TimezoneData(
      iana: 'America/Mexico_City',
      city: 'Mexico City',
      offset: 'UTC-6/-5',
    ),
    const TimezoneData(
      iana: 'America/Phoenix',
      city: 'Phoenix',
      offset: 'UTC-7',
    ),
    const TimezoneData(
      iana: 'America/Anchorage',
      city: 'Anchorage',
      offset: 'UTC-9/-8',
    ),

    // South America
    const TimezoneData(
      iana: 'America/Sao_Paulo',
      city: 'São Paulo',
      offset: 'UTC-3',
    ),
    const TimezoneData(
      iana: 'America/Buenos_Aires',
      city: 'Buenos Aires',
      offset: 'UTC-3',
    ),
    const TimezoneData(
      iana: 'America/Santiago',
      city: 'Santiago',
      offset: 'UTC-4/-3',
    ),
    const TimezoneData(iana: 'America/Lima', city: 'Lima', offset: 'UTC-5'),
    const TimezoneData(iana: 'America/Bogota', city: 'Bogotá', offset: 'UTC-5'),
    const TimezoneData(
      iana: 'America/Caracas',
      city: 'Caracas',
      offset: 'UTC-4',
    ),

    // Europe
    const TimezoneData(
      iana: 'Europe/London',
      city: 'London',
      offset: 'UTC+0/+1',
    ),
    const TimezoneData(iana: 'Europe/Paris', city: 'Paris', offset: 'UTC+1/+2'),
    const TimezoneData(
      iana: 'Europe/Berlin',
      city: 'Berlin',
      offset: 'UTC+1/+2',
    ),
    const TimezoneData(
      iana: 'Europe/Madrid',
      city: 'Madrid',
      offset: 'UTC+1/+2',
    ),
    const TimezoneData(iana: 'Europe/Rome', city: 'Rome', offset: 'UTC+1/+2'),
    const TimezoneData(
      iana: 'Europe/Amsterdam',
      city: 'Amsterdam',
      offset: 'UTC+1/+2',
    ),
    const TimezoneData(
      iana: 'Europe/Brussels',
      city: 'Brussels',
      offset: 'UTC+1/+2',
    ),
    const TimezoneData(
      iana: 'Europe/Zurich',
      city: 'Zurich',
      offset: 'UTC+1/+2',
    ),
    const TimezoneData(
      iana: 'Europe/Vienna',
      city: 'Vienna',
      offset: 'UTC+1/+2',
    ),
    const TimezoneData(
      iana: 'Europe/Prague',
      city: 'Prague',
      offset: 'UTC+1/+2',
    ),
    const TimezoneData(
      iana: 'Europe/Warsaw',
      city: 'Warsaw',
      offset: 'UTC+1/+2',
    ),
    const TimezoneData(
      iana: 'Europe/Stockholm',
      city: 'Stockholm',
      offset: 'UTC+1/+2',
    ),
    const TimezoneData(iana: 'Europe/Oslo', city: 'Oslo', offset: 'UTC+1/+2'),
    const TimezoneData(
      iana: 'Europe/Copenhagen',
      city: 'Copenhagen',
      offset: 'UTC+1/+2',
    ),
    const TimezoneData(
      iana: 'Europe/Helsinki',
      city: 'Helsinki',
      offset: 'UTC+2/+3',
    ),
    const TimezoneData(
      iana: 'Europe/Athens',
      city: 'Athens',
      offset: 'UTC+2/+3',
    ),
    const TimezoneData(
      iana: 'Europe/Istanbul',
      city: 'Istanbul',
      offset: 'UTC+3',
    ),
    const TimezoneData(iana: 'Europe/Moscow', city: 'Moscow', offset: 'UTC+3'),
    const TimezoneData(
      iana: 'Europe/Dublin',
      city: 'Dublin',
      offset: 'UTC+0/+1',
    ),
    const TimezoneData(
      iana: 'Europe/Lisbon',
      city: 'Lisbon',
      offset: 'UTC+0/+1',
    ),
    const TimezoneData(
      iana: 'Europe/Budapest',
      city: 'Budapest',
      offset: 'UTC+1/+2',
    ),

    // Asia
    const TimezoneData(iana: 'Asia/Dubai', city: 'Dubai', offset: 'UTC+4'),
    const TimezoneData(
      iana: 'Asia/Kolkata',
      city: 'Mumbai (Kolkata)',
      offset: 'UTC+5:30',
    ),
    const TimezoneData(
      iana: 'Asia/Shanghai',
      city: 'Shanghai',
      offset: 'UTC+8',
    ),
    const TimezoneData(
      iana: 'Asia/Hong_Kong',
      city: 'Hong Kong',
      offset: 'UTC+8',
    ),
    const TimezoneData(iana: 'Asia/Tokyo', city: 'Tokyo', offset: 'UTC+9'),
    const TimezoneData(iana: 'Asia/Seoul', city: 'Seoul', offset: 'UTC+9'),
    const TimezoneData(
      iana: 'Asia/Singapore',
      city: 'Singapore',
      offset: 'UTC+8',
    ),
    const TimezoneData(iana: 'Asia/Bangkok', city: 'Bangkok', offset: 'UTC+7'),
    const TimezoneData(iana: 'Asia/Jakarta', city: 'Jakarta', offset: 'UTC+7'),
    const TimezoneData(iana: 'Asia/Manila', city: 'Manila', offset: 'UTC+8'),
    const TimezoneData(
      iana: 'Asia/Kuala_Lumpur',
      city: 'Kuala Lumpur',
      offset: 'UTC+8',
    ),
    const TimezoneData(iana: 'Asia/Taipei', city: 'Taipei', offset: 'UTC+8'),
    // Beijing timezone is handled by Shanghai
    const TimezoneData(
      iana: 'Asia/Ho_Chi_Minh',
      city: 'Ho Chi Minh City',
      offset: 'UTC+7',
    ),

    // Australia & Pacific
    const TimezoneData(
      iana: 'Australia/Sydney',
      city: 'Sydney',
      offset: 'UTC+10/+11',
    ),
    const TimezoneData(
      iana: 'Australia/Melbourne',
      city: 'Melbourne',
      offset: 'UTC+10/+11',
    ),
    const TimezoneData(
      iana: 'Australia/Brisbane',
      city: 'Brisbane',
      offset: 'UTC+10',
    ),
    const TimezoneData(iana: 'Australia/Perth', city: 'Perth', offset: 'UTC+8'),
    const TimezoneData(
      iana: 'Australia/Adelaide',
      city: 'Adelaide',
      offset: 'UTC+9:30/+10:30',
    ),
    const TimezoneData(
      iana: 'Australia/Darwin',
      city: 'Darwin',
      offset: 'UTC+9:30',
    ),
    const TimezoneData(
      iana: 'Pacific/Auckland',
      city: 'Auckland',
      offset: 'UTC+12/+13',
    ),
    const TimezoneData(
      iana: 'Pacific/Fiji',
      city: 'Fiji',
      offset: 'UTC+12/+13',
    ),
    const TimezoneData(iana: 'Pacific/Guam', city: 'Guam', offset: 'UTC+10'),

    // Africa
    const TimezoneData(iana: 'Africa/Cairo', city: 'Cairo', offset: 'UTC+2'),
    const TimezoneData(
      iana: 'Africa/Johannesburg',
      city: 'Johannesburg (Cape Town)',
      offset: 'UTC+2',
    ),
    const TimezoneData(iana: 'Africa/Lagos', city: 'Lagos', offset: 'UTC+1'),
    const TimezoneData(
      iana: 'Africa/Casablanca',
      city: 'Casablanca',
      offset: 'UTC+0/+1',
    ),
    const TimezoneData(
      iana: 'Africa/Nairobi',
      city: 'Nairobi',
      offset: 'UTC+3',
    ),

    // Middle East
    const TimezoneData(
      iana: 'Asia/Tel_Aviv',
      city: 'Tel Aviv',
      offset: 'UTC+2/+3',
    ),
    const TimezoneData(
      iana: 'Asia/Jerusalem',
      city: 'Jerusalem',
      offset: 'UTC+2/+3',
    ),
    const TimezoneData(iana: 'Asia/Riyadh', city: 'Riyadh', offset: 'UTC+3'),
    const TimezoneData(iana: 'Asia/Kuwait', city: 'Kuwait', offset: 'UTC+3'),
    const TimezoneData(
      iana: 'Asia/Tehran',
      city: 'Tehran',
      offset: 'UTC+3:30/+4:30',
    ),

    // Additional important timezones
    const TimezoneData(iana: 'Asia/Karachi', city: 'Karachi', offset: 'UTC+5'),
    const TimezoneData(iana: 'Asia/Dhaka', city: 'Dhaka', offset: 'UTC+6'),
    const TimezoneData(
      iana: 'Asia/Colombo',
      city: 'Colombo',
      offset: 'UTC+5:30',
    ),
    const TimezoneData(
      iana: 'Atlantic/Reykjavik',
      city: 'Reykjavik',
      offset: 'UTC+0',
    ),
    const TimezoneData(
      iana: 'America/Barbados',
      city: 'Barbados',
      offset: 'UTC-4',
    ),
    const TimezoneData(
      iana: 'Atlantic/Bermuda',
      city: 'Bermuda',
      offset: 'UTC-4/-3',
    ),
    const TimezoneData(
      iana: 'America/Cayman',
      city: 'Cayman Islands',
      offset: 'UTC-5',
    ),
    const TimezoneData(iana: 'America/Aruba', city: 'Aruba', offset: 'UTC-4'),
    const TimezoneData(
      iana: 'Pacific/Honolulu',
      city: 'Honolulu',
      offset: 'UTC-10',
    ),
  ];
}

/// Widget allowing user to select and change their timezone
class TimezoneSelector extends ConsumerStatefulWidget {
  const TimezoneSelector({super.key});

  @override
  ConsumerState<TimezoneSelector> createState() => _TimezoneSelectorState();
}

class _TimezoneSelectorState extends ConsumerState<TimezoneSelector> {
  bool _isUpdating = false;
  bool _autoSyncEnabled = false;
  static const String _autoSyncKey = 'autoSyncTimezone';
  List<TimezoneData> _allTimezones = [];
  List<TimezoneData> _filteredTimezones = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _allTimezones = getAllTimezones();
    _filteredTimezones = _allTimezones;
    _loadAutoSyncPreference();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredTimezones = _allTimezones;
      } else {
        _filteredTimezones = _allTimezones.where((tz) {
          return tz.city.toLowerCase().contains(query) ||
              tz.iana.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _loadAutoSyncPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if user has previously set the preference
      final hasSetPreference = prefs.containsKey(_autoSyncKey);

      bool autoSync;
      if (hasSetPreference) {
        // User has explicitly chosen a setting - respect it
        autoSync = prefs.getBool(_autoSyncKey)!;
      } else {
        // First time - enable auto-sync by default for better UX
        autoSync = true;
        // Save the default so we track that it's been initialized
        await prefs.setBool(_autoSyncKey, true);

        // NOTE: Do NOT sync timezone here! The bootstrap.dart already handles
        // initial timezone sync during app startup. Calling _autoDetectTimezone()
        // here would set _isUpdating = true and leave the checkbox greyed out
        // while the async operation completes. This creates a poor UX where the
        // checkbox appears disabled on first launch.
      }

      if (mounted) {
        setState(() {
          _autoSyncEnabled = autoSync;
        });
      }
    } catch (e) {
      // On error, default to false and log
      debugPrint('Error loading auto-sync preference: $e');
      if (mounted) {
        setState(() {
          _autoSyncEnabled = false;
        });
      }
    }
  }

  bool _isValidTimezone(String timezone) {
    try {
      tz.getLocation(timezone);
      return true;
    } catch (e) {
      return false;
    }
  }

  String _getLocalTime(String timezone, AppLocalizations l10n) {
    try {
      final location = tz.getLocation(timezone);
      final now = tz.TZDateTime.now(location);
      final formatter = DateFormat('HH:mm');
      final offset = now.timeZoneOffset;
      final offsetHours = offset.inHours;
      final offsetMinutes = offset.inMinutes.remainder(60);
      final offsetString = offsetHours >= 0
          ? 'UTC+$offsetHours${offsetMinutes > 0 ? ':${offsetMinutes.toString().padLeft(2, '0')}' : ''}'
          : 'UTC$offsetHours${offsetMinutes > 0 ? ':${offsetMinutes.toString().padLeft(2, '0')}' : ''}';
      return '${formatter.format(now)} ($offsetString)';
    } catch (e) {
      return l10n.unknownTimezone;
    }
  }

  Future<void> _updateTimezone(String timezone, AppLocalizations l10n) async {
    if (_isUpdating) return;

    // Validate timezone first
    if (!_isValidTimezone(timezone)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.invalidTimezoneFormat)));
      }
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    final messenger = ScaffoldMessenger.of(context);

    try {
      final authService = ref.read(authStateProvider.notifier).authService;
      final result = await authService.updateUserTimezone(timezone);

      if (!mounted) return;

      if (result.isOk) {
        final updatedUser = result.value!;
        // Use login() to update the user state in authStateProvider
        ref.read(authStateProvider.notifier).login(updatedUser);

        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.timezoneUpdatedSuccessfully),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.failedToUpdateTimezone),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.failedToUpdateTimezone),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _autoDetectTimezone(AppLocalizations l10n) async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    final messenger = ScaffoldMessenger.of(context);

    try {
      final deviceTimezone = await TimezoneService.getCurrentTimezone();
      await _updateTimezone(deviceTimezone, l10n);
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.failedToDetectTimezone),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _toggleAutoSync(bool enabled, AppLocalizations l10n) async {
    if (_isUpdating) return; // Prevent concurrent calls

    setState(() {
      _isUpdating = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoSyncKey, enabled);

      if (!mounted) return;

      setState(() {
        _autoSyncEnabled = enabled;
      });

      // Show feedback for preference change
      messenger.showSnackBar(
        SnackBar(
          content: Text(enabled ? l10n.autoSyncEnabled : l10n.autoSyncDisabled),
          backgroundColor: theme.colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      // If enabled, immediately sync timezone
      if (enabled) {
        await _autoDetectTimezone(l10n);
      }
    } catch (error) {
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.failedToUpdateAutoSyncPreference),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final currentTimezone = currentUser?.timezone ?? 'UTC';
    final l10n = AppLocalizations.of(context);

    return Card(
      key: const Key('profile_timezone_card'),
      margin: context.getAdaptivePadding(
        mobileHorizontal: 16,
        tabletHorizontal: 20,
        desktopHorizontal: 24,
        mobileVertical: 8,
        tabletVertical: 10,
        desktopVertical: 12,
      ),
      elevation: 3.0, // Standard elevation for cards
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          context.getAdaptiveBorderRadius(mobile: 12, tablet: 14, desktop: 16),
        ),
      ),
      child: Padding(
        padding: context.getAdaptivePadding(
          mobileAll: 16,
          tabletAll: 20,
          desktopAll: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Theme.of(context).colorScheme.primary,
                  size: context.getAdaptiveIconSize(
                    mobile: 20,
                    tablet: 24,
                    desktop: 28,
                  ),
                ),
                SizedBox(
                  width: context.getAdaptiveSpacing(
                    mobile: 8,
                    tablet: 10,
                    desktop: 12,
                  ),
                ),
                Text(
                  'Timezone',
                  style: context.isDesktop
                      ? Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        )
                      : context.isTablet
                      ? Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        )
                      : Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                ),
              ],
            ),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
            Text(
              l10n.currentTimezone(currentTimezone),
              key: const Key('current_timezone_display'),
              style: context.isDesktop
                  ? Theme.of(context).textTheme.bodyLarge
                  : context.isTablet
                  ? Theme.of(context).textTheme.bodyLarge
                  : Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 4,
                tablet: 6,
                desktop: 8,
              ),
            ),
            Text(
              l10n.localTime(_getLocalTime(currentTimezone, l10n)),
              style: context.isDesktop
                  ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )
                  : context.isTablet
                  ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )
                  : Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
            ),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
            // Search field for filtering timezones
            SizedBox(
              height: context.getAdaptiveButtonHeight(
                mobile: 48,
                tablet: 52,
                desktop: 56,
              ),
              child: TextField(
                controller: _searchController,
                key: const Key('timezone_search_field'),
                enabled: !_isUpdating && !_autoSyncEnabled,
                decoration: InputDecoration(
                  hintText: l10n.searchTimezones,
                  prefixIcon: Icon(
                    Icons.search,
                    size: context.getAdaptiveIconSize(
                      mobile: 20,
                      tablet: 22,
                      desktop: 24,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      context.getAdaptiveBorderRadius(
                        mobile: 8,
                        tablet: 10,
                        desktop: 12,
                      ),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      context.getAdaptiveBorderRadius(
                        mobile: 8,
                        tablet: 10,
                        desktop: 12,
                      ),
                    ),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      context.getAdaptiveBorderRadius(
                        mobile: 8,
                        tablet: 10,
                        desktop: 12,
                      ),
                    ),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: context.getAdaptivePadding(
                    mobileHorizontal: 12,
                    tabletHorizontal: 16,
                    desktopHorizontal: 20,
                    mobileVertical: 12,
                    tabletVertical: 16,
                    desktopVertical: 20,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
            ),
            // Timezone dropdown with filtered results
            SizedBox(
              height: context.getAdaptiveButtonHeight(
                mobile: 56,
                tablet: 60,
                desktop: 64,
              ),
              child: DropdownButtonFormField<String>(
                key: const Key('timezone_dropdown'),
                initialValue:
                    _filteredTimezones.any((tz) => tz.iana == currentTimezone)
                    ? currentTimezone
                    : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      context.getAdaptiveBorderRadius(
                        mobile: 8,
                        tablet: 10,
                        desktop: 12,
                      ),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      context.getAdaptiveBorderRadius(
                        mobile: 8,
                        tablet: 10,
                        desktop: 12,
                      ),
                    ),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      context.getAdaptiveBorderRadius(
                        mobile: 8,
                        tablet: 10,
                        desktop: 12,
                      ),
                    ),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      context.getAdaptiveBorderRadius(
                        mobile: 8,
                        tablet: 10,
                        desktop: 12,
                      ),
                    ),
                    borderSide: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.12),
                    ),
                  ),
                  contentPadding: context.getAdaptivePadding(
                    mobileHorizontal: 12,
                    tabletHorizontal: 16,
                    desktopHorizontal: 20,
                    mobileVertical: 8,
                    tabletVertical: 12,
                    desktopVertical: 16,
                  ),
                  enabled: !_isUpdating && !_autoSyncEnabled,
                  labelText: _filteredTimezones.isEmpty
                      ? l10n.noTimezonesFound
                      : l10n.selectTimezone,
                  helperText: _filteredTimezones.isEmpty
                      ? l10n.tryDifferentSearchTerm
                      : l10n.timezonesAvailable(_filteredTimezones.length),
                  hintStyle: context.isDesktop
                      ? Theme.of(context).textTheme.bodyMedium
                      : context.isTablet
                      ? Theme.of(context).textTheme.bodyMedium
                      : Theme.of(context).textTheme.bodySmall,
                ),
                items: _filteredTimezones.map((tz) {
                  return DropdownMenuItem(
                    value: tz.iana,
                    child: Text(
                      tz.displayName,
                      style: context.isDesktop
                          ? Theme.of(context).textTheme.bodyLarge
                          : context.isTablet
                          ? Theme.of(context).textTheme.bodyLarge
                          : Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (_isUpdating || _autoSyncEnabled)
                    ? null
                    : (String? value) {
                        if (value != null && value != currentTimezone) {
                          _updateTimezone(value, l10n);
                        }
                      },
                isExpanded: true, // Allow text to wrap on smaller screens
                dropdownColor: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(
                  context.getAdaptiveBorderRadius(
                    mobile: 8,
                    tablet: 10,
                    desktop: 12,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
            ),
            CheckboxListTile(
              key: const Key('auto_sync_timezone_checkbox'),
              title: Text(
                l10n.automaticallySyncTimezone,
                style: context.isDesktop
                    ? Theme.of(context).textTheme.bodyLarge
                    : context.isTablet
                    ? Theme.of(context).textTheme.bodyLarge
                    : Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: Text(
                l10n.keepTimezoneSyncedWithDevice,
                style: context.isDesktop
                    ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      )
                    : context.isTablet
                    ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      )
                    : Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
              ),
              value: _autoSyncEnabled,
              enabled: !_isUpdating,
              onChanged: _isUpdating
                  ? null
                  : (bool? value) {
                      if (value != null) {
                        _toggleAutoSync(value, l10n);
                      }
                    },
              contentPadding: context.getAdaptivePadding(
                mobileHorizontal: 0,
                tabletHorizontal: 4,
                desktopHorizontal: 8,
                mobileVertical: 4,
                tabletVertical: 6,
                desktopVertical: 8,
              ),
              controlAffinity: ListTileControlAffinity.leading,
              dense: context.isMobile,
            ),
          ],
        ),
      ),
    );
  }
}
