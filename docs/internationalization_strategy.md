# Internationalization Strategy and Implementation Guidelines

This document outlines the comprehensive strategy for implementing internationalization (i18n) in the mobile application, including key creation conventions, technical implementation guidelines, and best practices.

## 1. Overall Strategy

### 1.1 Objectives
- Support multiple languages (starting with English and French)
- Maintain a consistent user experience across all supported languages
- Ensure all user-facing strings are externalized
- Implement proper pluralization and formatting for different locales
- Establish a scalable system for future language additions

### 1.2 Scope
- All user-facing text strings in the application
- Error messages and system notifications
- UI labels, buttons, and navigation elements
- Help text and descriptive content
- Date, time, and number formatting

### 1.3 Target Languages
- Primary: English (en)
- Secondary: French (fr)
- Future expansion: Spanish (es), German (de)

## 2. Technical Implementation

### 2.1 ARB File Structure
The application will use ARB (Application Resource Bundle) files for managing translations, following the existing structure in `lib/l10n/`.

**File Naming Convention:**
- `app_en.arb` - English base translations
- `app_fr.arb` - French translations
- `app_es.arb` - Spanish translations (future)

### 2.2 Key Creation Conventions

#### 2.2.1 General Structure
```
{featureArea}_{component}_{element}_{variant}
```

#### 2.2.2 Feature Area Identifiers
- `auth` - Authentication and login
- `family` - Family management
- `schedule` - Schedule coordination
- `groups` - Group functionality
- `vehicle` - Vehicle management
- `child` - Child management
- `invitation` - Invitation system
- `dashboard` - Main dashboard
- `settings` - User settings
- `error` - Error handling
- `common` - Shared/common elements

#### 2.2.3 Component Types
- `screen` - Page/screen titles
- `button` - Action buttons
- `label` - Form labels and UI text
- `dialog` - Modal dialogs
- `toast` - Toast notifications
- `tooltip` - Tooltip text
- `error` - Error messages
- `success` - Success messages
- `warning` - Warning messages
- `placeholder` - Placeholder text

#### 2.2.4 Element Descriptors
- Use descriptive, context-specific names
- Avoid abbreviations unless widely understood
- Use camelCase for multi-word descriptors

#### 2.2.5 Variant Indicators
- `title` - Titles and headings
- `message` - Body content
- `action` - Action labels
- `hint` - Hint or helper text
- `confirmation` - Confirmation messages
- `validation` - Validation messages

### 2.3 Key Naming Examples

#### 2.3.1 Authentication
```json
{
  "auth_loginScreenTitle": "Log In",
  "auth_loginButtonAction": "Log In",
  "auth_loginFailedErrorMessage": "Login failed: {error}",
  "auth_biometricFailedErrorMessage": "Biometric authentication failed: {error}",
  "auth_logoutConfirmationTitle": "Confirm Logout",
  "auth_logoutConfirmationMessage": "Are you sure you want to logout?",
  "auth_logoutButtonAction": "Logout"
}
```

#### 2.3.2 Family Management
```json
{
  "family_createScreenTitle": "Create Your Family",
  "family_createButtonAction": "Create Family",
  "family_createProgressMessage": "Creating...",
  "family_inviteMemberTitle": "Family Member",
  "family_inviteSendButtonAction": "Send Invitation",
  "family_inviteSuccessMessage": "Invitation sent to {email}",
  "family_inviteFailedErrorMessage": "Failed to send invitation: {error}",
  "family_removeMemberTitle": "Remove Member",
  "family_removeMemberConfirmationMessage": "Remove {name} from this family?",
  "family_removeMemberButtonAction": "Remove Member",
  "family_removeMemberSuccessMessage": "{name} removed from family",
  "family_removeMemberFailedErrorMessage": "Failed to remove member: {error}"
}
```

#### 2.3.3 Schedule Management
```json
{
  "schedule_coordinationScreenTitle": "Schedule Coordination",
  "schedule_viewDayAction": "Day",
  "schedule_viewWeekAction": "Week",
  "schedule_viewMonthAction": "Month",
  "schedule_refreshSuccessMessage": "Schedule refreshed",
  "schedule_addEventAction": "Add Event",
  "schedule_conflictTitle": "Conflict Resolution",
  "schedule_filterTitle": "Filter Options",
  "schedule_loadingMessage": "Loading schedule...",
  "schedule_createSlotAction": "Create Slot",
  "schedule_loadErrorTitle": "Loading Error",
  "schedule_retryAction": "Try Again"
}
```

### 2.4 ICU Message Syntax

#### 2.4.1 Pluralization
```json
{
  "common_memberCountMessage": "{count, plural, =0{No members} one{1 member} other{{count} members}}",
  "common_vehicleCountMessage": "{count, plural, =0{No vehicles} one{1 vehicle} other{{count} vehicles}}",
  "common_childCountMessage": "{count, plural, =0{No children} one{1 child} other{{count} children}}"
}
```

#### 2.4.2 Parameter Substitution
```json
{
  "invitation_sentSuccessMessage": "Invitation sent to {email}",
  "family_removeMemberConfirmationMessage": "Remove {name} from this family?",
  "vehicle_addedSuccessMessage": "{vehicleName} added successfully"
}
```

#### 2.4.3 Gender and Select
```json
{
  "common_roleDisplayName": "{gender, select, male{Father} female{Mother} other{Parent}}"
}
```

### 2.5 Technical Implementation Guidelines

#### 2.5.1 Using AppLocalizations
```dart
// Basic usage
Text(AppLocalizations.of(context)!.auth_loginButtonAction)

// With parameters
Text(AppLocalizations.of(context)!.invitation_sentSuccessMessage(email: userEmail))

// With plurals
Text(AppLocalizations.of(context)!.common_memberCountMessage(count: memberCount))
```

#### 2.5.2 Handling Rich Text
For strings that require rich text formatting, use parameterized messages:
```json
{
  "auth_termsAgreementMessage": "I agree to the {termsLink} and {privacyLink}",
  "auth_termsLinkText": "Terms of Service",
  "auth_privacyLinkText": "Privacy Policy"
}
```

#### 2.5.3 Date and Number Formatting
Use Flutter's built-in formatting for dates and numbers:
```dart
// Date formatting
DateFormat.yMMMMd(Localizations.localeOf(context).languageCode).format(date)

// Number formatting
NumberFormat.decimalPattern(Localizations.localeOf(context).languageCode).format(number)
```

## 3. Implementation Process

### 3.1 String Externalization Workflow

1. **Identification**: Use the `clean_detector.dart` tool to identify hardcoded strings
2. **Categorization**: Classify strings by feature area and priority
3. **Key Creation**: Generate appropriate ARB keys following naming conventions
4. **Translation**: Add translations to respective ARB files
5. **Implementation**: Replace hardcoded strings with `AppLocalizations` calls
6. **Testing**: Verify translations and formatting in all supported languages

### 3.2 Code Migration Process

#### 3.2.1 Before Migration
```dart
Text("Log In")
```

#### 3.2.2 After Migration
```dart
Text(AppLocalizations.of(context)!.auth_loginButtonAction)
```

#### 3.2.3 With Parameters
```dart
// Before
Text("Invitation sent to $email")

// After
Text(AppLocalizations.of(context)!.invitation_sentSuccessMessage(email: email))
```

### 3.3 Quality Assurance

#### 3.3.1 Automated Checks
- Run `clean_detector.dart` regularly to identify new hardcoded strings
- Validate ARB files for syntax and completeness
- Check for missing translations across language files

#### 3.3.2 Manual Testing
- Test all screens in all supported languages
- Verify proper text wrapping and layout adjustments
- Check pluralization and parameter substitution
- Validate date, time, and number formatting

## 4. Maintenance and Updates

### 4.1 Adding New Languages
1. Create new ARB file with base language content
2. Send to translation service or translators
3. Add language to supported locales list
4. Test thoroughly in the new language

### 4.2 Updating Existing Translations
1. Identify strings requiring updates
2. Modify ARB files for all supported languages
3. Review changes with translators if needed
4. Test updated strings in context

### 4.3 Deprecating Strings
1. Mark deprecated strings in ARB files with comments
2. Remove usage from codebase
3. Remove strings after confirmation of non-usage

## 5. Best Practices

### 5.1 String Management
- Keep strings concise but clear
- Avoid concatenating translated strings
- Use complete sentences for better translation quality
- Include context comments in ARB files for translators

### 5.2 Translation Considerations
- Account for text expansion/contraction in different languages
- Consider right-to-left language support (future)
- Be culturally sensitive in string content
- Use gender-neutral language where possible

### 5.3 Performance
- Cache localized strings where appropriate
- Minimize repeated localization lookups
- Use const strings for non-localized content

## 6. Tools and Validation

### 6.1 Audit Tools
- `clean_detector.dart` - Identifies hardcoded strings
- ARB validator - Checks syntax and completeness
- Cross-language checker - Ensures consistency

### 6.2 Validation Process
1. Weekly automated scans for hardcoded strings
2. Monthly translation quality reviews
3. Quarterly comprehensive i18n audits
4. Continuous integration checks for i18n compliance

This strategy provides a comprehensive framework for implementing and maintaining internationalization in the application while ensuring scalability and maintainability.