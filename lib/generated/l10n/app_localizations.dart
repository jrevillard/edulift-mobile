import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// About menu label
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Accept invitation button text
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// Accepted status label
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// Accepted invitations label in stats
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get acceptedInvitations;

  /// Warning that leaving family cannot be reversed
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get actionCannotBeUndone;

  /// Action step for checking internet connection
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection'**
  String get actionCheckConnection;

  /// Action step for checking email for authentication link
  ///
  /// In en, this message translates to:
  /// **'Check your email for a new login link'**
  String get actionCheckEmail;

  /// Action step for completing required form fields
  ///
  /// In en, this message translates to:
  /// **'Make sure all required fields are filled'**
  String get actionFillRequired;

  /// Action step for restarting the application
  ///
  /// In en, this message translates to:
  /// **'Restart the app if the problem continues'**
  String get actionRestartApp;

  /// Action step for reviewing input information
  ///
  /// In en, this message translates to:
  /// **'Review the information you entered'**
  String get actionReviewInfo;

  /// Action step for re-authenticating
  ///
  /// In en, this message translates to:
  /// **'Sign out and sign in again'**
  String get actionSignOutSignIn;

  /// Action step for switching network connection
  ///
  /// In en, this message translates to:
  /// **'Switch to mobile data if using WiFi'**
  String get actionSwitchNetwork;

  /// Action step for retrying an operation
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionTryAgain;

  /// Active status text
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Active days label
  ///
  /// In en, this message translates to:
  /// **'Active Days'**
  String get activeDays;

  /// Label for active seat override
  ///
  /// In en, this message translates to:
  /// **'Active Override'**
  String get activeOverride;

  /// Add button text for floating action button
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Add child button text
  ///
  /// In en, this message translates to:
  /// **'Add child'**
  String get addChild;

  /// Button to add event
  ///
  /// In en, this message translates to:
  /// **'Add Event'**
  String get addEvent;

  /// First time slot button
  ///
  /// In en, this message translates to:
  /// **'Add First Time Slot'**
  String get addFirstTimeSlot;

  /// Message when no vehicles exist
  ///
  /// In en, this message translates to:
  /// **'Add your first vehicle to start\\norganizing trips.'**
  String get addFirstVehicle;

  /// Manage vehicles description
  ///
  /// In en, this message translates to:
  /// **'Add or remove vehicles'**
  String get addOrRemoveVehicles;

  /// Button text to add seat override
  ///
  /// In en, this message translates to:
  /// **'Add Override'**
  String get addOverride;

  /// Add slot button
  ///
  /// In en, this message translates to:
  /// **'Add Slot'**
  String get addSlot;

  /// Dialog title for adding time slot
  ///
  /// In en, this message translates to:
  /// **'Add Time Slot'**
  String get addTimeSlot;

  /// Time slots help text
  ///
  /// In en, this message translates to:
  /// **'Add time slots to define when vehicles can be scheduled'**
  String get addTimeSlotsDescription;

  /// Add vehicle page title
  ///
  /// In en, this message translates to:
  /// **'Add vehicle'**
  String get addVehicle;

  /// Add vehicle page title
  ///
  /// In en, this message translates to:
  /// **'Add Vehicle'**
  String get addVehicleTitle;

  /// Add vehicle to schedule slot button
  ///
  /// In en, this message translates to:
  /// **'Add Vehicle'**
  String get addVehicleToSlot;

  /// Message when no vehicles exist for scheduling
  ///
  /// In en, this message translates to:
  /// **'Add vehicles to your family to start scheduling'**
  String get addVehiclesToFamilyToStartScheduling;

  /// Hint text for additional notes
  ///
  /// In en, this message translates to:
  /// **'Any additional information...'**
  String get additionalInformation;

  /// Placeholder for navigation options
  ///
  /// In en, this message translates to:
  /// **'Additional navigation options would appear here'**
  String get additionalNavigationOptions;

  /// Label for additional notes input
  ///
  /// In en, this message translates to:
  /// **'Additional Notes (Optional)'**
  String get additionalNotesOptional;

  /// No description provided for @adjustCapacity.
  ///
  /// In en, this message translates to:
  /// **'Adjust Capacity'**
  String get adjustCapacity;

  /// No description provided for @adjustedCapacity.
  ///
  /// In en, this message translates to:
  /// **'Adjusted Capacity'**
  String get adjustedCapacity;

  /// No description provided for @adjustmentReason.
  ///
  /// In en, this message translates to:
  /// **'Reason for adjustment (optional)'**
  String get adjustmentReason;

  /// No description provided for @adjustmentReasonHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., car seat, maintenance'**
  String get adjustmentReasonHint;

  /// Description of admin role permissions
  ///
  /// In en, this message translates to:
  /// **'Admin can manage family members'**
  String get adminCanManageMembers;

  /// Administrator role label
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get administrator;

  /// Afternoon time slot
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// Age display format
  ///
  /// In en, this message translates to:
  /// **'Age: {years} years'**
  String age(int years);

  /// Filter option to show all items
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// All days selection option
  ///
  /// In en, this message translates to:
  /// **'All Days'**
  String get allDays;

  /// All days option subtitle
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get allDaysSubtitle;

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'EduLift'**
  String get appName;

  /// Application version
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get appVersion;

  /// No description provided for @applyChanges.
  ///
  /// In en, this message translates to:
  /// **'Apply Changes'**
  String get applyChanges;

  /// Assign children button text with ICU pluralization
  ///
  /// In en, this message translates to:
  /// **'Assign {count, plural, =1{{count} Child} other{{count} Children}}'**
  String assignChildrenButton(num count);

  /// Manage children description
  ///
  /// In en, this message translates to:
  /// **'Assign children to vehicles'**
  String get assignChildrenToVehicles;

  /// Option to assign new admin before switching
  ///
  /// In en, this message translates to:
  /// **'Assign New Admin and Switch'**
  String get assignNewAdminAndSwitch;

  /// Description for assigning new admin
  ///
  /// In en, this message translates to:
  /// **'Promote another member to admin, then join the new family'**
  String get assignNewAdminDesc;

  /// Add vehicle to slot description
  ///
  /// In en, this message translates to:
  /// **'Assign a vehicle to this time slot'**
  String get assignVehicleToSlot;

  /// No description provided for @assignedChildren.
  ///
  /// In en, this message translates to:
  /// **'Assigned Child'**
  String get assignedChildren;

  /// Section header for available options
  ///
  /// In en, this message translates to:
  /// **'Available Options'**
  String get availableOptions;

  /// Label for available seat count
  ///
  /// In en, this message translates to:
  /// **'Available seats'**
  String get availableSeats;

  /// Button text to return to home page
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backToHome;

  /// Button text to go back to login page
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get backToLogin;

  /// Section title for basic info
  ///
  /// In en, this message translates to:
  /// **'Basic information'**
  String get basicInformation;

  /// Biometric authentication button text
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication'**
  String get biometricAuthentication;

  /// Introduction to list of consequences of leaving family
  ///
  /// In en, this message translates to:
  /// **'By leaving this family, you will:'**
  String get byLeavingFamilyYouWill;

  /// Generic cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Action to cancel a pending invitation
  ///
  /// In en, this message translates to:
  /// **'Cancel Invitation'**
  String get cancelInvitation;

  /// Explanation message for cancelling invitation
  ///
  /// In en, this message translates to:
  /// **'They will no longer be able to join your family using this invitation.'**
  String get cancelInvitationMessage;

  /// Title for cancel invitation dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel Invitation'**
  String get cancelInvitationTitle;

  /// Cancelled status label
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// Generic capacity field label
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacity;

  /// No description provided for @capacityAdjustmentHint.
  ///
  /// In en, this message translates to:
  /// **'Temporarily adjust the number of available seats.'**
  String get capacityAdjustmentHint;

  /// Error when capacity and reason are not provided
  ///
  /// In en, this message translates to:
  /// **'Capacity and reason are required'**
  String get capacityAndReasonRequired;

  /// Warning when capacity is exceeded
  ///
  /// In en, this message translates to:
  /// **'Capacity exceeded by {count}'**
  String capacityExceeded(int count);

  /// Help text explaining how to count vehicle capacity
  ///
  /// In en, this message translates to:
  /// **'Include the driver seat in the total count'**
  String get capacityHelpText;

  /// Section header for capacity information
  ///
  /// In en, this message translates to:
  /// **'Capacity Information'**
  String get capacityInformation;

  /// Car vehicle type
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get car;

  /// Message for non-admins when no invitations
  ///
  /// In en, this message translates to:
  /// **'Check back later for new invitations'**
  String get checkBackLater;

  /// Main title on magic link page
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkYourEmail;

  /// Loading message when checking user status
  ///
  /// In en, this message translates to:
  /// **'Checking user...'**
  String get checkingUser;

  /// Success message after adding child
  ///
  /// In en, this message translates to:
  /// **'Child \"{childName}\" added successfully'**
  String childAddedSuccessfully(String childName);

  /// Title for child details page
  ///
  /// In en, this message translates to:
  /// **'Child Details'**
  String get childDetailsTitle;

  /// Label showing child ID
  ///
  /// In en, this message translates to:
  /// **'Child ID: {childId}'**
  String childIdLabel(String childId);

  /// Description for adding child information
  ///
  /// In en, this message translates to:
  /// **'Add your child\'s information to include them in family management.'**
  String get childInfoDescription;

  /// No description provided for @childNameHint.
  ///
  /// In en, this message translates to:
  /// **'First or last name'**
  String get childNameHint;

  /// Label for optional child age field
  ///
  /// In en, this message translates to:
  /// **'Age (optional)'**
  String get childAgeOptional;

  /// Hint text for child age input field
  ///
  /// In en, this message translates to:
  /// **'Enter age'**
  String get enterChildAge;

  /// Error message for invalid child name format
  ///
  /// In en, this message translates to:
  /// **'Name can only contain letters, spaces, hyphens, and apostrophes'**
  String get childNameInvalidCharacters;

  /// Error message when child is not found
  ///
  /// In en, this message translates to:
  /// **'Child not found'**
  String get childNotFound;

  /// Age unit in years
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// Child transport capacity with driver exclusion note and ICU pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{This vehicle cannot transport children (driver seat excluded)} =1{This vehicle can transport up to {count} child (driver seat excluded)} other{This vehicle can transport up to {count} children (driver seat excluded)}}'**
  String childTransportCapacity(int count);

  /// Success message after updating child
  ///
  /// In en, this message translates to:
  /// **'Child updated successfully'**
  String get childUpdatedSuccessfully;

  /// Children page title
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get children;

  /// Children assigned successfully with ICU pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} child assigned successfully} other{{count} children assigned successfully}}'**
  String childrenAssigned(num count);

  /// Count of children in family
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} child} other{{count} children}}'**
  String childrenCount(int count);

  /// Children selected with ICU pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} child selected} other{{count} children selected}}'**
  String childrenSelected(num count);

  /// Group selection description
  ///
  /// In en, this message translates to:
  /// **'Choose a transport group to view its weekly schedule'**
  String get chooseGroupForSchedule;

  /// Section header for resolution options
  ///
  /// In en, this message translates to:
  /// **'Choose Resolution'**
  String get chooseResolution;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// Menu item to clear filters
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Success message when code is copied
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get codeCopiedToClipboard;

  /// Message for expired codes
  ///
  /// In en, this message translates to:
  /// **'This code has expired'**
  String get codeExpired;

  /// Label for invitation code with email
  ///
  /// In en, this message translates to:
  /// **'Code for {email}:'**
  String codeForEmail(String email);

  /// Code joining type title
  ///
  /// In en, this message translates to:
  /// **'Code joining'**
  String get codeJoining;

  /// Tab label for invitation codes
  ///
  /// In en, this message translates to:
  /// **'Codes'**
  String get codes;

  /// Feature coming soon message
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// Section title for common departure times
  ///
  /// In en, this message translates to:
  /// **'Common departure times'**
  String get commonDepartureTimes;

  /// No description provided for @compact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get compact;

  /// Configuration section title
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get configuration;

  /// Button to navigate to schedule configuration (admin only)
  ///
  /// In en, this message translates to:
  /// **'Configure Schedule'**
  String get configureSchedule;

  /// Time slots configuration title
  ///
  /// In en, this message translates to:
  /// **'Configure Time Slots'**
  String get configureTimeSlots;

  /// Configure specific weekday schedule title
  ///
  /// In en, this message translates to:
  /// **'Configure {weekday} schedule'**
  String configureWeekdaySchedule(String weekday);

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Delete confirmation message prefix
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete'**
  String get confirmDelete;

  /// Logout confirmation title
  ///
  /// In en, this message translates to:
  /// **'Confirm Sign Out'**
  String get confirmLogout;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get confirmLogoutMessage;

  /// Confirmation message for vehicle deletion
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{vehicleName}\"?\n\nThis action is irreversible and will also delete\nall assignments for this vehicle.'**
  String confirmVehicleDeletion(String vehicleName);

  /// Title for conflict resolution
  ///
  /// In en, this message translates to:
  /// **'Conflict Resolution'**
  String get conflictResolution;

  /// Temporary message for upcoming feature
  ///
  /// In en, this message translates to:
  /// **'Conflict resolution feature coming soon'**
  String get conflictResolutionComingSoon;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Button text to copy invitation code
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get copyCode;

  /// Button text for account creation
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// Button to create family
  ///
  /// In en, this message translates to:
  /// **'Create Family'**
  String get createFamily;

  /// Create group button text
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get createGroup;

  /// Create new group title
  ///
  /// In en, this message translates to:
  /// **'Create New Group'**
  String get createNewGroup;

  /// Button text to create seat override
  ///
  /// In en, this message translates to:
  /// **'Create Override'**
  String get createOverride;

  /// Error message when creating seat override fails
  ///
  /// In en, this message translates to:
  /// **'Failed to create override. Please try again.'**
  String get createOverrideError;

  /// Title for create seat override form
  ///
  /// In en, this message translates to:
  /// **'Create Seat Override'**
  String get createSeatOverride;

  /// Create group description
  ///
  /// In en, this message translates to:
  /// **'Create a transport group to coordinate with other families'**
  String get createTransportGroupDescription;

  /// Create trip page title
  ///
  /// In en, this message translates to:
  /// **'Create Trip'**
  String get createTrip;

  /// Create vehicle button text
  ///
  /// In en, this message translates to:
  /// **'Create Vehicle'**
  String get createVehicle;

  /// Header title for creating a new family
  ///
  /// In en, this message translates to:
  /// **'Create Your Family'**
  String get createYourFamily;

  /// Created date field label
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// Created date format for invitations
  ///
  /// In en, this message translates to:
  /// **'Created on {date}'**
  String createdOn(String date);

  /// Loading text when creating an item
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creating;

  /// Dashboard page title
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Critical expiring count message
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} expiring in 2 hours or less} other{{count} expiring in 2 hours or less}}'**
  String criticalExpiringCount(int count);

  /// Current capacity display with pluralization
  ///
  /// In en, this message translates to:
  /// **'Current: {count} {count, plural, =1{seat} other{seats}}'**
  String currentCapacity(int count);

  /// Current family name display
  ///
  /// In en, this message translates to:
  /// **'Current family: {familyName}'**
  String currentFamily(String familyName);

  /// No description provided for @currentSeatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Current: {count} seats'**
  String currentSeatsLabel(int count);

  /// Section header for current family situation
  ///
  /// In en, this message translates to:
  /// **'Current Situation'**
  String get currentSituation;

  /// Custom time option label
  ///
  /// In en, this message translates to:
  /// **'Custom time'**
  String get customTime;

  /// Relative date display with ICU pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Today} =1{Yesterday} other{{count}d ago}}'**
  String daysAgo(int count);

  /// Days count with ICU pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} day} other{{count} days}}'**
  String daysCount(num count);

  /// Decline invitation button text
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// Default capacity display with pluralization
  ///
  /// In en, this message translates to:
  /// **'Default: {count} {count, plural, =1{seat} other{seats}}'**
  String defaultCapacity(int count);

  /// Generic delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Delete assignment tooltip
  ///
  /// In en, this message translates to:
  /// **'Delete Assignment'**
  String get deleteAssignment;

  /// Tooltip for delete assignment button
  ///
  /// In en, this message translates to:
  /// **'Delete Assignment'**
  String get deleteAssignmentTooltip;

  /// Option to delete family
  ///
  /// In en, this message translates to:
  /// **'Delete Family'**
  String get deleteFamily;

  /// Option to delete current family and switch
  ///
  /// In en, this message translates to:
  /// **'Delete Family and Switch'**
  String get deleteFamilyAndSwitch;

  /// Dialog title for family deletion confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete Family'**
  String get deleteFamilyConfirmation;

  /// Description for deleting family
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your current family and join the new one'**
  String get deleteFamilyDesc;

  /// Description for deleting family as last member
  ///
  /// In en, this message translates to:
  /// **'Permanently delete this family since you are the only member'**
  String get deleteFamilyLastMemberDesc;

  /// Warning message for family deletion
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the family \'{familyName}\' and all its data. This action cannot be undone.'**
  String deleteFamilyWarning(String familyName);

  /// Delete button tooltip
  ///
  /// In en, this message translates to:
  /// **'Delete time slot'**
  String get deleteTimeSlotTooltip;

  /// Delete vehicle confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete vehicle'**
  String get deleteVehicle;

  /// Option to demote member from admin role
  ///
  /// In en, this message translates to:
  /// **'Demote from Admin'**
  String get demoteFromAdmin;

  /// Number of selected departure times with ICU pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} departure time selected} other{{count} departure times selected}}'**
  String departureTimesSelected(num count);

  /// Label for departure hours configuration section
  ///
  /// In en, this message translates to:
  /// **'Departure Hours'**
  String get departureHours;

  /// Generic description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Developer tools section title
  ///
  /// In en, this message translates to:
  /// **'Developer Tools'**
  String get developerTools;

  /// Description for show invitation code action
  ///
  /// In en, this message translates to:
  /// **'Display the invitation code'**
  String get displayInvitationCode;

  /// Instructions for drag and drop vehicles
  ///
  /// In en, this message translates to:
  /// **'Drag vehicles to time slots'**
  String get dragVehiclesToTimeSlots;

  /// Generic edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Edit assignment tooltip
  ///
  /// In en, this message translates to:
  /// **'Edit Assignment'**
  String get editAssignment;

  /// Tooltip for edit assignment button
  ///
  /// In en, this message translates to:
  /// **'Edit Assignment'**
  String get editAssignmentTooltip;

  /// Placeholder message for unimplemented edit feature
  ///
  /// In en, this message translates to:
  /// **'Edit functionality coming soon'**
  String get editFunctionalityComingSoon;

  /// No description provided for @editGroup.
  ///
  /// In en, this message translates to:
  /// **'Edit Group'**
  String get editGroup;

  /// Dialog title for editing time slot
  ///
  /// In en, this message translates to:
  /// **'Edit Time Slot'**
  String get editTimeSlot;

  /// Edit button tooltip
  ///
  /// In en, this message translates to:
  /// **'Edit time slot'**
  String get editTimeSlotTooltip;

  /// Edit vehicle page title
  ///
  /// In en, this message translates to:
  /// **'Edit Vehicle'**
  String get editVehicle;

  /// Edit vehicle page title
  ///
  /// In en, this message translates to:
  /// **'Edit Vehicle'**
  String get editVehicleTitle;

  /// Edit vehicle button tooltip
  ///
  /// In en, this message translates to:
  /// **'Edit Vehicle'**
  String get editVehicleTooltip;

  /// Label for email field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Label for email input field
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// Label for email display
  ///
  /// In en, this message translates to:
  /// **'Email: '**
  String get emailLabel;

  /// Validation error when email is missing
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// Emergency seat override type
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// Emergency contact field label
  ///
  /// In en, this message translates to:
  /// **'Emergency contact'**
  String get emergencyContact;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Warning for admin users about ensuring other admins exist
  ///
  /// In en, this message translates to:
  /// **'As an admin, ensure there are other admins in the family before leaving.'**
  String get ensureOtherAdmins;

  /// Hint text for new admin email field
  ///
  /// In en, this message translates to:
  /// **'Enter email of a family member'**
  String get enterEmailOfFamilyMember;

  /// Instruction text for family invitation code entry
  ///
  /// In en, this message translates to:
  /// **'Please enter your family invitation code to continue'**
  String get enterFamilyInvitationInstruction;

  /// Hint text for full name input field
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// Title for group invitation code entry
  ///
  /// In en, this message translates to:
  /// **'Enter Group Invitation Code'**
  String get enterGroupInvitationCodeTitle;

  /// Instruction text for group invitation code entry
  ///
  /// In en, this message translates to:
  /// **'Please enter your group invitation code to continue'**
  String get enterGroupInvitationInstruction;

  /// Group name hint
  ///
  /// In en, this message translates to:
  /// **'Enter group name'**
  String get enterGroupName;

  /// Invitation code hint
  ///
  /// In en, this message translates to:
  /// **'Enter invitation code'**
  String get enterInvitationCode;

  /// Title for manual invitation code entry
  ///
  /// In en, this message translates to:
  /// **'Enter Invitation Code'**
  String get enterInvitationCodeTitle;

  /// Placeholder for member email input
  ///
  /// In en, this message translates to:
  /// **'Enter member\'s email'**
  String get enterMemberEmail;

  /// Placeholder for member name input
  ///
  /// In en, this message translates to:
  /// **'Enter member\'s name'**
  String get enterMemberName;

  /// Hint text for capacity input
  ///
  /// In en, this message translates to:
  /// **'Enter new capacity'**
  String get enterNewCapacity;

  /// Hint text for code input field
  ///
  /// In en, this message translates to:
  /// **'Enter received code'**
  String get enterReceivedCode;

  /// Placeholder text for total seats field
  ///
  /// In en, this message translates to:
  /// **'Enter total seats'**
  String get enterTotalSeats;

  /// Placeholder text for vehicle name field
  ///
  /// In en, this message translates to:
  /// **'Enter vehicle name'**
  String get enterVehicleName;

  /// Authentication error message
  ///
  /// In en, this message translates to:
  /// **'Authentication error'**
  String get errorAuth;

  /// Domain: Access denied
  ///
  /// In en, this message translates to:
  /// **'Access denied'**
  String get errorAuthAccessDenied;

  /// Domain: Account is disabled
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled. Please contact support'**
  String get errorAuthAccountDisabled;

  /// Domain: Account is locked
  ///
  /// In en, this message translates to:
  /// **'This account has been locked due to suspicious activity'**
  String get errorAuthAccountLocked;

  /// Domain: Account does not exist
  ///
  /// In en, this message translates to:
  /// **'No account found with this email address'**
  String get errorAuthAccountNotFound;

  /// Domain: API error
  ///
  /// In en, this message translates to:
  /// **'API error. Please try again'**
  String get errorAuthApiError;

  /// Domain: Biometric auth failed
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed. Please try again'**
  String get errorAuthBiometricAuthFailed;

  /// Domain: Biometric lockout
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is temporarily locked. Please try again later'**
  String get errorAuthBiometricLockout;

  /// Domain: Biometric not available
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not available on this device'**
  String get errorAuthBiometricNotAvailable;

  /// Domain: Biometric not enabled
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not enabled'**
  String get errorAuthBiometricNotEnabled;

  /// Domain: Biometric not enrolled
  ///
  /// In en, this message translates to:
  /// **'No biometric data enrolled. Please set up biometric authentication in your device settings'**
  String get errorAuthBiometricNotEnrolled;

  /// Domain: Configuration error
  ///
  /// In en, this message translates to:
  /// **'Authentication configuration error. Please contact support'**
  String get errorAuthConfigurationError;

  /// Domain: Connection lost
  ///
  /// In en, this message translates to:
  /// **'Connection lost. Please check your internet connection'**
  String get errorAuthConnectionLost;

  /// Domain: Token belongs to different user
  ///
  /// In en, this message translates to:
  /// **'Invalid token for this user'**
  String get errorAuthCrossUserTokenAttempt;

  /// Domain: Decryption error
  ///
  /// In en, this message translates to:
  /// **'Failed to decrypt authentication data'**
  String get errorAuthDecryptionError;

  /// Domain: Device not recognized
  ///
  /// In en, this message translates to:
  /// **'Device not recognized. Please verify your identity'**
  String get errorAuthDeviceNotRecognized;

  /// Domain: Email already registered
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists'**
  String get errorAuthEmailAlreadyExists;

  /// Validation: Email format is invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get errorAuthEmailInvalid;

  /// Domain: Email not verified
  ///
  /// In en, this message translates to:
  /// **'Email address has not been verified'**
  String get errorAuthEmailNotVerified;

  /// Validation: Email is required
  ///
  /// In en, this message translates to:
  /// **'Email address is required'**
  String get errorAuthEmailRequired;

  /// Validation: Email exceeds maximum length
  ///
  /// In en, this message translates to:
  /// **'Email address is too long (maximum 254 characters)'**
  String get errorAuthEmailTooLong;

  /// Domain: Encryption error
  ///
  /// In en, this message translates to:
  /// **'Failed to encrypt authentication data'**
  String get errorAuthEncryptionError;

  /// Domain: Insufficient permissions
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to perform this action'**
  String get errorAuthInsufficientPermissions;

  /// Domain: Credentials are invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get errorAuthInvalidCredentials;

  /// Domain: Email format invalid
  ///
  /// In en, this message translates to:
  /// **'Email address format is invalid'**
  String get errorAuthInvalidEmail;

  /// Domain: Magic link is invalid
  ///
  /// In en, this message translates to:
  /// **'This magic link is invalid or has already been used'**
  String get errorAuthInvalidMagicLink;

  /// Domain: Invalid request
  ///
  /// In en, this message translates to:
  /// **'Invalid request. Please try again'**
  String get errorAuthInvalidRequest;

  /// Domain: Token is invalid
  ///
  /// In en, this message translates to:
  /// **'Authentication token is invalid'**
  String get errorAuthInvalidToken;

  /// Domain: Verification code invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code'**
  String get errorAuthInvalidVerificationCode;

  /// Validation: Invite code has expired
  ///
  /// In en, this message translates to:
  /// **'This invitation code has expired'**
  String get errorAuthInviteCodeExpired;

  /// Validation: Invite code format is invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid invitation code (at least 6 characters)'**
  String get errorAuthInviteCodeInvalid;

  /// Domain: IP blocked
  ///
  /// In en, this message translates to:
  /// **'Access temporarily blocked. Please try again later'**
  String get errorAuthIpBlocked;

  /// Domain: Magic link already used
  ///
  /// In en, this message translates to:
  /// **'This magic link has already been used'**
  String get errorAuthMagicLinkAlreadyUsed;

  /// Domain: Magic link expired
  ///
  /// In en, this message translates to:
  /// **'This magic link has expired. Please request a new one'**
  String get errorAuthMagicLinkExpired;

  /// Validation: Magic link token is invalid
  ///
  /// In en, this message translates to:
  /// **'The magic link token is invalid or has expired'**
  String get errorAuthMagicLinkTokenInvalid;

  /// Validation: Magic link token is required
  ///
  /// In en, this message translates to:
  /// **'Magic link token is required'**
  String get errorAuthMagicLinkTokenRequired;

  /// Authentication error message
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get errorAuthMessage;

  /// Domain: Multiple sessions detected
  ///
  /// In en, this message translates to:
  /// **'Multiple sessions detected. Please sign in again'**
  String get errorAuthMultipleSessions;

  /// Validation: Name contains invalid characters
  ///
  /// In en, this message translates to:
  /// **'Name can only contain letters, spaces, hyphens, and apostrophes'**
  String get errorAuthNameInvalidChars;

  /// Validation: Name is too long
  ///
  /// In en, this message translates to:
  /// **'Name cannot exceed 50 characters'**
  String get errorAuthNameMaxLength;

  /// Validation: Name is too short
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get errorAuthNameMinLength;

  /// Validation: Name is required
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get errorAuthNameRequired;

  /// Domain: Network error
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection'**
  String get errorAuthNetworkError;

  /// Domain: Operation cancelled
  ///
  /// In en, this message translates to:
  /// **'Operation cancelled'**
  String get errorAuthOperationCancelled;

  /// Domain: PKCE verification failed
  ///
  /// In en, this message translates to:
  /// **'Authentication verification failed'**
  String get errorAuthPkceVerificationFailed;

  /// Domain: Resource not found
  ///
  /// In en, this message translates to:
  /// **'The requested resource was not found'**
  String get errorAuthResourceNotFound;

  /// Domain: Secure storage unavailable
  ///
  /// In en, this message translates to:
  /// **'Secure storage is not available on this device'**
  String get errorAuthSecureStorageUnavailable;

  /// Domain: Security validation failed
  ///
  /// In en, this message translates to:
  /// **'Security validation failed. Please try again'**
  String get errorAuthSecurityValidationFailed;

  /// Domain: Server error
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later'**
  String get errorAuthServerError;

  /// Domain: Session has expired
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again'**
  String get errorAuthSessionExpired;

  /// Domain: Storage error
  ///
  /// In en, this message translates to:
  /// **'Failed to save authentication data. Please try again'**
  String get errorAuthStorageError;

  /// Domain: Suspicious activity
  ///
  /// In en, this message translates to:
  /// **'Suspicious activity detected. Please verify your identity'**
  String get errorAuthSuspiciousActivity;

  /// Domain: Request timeout
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again'**
  String get errorAuthTimeout;

  /// Authentication error title
  ///
  /// In en, this message translates to:
  /// **'Authentication Required'**
  String get errorAuthTitle;

  /// Domain: Token has expired
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again'**
  String get errorAuthTokenExpired;

  /// Domain: Token is missing
  ///
  /// In en, this message translates to:
  /// **'Authentication token is missing'**
  String get errorAuthTokenMissing;

  /// Domain: Token refresh failed
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh authentication. Please sign in again'**
  String get errorAuthTokenRefreshFailed;

  /// Domain: Token storage error
  ///
  /// In en, this message translates to:
  /// **'Failed to store authentication token'**
  String get errorAuthTokenStorageError;

  /// Domain: Too many attempts
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts. Please try again later'**
  String get errorAuthTooManyAttempts;

  /// Domain: Unknown error
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again'**
  String get errorAuthUnknown;

  /// Domain: User already in family
  ///
  /// In en, this message translates to:
  /// **'This user is already member of another family'**
  String get errorAuthUserAlreadyInFamily;

  /// Domain: User data storage error
  ///
  /// In en, this message translates to:
  /// **'Failed to store user data'**
  String get errorAuthUserDataStorageError;

  /// Authorization error message
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to perform this action.'**
  String get errorAuthorizationMessage;

  /// Authorization error title
  ///
  /// In en, this message translates to:
  /// **'Access Denied'**
  String get errorAuthorizationTitle;

  /// Biometric error message
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed. Please try again or use your passcode.'**
  String get errorBiometricMessage;

  /// Biometric error title
  ///
  /// In en, this message translates to:
  /// **'Biometric Error'**
  String get errorBiometricTitle;

  /// Error message for language change
  ///
  /// In en, this message translates to:
  /// **'Error changing language'**
  String get errorChangingLanguage;

  /// Validation error when child age is not a valid number
  ///
  /// In en, this message translates to:
  /// **'Child age must be a number'**
  String get errorChildAgeNotNumber;

  /// Validation error for missing child age
  ///
  /// In en, this message translates to:
  /// **'Child age is required'**
  String get errorChildAgeRequired;

  /// Validation error when child age is above maximum
  ///
  /// In en, this message translates to:
  /// **'Child age cannot exceed {maxAge} years'**
  String errorChildAgeTooOld(int maxAge);

  /// Validation error when child age is below minimum
  ///
  /// In en, this message translates to:
  /// **'Child age must be at least {minAge} year(s) old'**
  String errorChildAgeTooYoung(int minAge);

  /// Validation error when emergency contact format is not valid
  ///
  /// In en, this message translates to:
  /// **'Emergency contact format is invalid (phone or email required)'**
  String get errorChildEmergencyContactInvalid;

  /// Validation error for missing emergency contact
  ///
  /// In en, this message translates to:
  /// **'Emergency contact is required'**
  String get errorChildEmergencyContactRequired;

  /// Validation error when grade format is not recognized
  ///
  /// In en, this message translates to:
  /// **'Grade format is invalid'**
  String get errorChildGradeInvalid;

  /// Validation error when medical information exceeds length limit
  ///
  /// In en, this message translates to:
  /// **'Medical information is too long (maximum {maxLength} characters)'**
  String errorChildMedicalInfoTooLong(int maxLength);

  /// Error message when child name has invalid characters
  ///
  /// In en, this message translates to:
  /// **'Child name contains invalid characters'**
  String get errorChildNameInvalidChars;

  /// Error message when child name is too long
  ///
  /// In en, this message translates to:
  /// **'Child name cannot exceed 30 characters'**
  String get errorChildNameMaxLength;

  /// Error message when child name is too short
  ///
  /// In en, this message translates to:
  /// **'Child name must be at least 2 characters'**
  String get errorChildNameMinLength;

  /// Error message when child name is empty
  ///
  /// In en, this message translates to:
  /// **'Child name is required'**
  String get errorChildNameRequired;

  /// Validation error when school name exceeds length limit
  ///
  /// In en, this message translates to:
  /// **'School name is too long (maximum {maxLength} characters)'**
  String errorChildSchoolNameTooLong(int maxLength);

  /// Validation error when special needs information exceeds length limit
  ///
  /// In en, this message translates to:
  /// **'Special needs information is too long (maximum {maxLength} characters)'**
  String errorChildSpecialNeedsTooLong(int maxLength);

  /// Conflict error message
  ///
  /// In en, this message translates to:
  /// **'Your data conflicts with recent changes. Please refresh and try again.'**
  String get errorConflictMessage;

  /// Conflict error title
  ///
  /// In en, this message translates to:
  /// **'Data Conflict'**
  String get errorConflictTitle;

  /// Error message when email already exists in system
  ///
  /// In en, this message translates to:
  /// **'This email address is already registered'**
  String get errorEmailAlreadyExists;

  /// Error message when email format is invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get errorEmailInvalid;

  /// Error message when email is empty
  ///
  /// In en, this message translates to:
  /// **'Email address is required'**
  String get errorEmailRequired;

  /// Error when exporting logs fails
  ///
  /// In en, this message translates to:
  /// **'Failed to export logs: {error}'**
  String errorFailedToExportLogs(String error);

  /// Error when leaving family fails
  ///
  /// In en, this message translates to:
  /// **'Failed to leave family: {error}'**
  String errorFailedToLeaveFamily(String error);

  /// Error when removing member fails
  ///
  /// In en, this message translates to:
  /// **'Failed to remove member: {error}'**
  String errorFailedToRemoveMember(String error);

  /// Error when updating role fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update role: {error}'**
  String errorFailedToUpdateRole(String error);

  /// Error message when family name has invalid characters
  ///
  /// In en, this message translates to:
  /// **'Family name contains invalid characters'**
  String get errorFamilyNameInvalidChars;

  /// Error message when family name is too long
  ///
  /// In en, this message translates to:
  /// **'Family name cannot exceed 50 characters'**
  String get errorFamilyNameMaxLength;

  /// Error message when family name is too short
  ///
  /// In en, this message translates to:
  /// **'Family name must be at least 2 characters'**
  String get errorFamilyNameMinLength;

  /// Error message when family name is empty
  ///
  /// In en, this message translates to:
  /// **'Family name is required'**
  String get errorFamilyNameRequired;

  /// Error message when user lacks required permissions
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to perform this action'**
  String get errorInsufficientPermissions;

  /// Error message for generic data validation failures
  ///
  /// In en, this message translates to:
  /// **'Invalid data provided. Please check your information and try again.'**
  String get errorInvalidData;

  /// Error message when invitation has been cancelled by sender
  ///
  /// In en, this message translates to:
  /// **'This invitation has been cancelled'**
  String get errorInvitationCancelled;

  /// Error message when invitation code is invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid invitation code'**
  String get errorInvitationCodeInvalid;

  /// Error message when invitation code is empty
  ///
  /// In en, this message translates to:
  /// **'Invitation code is required'**
  String get errorInvitationCodeRequired;

  /// Error message when user tries to accept invitation with different email
  ///
  /// In en, this message translates to:
  /// **'This invitation was sent to a different email address. Please use the email address the invitation was sent to.'**
  String get errorInvitationEmailMismatch;

  /// Error message when invitation code is expired
  ///
  /// In en, this message translates to:
  /// **'This invitation has expired'**
  String get errorInvitationExpired;

  /// Error message when invitation doesn't exist or was revoked
  ///
  /// In en, this message translates to:
  /// **'Invitation not found or has been revoked'**
  String get errorInvitationNotFound;

  /// Error loading data message
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// Error message when log level cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Error loading log level'**
  String get errorLoadingLogLevel;

  /// Error message when trying to add existing member
  ///
  /// In en, this message translates to:
  /// **'This member is already part of the family'**
  String get errorMemberAlreadyExists;

  /// Error message when member doesn't exist
  ///
  /// In en, this message translates to:
  /// **'Member not found'**
  String get errorMemberNotFound;

  /// Error message when personal message is too long
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Message cannot exceed 1 character} other{Message cannot exceed {count} characters}}'**
  String errorMessageTooLong(int count);

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error occurred'**
  String get errorNetwork;

  /// General network error message
  ///
  /// In en, this message translates to:
  /// **'Connection error. Check your internet connection.'**
  String get errorNetworkGeneral;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get errorNetworkMessage;

  /// Network error title
  ///
  /// In en, this message translates to:
  /// **'Connection Problem'**
  String get errorNetworkTitle;

  /// Offline error message
  ///
  /// In en, this message translates to:
  /// **'This feature is not available while offline. Please connect to the internet.'**
  String get errorOfflineMessage;

  /// Offline error title
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get errorOfflineTitle;

  /// Error page title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorPageTitle;

  /// Error message when trying to invite email that already has pending invitation
  ///
  /// In en, this message translates to:
  /// **'An invitation to this email address is already pending'**
  String get errorPendingInvitationExists;

  /// Permission error message
  ///
  /// In en, this message translates to:
  /// **'This app needs permission to continue. Please grant the required permission.'**
  String get errorPermissionMessage;

  /// Permission error title
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get errorPermissionTitle;

  /// Error processing request message
  ///
  /// In en, this message translates to:
  /// **'Error processing request'**
  String get errorProcessingRequest;

  /// Raw error message from server for user-friendly display
  ///
  /// In en, this message translates to:
  /// **'{message}'**
  String errorRawMessage(Object message);

  /// Error message when selected role is invalid
  ///
  /// In en, this message translates to:
  /// **'Please select a valid role'**
  String get errorRoleInvalid;

  /// Error message when role is not selected
  ///
  /// In en, this message translates to:
  /// **'Role selection is required'**
  String get errorRoleRequired;

  /// General server error message
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get errorServerGeneral;

  /// Server error message
  ///
  /// In en, this message translates to:
  /// **'The server is currently experiencing issues. Please try again later.'**
  String get errorServerMessage;

  /// Server error title
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get errorServerTitle;

  /// Storage error message
  ///
  /// In en, this message translates to:
  /// **'There was a problem saving your data. Please try again.'**
  String get errorStorageMessage;

  /// Storage error title
  ///
  /// In en, this message translates to:
  /// **'Storage Problem'**
  String get errorStorageTitle;

  /// Sync error message
  ///
  /// In en, this message translates to:
  /// **'Unable to sync your data. Your changes will be saved when connection is restored.'**
  String get errorSyncMessage;

  /// Sync error title
  ///
  /// In en, this message translates to:
  /// **'Sync Failed'**
  String get errorSyncTitle;

  /// System error message for fallback error handling
  ///
  /// In en, this message translates to:
  /// **'An unexpected system error occurred. Please try again.'**
  String get errorSystemMessage;

  /// System error title for fallback error handling
  ///
  /// In en, this message translates to:
  /// **'System Error'**
  String get errorSystemTitle;

  /// Generic error page title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// General unexpected error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get errorUnexpected;

  /// Unexpected error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again or contact support if the problem continues.'**
  String get errorUnexpectedMessage;

  /// Unexpected error title
  ///
  /// In en, this message translates to:
  /// **'Unexpected Error'**
  String get errorUnexpectedTitle;

  /// Generic unknown error message
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get errorUnknown;

  /// Validation error message
  ///
  /// In en, this message translates to:
  /// **'Validation error'**
  String get errorValidation;

  /// Validation error message
  ///
  /// In en, this message translates to:
  /// **'Please check the information you entered and try again.'**
  String get errorValidationMessage;

  /// Validation error title
  ///
  /// In en, this message translates to:
  /// **'Invalid Information'**
  String get errorValidationTitle;

  /// Validation error for non-numeric vehicle capacity
  ///
  /// In en, this message translates to:
  /// **'Vehicle capacity must be a number'**
  String get errorVehicleCapacityNotNumber;

  /// Validation error for empty vehicle capacity
  ///
  /// In en, this message translates to:
  /// **'Vehicle capacity is required'**
  String get errorVehicleCapacityRequired;

  /// Validation error for vehicle capacity too high
  ///
  /// In en, this message translates to:
  /// **'Vehicle capacity cannot exceed 10'**
  String get errorVehicleCapacityTooHigh;

  /// Validation error for vehicle capacity too low
  ///
  /// In en, this message translates to:
  /// **'Vehicle capacity must be at least 1'**
  String get errorVehicleCapacityTooLow;

  /// Validation error for vehicle description length
  ///
  /// In en, this message translates to:
  /// **'Vehicle description is too long'**
  String get errorVehicleDescriptionTooLong;

  /// Validation error for vehicle name invalid characters
  ///
  /// In en, this message translates to:
  /// **'Vehicle name contains invalid characters'**
  String get errorVehicleNameInvalidChars;

  /// Validation error for vehicle name maximum length
  ///
  /// In en, this message translates to:
  /// **'Vehicle name cannot exceed 50 characters'**
  String get errorVehicleNameMaxLength;

  /// Validation error for vehicle name minimum length
  ///
  /// In en, this message translates to:
  /// **'Vehicle name must be at least 2 characters'**
  String get errorVehicleNameMinLength;

  /// Validation error for empty vehicle name
  ///
  /// In en, this message translates to:
  /// **'Vehicle name is required'**
  String get errorVehicleNameRequired;

  /// Shows estimated size of log files
  ///
  /// In en, this message translates to:
  /// **'Estimated log size: {sizeMB}MB'**
  String estimatedLogSize(String sizeMB);

  /// Event seat override type
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get event;

  /// Status indicating something has expired
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// Expired label for expired invitations
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expiredLabel;

  /// Expiry date display
  ///
  /// In en, this message translates to:
  /// **'Expires: {date}'**
  String expires(String date);

  /// Label for expiry date selection
  ///
  /// In en, this message translates to:
  /// **'Expires At (Optional)'**
  String get expiresAtOptional;

  /// Message showing when something expires with pluralization
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Expires today} =1{Expires tomorrow} other{Expires in {days} days}}'**
  String expiresIn(int days);

  /// Expiry message with days only
  ///
  /// In en, this message translates to:
  /// **'Expires in {days} days'**
  String expiresInDays(int days);

  /// Expiry message with days and hours
  ///
  /// In en, this message translates to:
  /// **'Expires in {days} days and {hours} hours'**
  String expiresInDaysHours(int days, int hours);

  /// Day label for segmented button
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get dayLabel;

  /// Expiry message with hours only
  ///
  /// In en, this message translates to:
  /// **'Expires in {hours} hours'**
  String expiresInHours(int hours);

  /// Expiry message with hours and minutes
  ///
  /// In en, this message translates to:
  /// **'Expires in {hours} hours and {minutes} minutes'**
  String expiresInHoursMinutes(int hours, int minutes);

  /// Expiry message with minutes only
  ///
  /// In en, this message translates to:
  /// **'Expires in {minutes} minutes'**
  String expiresInMinutes(int minutes);

  /// Expiration date for pending invitation
  ///
  /// In en, this message translates to:
  /// **'Expires: {date}'**
  String expiresOn(String date);

  /// Title for medium expiry warning
  ///
  /// In en, this message translates to:
  /// **'Expiring in 3 Days'**
  String get expiringIn3Days;

  /// Status indicating something is expiring soon
  ///
  /// In en, this message translates to:
  /// **'Expiring Soon'**
  String get expiringSoon;

  /// Title for low expiry warning
  ///
  /// In en, this message translates to:
  /// **'Expiring This Week'**
  String get expiringThisWeek;

  /// Title for critical expiry warning
  ///
  /// In en, this message translates to:
  /// **'Expiring Very Soon'**
  String get expiringVeryShortly;

  /// Comprehensive export information description
  ///
  /// In en, this message translates to:
  /// **'Export includes comprehensive diagnostic information for support'**
  String get exportIncludesComprehensive;

  /// Information about what's included in log export
  ///
  /// In en, this message translates to:
  /// **'Export includes app version, device info, recent logs, and diagnostic data'**
  String get exportIncludesInfo;

  /// Button text to export logs for support team
  ///
  /// In en, this message translates to:
  /// **'Export Logs for Support'**
  String get exportLogsForSupport;

  /// Text shown while export is in progress
  ///
  /// In en, this message translates to:
  /// **'Exporting...'**
  String get exporting;

  /// Button text to extend invitation
  ///
  /// In en, this message translates to:
  /// **'Extend'**
  String get extend;

  /// No description provided for @extended.
  ///
  /// In en, this message translates to:
  /// **'Extended'**
  String get extended;

  /// Failed status label
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// Error message when child assignment fails
  ///
  /// In en, this message translates to:
  /// **'Failed to assign children: {error}'**
  String failedToAssignChildren(String error);

  /// Error message when cancellation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel: {error}'**
  String failedToCancel(String error);

  /// Error message when copying code fails
  ///
  /// In en, this message translates to:
  /// **'Failed to copy code: {error}'**
  String failedToCopyCode(String error);

  /// Error message when log export fails
  ///
  /// In en, this message translates to:
  /// **'Failed to export logs: {error}'**
  String failedToExportLogs(String error);

  /// Error message when leaving family fails
  ///
  /// In en, this message translates to:
  /// **'Failed to leave family: {error}'**
  String failedToLeaveFamily(String error);

  /// Error message for loading groups
  ///
  /// In en, this message translates to:
  /// **'Failed to load groups'**
  String get failedToLoadGroups;

  /// Schedule loading error title
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Schedule'**
  String get failedToLoadSchedule;

  /// Error message when changing week
  ///
  /// In en, this message translates to:
  /// **'Failed to change week'**
  String get failedToChangeWeek;

  /// Vehicle loading error message
  ///
  /// In en, this message translates to:
  /// **'Failed to load vehicles: {error}'**
  String failedToLoadVehicles(String error);

  /// Error message when member removal fails
  ///
  /// In en, this message translates to:
  /// **'Failed to remove member: {error}'**
  String failedToRemoveMember(String error);

  /// Error message when invitation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to send invitation'**
  String get failedToSendInvitation;

  /// Error message when role update fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update role: {error}'**
  String failedToUpdateRole(String error);

  /// Family type label
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// Title for family conflict resolution dialog
  ///
  /// In en, this message translates to:
  /// **'Family Conflict'**
  String get familyConflictTitle;

  /// Family count with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} family} other{{count} families}}'**
  String familyCount(int count);

  /// Family invitation type title
  ///
  /// In en, this message translates to:
  /// **'Family invitation'**
  String get familyInvitation;

  /// Title for family invitations section
  ///
  /// In en, this message translates to:
  /// **'Family Invitations'**
  String get familyInvitations;

  /// Family member role type
  ///
  /// In en, this message translates to:
  /// **'Family Member'**
  String get familyMember;

  /// Title for family member actions screen
  ///
  /// In en, this message translates to:
  /// **'Family Member Actions'**
  String get familyMemberActions;

  /// Description for family member role
  ///
  /// In en, this message translates to:
  /// **'Regular family member with basic access'**
  String get familyMemberDescription;

  /// Family members section header
  ///
  /// In en, this message translates to:
  /// **'Family Members'**
  String get familyMembers;

  /// Family members title with count and ICU pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Family Members} =1{Family Members ({count})} other{Family Members ({count})}}'**
  String familyMembersCount(int count);

  /// Label appended to current user name in member list
  ///
  /// In en, this message translates to:
  /// **', current user'**
  String get currentUserLabel;

  /// Indicator showing current user in member list
  ///
  /// In en, this message translates to:
  /// **'(You)'**
  String get youLabel;

  /// Relative date display in weeks with ICU pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} week ago} other{{count} weeks ago}}'**
  String weeksAgo(int count);

  /// Relative date display in months with ICU pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} month ago} other{{count} months ago}}'**
  String monthsAgo(int count);

  /// Relative date display in years with ICU pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} year ago} other{{count} years ago}}'**
  String yearsAgo(int count);

  /// Option to remove admin role from member
  ///
  /// In en, this message translates to:
  /// **'Remove Admin Role'**
  String get removeAdminRole;

  /// Description of demoting admin action
  ///
  /// In en, this message translates to:
  /// **'Change to regular member'**
  String get changeToRegularMember;

  /// Description of promoting member to admin action
  ///
  /// In en, this message translates to:
  /// **'Grant admin permissions'**
  String get grantAdminPermissions;

  /// Header for list of admin permissions
  ///
  /// In en, this message translates to:
  /// **'Admin permissions include:'**
  String get adminPermissionsInclude;

  /// Admin permission to manage family members
  ///
  /// In en, this message translates to:
  /// **'• Manage family members'**
  String get adminPermissionManageMembers;

  /// Admin permission to send invitations
  ///
  /// In en, this message translates to:
  /// **'• Send invitations'**
  String get adminPermissionSendInvitations;

  /// Admin permission to manage vehicles and children
  ///
  /// In en, this message translates to:
  /// **'• Manage vehicles and children'**
  String get adminPermissionManageVehiclesChildren;

  /// Admin permission to configure family settings
  ///
  /// In en, this message translates to:
  /// **'• Configure family settings'**
  String get adminPermissionConfigureSettings;

  /// Validation error when family name is empty
  ///
  /// In en, this message translates to:
  /// **'Family name is required'**
  String get familyNameRequired;

  /// Validation error when family name is too long
  ///
  /// In en, this message translates to:
  /// **'Family name must be less than 50 characters'**
  String get familyNameTooLong;

  /// Validation error when family name is too short
  ///
  /// In en, this message translates to:
  /// **'Family name must be at least 2 characters'**
  String get familyNameTooShort;

  /// Validation message for required fields
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// Filter menu item
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// Filter option to show all invitations
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Filter option to show expired invitations
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get filterExpired;

  /// Filter option to show expiring soon invitations
  ///
  /// In en, this message translates to:
  /// **'Expiring Soon'**
  String get filterExpiringSoon;

  /// Title for filter options
  ///
  /// In en, this message translates to:
  /// **'Filter Options'**
  String get filterOptions;

  /// Filter option to show pending invitations
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get filterPending;

  /// First name field label
  ///
  /// In en, this message translates to:
  /// **'First name *'**
  String get firstName;

  /// First name required validation message
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameRequired;

  /// French language name
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// Friday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// Friday day name
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @fridayShort.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fridayShort;

  /// Label for full name input field
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// Generate button text for FAB
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// Menu item to generate invitation codes
  ///
  /// In en, this message translates to:
  /// **'Generate codes'**
  String get generateCodes;

  /// Tooltip for generate codes FAB
  ///
  /// In en, this message translates to:
  /// **'Generate codes'**
  String get generateCodesTooltip;

  /// Tooltip for refresh button in code card
  ///
  /// In en, this message translates to:
  /// **'Generate new code'**
  String get generateNewCode;

  /// Consequence of leaving family - admin privileges
  ///
  /// In en, this message translates to:
  /// **'• Give up admin privileges'**
  String get giveUpAdminPrivileges;

  /// Go back button text
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// Button to go back
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBackButton;

  /// Button text to navigate to groups
  ///
  /// In en, this message translates to:
  /// **'Go to Groups'**
  String get goToGroups;

  /// Button text to acknowledge
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotItButton;

  /// Grant admin role button text
  ///
  /// In en, this message translates to:
  /// **'Grant Admin Role'**
  String get grantAdminRole;

  /// Success message
  ///
  /// In en, this message translates to:
  /// **'Group created successfully'**
  String get groupCreated;

  /// Success message for group creation
  ///
  /// In en, this message translates to:
  /// **'Group created successfully\\!'**
  String get groupCreatedSuccessfully;

  /// Group creator information
  ///
  /// In en, this message translates to:
  /// **'As the creator, you\'ll be the group administrator and can invite other families.'**
  String get groupCreatorInfo;

  /// Group description field
  ///
  /// In en, this message translates to:
  /// **'Group Description'**
  String get groupDescription;

  /// Group description maximum length validation
  ///
  /// In en, this message translates to:
  /// **'Description cannot exceed 500 characters'**
  String get groupDescriptionMaxLength;

  /// Group details title
  ///
  /// In en, this message translates to:
  /// **'Group Details'**
  String get groupDetails;

  /// Group invitation type title
  ///
  /// In en, this message translates to:
  /// **'Group invitation'**
  String get groupInvitation;

  /// Group invitations section title
  ///
  /// In en, this message translates to:
  /// **'Group Invitations'**
  String get groupInvitations;

  /// Success message
  ///
  /// In en, this message translates to:
  /// **'Joined group successfully'**
  String get groupJoined;

  /// Group name label
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupName;

  /// Group name maximum length validation
  ///
  /// In en, this message translates to:
  /// **'Group name must be less than 50 characters'**
  String get groupNameMaxLength;

  /// Group name minimum length validation
  ///
  /// In en, this message translates to:
  /// **'Group name must be at least 3 characters'**
  String get groupNameMinLength;

  /// Group name required validation
  ///
  /// In en, this message translates to:
  /// **'Group name is required'**
  String get groupNameRequired;

  /// Error title when group not found
  ///
  /// In en, this message translates to:
  /// **'Group Not Found'**
  String get groupNotFound;

  /// Error message when group not found
  ///
  /// In en, this message translates to:
  /// **'The selected group could not be found or you no longer have access to it.'**
  String get groupNotFoundMessage;

  /// Groups membership count
  ///
  /// In en, this message translates to:
  /// **'Groups: {count}'**
  String groups(int count);

  /// Groups section label
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groupsLabel;

  /// Help menu label
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// Helper text showing default seat count
  ///
  /// In en, this message translates to:
  /// **'Default: {count} {count, plural, =1{seat} other{seats}}'**
  String helperTextDefaultSeats(int count);

  /// Tooltip for hide vehicles button
  ///
  /// In en, this message translates to:
  /// **'Hide Vehicles'**
  String get hideVehicles;

  /// High priority expiring count message
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} expiring within 24 hours} other{{count} expiring within 24 hours}}'**
  String highExpiringCount(int count);

  /// Hours ago with ICU pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} hour ago} other{{count} hours ago}}'**
  String hoursAgo(num count);

  /// Message for upcoming features
  ///
  /// In en, this message translates to:
  /// **'Implementation coming soon'**
  String get implementationComingSoon;

  /// Error message for incorrect confirmation text
  ///
  /// In en, this message translates to:
  /// **'Confirmation text does not match'**
  String get incorrectConfirmation;

  /// First instruction step
  ///
  /// In en, this message translates to:
  /// **'1. Open your email app'**
  String get instructionStep1;

  /// Second instruction step
  ///
  /// In en, this message translates to:
  /// **'2. Look for the EduLift email'**
  String get instructionStep2;

  /// Third instruction step
  ///
  /// In en, this message translates to:
  /// **'3. Click the login link'**
  String get instructionStep3;

  /// Fourth instruction step
  ///
  /// In en, this message translates to:
  /// **'4. You will be automatically logged in'**
  String get instructionStep4;

  /// Title for the instructions section
  ///
  /// In en, this message translates to:
  /// **'Instructions:'**
  String get instructionsTitle;

  /// Invalid status label
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get invalid;

  /// Error for invalid capacity range
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid capacity between 1 and 50'**
  String get invalidCapacityRange;

  /// Validation message for invalid email
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// Error message for invalid email format
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmailFormat;

  /// Title for invalid deep link error page
  ///
  /// In en, this message translates to:
  /// **'Invalid Link'**
  String get invalidDeepLinkTitle;

  /// Error message for invalid deep link
  ///
  /// In en, this message translates to:
  /// **'The link you followed is not valid or has expired. Please check the link and try again.'**
  String get invalidDeepLinkMessage;

  /// Title for invalid invitation error display
  ///
  /// In en, this message translates to:
  /// **'Invalid Invitation'**
  String get invalidInvitationTitle;

  /// Time validation error
  ///
  /// In en, this message translates to:
  /// **'Invalid time format. Use HH:MM (24-hour)'**
  String get invalidTimeFormat;

  /// Title for invitation actions dialog
  ///
  /// In en, this message translates to:
  /// **'Invitation Actions'**
  String get invitationActions;

  /// Tooltip for invitation actions button
  ///
  /// In en, this message translates to:
  /// **'Invitation actions for {email}'**
  String invitationActionsTooltip(String email);

  /// Title for invitation analytics section
  ///
  /// In en, this message translates to:
  /// **'Invitation Analytics'**
  String get invitationAnalytics;

  /// Success message when invitation cancelled for specific email
  ///
  /// In en, this message translates to:
  /// **'Invitation cancelled for {email}'**
  String invitationCancelledFor(String email);

  /// Success message when invitation is cancelled
  ///
  /// In en, this message translates to:
  /// **'Invitation cancelled successfully'**
  String get invitationCancelledSuccessfully;

  /// Invitation code label
  ///
  /// In en, this message translates to:
  /// **'Invitation Code'**
  String get invitationCode;

  /// Success message when invitation code is copied
  ///
  /// In en, this message translates to:
  /// **'Invitation code copied to clipboard'**
  String get invitationCodeCopied;

  /// Error when invitation code cannot be found
  ///
  /// In en, this message translates to:
  /// **'Invitation code not available'**
  String get invitationCodeNotAvailable;

  /// Invitation code required validation
  ///
  /// In en, this message translates to:
  /// **'Invitation code is required'**
  String get invitationCodeRequired;

  /// Message indicating an invitation has expired
  ///
  /// In en, this message translates to:
  /// **'This invitation has expired'**
  String get invitationExpired;

  /// Description for expired invitation
  ///
  /// In en, this message translates to:
  /// **'This invitation has expired and is no longer valid'**
  String get invitationExpiredDesc;

  /// Success message when invitation is sent
  ///
  /// In en, this message translates to:
  /// **'Invitation sent to {email}'**
  String invitationSentTo(String email);

  /// Statistics card title
  ///
  /// In en, this message translates to:
  /// **'Invitation statistics'**
  String get invitationStatistics;

  /// Label for invitation type selection
  ///
  /// In en, this message translates to:
  /// **'Invitation Type'**
  String get invitationType;

  /// Invitations page title
  ///
  /// In en, this message translates to:
  /// **'Invitations'**
  String get invitations;

  /// Header with invitation count
  ///
  /// In en, this message translates to:
  /// **'Invitations ({count})'**
  String invitationsCount(int count);

  /// Banner message for multiple expiring invitations
  ///
  /// In en, this message translates to:
  /// **'{count} invitations expiring soon'**
  String invitationsExpiring(int count);

  /// Invite action button
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// Invite family member button text
  ///
  /// In en, this message translates to:
  /// **'Invite Family Member'**
  String get inviteFamilyMember;

  /// Menu item to invite family members
  ///
  /// In en, this message translates to:
  /// **'Invite to family'**
  String get inviteFamilyMembers;

  /// Call to action for admins when no invitations
  ///
  /// In en, this message translates to:
  /// **'Invite members to get started'**
  String get inviteMembersToStart;

  /// Button text to invite new family member
  ///
  /// In en, this message translates to:
  /// **'Invite New Member'**
  String get inviteNewMember;

  /// Description text explaining how family invitations work
  ///
  /// In en, this message translates to:
  /// **'Send an invitation to join your family. They will receive an email with instructions to accept the invitation.'**
  String get sendInvitationDescription;

  /// Menu item to invite to group
  ///
  /// In en, this message translates to:
  /// **'Invite to group'**
  String get inviteToGroup;

  /// New family invitation display
  ///
  /// In en, this message translates to:
  /// **'Invited to join: {familyName}'**
  String invitedToFamily(String familyName);

  /// Join button text
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// Join family button text
  ///
  /// In en, this message translates to:
  /// **'Join {familyName}'**
  String joinFamily(String familyName);

  /// Button to join specific family
  ///
  /// In en, this message translates to:
  /// **'Join {familyName}'**
  String joinFamilyName(String familyName);

  /// Join group button text
  ///
  /// In en, this message translates to:
  /// **'Join Group'**
  String get joinGroup;

  /// Button to join specific group
  ///
  /// In en, this message translates to:
  /// **'Join {groupName}'**
  String joinGroupName(String groupName);

  /// Menu item to join with code
  ///
  /// In en, this message translates to:
  /// **'Join with code'**
  String get joinWithCode;

  /// Label for join date field
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joined;

  /// Loading text when joining with code
  ///
  /// In en, this message translates to:
  /// **'Joining in progress...'**
  String get joiningInProgress;

  /// Just now relative time
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// Button to keep invitation (cancel dialog)
  ///
  /// In en, this message translates to:
  /// **'Keep Invitation'**
  String get keepInvitation;

  /// Label input field
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get labelFieldLabel;

  /// Label input hint
  ///
  /// In en, this message translates to:
  /// **'School Drop-off'**
  String get labelHint;

  /// Empty label validation
  ///
  /// In en, this message translates to:
  /// **'Label cannot be empty'**
  String get labelRequired;

  /// Label length validation
  ///
  /// In en, this message translates to:
  /// **'Label must be 50 characters or less'**
  String get labelTooLong;

  /// Language section title
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Description for settings page menu item
  ///
  /// In en, this message translates to:
  /// **'Language, Developer Tools & More'**
  String get languageAndToolsMore;

  /// Success message for language change
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully'**
  String get languageChanged;

  /// Title for last admin protection widget
  ///
  /// In en, this message translates to:
  /// **'Last Admin Protection'**
  String get lastAdminProtection;

  /// Warning message for last admin
  ///
  /// In en, this message translates to:
  /// **'You are the last admin of this family. You must assign a new admin or transfer ownership before leaving.'**
  String get lastAdminWarning;

  /// Shows when logs were last exported
  ///
  /// In en, this message translates to:
  /// **'Last exported: {timeAgo}'**
  String lastExported(String timeAgo);

  /// Last name field label
  ///
  /// In en, this message translates to:
  /// **'Last name *'**
  String get lastName;

  /// Last updated date field label
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get lastUpdated;

  /// Button to leave page with unsaved changes
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// Button to leave page without saving
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leaveButton;

  /// Instruction to type name to confirm action
  ///
  /// In en, this message translates to:
  /// **'To confirm, type the name exactly: {name}'**
  String typeNameToConfirm(String name);

  /// Error message when name doesn't match
  ///
  /// In en, this message translates to:
  /// **'Please type \"{name}\" exactly'**
  String pleaseTypeNameExactly(String name);

  /// Option to leave the family
  ///
  /// In en, this message translates to:
  /// **'Leave Family'**
  String get leaveFamily;

  /// Button text to leave current family and join invitation family
  ///
  /// In en, this message translates to:
  /// **'Leave current family and join {familyName}'**
  String leaveFamilyAndJoinFamilyName(String familyName);

  /// Confirmation message for leaving family
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave this family?'**
  String get leaveFamilyConfirmation;

  /// Title for leave family dialog
  ///
  /// In en, this message translates to:
  /// **'Leave Family'**
  String get leaveFamilyTitle;

  /// Warning label for critical actions
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// Warning message when leaving family
  ///
  /// In en, this message translates to:
  /// **'You will lose access to all family data, schedules, and vehicles. This action cannot be undone.'**
  String get leaveFamilyWarningMessage;

  /// Warning message when removing a member from family
  ///
  /// In en, this message translates to:
  /// **'This member will lose access to all family data. This action cannot be undone.'**
  String get removeMemberWarningMessage;

  /// Tooltip for member actions menu
  ///
  /// In en, this message translates to:
  /// **'Member actions for {memberName}'**
  String memberActionsFor(String memberName);

  /// Leave group button
  ///
  /// In en, this message translates to:
  /// **'Leave Group'**
  String get leaveGroup;

  /// Title for leave group dialog
  ///
  /// In en, this message translates to:
  /// **'Leave Group'**
  String get leaveGroupTitle;

  /// Introduction to list of consequences of leaving group
  ///
  /// In en, this message translates to:
  /// **'By leaving this group, you will:'**
  String get byLeavingGroupYouWill;

  /// Consequence of leaving group - schedules
  ///
  /// In en, this message translates to:
  /// **'• Lose access to all group schedules'**
  String get loseAccessGroupSchedules;

  /// Consequence of leaving group - members
  ///
  /// In en, this message translates to:
  /// **'• No longer see group families and members'**
  String get noLongerSeeGroupMembers;

  /// Consequence of leaving group - admin privileges
  ///
  /// In en, this message translates to:
  /// **'• Give up group admin privileges'**
  String get giveUpGroupAdminPrivileges;

  /// Warning that owner family cannot leave the group
  ///
  /// In en, this message translates to:
  /// **'Note: The owner family cannot leave the group. Only members can leave.'**
  String get ownerFamilyCannotLeave;

  /// Error message when leaving group fails
  ///
  /// In en, this message translates to:
  /// **'Failed to leave group: {error}'**
  String failedToLeaveGroup(String error);

  /// Information about link expiration time
  ///
  /// In en, this message translates to:
  /// **'The link expires in 15 minutes for your security.'**
  String get linkExpiryInfo;

  /// General loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error message when loading fails
  ///
  /// In en, this message translates to:
  /// **'Loading error'**
  String get loadingError;

  /// Loading error title
  ///
  /// In en, this message translates to:
  /// **'Loading error'**
  String get loadingErrorText;

  /// Loading message when fetching invitations
  ///
  /// In en, this message translates to:
  /// **'Loading invitations...'**
  String get loadingInvitations;

  /// Loading message when fetching sent invitations
  ///
  /// In en, this message translates to:
  /// **'Loading sent invitations...'**
  String get loadingSentInvitations;

  /// Loading message when fetching statistics
  ///
  /// In en, this message translates to:
  /// **'Loading statistics...'**
  String get loadingStatistics;

  /// Loading message for vehicles
  ///
  /// In en, this message translates to:
  /// **'Loading vehicles...'**
  String get loadingVehicles;

  /// Title for log export
  ///
  /// In en, this message translates to:
  /// **'Log Export'**
  String get logExport;

  /// Label for log level setting
  ///
  /// In en, this message translates to:
  /// **'Log Level'**
  String get logLevel;

  /// Log level change error
  ///
  /// In en, this message translates to:
  /// **'Failed to change log level: {error}'**
  String logLevelChangeFailed(String error);

  /// Log level change confirmation
  ///
  /// In en, this message translates to:
  /// **'Log level changed to: {level}'**
  String logLevelChanged(String level);

  /// Description text for log level setting
  ///
  /// In en, this message translates to:
  /// **'Controls verbosity of app logging for debugging'**
  String get logLevelDescription;

  /// Logout button
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get logout;

  /// Successful log export message - logs are automatically sent to Firebase
  ///
  /// In en, this message translates to:
  /// **'📤 Logs exported and uploaded to Firebase successfully!'**
  String get logsExportedSuccess;

  /// Error when trying to export logs on desktop platforms
  ///
  /// In en, this message translates to:
  /// **'Log export is only supported on mobile platforms (Android/iOS)'**
  String get logExportUnsupportedPlatform;

  /// Error when log export directory doesn't exist
  ///
  /// In en, this message translates to:
  /// **'No export directory found'**
  String get logExportNoDirectory;

  /// Error when no ZIP files are found after log export
  ///
  /// In en, this message translates to:
  /// **'No log files found after export'**
  String get logExportNoFiles;

  /// Consequence of leaving family - schedules
  ///
  /// In en, this message translates to:
  /// **'• Lose access to all family schedules'**
  String get loseAccessSchedules;

  /// Consequence of leaving family - vehicles
  ///
  /// In en, this message translates to:
  /// **'• Lose access to family vehicles and assignments'**
  String get loseAccessVehicles;

  /// Magic link expired error
  ///
  /// In en, this message translates to:
  /// **'Magic link has expired. Please request a new one.'**
  String get magicLinkExpired;

  /// Confirmation message when magic link is resent
  ///
  /// In en, this message translates to:
  /// **'Login link resent'**
  String get magicLinkResent;

  /// Magic link sent confirmation
  ///
  /// In en, this message translates to:
  /// **'Magic link sent to your email'**
  String get magicLinkSent;

  /// Description explaining where the magic link was sent
  ///
  /// In en, this message translates to:
  /// **'A secure login link has been sent to:'**
  String get magicLinkSentDescription;

  /// Title for magic link sent page
  ///
  /// In en, this message translates to:
  /// **'Login link sent'**
  String get magicLinkSentTitle;

  /// Maintenance seat override type
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenance;

  /// Option to make member an admin
  ///
  /// In en, this message translates to:
  /// **'Make Admin'**
  String get makeAdmin;

  /// Confirmation message for granting admin role
  ///
  /// In en, this message translates to:
  /// **'Grant admin privileges to {name}?'**
  String makeAdminConfirmation(String name);

  /// Manage button text
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// Family management section
  ///
  /// In en, this message translates to:
  /// **'Manage Family'**
  String get manageFamily;

  /// No description provided for @maxSeatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Max: {max}'**
  String maxSeatsLabel(int max);

  /// Max vehicles label
  ///
  /// In en, this message translates to:
  /// **'Max Vehicles'**
  String get maxVehicles;

  /// Error when max slots reached
  ///
  /// In en, this message translates to:
  /// **'Maximum {count} time slots allowed'**
  String maximumTimeSlotsAllowed(int count);

  /// Member role label
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// Title for member actions menu
  ///
  /// In en, this message translates to:
  /// **'Member Actions'**
  String get memberActions;

  /// Title for group actions section
  ///
  /// In en, this message translates to:
  /// **'Group Actions'**
  String get groupActions;

  /// Description for creating a new group
  ///
  /// In en, this message translates to:
  /// **'Create a new transport group for organizing family schedules'**
  String get createNewGroupDescription;

  /// Description for joining an existing group
  ///
  /// In en, this message translates to:
  /// **'Join an existing group using an invitation code or link'**
  String get joinExistingGroupDescription;

  /// Number of members in family
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String memberCount(int count);

  /// Title for member details dialog
  ///
  /// In en, this message translates to:
  /// **'Member Details'**
  String get memberDetails;

  /// Success message when member is removed from family
  ///
  /// In en, this message translates to:
  /// **'{memberName} removed from family'**
  String memberRemovedFromFamily(String memberName);

  /// Default member role text
  ///
  /// In en, this message translates to:
  /// **'MEMBER'**
  String get memberRole;

  /// Members suffix
  ///
  /// In en, this message translates to:
  /// **'members'**
  String get members;

  /// Tab label for family members
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get membersTabLabel;

  /// No description provided for @minSeatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Min: {min}'**
  String minSeatsLabel(int min);

  /// Minimum interval error
  ///
  /// In en, this message translates to:
  /// **'Minimum {minutes} minutes required between time slots'**
  String minimumIntervalRequired(int minutes);

  /// Minutes ago format for relative time
  ///
  /// In en, this message translates to:
  /// **'{count}min ago'**
  String minutesAgo(int count);

  /// No description provided for @modifiedFrom.
  ///
  /// In en, this message translates to:
  /// **'modified from {original}'**
  String modifiedFrom(int original);

  /// Tooltip for modify button (French import)
  ///
  /// In en, this message translates to:
  /// **'Modifier'**
  String get modifyTooltip;

  /// Monday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// Monday day name
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @mondayShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mondayShort;

  /// Short abbreviation for weekdays
  ///
  /// In en, this message translates to:
  /// **'Mon - Fri'**
  String get mondayToFridayShort;

  /// Month view option
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get monthView;

  /// Message for month view
  ///
  /// In en, this message translates to:
  /// **'Month view implementation'**
  String get monthViewImplementation;

  /// Accessibility label for more actions
  ///
  /// In en, this message translates to:
  /// **'More actions for'**
  String get moreActionsFor;

  /// Morning time slot
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// Month label for segmented button
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get monthLabel;

  /// Family section title
  ///
  /// In en, this message translates to:
  /// **'My family'**
  String get myFamily;

  /// Label for name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Vehicle name maximum length validation
  ///
  /// In en, this message translates to:
  /// **'Name cannot exceed 50 characters'**
  String get nameMaxLength;

  /// Vehicle name minimum length validation
  ///
  /// In en, this message translates to:
  /// **'Name must contain at least 2 characters'**
  String get nameMinLength;

  /// Label for optional name field
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get nameOptional;

  /// Navigation label for dashboard
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navigationDashboard;

  /// Short navigation label for dashboard (mobile)
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigationDashboardShort;

  /// Navigation label for family
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get navigationFamily;

  /// Navigation label for groups
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get navigationGroups;

  /// Profile navigation label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navigationProfile;

  /// Navigation label for schedule
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get navigationSchedule;

  /// Empty state message for no groups
  ///
  /// In en, this message translates to:
  /// **'You need to join or create a transport group to view schedules.'**
  String get needGroupForSchedules;

  /// Label for new admin email field
  ///
  /// In en, this message translates to:
  /// **'New Admin Email'**
  String get newAdminEmail;

  /// New child title
  ///
  /// In en, this message translates to:
  /// **'New child'**
  String get newChild;

  /// Section header for new family invitation
  ///
  /// In en, this message translates to:
  /// **'New Family Invitation'**
  String get newFamilyInvitation;

  /// New invitation update notification
  ///
  /// In en, this message translates to:
  /// **'New invitation update received'**
  String get newInvitationUpdate;

  /// Tooltip for next week button
  ///
  /// In en, this message translates to:
  /// **'Next Week'**
  String get nextWeek;

  /// Label for current week indicator
  ///
  /// In en, this message translates to:
  /// **'Current Week'**
  String get currentWeek;

  /// Label for previous week
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get lastWeek;

  /// Label for weeks in the future with ICU pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{In {count} week} other{In {count} weeks}}'**
  String inWeeks(int count);

  /// Message when no children are found
  ///
  /// In en, this message translates to:
  /// **'No children'**
  String get noChildren;

  /// Message when no children are assigned to vehicles
  ///
  /// In en, this message translates to:
  /// **'No children assigned'**
  String get noChildrenAssigned;

  /// Display vehicle count with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} vehicle} other{{count} vehicles}}'**
  String vehiclesPlural(int count);

  /// Fallback name for vehicle with no name
  ///
  /// In en, this message translates to:
  /// **'Unknown Vehicle'**
  String get unknownVehicle;

  /// Label showing additional items count
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String moreItems(int count);

  /// Message when no days are configured in schedule preview
  ///
  /// In en, this message translates to:
  /// **'No days configured'**
  String get noDaysConfigured;

  /// Message when no departure times are selected
  ///
  /// In en, this message translates to:
  /// **'No departure times selected'**
  String get noDepartureTimesSelected;

  /// Text when no expiry date is set
  ///
  /// In en, this message translates to:
  /// **'No expiry (single use)'**
  String get noExpiryDate;

  /// Title when no expiry issues
  ///
  /// In en, this message translates to:
  /// **'No Expiry Issues'**
  String get noExpiryIssues;

  /// No family found message
  ///
  /// In en, this message translates to:
  /// **'No family'**
  String get noFamily;

  /// Message when no family is available
  ///
  /// In en, this message translates to:
  /// **'No family found'**
  String get noFamilyFound;

  /// Error when family ID is not available
  ///
  /// In en, this message translates to:
  /// **'No family ID available'**
  String get noFamilyIdAvailable;

  /// Message when no invitations match filter
  ///
  /// In en, this message translates to:
  /// **'No {filterType} invitations'**
  String noFilteredInvitations(String filterType);

  /// Empty state title for no invitation codes
  ///
  /// In en, this message translates to:
  /// **'No invitation codes'**
  String get noInvitationCodes;

  /// Empty state message for no invitation codes
  ///
  /// In en, this message translates to:
  /// **'Generate invitation codes\nto facilitate joining.'**
  String get noInvitationCodesMessage;

  /// Empty state title for no invitations
  ///
  /// In en, this message translates to:
  /// **'No invitations'**
  String get noInvitations;

  /// Empty state message for no invitations
  ///
  /// In en, this message translates to:
  /// **'You have no pending invitations.\nNew invitations will appear here.'**
  String get noInvitationsMessage;

  /// Message when no invitations exist
  ///
  /// In en, this message translates to:
  /// **'No invitations yet'**
  String get noInvitationsYet;

  /// Consequence of leaving family - members
  ///
  /// In en, this message translates to:
  /// **'• No longer see family members and children'**
  String get noLongerSeeFamilyMembers;

  /// Message when no pending invitations
  ///
  /// In en, this message translates to:
  /// **'No pending invitations'**
  String get noPendingInvitations;

  /// Empty state message for no recent activity
  ///
  /// In en, this message translates to:
  /// **'No recent activity'**
  String get noRecentActivity;

  /// Empty state subtext for no recent activity section
  ///
  /// In en, this message translates to:
  /// **'Your activity will appear here'**
  String get noRecentActivityMessage;

  /// Empty state title for no sent invitations
  ///
  /// In en, this message translates to:
  /// **'No sent invitations'**
  String get noSentInvitations;

  /// Empty state message for no sent invitations
  ///
  /// In en, this message translates to:
  /// **'Invite members to your family\nor groups to get started.'**
  String get noSentInvitationsMessage;

  /// Message shown when a day has no schedule configuration
  ///
  /// In en, this message translates to:
  /// **'No schedule configured for this day'**
  String get noScheduleConfigured;

  /// No time slots message
  ///
  /// In en, this message translates to:
  /// **'No time slots configured'**
  String get noTimeSlotsConfigured;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No Transport Groups'**
  String get noTransportGroups;

  /// Empty state description
  ///
  /// In en, this message translates to:
  /// **'Create or join a transport group to coordinate school trips with other families.'**
  String get noTransportGroupsDescription;

  /// Message when no vehicles are found
  ///
  /// In en, this message translates to:
  /// **'No vehicles'**
  String get noVehicles;

  /// None status text
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// Not available text (French import)
  ///
  /// In en, this message translates to:
  /// **'Non disponible'**
  String get notAvailable;

  /// Notes field label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Notifications settings label
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Label for optional description field
  ///
  /// In en, this message translates to:
  /// **'Optional description'**
  String get optionalDescription;

  /// Label for capacity override input field
  ///
  /// In en, this message translates to:
  /// **'Override capacity'**
  String get overrideCapacity;

  /// Override capacity display
  ///
  /// In en, this message translates to:
  /// **'Override: {count}'**
  String overrideCapacityDisplay(int count);

  /// Title for seat override history section
  ///
  /// In en, this message translates to:
  /// **'Override History'**
  String get overrideHistory;

  /// Label for seat override type selection
  ///
  /// In en, this message translates to:
  /// **'Override Type'**
  String get overrideType;

  /// Paste from clipboard tooltip
  ///
  /// In en, this message translates to:
  /// **'Paste from clipboard'**
  String get pasteFromClipboard;

  /// Status indicating something is pending
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Pending invitations badge label
  ///
  /// In en, this message translates to:
  /// **'Pending Invitations'**
  String get pendingInvitations;

  /// Pending invitations label in stats
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingInvitationsStats;

  /// Personal information section title
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInformation;

  /// Error message for missing admin email
  ///
  /// In en, this message translates to:
  /// **'Please enter an email for the new admin'**
  String get pleaseEnterNewAdminEmail;

  /// Valid number validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get pleaseEnterValidNumber;

  /// Tooltip for previous week button
  ///
  /// In en, this message translates to:
  /// **'Previous Week'**
  String get previousWeek;

  /// Privacy settings label
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// Processing status message
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// Profile page title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Option to promote another member to admin
  ///
  /// In en, this message translates to:
  /// **'Promote Another Admin'**
  String get promoteAnotherAdmin;

  /// Description for promoting another admin
  ///
  /// In en, this message translates to:
  /// **'Choose a family member to promote to admin role'**
  String get promoteAnotherAdminDesc;

  /// Action to promote a family to administrator role
  ///
  /// In en, this message translates to:
  /// **'Promote to Admin'**
  String get promoteToAdmin;

  /// No description provided for @quickConfigurations.
  ///
  /// In en, this message translates to:
  /// **'Quick Configurations'**
  String get quickConfigurations;

  /// Warning message when WebSocket connection is unavailable
  ///
  /// In en, this message translates to:
  /// **'Real-time updates unavailable. Tap refresh to load latest invitations.'**
  String get realTimeUpdatesUnavailable;

  /// Label for reason input field
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// Tab label for received invitations
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// Recent activity section title
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// Refresh button tooltip
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Rejected status label
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// Rejected invitations label in stats
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejectedInvitations;

  /// Remove admin role button text
  ///
  /// In en, this message translates to:
  /// **'Remove Admin'**
  String get removeAdmin;

  /// Confirmation message for removing admin role
  ///
  /// In en, this message translates to:
  /// **'Remove admin privileges from {name}?'**
  String removeAdminConfirmation(String name);

  /// Note about admin privileges when removing member
  ///
  /// In en, this message translates to:
  /// **'Note: This member will lose admin privileges'**
  String get removeAdminNote;

  /// Option to remove member from family
  ///
  /// In en, this message translates to:
  /// **'Remove Member'**
  String get removeMember;

  /// Confirmation message for removing member
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {memberName} from the family?'**
  String removeMemberConfirmation(String memberName);

  /// Accessibility label for remove member dialog
  ///
  /// In en, this message translates to:
  /// **'Remove Member Confirmation Dialog'**
  String get removeMemberDialogAccessibilityLabel;

  /// Description for removing member option
  ///
  /// In en, this message translates to:
  /// **'Remove member from this family'**
  String get removeMemberFromFamily;

  /// Description for cancel invitation action
  ///
  /// In en, this message translates to:
  /// **'Remove this invitation'**
  String get removeThisInvitation;

  /// Tooltip for remove button (French import)
  ///
  /// In en, this message translates to:
  /// **'Supprimer'**
  String get removeTooltip;

  /// Description for leaving family option
  ///
  /// In en, this message translates to:
  /// **'Remove yourself from this family'**
  String get removeYourselfFromFamily;

  /// Button text to resend invitation
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// Button text to resend magic link
  ///
  /// In en, this message translates to:
  /// **'Resend link'**
  String get resendLink;

  /// Button to reset values to default
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Button to retry export
  ///
  /// In en, this message translates to:
  /// **'Retry Export'**
  String get retryExport;

  /// Revoke invitation menu item
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get revoke;

  /// Revoked status label
  ///
  /// In en, this message translates to:
  /// **'Revoked'**
  String get revoked;

  /// Reconnect button text
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get reconnect;

  /// Resolve button text for conflicts
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get resolve;

  /// Label for role field
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// Label displaying a user's role
  ///
  /// In en, this message translates to:
  /// **'Role: {role}'**
  String roleLabel(String role);

  /// Success message when role is updated
  ///
  /// In en, this message translates to:
  /// **'Role updated successfully for {name}'**
  String roleUpdatedSuccessfully(String name);

  /// Saturday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// Saturday day name
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @saturdayShort.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturdayShort;

  /// Short abbreviation for weekend
  ///
  /// In en, this message translates to:
  /// **'Sat - Sun'**
  String get saturdayToSundayShort;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Successfully saved status
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// Saving process message
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// Schedule menu item
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// Schedule navigation label
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleLabel;

  /// Schedule configuration section
  ///
  /// In en, this message translates to:
  /// **'Schedule Configuration'**
  String get scheduleConfiguration;

  /// Success message after saving schedule
  ///
  /// In en, this message translates to:
  /// **'Schedule configuration updated successfully'**
  String get scheduleConfigurationUpdatedSuccessfully;

  /// Schedule coordination header
  ///
  /// In en, this message translates to:
  /// **'Schedule Coordination'**
  String get scheduleCoordination;

  /// Schedule count with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} schedule} other{{count} schedules}}'**
  String scheduleCount(int count);

  /// Schedule preview title
  ///
  /// In en, this message translates to:
  /// **'Schedule Preview'**
  String get schedulePreview;

  /// Message after refreshing schedule
  ///
  /// In en, this message translates to:
  /// **'Schedule refreshed'**
  String get scheduleRefreshed;

  /// School field label
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get school;

  /// School field hint
  ///
  /// In en, this message translates to:
  /// **'School name'**
  String get schoolName;

  /// Search button tooltip and functionality
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Placeholder text for invitation search field
  ///
  /// In en, this message translates to:
  /// **'Search invitations...'**
  String get searchInvitations;

  /// Title for seat capacity management section
  ///
  /// In en, this message translates to:
  /// **'Seat Capacity Management'**
  String get seatCapacityManagement;

  /// Seating configuration section title
  ///
  /// In en, this message translates to:
  /// **'Seating Configuration'**
  String get seatingConfiguration;

  /// Label for seat capacity (lowercase)
  ///
  /// In en, this message translates to:
  /// **'seats'**
  String get seats;

  /// Secure login description
  ///
  /// In en, this message translates to:
  /// **'Secure magic link login'**
  String get secureLogin;

  /// Description for view member details option
  ///
  /// In en, this message translates to:
  /// **'See member information and activity'**
  String get seeMemberInformation;

  /// Select button text
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// Button to go back to group selection
  ///
  /// In en, this message translates to:
  /// **'Select Another Group'**
  String get selectAnotherGroup;

  /// Group selection page title
  ///
  /// In en, this message translates to:
  /// **'Select a Group'**
  String get selectGroup;

  /// Language selection description
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get selectLanguage;

  /// Dialog title for selecting member to promote
  ///
  /// In en, this message translates to:
  /// **'Select Member to Promote'**
  String get selectMemberToPromote;

  /// Label for selecting new admin
  ///
  /// In en, this message translates to:
  /// **'Select New Admin'**
  String get selectNewAdmin;

  /// Button to send family invitation
  ///
  /// In en, this message translates to:
  /// **'Send Invitation'**
  String get sendInvitation;

  /// Tooltip for send invitation FAB
  ///
  /// In en, this message translates to:
  /// **'Send invitation'**
  String get sendInvitationTooltip;

  /// Send magic link button text
  ///
  /// In en, this message translates to:
  /// **'Send Magic Link'**
  String get sendMagicLink;

  /// Button text while sending
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sendingButton;

  /// Status label for sent items
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// Error for server errors (500+)
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later'**
  String get serverError;

  /// Settings label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Action to display invitation code
  ///
  /// In en, this message translates to:
  /// **'Show Invitation Code'**
  String get showInvitationCode;

  /// Tooltip for show vehicles button
  ///
  /// In en, this message translates to:
  /// **'Show Vehicles'**
  String get showVehicles;

  /// Sign in to join button text
  ///
  /// In en, this message translates to:
  /// **'Sign In to Join {familyName}'**
  String signInToJoin(String familyName);

  /// Button text to sign in and join family
  ///
  /// In en, this message translates to:
  /// **'Sign In to Join {familyName}'**
  String signInToJoinFamilyName(String familyName);

  /// Button to sign in and join group
  ///
  /// In en, this message translates to:
  /// **'Sign In to Join {groupName}'**
  String signInToJoinGroupName(String groupName);

  /// Slots status text
  ///
  /// In en, this message translates to:
  /// **'{current}/{max} slots configured • {active} active'**
  String slotsConfigured(int current, int max, int active);

  /// Number of time slots with ICU pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} slot} other{{count} slots}}'**
  String slotsCount(num count);

  /// No description provided for @stackTrace.
  ///
  /// In en, this message translates to:
  /// **'Stack Trace'**
  String get stackTrace;

  /// No description provided for @standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  /// Tab label for invitation statistics
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Accepted status in uppercase
  ///
  /// In en, this message translates to:
  /// **'ACCEPTED'**
  String get statusAccepted;

  /// Active status
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// Cancelled status in uppercase
  ///
  /// In en, this message translates to:
  /// **'CANCELLED'**
  String get statusCancelled;

  /// Declined status in uppercase
  ///
  /// In en, this message translates to:
  /// **'DECLINED'**
  String get statusDeclined;

  /// Expired status in uppercase
  ///
  /// In en, this message translates to:
  /// **'EXPIRED'**
  String get statusExpired;

  /// Expiring soon status in uppercase
  ///
  /// In en, this message translates to:
  /// **'EXPIRING SOON'**
  String get statusExpiringSoon;

  /// Failed status in uppercase
  ///
  /// In en, this message translates to:
  /// **'FAILED'**
  String get statusFailed;

  /// Invalid status in uppercase
  ///
  /// In en, this message translates to:
  /// **'INVALID'**
  String get statusInvalid;

  /// Pending status in uppercase
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get statusPending;

  /// Revoked status in uppercase
  ///
  /// In en, this message translates to:
  /// **'REVOKED'**
  String get statusRevoked;

  /// Button to stay on current page
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// Button to stay on page
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stayButton;

  /// Option to stay in current family
  ///
  /// In en, this message translates to:
  /// **'Stay in Current Family'**
  String get stayInCurrentFamily;

  /// Description for staying in current family
  ///
  /// In en, this message translates to:
  /// **'Decline the new invitation and remain in your current family'**
  String get stayInCurrentFamilyDesc;

  /// Success message for joining group
  ///
  /// In en, this message translates to:
  /// **'Successfully joined group\\!'**
  String get successfullyJoinedGroup;

  /// Sunday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// Sunday day name
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @sundayShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sundayShort;

  /// SUV vehicle type
  ///
  /// In en, this message translates to:
  /// **'SUV'**
  String get suv;

  /// Option to switch to new family
  ///
  /// In en, this message translates to:
  /// **'Switch to New Family'**
  String get switchToNewFamily;

  /// Description for switching to new family
  ///
  /// In en, this message translates to:
  /// **'Leave your current family and join the new one'**
  String get switchToNewFamilyDesc;

  /// Sync status badge text
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// Hint text for adding first time slot
  ///
  /// In en, this message translates to:
  /// **'Tap to add first time slot'**
  String get tapToAddFirstTimeSlot;

  /// Temporary seat override type
  ///
  /// In en, this message translates to:
  /// **'Temporary'**
  String get temporary;

  /// Thursday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// Thursday day name
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @thursdayShort.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursdayShort;

  /// Time column header
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// Time ago in days
  ///
  /// In en, this message translates to:
  /// **'{days} day{plural} ago'**
  String timeAgoDays(int days, String plural);

  /// Time ago in hours
  ///
  /// In en, this message translates to:
  /// **'{hours} hour{plural} ago'**
  String timeAgoHours(int hours, String plural);

  /// Time ago in minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes} minute{plural} ago'**
  String timeAgoMinutes(int minutes, String plural);

  /// Warning when time is already selected
  ///
  /// In en, this message translates to:
  /// **'Time {time} is already selected'**
  String timeAlreadySelected(String time);

  /// Time input hint text
  ///
  /// In en, this message translates to:
  /// **'08:00'**
  String get timeHint;

  /// Time interval validation
  ///
  /// In en, this message translates to:
  /// **'Time must be in 15-minute intervals (00, 15, 30, 45)'**
  String get timeIntervalError;

  /// Time input field label
  ///
  /// In en, this message translates to:
  /// **'Time (HH:MM)'**
  String get timeLabel;

  /// Instructions for time picker widget
  ///
  /// In en, this message translates to:
  /// **'Select departure times by tapping on the time slots'**
  String get timePickerInstructions;

  /// Time range display
  ///
  /// In en, this message translates to:
  /// **'Time range: {range}'**
  String timeRange(String range);

  /// Duplicate time slot error
  ///
  /// In en, this message translates to:
  /// **'This time slot already exists'**
  String get timeSlotExists;

  /// Time slots section header in help dialog
  ///
  /// In en, this message translates to:
  /// **'Time Slots'**
  String get timeSlots;

  /// Number of selected time slots with ICU pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No time slots selected} =1{{count} time slot selected} other{{count} time slots selected}}'**
  String timeSlotsSelected(num count);

  /// Today time indicator
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Label for total seats
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Total children count with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No children} =1{1 child} other{{count} children}}'**
  String totalChildrenCount(int count);

  /// Total members count with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No members} =1{1 member} other{{count} members}}'**
  String totalMembersCount(int count);

  /// Total vehicles count with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No vehicles} =1{1 vehicle} other{{count} vehicles}}'**
  String totalVehiclesCount(int count);

  /// Total capacity label in summary card
  ///
  /// In en, this message translates to:
  /// **'Total capacity'**
  String get totalCapacity;

  /// Display of total seat count
  ///
  /// In en, this message translates to:
  /// **'Total: {count}'**
  String totalSeats(int count);

  /// Vehicle capacity field hint text
  ///
  /// In en, this message translates to:
  /// **'Total number of seats'**
  String get totalSeatsHint;

  /// Option to transfer ownership
  ///
  /// In en, this message translates to:
  /// **'Transfer Ownership'**
  String get transferOwnership;

  /// Description for transferring ownership
  ///
  /// In en, this message translates to:
  /// **'Transfer full ownership of the family to another member'**
  String get transferOwnershipDesc;

  /// Warning message for ownership transfer
  ///
  /// In en, this message translates to:
  /// **'This will transfer full ownership and admin rights to the selected member. This action cannot be undone.'**
  String get transferOwnershipWarning;

  /// Transport groups page title
  ///
  /// In en, this message translates to:
  /// **'Transport Groups'**
  String get transportGroups;

  /// Placeholder message for trip creation form
  ///
  /// In en, this message translates to:
  /// **'Trip creation form to implement'**
  String get tripCreationFormToImplement;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Tuesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// Tuesday day name
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @tuesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesdayShort;

  /// Instruction for confirmation text
  ///
  /// In en, this message translates to:
  /// **'Type \'{confirmText}\' to confirm:'**
  String typeToConfirm(String confirmText);

  /// Universal invitation type title
  ///
  /// In en, this message translates to:
  /// **'Universal invitation'**
  String get universalInvitation;

  /// Default text when family name is unknown
  ///
  /// In en, this message translates to:
  /// **'Unknown Family'**
  String get unknownFamily;

  /// Dialog title for unsaved changes
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsavedChanges;

  /// Dialog title for unsaved changes
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsavedChangesTitle;

  /// Update vehicle button text
  ///
  /// In en, this message translates to:
  /// **'Update Vehicle'**
  String get updateVehicle;

  /// Generic updating status text
  ///
  /// In en, this message translates to:
  /// **'Updating'**
  String get updating;

  /// Usage indicator label
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get usage;

  /// User menu title
  ///
  /// In en, this message translates to:
  /// **'User Menu'**
  String get userMenu;

  /// User profile options placeholder text
  ///
  /// In en, this message translates to:
  /// **'User profile options would appear here'**
  String get userProfileOptions;

  /// User role display
  ///
  /// In en, this message translates to:
  /// **'Role: {role}'**
  String userRole(String role);

  /// Button text to validate invitation code
  ///
  /// In en, this message translates to:
  /// **'Validate Code'**
  String get validateCode;

  /// Loading message for group invitation validation
  ///
  /// In en, this message translates to:
  /// **'Validating group invitation...'**
  String get validatingGroupInvitation;

  /// Validating invitation state text
  ///
  /// In en, this message translates to:
  /// **'Validating invitation...'**
  String get validatingInvitation;

  /// Van vehicle type
  ///
  /// In en, this message translates to:
  /// **'Van'**
  String get van;

  /// Success message when vehicle is added
  ///
  /// In en, this message translates to:
  /// **'Vehicle added successfully'**
  String get vehicleAddedSuccessfully;

  /// Vehicle assignment display
  ///
  /// In en, this message translates to:
  /// **'Vehicle Assignment: {vehicleId}'**
  String vehicleAssignment(String vehicleId);

  /// Vehicle count with ICU pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} vehicle} other{{count} vehicles}}'**
  String vehicleCount(num count);

  /// Title for vehicle information screen
  ///
  /// In en, this message translates to:
  /// **'Vehicle details'**
  String get vehicleDetails;

  /// Vehicle ID field label
  ///
  /// In en, this message translates to:
  /// **'Vehicle ID'**
  String get vehicleId;

  /// Vehicle information section title
  ///
  /// In en, this message translates to:
  /// **'Vehicle Information'**
  String get vehicleInformation;

  /// Vehicle name field label
  ///
  /// In en, this message translates to:
  /// **'Vehicle Name'**
  String get vehicleName;

  /// Vehicle name field label with required indicator
  ///
  /// In en, this message translates to:
  /// **'Vehicle name *'**
  String get vehicleNameRequired;

  /// Error when vehicle is not found
  ///
  /// In en, this message translates to:
  /// **'Vehicle not found'**
  String get vehicleNotFound;

  /// Vehicle type selection section title
  ///
  /// In en, this message translates to:
  /// **'Vehicle type'**
  String get vehicleType;

  /// Success message when vehicle is updated
  ///
  /// In en, this message translates to:
  /// **'Vehicle updated successfully'**
  String get vehicleUpdatedSuccessfully;

  /// Vehicles page title and section label
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get vehicles;

  /// Success message when vehicle is added
  ///
  /// In en, this message translates to:
  /// **'{vehicleName} added successfully'**
  String vehicleAddedSuccess(String vehicleName);

  /// Error message when vehicle addition fails
  ///
  /// In en, this message translates to:
  /// **'Failed to add vehicle: {error}'**
  String vehicleFailedToAdd(String error);

  /// Info message when vehicle is already assigned to a slot
  ///
  /// In en, this message translates to:
  /// **'{vehicleName} is already assigned to this slot'**
  String vehicleAlreadyAssigned(String vehicleName);

  /// Error message when vehicle removal fails
  ///
  /// In en, this message translates to:
  /// **'Failed to remove vehicle: {error}'**
  String vehicleFailedToRemove(String error);

  /// Success message when vehicle is removed
  ///
  /// In en, this message translates to:
  /// **'{vehicleName} removed successfully'**
  String vehicleRemovedSuccess(String vehicleName);

  /// Title shown when magic link verification fails
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get verificationFailedTitle;

  /// View button text
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// Button text to view all items
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// View details action label
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// Button to view group schedule
  ///
  /// In en, this message translates to:
  /// **'View Group Schedule'**
  String get viewGroupSchedule;

  /// Option to view member details
  ///
  /// In en, this message translates to:
  /// **'View Member Details'**
  String get viewMemberDetails;

  /// Wednesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// Wednesday day name
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @wednesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesdayShort;

  /// Week label for segmented button
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get weekLabel;

  /// Week view option
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get weekView;

  /// Message for week view
  ///
  /// In en, this message translates to:
  /// **'Week view implementation'**
  String get weekViewImplementation;

  /// Weekdays count with ICU pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} weekday} other{{count} weekdays}}'**
  String weekdaysCount(num count);

  /// Weekdays only selection option
  ///
  /// In en, this message translates to:
  /// **'Weekdays Only'**
  String get weekdaysOnly;

  /// Weekend days count with ICU pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} weekend day} other{{count} weekend days}}'**
  String weekendDaysCount(num count);

  /// Weekends only selection option
  ///
  /// In en, this message translates to:
  /// **'Weekends Only'**
  String get weekendsOnly;

  /// Weekly schedule page title
  ///
  /// In en, this message translates to:
  /// **'Weekly Schedule'**
  String get weeklySchedule;

  /// Weekly slot total with ICU pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} slot per week} other{{count} slots per week}}'**
  String weeklySlotTotal(num count);

  /// Welcome message for new users who need to provide their name
  ///
  /// In en, this message translates to:
  /// **'Welcome! We see you\'re new. Please provide your name to complete your account.'**
  String get welcomeNewUser;

  /// Welcome message on login page
  ///
  /// In en, this message translates to:
  /// **'Welcome to EduLift'**
  String get welcomeToEduLiftLogin;

  /// Hint text for reason input
  ///
  /// In en, this message translates to:
  /// **'Why is this override needed?'**
  String get whyOverrideNeeded;

  /// Yesterday time indicator
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Label indicating current user
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// Warning that user is the last admin
  ///
  /// In en, this message translates to:
  /// **'You are the last admin'**
  String get youAreLastAdmin;

  /// Shows user's role when leaving family
  ///
  /// In en, this message translates to:
  /// **'You are leaving as: {role}'**
  String youAreLeavingAs(String role);

  /// Success message after leaving family
  ///
  /// In en, this message translates to:
  /// **'You have left the family'**
  String get youHaveLeftFamily;

  /// Text shown when user has been invited to join a family
  ///
  /// In en, this message translates to:
  /// **'You\'ve been invited to join'**
  String get youveBeenInvitedToJoin;

  /// Message shown when group invitation code is valid
  ///
  /// In en, this message translates to:
  /// **'This group invitation is valid and ready to use.'**
  String get validGroupInvitation;

  /// Title shown while magic link is being verified
  ///
  /// In en, this message translates to:
  /// **'Verifying Magic Link'**
  String get verifyingMagicLink;

  /// Message shown while magic link is being verified
  ///
  /// In en, this message translates to:
  /// **'Please wait while we verify your magic link...'**
  String get verifyingMagicLinkMessage;

  /// Title shown when magic link verification succeeds
  ///
  /// In en, this message translates to:
  /// **'Verification Successful'**
  String get verificationSuccessful;

  /// Welcome message after successful magic link verification
  ///
  /// In en, this message translates to:
  /// **'Welcome to EduLift! Taking you to your dashboard...'**
  String get welcomeAfterMagicLinkSuccess;

  /// Authentication security label
  ///
  /// In en, this message translates to:
  /// **'Secure Authentication'**
  String get secureAuthentication;

  /// Button tooltip to cancel unsaved changes
  ///
  /// In en, this message translates to:
  /// **'Cancel Changes'**
  String get cancelChanges;

  /// Button tooltip to save configuration
  ///
  /// In en, this message translates to:
  /// **'Save Configuration'**
  String get saveConfiguration;

  /// Validation section header
  ///
  /// In en, this message translates to:
  /// **'Validation'**
  String get validation;

  /// Tooltip for weekday quick selection menu
  ///
  /// In en, this message translates to:
  /// **'Quick selection options'**
  String get quickSelectionOptions;

  /// Header for weekday selector
  ///
  /// In en, this message translates to:
  /// **'Active Schedule Days'**
  String get activeScheduleDays;

  /// Shows count of selected days
  ///
  /// In en, this message translates to:
  /// **'{count}/7 days selected'**
  String daysSelected(int count);

  /// Warning when trying to deselect last day
  ///
  /// In en, this message translates to:
  /// **'At least one day must be selected'**
  String get atLeastOneDayRequired;

  /// Warning when no days are selected
  ///
  /// In en, this message translates to:
  /// **'No days selected. Schedule will be disabled.'**
  String get noDaysSelectedWarning;

  /// Label showing schedule is active
  ///
  /// In en, this message translates to:
  /// **'Schedule Active'**
  String get scheduleActive;

  /// Monday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayAbbrevMon;

  /// Tuesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayAbbrevTue;

  /// Wednesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayAbbrevWed;

  /// Thursday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayAbbrevThu;

  /// Friday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayAbbrevFri;

  /// Saturday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdayAbbrevSat;

  /// Sunday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdayAbbrevSun;

  /// Weekend label badge
  ///
  /// In en, this message translates to:
  /// **'Weekend'**
  String get weekendLabel;

  /// Placeholder for email input field
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get enterEmailAddress;

  /// Validation error for invalid email
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// Success message after sending invitation
  ///
  /// In en, this message translates to:
  /// **'Invitation sent successfully'**
  String get invitationSentSuccessfully;

  /// Button to add a child
  ///
  /// In en, this message translates to:
  /// **'Add Child'**
  String get addChildButton;

  /// Button to save vehicle
  ///
  /// In en, this message translates to:
  /// **'Save Vehicle'**
  String get saveVehicle;

  /// Button to select time slot
  ///
  /// In en, this message translates to:
  /// **'Select Time Slot'**
  String get selectTimeSlot;

  /// Button to confirm schedule
  ///
  /// In en, this message translates to:
  /// **'Confirm Schedule'**
  String get confirmSchedule;

  /// Success message after confirming schedule
  ///
  /// In en, this message translates to:
  /// **'Schedule confirmed'**
  String get scheduleConfirmed;

  /// Schedule details page title
  ///
  /// In en, this message translates to:
  /// **'Schedule Details'**
  String get scheduleDetails;

  /// Button to edit schedule
  ///
  /// In en, this message translates to:
  /// **'Edit Schedule'**
  String get editSchedule;

  /// Welcome message in onboarding
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeOnboarding;

  /// Get started button in onboarding
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Skip button in onboarding
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipOnboarding;

  /// Next button in onboarding
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextOnboarding;

  /// Validation error when name is missing
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// Dashboard page title
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// Button to create family
  ///
  /// In en, this message translates to:
  /// **'Create Family'**
  String get createFamilyButton;

  /// Label for family name input
  ///
  /// In en, this message translates to:
  /// **'Family Name'**
  String get familyNameLabel;

  /// Success message after saving schedule configuration
  ///
  /// In en, this message translates to:
  /// **'Schedule configuration saved successfully'**
  String get scheduleConfigSavedSuccess;

  /// Error message with dynamic error text
  ///
  /// In en, this message translates to:
  /// **'Failed to save configuration: {error}'**
  String scheduleConfigSaveFailed(String error);

  /// Error message when save operation fails
  ///
  /// In en, this message translates to:
  /// **'Save operation did not complete successfully'**
  String get saveOperationFailed;

  /// Error message with exception details
  ///
  /// In en, this message translates to:
  /// **'Failed to save configuration: {error}'**
  String scheduleConfigSaveException(String exception, Object error);

  /// Message when changes are canceled and reverted
  ///
  /// In en, this message translates to:
  /// **'Changes canceled - reverted to original configuration'**
  String get changesCanceledReverted;

  /// Warning dialog for unsaved schedule changes
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes to the schedule configuration. Are you sure you want to leave without saving?'**
  String get unsavedChangesScheduleMessage;

  /// Error message when group is not accessible
  ///
  /// In en, this message translates to:
  /// **'The group could not be found or you no longer have access to it.'**
  String get groupNotFoundOrNoAccess;

  /// Error message when group details fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load group details'**
  String get failedToLoadGroupDetails;

  /// Label for name input field
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourNameLabel;

  /// Hint text for full name input
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullNameHint;

  /// Label for optional personal message field
  ///
  /// In en, this message translates to:
  /// **'Personal Message (Optional)'**
  String get personalMessageOptionalLabel;

  /// Placeholder for personal message field
  ///
  /// In en, this message translates to:
  /// **'Add a personal message to your invitation...'**
  String get addPersonalMessageHint;

  /// Label for optional age input field
  ///
  /// In en, this message translates to:
  /// **'Age (optional)'**
  String get ageOptionalLabel;

  /// Hint text for age input
  ///
  /// In en, this message translates to:
  /// **'Enter age'**
  String get enterAgeHint;

  /// Unit of time for age
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get yearsUnit;

  /// Hint text for family name input with example
  ///
  /// In en, this message translates to:
  /// **'Enter family name (e.g., Smith Family)'**
  String get enterFamilyNameHint;

  /// Hint text for optional family description
  ///
  /// In en, this message translates to:
  /// **'Describe your family (optional)'**
  String get describeFamilyOptionalHint;

  /// Hint text for invitation code input
  ///
  /// In en, this message translates to:
  /// **'Family invitation code'**
  String get familyInvitationCodeHint;

  /// Hint text for email input field
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get enterEmailAddressHint;

  /// Validation error when name is too short
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameTooShort;

  /// Validation error when family name is empty
  ///
  /// In en, this message translates to:
  /// **'Family name cannot be empty'**
  String get familyNameCannotBeEmpty;

  /// Validation error when family name is too short
  ///
  /// In en, this message translates to:
  /// **'Family name must be at least 2 characters'**
  String get familyNameTooShortValidation;

  /// Information banner for new group default configuration
  ///
  /// In en, this message translates to:
  /// **'Configure departure hours for each day and save to activate the schedule.'**
  String get defaultGroupConfigInfo;

  /// Dialog title for promoting user to admin
  ///
  /// In en, this message translates to:
  /// **'Make Admin'**
  String get makeAdminTitle;

  /// Dialog title for removing admin role
  ///
  /// In en, this message translates to:
  /// **'Remove Admin Role'**
  String get removeAdminRoleTitle;

  /// Button text to make user admin
  ///
  /// In en, this message translates to:
  /// **'Make Admin'**
  String get makeAdminButton;

  /// Button text to remove admin role
  ///
  /// In en, this message translates to:
  /// **'Remove Admin'**
  String get removeAdminButton;

  /// Action title to add a child
  ///
  /// In en, this message translates to:
  /// **'Add Child'**
  String get addChildAction;

  /// Action title to join a group
  ///
  /// In en, this message translates to:
  /// **'Join a Group'**
  String get joinGroupAction;

  /// Action title to add a vehicle
  ///
  /// In en, this message translates to:
  /// **'Add Vehicle'**
  String get addVehicleAction;

  /// Tooltip for schedule configuration button
  ///
  /// In en, this message translates to:
  /// **'Configure Schedule'**
  String get configureScheduleTooltip;

  /// Tooltip for remove vehicle button
  ///
  /// In en, this message translates to:
  /// **'Remove Vehicle'**
  String get removeVehicleTooltip;

  /// Tooltip for edit time button
  ///
  /// In en, this message translates to:
  /// **'Edit time'**
  String get editTimeTooltip;

  /// Tooltip for delete time button
  ///
  /// In en, this message translates to:
  /// **'Delete time'**
  String get deleteTimeTooltip;

  /// Tooltip for conflict resolution button
  ///
  /// In en, this message translates to:
  /// **'Resolve schedule conflicts'**
  String get resolveScheduleConflictsTooltip;

  /// Tooltip for refresh button
  ///
  /// In en, this message translates to:
  /// **'Refresh schedule'**
  String get refreshScheduleTooltip;

  /// Tooltip for filter button
  ///
  /// In en, this message translates to:
  /// **'Filter and sort options'**
  String get filterAndSortOptionsTooltip;

  /// Tooltip for logout button
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTooltip;

  /// Semantic label for retry button
  ///
  /// In en, this message translates to:
  /// **'Try loading configuration again'**
  String get tryLoadingConfigAgainLabel;

  /// Semantic label for day selector
  ///
  /// In en, this message translates to:
  /// **'Switch to {day} configuration'**
  String switchToDayConfigurationLabel(String day);

  /// Semantic hint for configured departure hours
  ///
  /// In en, this message translates to:
  /// **'{count} departure hours configured'**
  String departureHoursConfiguredHint(int count);

  /// Semantic hint when no departure hours
  ///
  /// In en, this message translates to:
  /// **'No departure hours configured'**
  String get noDepartureHoursConfiguredHint;

  /// Semantic label for view conflicts button
  ///
  /// In en, this message translates to:
  /// **'View schedule conflicts'**
  String get viewScheduleConflictsLabel;

  /// Semantic label for refresh button
  ///
  /// In en, this message translates to:
  /// **'Refresh schedule'**
  String get refreshScheduleLabel;

  /// Semantic label for filter button
  ///
  /// In en, this message translates to:
  /// **'Filter schedule'**
  String get filterScheduleLabel;

  /// Semantic label for event with time
  ///
  /// In en, this message translates to:
  /// **'{eventTitle} at {time}'**
  String eventAtTimeLabel(String eventTitle, String time);

  /// Semantic label for family name input field
  ///
  /// In en, this message translates to:
  /// **'Family name input field'**
  String get familyNameInputFieldLabel;

  /// Semantic label for family description input field
  ///
  /// In en, this message translates to:
  /// **'Family description input field'**
  String get familyDescriptionInputFieldLabel;

  /// Semantic label for create family button
  ///
  /// In en, this message translates to:
  /// **'Create family button'**
  String get createFamilyButtonLabel;

  /// Semantic label for cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel button'**
  String get cancelButtonLabel;

  /// Button to remove vehicle from selection
  ///
  /// In en, this message translates to:
  /// **'Remove Vehicle'**
  String get removeVehicle;

  /// Button to edit time slot
  ///
  /// In en, this message translates to:
  /// **'Edit time'**
  String get editTime;

  /// Button to delete time slot
  ///
  /// In en, this message translates to:
  /// **'Delete time'**
  String get deleteTime;

  /// Action to resolve scheduling conflicts
  ///
  /// In en, this message translates to:
  /// **'Resolve schedule conflicts'**
  String get resolveScheduleConflicts;

  /// Action to refresh schedule data
  ///
  /// In en, this message translates to:
  /// **'Refresh schedule'**
  String get refreshSchedule;

  /// Options for filtering and sorting schedule
  ///
  /// In en, this message translates to:
  /// **'Filter and sort options'**
  String get filterAndSortOptions;

  /// Label for member join date in family
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joinedDate;

  /// Placeholder for age input field
  ///
  /// In en, this message translates to:
  /// **'Enter age'**
  String get enterAge;

  /// Placeholder for email input field
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get enterYourEmailAddress;

  /// Semantic label for biometric authentication button
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication button'**
  String get biometricAuthenticationButton;

  /// Semantic label for WebSocket status indicator
  ///
  /// In en, this message translates to:
  /// **'WebSocket connection status'**
  String get websocketConnectionStatus;

  /// Semantic label for welcome section
  ///
  /// In en, this message translates to:
  /// **'Welcome Section'**
  String get welcomeSection;

  /// Semantic label for current date and dashboard description
  ///
  /// In en, this message translates to:
  /// **'Current date and dashboard description'**
  String get currentDateAndDashboardDescription;

  /// Semantic label for family overview section
  ///
  /// In en, this message translates to:
  /// **'Family Overview Section'**
  String get familyOverviewSection;

  /// Semantic label for welcome icon
  ///
  /// In en, this message translates to:
  /// **'Welcome icon'**
  String get welcomeIcon;

  /// Semantic label for family icon
  ///
  /// In en, this message translates to:
  /// **'Family icon'**
  String get familyIcon;

  /// Semantic label for loading state
  ///
  /// In en, this message translates to:
  /// **'Loading family information'**
  String get loadingFamilyInformation;

  /// Semantic label for error state
  ///
  /// In en, this message translates to:
  /// **'Error loading family information'**
  String get errorLoadingFamilyInformation;

  /// Semantic label for error icon
  ///
  /// In en, this message translates to:
  /// **'Error icon'**
  String get errorIcon;

  /// Semantic label for quick actions section
  ///
  /// In en, this message translates to:
  /// **'Quick Actions Section'**
  String get quickActionsSection;

  /// Semantic label for recent activities section
  ///
  /// In en, this message translates to:
  /// **'Recent Activities Section'**
  String get recentActivitiesSection;

  /// Semantic label for no activity icon
  ///
  /// In en, this message translates to:
  /// **'No recent activity icon'**
  String get noRecentActivityIcon;

  /// Semantic label for upcoming trips section
  ///
  /// In en, this message translates to:
  /// **'Upcoming Trips Section'**
  String get upcomingTripsSection;

  /// Semantic label for no trips icon
  ///
  /// In en, this message translates to:
  /// **'No trips scheduled icon'**
  String get noTripsScheduledIcon;

  /// Generic unexpected error message
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get unexpectedErrorOccurred;

  /// Error message when magic link sending fails
  ///
  /// In en, this message translates to:
  /// **'Failed to send magic link - empty response'**
  String get failedToSendMagicLink;

  /// WebSocket notification for vehicle near capacity
  ///
  /// In en, this message translates to:
  /// **'Vehicle Near Capacity'**
  String get vehicleNearCapacity;

  /// WebSocket notification for expired family invitation
  ///
  /// In en, this message translates to:
  /// **'Family Invitation Expired'**
  String get familyInvitationExpired;

  /// WebSocket notification for group membership update
  ///
  /// In en, this message translates to:
  /// **'Group Membership Updated'**
  String get groupMembershipUpdated;

  /// WebSocket notification for data refresh
  ///
  /// In en, this message translates to:
  /// **'Data Refresh'**
  String get dataRefresh;

  /// Link to view schedule conflict details
  ///
  /// In en, this message translates to:
  /// **'View conflict details'**
  String get viewConflictDetails;

  /// WebSocket reconnection status message
  ///
  /// In en, this message translates to:
  /// **'Attempting to reconnect...'**
  String get attemptingToReconnect;

  /// WebSocket connected status message
  ///
  /// In en, this message translates to:
  /// **'Real-time updates are active'**
  String get realtimeUpdatesActive;

  /// WebSocket connecting status message
  ///
  /// In en, this message translates to:
  /// **'Connecting to real-time updates...'**
  String get connectingToRealtimeUpdates;

  /// Data synchronization status message
  ///
  /// In en, this message translates to:
  /// **'Synchronizing data...'**
  String get synchronizingData;

  /// Semantic label for user avatar
  ///
  /// In en, this message translates to:
  /// **'User avatar for {userName}'**
  String userAvatarFor(String userName);

  /// Welcome back message with user name
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {userName}!'**
  String welcomeBackUser(String userName);

  /// Semantic label for current date display
  ///
  /// In en, this message translates to:
  /// **'Current date and dashboard description'**
  String get currentDateAndDashboardDesc;

  /// Transport dashboard title with date
  ///
  /// In en, this message translates to:
  /// **'Your transport dashboard • {date}'**
  String yourTransportDashboard(String date);

  /// Semantic label for family statistics
  ///
  /// In en, this message translates to:
  /// **'Family statistics: {members} members, {children} children, {vehicles} vehicles'**
  String familyStatistics(int members, int children, int vehicles);

  /// Quick action description for adding a child
  ///
  /// In en, this message translates to:
  /// **'Register for transport'**
  String get registerForTransport;

  /// Quick action description for joining a group
  ///
  /// In en, this message translates to:
  /// **'Connect with other families'**
  String get connectWithOtherFamilies;

  /// Quick action description for adding a vehicle
  ///
  /// In en, this message translates to:
  /// **'Offer rides to others'**
  String get offerRidesToOthers;

  /// Label indicating user login status
  ///
  /// In en, this message translates to:
  /// **'Logged in as'**
  String get loggedInAs;

  /// Instruction message for new users
  ///
  /// In en, this message translates to:
  /// **'To get started, you need to set up your family.'**
  String get toGetStartedSetupFamily;

  /// Loading message during onboarding setup
  ///
  /// In en, this message translates to:
  /// **'Setting up your onboarding...'**
  String get settingUpOnboarding;

  /// Message when user has pending family invitation
  ///
  /// In en, this message translates to:
  /// **'You\'ve been invited to join a family!'**
  String get youveBeenInvitedToJoinFamily;

  /// Instruction to accept family invitation
  ///
  /// In en, this message translates to:
  /// **'Accept the invitation to start coordinating with other families.'**
  String get acceptInvitationToCoordinate;

  /// Title for family setup choice
  ///
  /// In en, this message translates to:
  /// **'Choose Your Family Setup'**
  String get chooseYourFamilySetup;

  /// Button text to join an existing family
  ///
  /// In en, this message translates to:
  /// **'Join Existing Family'**
  String get joinExistingFamily;

  /// Group members page title
  ///
  /// In en, this message translates to:
  /// **'{groupName} - Members'**
  String groupMembersPageTitle(String groupName);

  /// Confirmation message for promoting family to admin
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to promote \"{familyName}\" to Administrator? They will be able to manage group members and settings.'**
  String promoteToAdminConfirm(String familyName);

  /// Promote button text
  ///
  /// In en, this message translates to:
  /// **'Promote'**
  String get promote;

  /// Success message when family is promoted
  ///
  /// In en, this message translates to:
  /// **'Family promoted to Admin successfully'**
  String get familyPromotedSuccess;

  /// Error message when promotion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to promote family'**
  String get failedToPromoteFamily;

  /// Action to demote a family to member role
  ///
  /// In en, this message translates to:
  /// **'Demote to Member'**
  String get demoteToMember;

  /// Confirmation message for demoting family to member
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to demote \"{familyName}\" to Member? They will lose administrative privileges.'**
  String demoteToMemberConfirm(String familyName);

  /// Demote button text
  ///
  /// In en, this message translates to:
  /// **'Demote'**
  String get demote;

  /// Success message when family is demoted
  ///
  /// In en, this message translates to:
  /// **'Family demoted to Member successfully'**
  String get familyDemotedSuccess;

  /// Error message when demotion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to demote family'**
  String get failedToDemoteFamily;

  /// Action to remove a family from group
  ///
  /// In en, this message translates to:
  /// **'Remove Family'**
  String get removeFamily;

  /// Confirmation message for removing family
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove \"{familyName}\" from the group? This action cannot be undone.'**
  String removeFamilyConfirm(String familyName);

  /// Remove button text in confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeFamilyAction;

  /// Success message when family is removed
  ///
  /// In en, this message translates to:
  /// **'Family removed successfully'**
  String get familyRemovedSuccess;

  /// Error message when removing a family from a group fails
  ///
  /// In en, this message translates to:
  /// **'Failed to remove family: {error}'**
  String failedToRemoveFamily(String error);

  /// Action menu item to remove family from group
  ///
  /// In en, this message translates to:
  /// **'Remove from Group'**
  String get removeFromGroup;

  /// Confirmation message for canceling invitation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel the invitation for \"{familyName}\"?'**
  String cancelInvitationConfirm(String familyName);

  /// Success message when invitation is canceled
  ///
  /// In en, this message translates to:
  /// **'Invitation canceled successfully'**
  String get invitationCanceledSuccess;

  /// Error message when canceling invitation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel invitation: {error}'**
  String failedToCancelInvitation(String error);

  /// Error message when invitation ID is missing
  ///
  /// In en, this message translates to:
  /// **'No invitation ID found'**
  String get noInvitationIdFound;

  /// Generic error message with error details
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String anErrorOccurred(String error);

  /// Owner role badge text
  ///
  /// In en, this message translates to:
  /// **'OWNER'**
  String get roleOwner;

  /// Admin role badge text
  ///
  /// In en, this message translates to:
  /// **'ADMIN'**
  String get roleAdmin;

  /// Member role badge text
  ///
  /// In en, this message translates to:
  /// **'MEMBER'**
  String get roleMember;

  /// Pending invitation role badge text
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get rolePending;

  /// Description of member role permissions
  ///
  /// In en, this message translates to:
  /// **'Can view and join group trips'**
  String get roleMemberDescription;

  /// Description of admin role permissions
  ///
  /// In en, this message translates to:
  /// **'Can manage group and invite members'**
  String get roleAdminDescription;

  /// Text shown when family has no admins
  ///
  /// In en, this message translates to:
  /// **'No admins'**
  String get noAdmins;

  /// Admin count with additional admins indicator
  ///
  /// In en, this message translates to:
  /// **'{firstName} (+{count} more)'**
  String adminCountMore(String firstName, int count);

  /// Indicator for user's own family
  ///
  /// In en, this message translates to:
  /// **'Your Family'**
  String get yourFamily;

  /// Button to invite a family to the group
  ///
  /// In en, this message translates to:
  /// **'Invite Family'**
  String get inviteFamily;

  /// Placeholder message for invite family feature
  ///
  /// In en, this message translates to:
  /// **'Invite family feature coming soon'**
  String get inviteFamilyComingSoon;

  /// Empty state title when no families in group
  ///
  /// In en, this message translates to:
  /// **'No families yet'**
  String get noFamiliesYet;

  /// Empty state message to invite families
  ///
  /// In en, this message translates to:
  /// **'Invite families to get started'**
  String get inviteFamiliesToGetStarted;

  /// Loading state message for families
  ///
  /// In en, this message translates to:
  /// **'Loading families...'**
  String get loadingFamilies;

  /// Error state title when loading families fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load families'**
  String get failedToLoadFamilies;

  /// Title of invite family dialog
  ///
  /// In en, this message translates to:
  /// **'Invite Family to Group'**
  String get inviteFamilyToGroup;

  /// Subtitle of invite family dialog
  ///
  /// In en, this message translates to:
  /// **'Search and invite families to join this group'**
  String get inviteFamilyToGroupSubtitle;

  /// Label for family search field
  ///
  /// In en, this message translates to:
  /// **'Search Families'**
  String get searchFamilies;

  /// Placeholder for family search field
  ///
  /// In en, this message translates to:
  /// **'Enter family name...'**
  String get enterFamilyName;

  /// Label for role selector
  ///
  /// In en, this message translates to:
  /// **'Invite as:'**
  String get inviteAs;

  /// Label for optional personal message field
  ///
  /// In en, this message translates to:
  /// **'Personal Message (Optional)'**
  String get personalMessageOptional;

  /// Header for search results section
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// Message shown when search results reach the limit
  ///
  /// In en, this message translates to:
  /// **'Showing maximum results. Refine your search to see more specific matches.'**
  String get refineSearchForMoreResults;

  /// Indicator showing additional items not displayed
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String andXMore(int count);

  /// Prompt to enter minimum characters for search
  ///
  /// In en, this message translates to:
  /// **'Enter at least 2 characters to search'**
  String get enterAtLeast2Characters;

  /// Empty state when search returns no results
  ///
  /// In en, this message translates to:
  /// **'No families found'**
  String get noFamiliesFound;

  /// Badge shown when family is already invited
  ///
  /// In en, this message translates to:
  /// **'Already invited'**
  String get alreadyInvited;

  /// Button text while invitation is being sent
  ///
  /// In en, this message translates to:
  /// **'Inviting...'**
  String get inviting;

  /// Error message when search fails
  ///
  /// In en, this message translates to:
  /// **'Search failed: {error}'**
  String searchFailed(String error);

  /// Success message when invitation is sent
  ///
  /// In en, this message translates to:
  /// **'Invitation sent to {familyName}'**
  String invitationSent(String familyName);

  /// Error message when invitation fails
  ///
  /// In en, this message translates to:
  /// **'Invitation failed: {error}'**
  String invitationFailed(String error);

  /// Title for member management section
  ///
  /// In en, this message translates to:
  /// **'Manage Members'**
  String get manageMembers;

  /// Description for member management section
  ///
  /// In en, this message translates to:
  /// **'Manage family members, roles, and invitations for this group'**
  String get manageMembersDescription;

  /// Label for pending invitation status
  ///
  /// In en, this message translates to:
  /// **'Pending Invitation'**
  String get pendingInvitation;

  /// Description for cancel invitation action
  ///
  /// In en, this message translates to:
  /// **'Revoke this pending invitation'**
  String get cancelInvitationDescription;

  /// Description for promote to admin action
  ///
  /// In en, this message translates to:
  /// **'Grant admin permissions to this family'**
  String get promoteToAdminDescription;

  /// Description for demote to member action
  ///
  /// In en, this message translates to:
  /// **'Remove admin permissions from this family'**
  String get demoteToMemberDescription;

  /// Description for remove family action
  ///
  /// In en, this message translates to:
  /// **'Remove this family from the group'**
  String get removeFamilyFromGroupDescription;

  /// Confirmation message for promoting family to admin
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to promote {familyName} to group admin?'**
  String promoteToAdminConfirmation(String familyName);

  /// Note about admin permissions
  ///
  /// In en, this message translates to:
  /// **'Admins can manage group members and schedules'**
  String get adminCanManageGroupMembers;

  /// Confirmation message for demoting family to member
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to demote {familyName} to member?'**
  String demoteToMemberConfirmation(String familyName);

  /// Warning note for demotion
  ///
  /// In en, this message translates to:
  /// **'This family will lose admin permissions'**
  String get demoteToMemberNote;

  /// Accessibility label for remove family dialog
  ///
  /// In en, this message translates to:
  /// **'Remove family from group'**
  String get removeFamilyDialogAccessibilityLabel;

  /// Confirmation message for removing family from group
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {familyName} from this group?'**
  String removeFamilyConfirmation(String familyName);

  /// Warning note when removing admin family
  ///
  /// In en, this message translates to:
  /// **'Warning: This admin family will be removed from the group'**
  String get removeAdminFamilyNote;

  /// Label showing when invitation was sent
  ///
  /// In en, this message translates to:
  /// **'Invited on {date}'**
  String invitedOn(String date);

  /// Confirmation message for canceling invitation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel the invitation for {familyName}?'**
  String cancelInvitationConfirmation(String familyName);

  /// Note about canceling invitation
  ///
  /// In en, this message translates to:
  /// **'The family will not be able to join with this invitation link'**
  String get cancelInvitationNote;

  /// Error when family already has pending invitation
  ///
  /// In en, this message translates to:
  /// **'This family has already been invited to this group'**
  String get familyAlreadyInvited;

  /// Error when family is already a member
  ///
  /// In en, this message translates to:
  /// **'This family is already a member of this group'**
  String get familyAlreadyMember;

  /// Error when family doesn't exist
  ///
  /// In en, this message translates to:
  /// **'Family not found'**
  String get familyNotFound;

  /// Error when invitation code is invalid or expired
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired invitation code'**
  String get invalidInvitationCode;

  /// Error for insufficient permissions
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to perform this action'**
  String get insufficientPermissions;

  /// Error for bad request (400)
  ///
  /// In en, this message translates to:
  /// **'Invalid request. Please check your input'**
  String get invalidRequest;

  /// Error for unauthenticated request (401)
  ///
  /// In en, this message translates to:
  /// **'Authentication required'**
  String get authenticationRequired;

  /// Error for resource not found (404)
  ///
  /// In en, this message translates to:
  /// **'Resource not found'**
  String get resourceNotFound;

  /// Error for conflict (409)
  ///
  /// In en, this message translates to:
  /// **'This action conflicts with existing data'**
  String get conflictError;

  /// Error for network connection issues
  ///
  /// In en, this message translates to:
  /// **'Network connection error. Please check your internet connection'**
  String get networkError;

  /// Error for request timeout
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again'**
  String get requestTimeout;

  /// Generic error fallback
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get unexpectedError;

  /// Title for group management context
  ///
  /// In en, this message translates to:
  /// **'Group Management'**
  String get groupManagement;

  /// Message shown when group invitation is valid
  ///
  /// In en, this message translates to:
  /// **'This group invitation is valid and ready to use.'**
  String get invitationIsValid;

  /// Label for invitation sender
  ///
  /// In en, this message translates to:
  /// **'Invited by:'**
  String get invitedBy;

  /// Fallback text for unnamed group
  ///
  /// In en, this message translates to:
  /// **'a group'**
  String get aGroup;

  /// Connection status - HTTP and WebSocket connected
  ///
  /// In en, this message translates to:
  /// **'Fully Connected'**
  String get connectionFullyConnected;

  /// Connection status - HTTP ok but WebSocket disconnected
  ///
  /// In en, this message translates to:
  /// **'Limited Connectivity'**
  String get connectionLimitedConnectivity;

  /// Connection status - no HTTP connection
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get connectionOffline;

  /// Title for connection status bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Connection Status'**
  String get connectionStatusTitle;

  /// Label for HTTP connection status
  ///
  /// In en, this message translates to:
  /// **'Internet Connection'**
  String get connectionHttpStatus;

  /// Label for WebSocket connection status
  ///
  /// In en, this message translates to:
  /// **'Real-time Updates'**
  String get connectionWebSocketStatus;

  /// Connected status
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connectionConnected;

  /// Disconnected status
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get connectionDisconnected;

  /// Snackbar message when connection is restored
  ///
  /// In en, this message translates to:
  /// **'Back online. Syncing...'**
  String get snackbarBackOnline;

  /// Snackbar message for limited connectivity
  ///
  /// In en, this message translates to:
  /// **'Limited connectivity. Real-time updates may be delayed.'**
  String get snackbarLimitedConnectivity;

  /// Snackbar message for offline mode
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Changes will sync when reconnected.'**
  String get snackbarOffline;

  /// Midday time slot label for schedule grid
  ///
  /// In en, this message translates to:
  /// **'Midday'**
  String get midday;

  /// Evening time slot label for schedule grid
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// Night time slot label for schedule grid
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get night;

  /// Unknown or unspecified value
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Fallback text for group without name
  ///
  /// In en, this message translates to:
  /// **'Unnamed Group'**
  String get unnamedGroup;

  /// Section header for currently assigned vehicles
  ///
  /// In en, this message translates to:
  /// **'Currently Assigned'**
  String get currentlyAssigned;

  /// Section header for available vehicles to assign
  ///
  /// In en, this message translates to:
  /// **'Available Vehicles'**
  String get availableVehicles;

  /// Empty state title when no vehicles exist
  ///
  /// In en, this message translates to:
  /// **'No Vehicles Available'**
  String get noVehiclesAvailable;

  /// Empty state description for adding vehicles
  ///
  /// In en, this message translates to:
  /// **'Add vehicles to your family to assign them to schedules'**
  String get addVehiclesToFamily;

  /// Error state title when vehicles fail to load
  ///
  /// In en, this message translates to:
  /// **'Error Loading Vehicles'**
  String get errorLoadingVehicles;

  /// Count of vehicles assigned to a time slot
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No vehicles} =1{1 vehicle} other{{count} vehicles}}'**
  String vehiclesCount(int count);

  /// Label for assigned section in vehicle list
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get assigned;

  /// Button/section to assign a vehicle
  ///
  /// In en, this message translates to:
  /// **'Assign Vehicle'**
  String get assignVehicle;

  /// Count of available vehicles
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{None available} =1{1 available} other{{count} available}}'**
  String availableCount(int count);

  /// Warning when no vehicles are assigned to a specific time slot
  ///
  /// In en, this message translates to:
  /// **'No vehicles assigned to this time slot'**
  String get noVehiclesAssignedToTimeSlot;

  /// Info message when all vehicles are already assigned
  ///
  /// In en, this message translates to:
  /// **'All available vehicles are assigned'**
  String get allVehiclesAssigned;

  /// Semantic label to expand time slot section
  ///
  /// In en, this message translates to:
  /// **'Expand {timeSlot}'**
  String expandTimeSlot(String timeSlot);

  /// Seat count display
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No seats} =1{1 seat} other{{count} seats}}'**
  String seatsCount(int count);

  /// Title for seat override section
  ///
  /// In en, this message translates to:
  /// **'Seat Override'**
  String get seatOverride;

  /// Subtitle for seat override section
  ///
  /// In en, this message translates to:
  /// **'Adjust capacity for this trip'**
  String get adjustCapacityForTrip;

  /// Description for seat override feature
  ///
  /// In en, this message translates to:
  /// **'Temporarily adjust vehicle capacity (e.g., wheelchair configuration)'**
  String get temporarilyAdjustCapacity;

  /// Helper text for seat override field
  ///
  /// In en, this message translates to:
  /// **'Leave empty for default ({capacity, plural, =0{no seats} =1{1 seat} other{{capacity} seats}})'**
  String leaveEmptyForDefault(int capacity);

  /// Validation error for seat override range
  ///
  /// In en, this message translates to:
  /// **'Override must be between 0 and 50 seats'**
  String get overrideMustBeBetween;

  /// Error when week cannot be determined
  ///
  /// In en, this message translates to:
  /// **'Cannot determine week for schedule'**
  String get cannotDetermineWeek;

  /// Success message after updating seat override
  ///
  /// In en, this message translates to:
  /// **'Seat override updated'**
  String get seatOverrideUpdated;

  /// Tooltip when seat override is active
  ///
  /// In en, this message translates to:
  /// **'Seat override active'**
  String get seatOverrideActive;

  /// Display override and base capacity
  ///
  /// In en, this message translates to:
  /// **'Override: {override} ({base} base)'**
  String overrideDetails(int override, int base);

  /// Title shown when group has no schedule config
  ///
  /// In en, this message translates to:
  /// **'Schedule configuration required'**
  String get scheduleConfigurationRequired;

  /// Description explaining why schedule is not available
  ///
  /// In en, this message translates to:
  /// **'This group needs schedule configuration. Set up time slots to enable scheduling.'**
  String get setupTimeSlotsToEnableScheduling;

  /// Message for non-admin users when config is missing
  ///
  /// In en, this message translates to:
  /// **'Contact a group administrator to set up time slots.'**
  String get contactAdministratorToSetupTimeSlots;

  /// Semantic label for previous week navigation button
  ///
  /// In en, this message translates to:
  /// **'Navigate to previous week'**
  String get navigateToPreviousWeek;

  /// Semantic label for next week navigation button
  ///
  /// In en, this message translates to:
  /// **'Navigate to next week'**
  String get navigateToNextWeek;

  /// Semantic label for empty schedule slot
  ///
  /// In en, this message translates to:
  /// **'Empty slot for {day} at {time}, tap to add vehicle'**
  String emptySlotTapToAddVehicle(String day, String time);

  /// Semantic label for filled schedule slot
  ///
  /// In en, this message translates to:
  /// **'{day} at {time} with {count, plural, =1{1 vehicle} other{{count} vehicles}}, tap to manage'**
  String slotWithVehiclesTapToManage(String day, String time, int count);

  /// Semantic label for remove vehicle button
  ///
  /// In en, this message translates to:
  /// **'Remove {vehicleName} from this slot'**
  String removeVehicleFromSlot(String vehicleName);

  /// Semantic label for assign child checkbox
  ///
  /// In en, this message translates to:
  /// **'Assign {childName} to vehicle'**
  String assignChildToVehicle(String childName);

  /// Semantic label for unassign child checkbox
  ///
  /// In en, this message translates to:
  /// **'Remove {childName} from vehicle'**
  String removeChildFromVehicle(String childName);

  /// Tooltip for offline changes indicator
  ///
  /// In en, this message translates to:
  /// **'Has pending offline changes'**
  String get hasPendingChanges;

  /// Error message when seat override update fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update seat override: {error}'**
  String seatOverrideUpdateFailed(String error);

  /// Save button text with assignment count
  ///
  /// In en, this message translates to:
  /// **'Save ({count})'**
  String saveAssignments(int count);

  /// Error message when trying to assign child to full vehicle
  ///
  /// In en, this message translates to:
  /// **'Cannot assign child: vehicle full'**
  String get vehicleCapacityFull;

  /// Success message after saving child assignments
  ///
  /// In en, this message translates to:
  /// **'Assignments saved successfully'**
  String get assignmentsSavedSuccessfully;

  /// Help text for date picker to select a week
  ///
  /// In en, this message translates to:
  /// **'Select week'**
  String get selectWeekHelpText;

  /// Helper text explaining week picker behavior
  ///
  /// In en, this message translates to:
  /// **'Select any date to jump to that week'**
  String get weekPickerHelperText;

  /// Number of vehicles assigned to a time slot
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No vehicles} =1{1 vehicle} other{{count} vehicles}}'**
  String vehiclesAssigned(int count);

  /// Message when no vehicles are assigned to a time slot
  ///
  /// In en, this message translates to:
  /// **'No vehicles assigned'**
  String get noVehiclesAssigned;

  /// Semantic label to collapse time slot section
  ///
  /// In en, this message translates to:
  /// **'Collapse {timeSlot}'**
  String collapseTimeSlot(String timeSlot);

  /// Error message when user tries to add vehicles to past time slots
  ///
  /// In en, this message translates to:
  /// **'Cannot add vehicles to past time slots'**
  String get cannotAddVehiclesToPastSlots;

  /// Error message when an assigned vehicle is no longer found in the family
  ///
  /// In en, this message translates to:
  /// **'The vehicle \"{vehicleName}\" (ID: {vehicleId}) is assigned to this time slot but no longer exists in your family.'**
  String vehicleNotFoundInFamily(String vehicleName, String vehicleId);

  /// Instruction message when an assigned vehicle is no longer found
  ///
  /// In en, this message translates to:
  /// **'Please contact support or remove this assignment.'**
  String get contactSupportOrRemoveAssignment;

  /// Button label to remove a problematic assignment
  ///
  /// In en, this message translates to:
  /// **'Remove Assignment'**
  String get removeAssignment;

  /// Message indicating times are shown in user's timezone
  ///
  /// In en, this message translates to:
  /// **'Times shown in your timezone'**
  String get timesShownInYourTimezone;

  /// Label for timezone
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get timezoneLabel;

  /// Message with specific timezone displayed
  ///
  /// In en, this message translates to:
  /// **'Times shown in your timezone ({timezone})'**
  String timesShownInTimezone(String timezone);

  /// Current timezone display
  ///
  /// In en, this message translates to:
  /// **'Current: {timezone}'**
  String currentTimezone(String timezone);

  /// Local time display with timezone offset
  ///
  /// In en, this message translates to:
  /// **'Local time: {time}'**
  String localTime(String time);

  /// Search placeholder for timezone field
  ///
  /// In en, this message translates to:
  /// **'Search timezones...'**
  String get searchTimezones;

  /// Message when timezone search returns no results
  ///
  /// In en, this message translates to:
  /// **'No timezones found'**
  String get noTimezonesFound;

  /// Label for timezone dropdown
  ///
  /// In en, this message translates to:
  /// **'Select timezone'**
  String get selectTimezone;

  /// Helper text for empty timezone search
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearchTerm;

  /// Helper text showing number of available timezones
  ///
  /// In en, this message translates to:
  /// **'{count} timezones available'**
  String timezonesAvailable(int count);

  /// Title for auto-sync timezone checkbox
  ///
  /// In en, this message translates to:
  /// **'Automatically sync timezone'**
  String get automaticallySyncTimezone;

  /// Subtitle for auto-sync timezone checkbox
  ///
  /// In en, this message translates to:
  /// **'Keep timezone synchronized with device'**
  String get keepTimezoneSyncedWithDevice;

  /// Success message when auto-sync is enabled
  ///
  /// In en, this message translates to:
  /// **'Auto-sync enabled'**
  String get autoSyncEnabled;

  /// Success message when auto-sync is disabled
  ///
  /// In en, this message translates to:
  /// **'Auto-sync disabled'**
  String get autoSyncDisabled;

  /// Error message for invalid timezone
  ///
  /// In en, this message translates to:
  /// **'Invalid timezone format'**
  String get invalidTimezoneFormat;

  /// Success message when timezone is updated
  ///
  /// In en, this message translates to:
  /// **'Timezone updated successfully'**
  String get timezoneUpdatedSuccessfully;

  /// Error message when timezone update fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update timezone. Please try again.'**
  String get failedToUpdateTimezone;

  /// Error message when timezone detection fails
  ///
  /// In en, this message translates to:
  /// **'Failed to detect timezone. Please try again.'**
  String get failedToDetectTimezone;

  /// Error message when auto-sync preference update fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update auto-sync preference'**
  String get failedToUpdateAutoSyncPreference;

  /// Fallback text for unknown timezone
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownTimezone;

  /// Title for today's transport card
  ///
  /// In en, this message translates to:
  /// **'Today\'s Transports'**
  String get todayTransports;

  /// Message when no transports are scheduled for today
  ///
  /// In en, this message translates to:
  /// **'No transports scheduled today'**
  String get noTransportsToday;

  /// Button text to view full schedule
  ///
  /// In en, this message translates to:
  /// **'See full schedule →'**
  String get seeFullSchedule;

  /// Error message when transport data refresh fails
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh transport data'**
  String get refreshFailed;

  /// Loading message for today's transport data
  ///
  /// In en, this message translates to:
  /// **'Loading today\'s transports...'**
  String get loadingTodayTransports;

  /// Accessibility label for transport loading error
  ///
  /// In en, this message translates to:
  /// **'Error loading transports'**
  String get errorLoadingTransports;

  /// Accessibility label for today's transport list
  ///
  /// In en, this message translates to:
  /// **'Today\'s transport list'**
  String get todayTransportList;

  /// Header title for 7-day timeline view
  ///
  /// In en, this message translates to:
  /// **'Next 7 days'**
  String get next7Days;

  /// Accessibility label for expanded week view state
  ///
  /// In en, this message translates to:
  /// **'Week view expanded'**
  String get weekViewExpanded;

  /// Day badge text with transport count
  ///
  /// In en, this message translates to:
  /// **'{day} • {count} transports'**
  String dayWithTransports(String day, int count);

  /// Empty state message when no transports scheduled for the week
  ///
  /// In en, this message translates to:
  /// **'No transports this week'**
  String get noTransportsWeek;

  /// Tooltip for expand week view button
  ///
  /// In en, this message translates to:
  /// **'Expand week view'**
  String get expandWeekView;

  /// Tooltip for collapse week view button
  ///
  /// In en, this message translates to:
  /// **'Collapse week view'**
  String get collapseWeekView;

  /// User-friendly error message for schedule slot ID missing errors
  ///
  /// In en, this message translates to:
  /// **'Unable to complete this operation. The schedule slot may not exist or there may be a connection issue.'**
  String get scheduleSlotError;

  /// Error message when user lacks permissions
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to perform this action.'**
  String get permissionError;

  /// Error message when vehicle is not found
  ///
  /// In en, this message translates to:
  /// **'The selected vehicle could not be found. Please try again.'**
  String get vehicleNotFoundError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
