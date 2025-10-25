import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../services/providers/auth_provider.dart';
import '../../../services/timezone_service.dart';

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

  String _getLocalTime(String timezone) {
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
      return 'Unknown';
    }
  }

  Future<void> _updateTimezone(String timezone) async {
    if (_isUpdating) return;

    // Validate timezone first
    if (!_isValidTimezone(timezone)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid timezone format')),
        );
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
            content: const Text('Timezone updated successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Failed to update timezone. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Failed to update timezone. Please try again.'),
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

  Future<void> _autoDetectTimezone() async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    final messenger = ScaffoldMessenger.of(context);

    try {
      final deviceTimezone = await TimezoneService.getCurrentTimezone();
      await _updateTimezone(deviceTimezone);
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Failed to detect timezone. Please try again.'),
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

  Future<void> _toggleAutoSync(bool enabled) async {
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
          content: Text(enabled ? 'Auto-sync enabled' : 'Auto-sync disabled'),
          backgroundColor: theme.colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      // If enabled, immediately sync timezone
      if (enabled) {
        await _autoDetectTimezone();
      }
    } catch (error) {
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: const Text('Failed to update auto-sync preference'),
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

    return Card(
      key: const Key('profile_timezone_card'),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Timezone',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Current: $currentTimezone',
              key: const Key('current_timezone_display'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Local time: ${_getLocalTime(currentTimezone)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            // Search field for filtering timezones
            TextField(
              controller: _searchController,
              key: const Key('timezone_search_field'),
              enabled: !_isUpdating && !_autoSyncEnabled,
              decoration: const InputDecoration(
                hintText: 'Search timezones...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Timezone dropdown with filtered results
            DropdownButtonFormField<String>(
              key: const Key('timezone_dropdown'),
              initialValue:
                  _filteredTimezones.any((tz) => tz.iana == currentTimezone)
                      ? currentTimezone
                      : null,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                enabled: !_isUpdating && !_autoSyncEnabled,
                labelText: _filteredTimezones.isEmpty
                    ? 'No timezones found'
                    : 'Select timezone',
                helperText: _filteredTimezones.isEmpty
                    ? 'Try a different search term'
                    : '${_filteredTimezones.length} timezones available',
              ),
              items: _filteredTimezones.map((tz) {
                return DropdownMenuItem(
                  value: tz.iana,
                  child: Text(
                    tz.displayName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }).toList(),
              onChanged: (_isUpdating || _autoSyncEnabled)
                  ? null
                  : (String? value) {
                      if (value != null && value != currentTimezone) {
                        _updateTimezone(value);
                      }
                    },
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              key: const Key('auto_sync_timezone_checkbox'),
              title: const Text('Automatically sync timezone'),
              subtitle: const Text('Keep timezone synchronized with device'),
              value: _autoSyncEnabled,
              enabled: !_isUpdating,
              onChanged: _isUpdating
                  ? null
                  : (bool? value) {
                      if (value != null) {
                        _toggleAutoSync(value);
                      }
                    },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
    );
  }
}
