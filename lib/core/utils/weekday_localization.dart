import 'package:edulift/generated/l10n/app_localizations.dart';

/// Converts an English weekday name to a localized weekday name
/// using the provided AppLocalizations instance.
///
/// This utility function is used across the application to provide
/// consistent localized weekday names in the user's language.
///
/// **Parameters:**
/// - [dayKey]: The English weekday name (e.g., "Monday", "Tuesday")
/// - [l10n]: The AppLocalizations instance for the current locale
///
/// **Returns:**
/// The localized weekday name, or the original [dayKey] if not recognized
///
/// **Example:**
/// ```dart
/// final l10n = AppLocalizations.of(context);
/// final dayName = getLocalizedDayName('Monday', l10n); // Returns "Lundi" in French
/// final unknownDay = getLocalizedDayName('InvalidDay', l10n); // Returns "InvalidDay"
/// ```
String getLocalizedDayName(String dayKey, AppLocalizations l10n) {
  switch (dayKey) {
    case 'Monday':
      return l10n.monday;
    case 'Tuesday':
      return l10n.tuesday;
    case 'Wednesday':
      return l10n.wednesday;
    case 'Thursday':
      return l10n.thursday;
    case 'Friday':
      return l10n.friday;
    case 'Saturday':
      return l10n.saturday;
    case 'Sunday':
      return l10n.sunday;
    default:
      return dayKey; // Fallback to original if not recognized
  }
}

/// Returns a list of localized full weekday names starting with Monday.
///
/// This utility function provides a consistent way to get all weekday names
/// in the user's language, maintaining the standard Monday-Sunday order.
///
/// **Parameters:**
/// - [l10n]: The AppLocalizations instance for the current locale
///
/// **Returns:**
/// A list of 7 localized weekday names in order: Monday through Sunday
///
/// **Example:**
/// ```dart
/// final l10n = AppLocalizations.of(context);
/// final days = getLocalizedWeekdayLabels(l10n);
/// // Returns: ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'] in French
/// // Returns: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'] in English
/// ```
List<String> getLocalizedWeekdayLabels(AppLocalizations l10n) {
  return [
    l10n.monday,
    l10n.tuesday,
    l10n.wednesday,
    l10n.thursday,
    l10n.friday,
    l10n.saturday,
    l10n.sunday,
  ];
}

/// Returns a list of localized short weekday names starting with Monday.
///
/// This utility function provides a consistent way to get abbreviated weekday names
/// in the user's language, maintaining the standard Monday-Sunday order.
/// Useful for compact UI elements like calendar headers or day selectors.
///
/// **Parameters:**
/// - [l10n]: The AppLocalizations instance for the current locale
///
/// **Returns:**
/// A list of 7 localized short weekday names in order: Monday through Sunday
///
/// **Example:**
/// ```dart
/// final l10n = AppLocalizations.of(context);
/// final shortDays = getLocalizedWeekdayShortLabels(l10n);
/// // Returns: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'] in French
/// // Returns: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'] in English
/// ```
List<String> getLocalizedWeekdayShortLabels(AppLocalizations l10n) {
  return [
    l10n.mondayShort,
    l10n.tuesdayShort,
    l10n.wednesdayShort,
    l10n.thursdayShort,
    l10n.fridayShort,
    l10n.saturdayShort,
    l10n.sundayShort,
  ];
}
