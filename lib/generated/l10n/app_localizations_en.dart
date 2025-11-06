// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get about => 'About';

  @override
  String get accept => 'Accept';

  @override
  String get accepted => 'Accepted';

  @override
  String get acceptedInvitations => 'Accepted';

  @override
  String get actionCannotBeUndone => 'This action cannot be undone';

  @override
  String get actionCheckConnection => 'Check your internet connection';

  @override
  String get actionCheckEmail => 'Check your email for a new login link';

  @override
  String get actionFillRequired => 'Make sure all required fields are filled';

  @override
  String get actionRestartApp => 'Restart the app if the problem continues';

  @override
  String get actionReviewInfo => 'Review the information you entered';

  @override
  String get actionSignOutSignIn => 'Sign out and sign in again';

  @override
  String get actionSwitchNetwork => 'Switch to mobile data if using WiFi';

  @override
  String get actionTryAgain => 'Try again';

  @override
  String get active => 'Active';

  @override
  String get activeDays => 'Active Days';

  @override
  String get activeOverride => 'Active Override';

  @override
  String get add => 'Add';

  @override
  String get addChild => 'Add child';

  @override
  String get addEvent => 'Add Event';

  @override
  String get addFirstTimeSlot => 'Add First Time Slot';

  @override
  String get addFirstVehicle =>
      'Add your first vehicle to start\\norganizing trips.';

  @override
  String get addOrRemoveVehicles => 'Add or remove vehicles';

  @override
  String get addOverride => 'Add Override';

  @override
  String get addSlot => 'Add Slot';

  @override
  String get addTimeSlot => 'Add Time Slot';

  @override
  String get addTimeSlotsDescription =>
      'Add time slots to define when vehicles can be scheduled';

  @override
  String get addVehicle => 'Add vehicle';

  @override
  String get addVehicleTitle => 'Add Vehicle';

  @override
  String get addVehicleToSlot => 'Add Vehicle';

  @override
  String get addVehiclesToFamilyToStartScheduling =>
      'Add vehicles to your family to start scheduling';

  @override
  String get additionalInformation => 'Any additional information...';

  @override
  String get additionalNavigationOptions =>
      'Additional navigation options would appear here';

  @override
  String get additionalNotesOptional => 'Additional Notes (Optional)';

  @override
  String get adjustCapacity => 'Adjust Capacity';

  @override
  String get adjustedCapacity => 'Adjusted Capacity';

  @override
  String get adjustmentReason => 'Reason for adjustment (optional)';

  @override
  String get adjustmentReasonHint => 'e.g., car seat, maintenance';

  @override
  String get admin => 'Admin';

  @override
  String get adminCanManageMembers => 'Admin can manage family members';

  @override
  String get administrator => 'Administrator';

  @override
  String get afternoon => 'Afternoon';

  @override
  String age(int years) {
    return 'Age: $years years';
  }

  @override
  String get all => 'All';

  @override
  String get allDays => 'All Days';

  @override
  String get allDaysSubtitle => 'Every day';

  @override
  String get appName => 'EduLift';

  @override
  String get appVersion => 'Version 1.0.0';

  @override
  String get applyChanges => 'Apply Changes';

  @override
  String assignChildrenButton(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Children',
      one: '$count Child',
    );
    return 'Assign $_temp0';
  }

  @override
  String get assignChildrenToVehicles => 'Assign children to vehicles';

  @override
  String get assignNewAdminAndSwitch => 'Assign New Admin and Switch';

  @override
  String get assignNewAdminDesc =>
      'Promote another member to admin, then join the new family';

  @override
  String get assignVehicleToSlot => 'Assign a vehicle to this time slot';

  @override
  String get assignedChildren => 'Assigned Child';

  @override
  String get available => 'Available';

  @override
  String get availableOptions => 'Available Options';

  @override
  String get availableSeats => 'Available seats';

  @override
  String get backToHome => 'Back to home';

  @override
  String get backToLogin => 'Back to login';

  @override
  String get basicInformation => 'Basic information';

  @override
  String get biometricAuthentication => 'Biometric authentication';

  @override
  String get byLeavingFamilyYouWill => 'By leaving this family, you will:';

  @override
  String get cancel => 'Cancel';

  @override
  String get cancelInvitation => 'Cancel Invitation';

  @override
  String get cancelInvitationMessage =>
      'They will no longer be able to join your family using this invitation.';

  @override
  String get cancelInvitationTitle => 'Cancel Invitation';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get capacity => 'Capacity';

  @override
  String get capacityAdjustmentHint =>
      'Temporarily adjust the number of available seats.';

  @override
  String get capacityAndReasonRequired => 'Capacity and reason are required';

  @override
  String capacityExceeded(int count) {
    return 'Capacity exceeded by $count';
  }

  @override
  String get capacityHelpText => 'Include the driver seat in the total count';

  @override
  String get capacityInformation => 'Capacity Information';

  @override
  String get car => 'Car';

  @override
  String get checkBackLater => 'Check back later for new invitations';

  @override
  String get checkYourEmail => 'Check your email';

  @override
  String get checkingUser => 'Checking user...';

  @override
  String childAddedSuccessfully(String childName) {
    return 'Child \"$childName\" added successfully';
  }

  @override
  String get childDetailsTitle => 'Child Details';

  @override
  String childIdLabel(String childId) {
    return 'Child ID: $childId';
  }

  @override
  String get childInfoDescription =>
      'Add your child\'s information to include them in family management.';

  @override
  String get childNameHint => 'First or last name';

  @override
  String get childAgeOptional => 'Age (optional)';

  @override
  String get enterChildAge => 'Enter age';

  @override
  String childTransportCapacity(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'This vehicle can transport up to $count children (driver seat excluded)',
      one:
          'This vehicle can transport up to $count child (driver seat excluded)',
      zero: 'This vehicle cannot transport children (driver seat excluded)',
    );
    return '$_temp0';
  }

  @override
  String get childUpdatedSuccessfully => 'Child updated successfully';

  @override
  String get children => 'Children';

  @override
  String childrenAssigned(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count children assigned successfully',
      one: '$count child assigned successfully',
    );
    return '$_temp0';
  }

  @override
  String childrenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count children',
      one: '$count child',
    );
    return '$_temp0';
  }

  @override
  String childrenSelected(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count children selected',
      one: '$count child selected',
    );
    return '$_temp0';
  }

  @override
  String get chooseGroupForSchedule =>
      'Choose a transport group to view its weekly schedule';

  @override
  String get chooseResolution => 'Choose Resolution';

  @override
  String get clearAll => 'Clear all';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get close => 'Close';

  @override
  String get codeCopiedToClipboard => 'Code copied to clipboard';

  @override
  String get codeExpired => 'This code has expired';

  @override
  String codeForEmail(String email) {
    return 'Code for $email:';
  }

  @override
  String get codeJoining => 'Code joining';

  @override
  String get codes => 'Codes';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get commonDepartureTimes => 'Common departure times';

  @override
  String get compact => 'Compact';

  @override
  String get configuration => 'Configuration';

  @override
  String get configureSchedule => 'Configure Schedule';

  @override
  String get configureTimeSlots => 'Configure Time Slots';

  @override
  String configureWeekdaySchedule(String weekday) {
    return 'Configure $weekday schedule';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get confirmDelete => 'Are you sure you want to delete';

  @override
  String get confirmLogout => 'Confirm Sign Out';

  @override
  String get confirmLogoutMessage => 'Are you sure you want to sign out?';

  @override
  String confirmVehicleDeletion(String vehicleName) {
    return 'Are you sure you want to delete \"$vehicleName\"?\n\nThis action is irreversible and will also delete\nall assignments for this vehicle.';
  }

  @override
  String get conflictResolution => 'Conflict Resolution';

  @override
  String get conflictResolutionComingSoon =>
      'Conflict resolution feature coming soon';

  @override
  String get continueButton => 'Continue';

  @override
  String get copyCode => 'Copy Code';

  @override
  String get createAccount => 'Create account';

  @override
  String get createFamily => 'Create Family';

  @override
  String get createGroup => 'Create Group';

  @override
  String get createNewGroup => 'Create New Group';

  @override
  String get createOverride => 'Create Override';

  @override
  String get createOverrideError =>
      'Failed to create override. Please try again.';

  @override
  String get createSeatOverride => 'Create Seat Override';

  @override
  String get createTransportGroupDescription =>
      'Create a transport group to coordinate with other families';

  @override
  String get createTrip => 'Create Trip';

  @override
  String get createVehicle => 'Create Vehicle';

  @override
  String get createYourFamily => 'Create Your Family';

  @override
  String get created => 'Created';

  @override
  String createdOn(String date) {
    return 'Created on $date';
  }

  @override
  String get creating => 'Creating...';

  @override
  String get dashboard => 'Dashboard';

  @override
  String criticalExpiringCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expiring in 2 hours or less',
      one: '$count expiring in 2 hours or less',
    );
    return '$_temp0';
  }

  @override
  String currentCapacity(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'seats',
      one: 'seat',
    );
    return 'Current: $count $_temp0';
  }

  @override
  String currentFamily(String familyName) {
    return 'Current family: $familyName';
  }

  @override
  String currentSeatsLabel(int count) {
    return 'Current: $count seats';
  }

  @override
  String get currentSituation => 'Current Situation';

  @override
  String get customTime => 'Custom time';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '${count}d ago',
      one: 'Yesterday',
      zero: 'Today',
    );
    return '$_temp0';
  }

  @override
  String daysCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String get decline => 'Decline';

  @override
  String defaultCapacity(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'seats',
      one: 'seat',
    );
    return 'Default: $count $_temp0';
  }

  @override
  String get delete => 'Delete';

  @override
  String get deleteAssignment => 'Delete Assignment';

  @override
  String get deleteAssignmentTooltip => 'Delete Assignment';

  @override
  String get deleteFamily => 'Delete Family';

  @override
  String get deleteFamilyAndSwitch => 'Delete Family and Switch';

  @override
  String get deleteFamilyConfirmation => 'Delete Family';

  @override
  String get deleteFamilyDesc =>
      'Permanently delete your current family and join the new one';

  @override
  String get deleteFamilyLastMemberDesc =>
      'Permanently delete this family since you are the only member';

  @override
  String deleteFamilyWarning(String familyName) {
    return 'This will permanently delete the family \'$familyName\' and all its data. This action cannot be undone.';
  }

  @override
  String get deleteTimeSlotTooltip => 'Delete time slot';

  @override
  String get deleteVehicle => 'Delete vehicle';

  @override
  String get demoteFromAdmin => 'Demote from Admin';

  @override
  String departureTimesSelected(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count departure times selected',
      one: '$count departure time selected',
    );
    return '$_temp0';
  }

  @override
  String get departureHours => 'Departure Hours';

  @override
  String get description => 'Description';

  @override
  String get developerTools => 'Developer Tools';

  @override
  String get displayInvitationCode => 'Display the invitation code';

  @override
  String get dragVehiclesToTimeSlots => 'Drag vehicles to time slots';

  @override
  String get edit => 'Edit';

  @override
  String get editAssignment => 'Edit Assignment';

  @override
  String get editAssignmentTooltip => 'Edit Assignment';

  @override
  String get editFunctionalityComingSoon => 'Edit functionality coming soon';

  @override
  String get editGroup => 'Edit Group';

  @override
  String get editTimeSlot => 'Edit Time Slot';

  @override
  String get editTimeSlotTooltip => 'Edit time slot';

  @override
  String get editVehicle => 'Edit Vehicle';

  @override
  String get editVehicleTitle => 'Edit Vehicle';

  @override
  String get editVehicleTooltip => 'Edit Vehicle';

  @override
  String get email => 'Email';

  @override
  String get emailAddress => 'Email address';

  @override
  String get emailLabel => 'Email: ';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emergency => 'Emergency';

  @override
  String get emergencyContact => 'Emergency contact';

  @override
  String get english => 'English';

  @override
  String get ensureOtherAdmins =>
      'As an admin, ensure there are other admins in the family before leaving.';

  @override
  String get enterEmailOfFamilyMember => 'Enter email of a family member';

  @override
  String get enterFamilyInvitationInstruction =>
      'Please enter your family invitation code to continue';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get enterGroupInvitationCodeTitle => 'Enter Group Invitation Code';

  @override
  String get enterGroupInvitationInstruction =>
      'Please enter your group invitation code to continue';

  @override
  String get enterGroupName => 'Enter group name';

  @override
  String get enterInvitationCode => 'Enter invitation code';

  @override
  String get enterInvitationCodeTitle => 'Enter Invitation Code';

  @override
  String get enterMemberEmail => 'Enter member\'s email';

  @override
  String get enterMemberName => 'Enter member\'s name';

  @override
  String get enterNewCapacity => 'Enter new capacity';

  @override
  String get enterReceivedCode => 'Enter received code';

  @override
  String get enterTotalSeats => 'Enter total seats';

  @override
  String get enterVehicleName => 'Enter vehicle name';

  @override
  String get errorAuth => 'Authentication error';

  @override
  String get errorAuthAccessDenied => 'Access denied';

  @override
  String get errorAuthAccountDisabled =>
      'This account has been disabled. Please contact support';

  @override
  String get errorAuthAccountLocked =>
      'This account has been locked due to suspicious activity';

  @override
  String get errorAuthAccountNotFound =>
      'No account found with this email address';

  @override
  String get errorAuthApiError => 'API error. Please try again';

  @override
  String get errorAuthBiometricAuthFailed =>
      'Biometric authentication failed. Please try again';

  @override
  String get errorAuthBiometricLockout =>
      'Biometric authentication is temporarily locked. Please try again later';

  @override
  String get errorAuthBiometricNotAvailable =>
      'Biometric authentication is not available on this device';

  @override
  String get errorAuthBiometricNotEnabled =>
      'Biometric authentication is not enabled';

  @override
  String get errorAuthBiometricNotEnrolled =>
      'No biometric data enrolled. Please set up biometric authentication in your device settings';

  @override
  String get errorAuthConfigurationError =>
      'Authentication configuration error. Please contact support';

  @override
  String get errorAuthConnectionLost =>
      'Connection lost. Please check your internet connection';

  @override
  String get errorAuthCrossUserTokenAttempt => 'Invalid token for this user';

  @override
  String get errorAuthDecryptionError =>
      'Failed to decrypt authentication data';

  @override
  String get errorAuthDeviceNotRecognized =>
      'Device not recognized. Please verify your identity';

  @override
  String get errorAuthEmailAlreadyExists =>
      'An account with this email already exists';

  @override
  String get errorAuthEmailInvalid => 'Please enter a valid email address';

  @override
  String get errorAuthEmailNotVerified => 'Email address has not been verified';

  @override
  String get errorAuthEmailRequired => 'Email address is required';

  @override
  String get errorAuthEmailTooLong =>
      'Email address is too long (maximum 254 characters)';

  @override
  String get errorAuthEncryptionError =>
      'Failed to encrypt authentication data';

  @override
  String get errorAuthInsufficientPermissions =>
      'You don\'t have permission to perform this action';

  @override
  String get errorAuthInvalidCredentials => 'Invalid email or password';

  @override
  String get errorAuthInvalidEmail => 'Email address format is invalid';

  @override
  String get errorAuthInvalidMagicLink =>
      'This magic link is invalid or has already been used';

  @override
  String get errorAuthInvalidRequest => 'Invalid request. Please try again';

  @override
  String get errorAuthInvalidToken => 'Authentication token is invalid';

  @override
  String get errorAuthInvalidVerificationCode => 'Invalid verification code';

  @override
  String get errorAuthInviteCodeExpired => 'This invitation code has expired';

  @override
  String get errorAuthInviteCodeInvalid =>
      'Please enter a valid invitation code (at least 6 characters)';

  @override
  String get errorAuthIpBlocked =>
      'Access temporarily blocked. Please try again later';

  @override
  String get errorAuthMagicLinkAlreadyUsed =>
      'This magic link has already been used';

  @override
  String get errorAuthMagicLinkExpired =>
      'This magic link has expired. Please request a new one';

  @override
  String get errorAuthMagicLinkTokenInvalid =>
      'The magic link token is invalid or has expired';

  @override
  String get errorAuthMagicLinkTokenRequired => 'Magic link token is required';

  @override
  String get errorAuthMessage =>
      'Your session has expired. Please sign in again.';

  @override
  String get errorAuthMultipleSessions =>
      'Multiple sessions detected. Please sign in again';

  @override
  String get errorAuthNameInvalidChars =>
      'Name can only contain letters, spaces, hyphens, and apostrophes';

  @override
  String get errorAuthNameMaxLength => 'Name cannot exceed 50 characters';

  @override
  String get errorAuthNameMinLength => 'Name must be at least 2 characters';

  @override
  String get errorAuthNameRequired => 'Full name is required';

  @override
  String get errorAuthNetworkError =>
      'Network error. Please check your internet connection';

  @override
  String get errorAuthOperationCancelled => 'Operation cancelled';

  @override
  String get errorAuthPkceVerificationFailed =>
      'Authentication verification failed';

  @override
  String get errorAuthResourceNotFound =>
      'The requested resource was not found';

  @override
  String get errorAuthSecureStorageUnavailable =>
      'Secure storage is not available on this device';

  @override
  String get errorAuthSecurityValidationFailed =>
      'Security validation failed. Please try again';

  @override
  String get errorAuthServerError => 'Server error. Please try again later';

  @override
  String get errorAuthSessionExpired =>
      'Your session has expired. Please sign in again';

  @override
  String get errorAuthStorageError =>
      'Failed to save authentication data. Please try again';

  @override
  String get errorAuthSuspiciousActivity =>
      'Suspicious activity detected. Please verify your identity';

  @override
  String get errorAuthTimeout => 'Request timed out. Please try again';

  @override
  String get errorAuthTitle => 'Authentication Required';

  @override
  String get errorAuthTokenExpired =>
      'Your session has expired. Please sign in again';

  @override
  String get errorAuthTokenMissing => 'Authentication token is missing';

  @override
  String get errorAuthTokenRefreshFailed =>
      'Failed to refresh authentication. Please sign in again';

  @override
  String get errorAuthTokenStorageError =>
      'Failed to store authentication token';

  @override
  String get errorAuthTooManyAttempts =>
      'Too many failed attempts. Please try again later';

  @override
  String get errorAuthUnknown =>
      'An unexpected error occurred. Please try again';

  @override
  String get errorAuthUserAlreadyInFamily =>
      'This user is already member of another family';

  @override
  String get errorAuthUserDataStorageError => 'Failed to store user data';

  @override
  String get errorAuthorizationMessage =>
      'You don\'t have permission to perform this action.';

  @override
  String get errorAuthorizationTitle => 'Access Denied';

  @override
  String get errorBiometricMessage =>
      'Biometric authentication failed. Please try again or use your passcode.';

  @override
  String get errorBiometricTitle => 'Biometric Error';

  @override
  String get errorChangingLanguage => 'Error changing language';

  @override
  String get errorChildAgeNotNumber => 'Child age must be a number';

  @override
  String get errorChildAgeRequired => 'Child age is required';

  @override
  String errorChildAgeTooOld(int maxAge) {
    return 'Child age cannot exceed $maxAge years';
  }

  @override
  String errorChildAgeTooYoung(int minAge) {
    return 'Child age must be at least $minAge year(s) old';
  }

  @override
  String get errorChildEmergencyContactInvalid =>
      'Emergency contact format is invalid (phone or email required)';

  @override
  String get errorChildEmergencyContactRequired =>
      'Emergency contact is required';

  @override
  String get errorChildGradeInvalid => 'Grade format is invalid';

  @override
  String errorChildMedicalInfoTooLong(int maxLength) {
    return 'Medical information is too long (maximum $maxLength characters)';
  }

  @override
  String get errorChildNameInvalidChars =>
      'Child name contains invalid characters';

  @override
  String get errorChildNameMaxLength =>
      'Child name cannot exceed 30 characters';

  @override
  String get errorChildNameMinLength =>
      'Child name must be at least 2 characters';

  @override
  String get errorChildNameRequired => 'Child name is required';

  @override
  String errorChildSchoolNameTooLong(int maxLength) {
    return 'School name is too long (maximum $maxLength characters)';
  }

  @override
  String errorChildSpecialNeedsTooLong(int maxLength) {
    return 'Special needs information is too long (maximum $maxLength characters)';
  }

  @override
  String get errorConflictMessage =>
      'Your data conflicts with recent changes. Please refresh and try again.';

  @override
  String get errorConflictTitle => 'Data Conflict';

  @override
  String get errorEmailAlreadyExists =>
      'This email address is already registered';

  @override
  String get errorEmailInvalid => 'Please enter a valid email address';

  @override
  String get errorEmailRequired => 'Email address is required';

  @override
  String errorFailedToExportLogs(String error) {
    return 'Failed to export logs: $error';
  }

  @override
  String errorFailedToLeaveFamily(String error) {
    return 'Failed to leave family: $error';
  }

  @override
  String errorFailedToRemoveMember(String error) {
    return 'Failed to remove member: $error';
  }

  @override
  String errorFailedToUpdateRole(String error) {
    return 'Failed to update role: $error';
  }

  @override
  String get errorFamilyNameInvalidChars =>
      'Family name contains invalid characters';

  @override
  String get errorFamilyNameMaxLength =>
      'Family name cannot exceed 50 characters';

  @override
  String get errorFamilyNameMinLength =>
      'Family name must be at least 2 characters';

  @override
  String get errorFamilyNameRequired => 'Family name is required';

  @override
  String get errorInsufficientPermissions =>
      'You don\'t have permission to perform this action';

  @override
  String get errorInvalidData =>
      'Invalid data provided. Please check your information and try again.';

  @override
  String get errorInvitationCancelled => 'This invitation has been cancelled';

  @override
  String get errorInvitationCodeInvalid =>
      'Please enter a valid invitation code';

  @override
  String get errorInvitationCodeRequired => 'Invitation code is required';

  @override
  String get errorInvitationEmailMismatch =>
      'This invitation was sent to a different email address. Please use the email address the invitation was sent to.';

  @override
  String get errorInvitationExpired => 'This invitation has expired';

  @override
  String get errorInvitationNotFound =>
      'Invitation not found or has been revoked';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get errorLoadingLogLevel => 'Error loading log level';

  @override
  String get errorMemberAlreadyExists =>
      'This member is already part of the family';

  @override
  String get errorMemberNotFound => 'Member not found';

  @override
  String errorMessageTooLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Message cannot exceed $count characters',
      one: 'Message cannot exceed 1 character',
    );
    return '$_temp0';
  }

  @override
  String get errorNetwork => 'Network error occurred';

  @override
  String get errorNetworkGeneral =>
      'Connection error. Check your internet connection.';

  @override
  String get errorNetworkMessage =>
      'Please check your internet connection and try again.';

  @override
  String get errorNetworkTitle => 'Connection Problem';

  @override
  String get errorOfflineMessage =>
      'This feature is not available while offline. Please connect to the internet.';

  @override
  String get errorOfflineTitle => 'Offline Mode';

  @override
  String get errorPageTitle => 'Error';

  @override
  String get errorPendingInvitationExists =>
      'An invitation to this email address is already pending';

  @override
  String get errorPermissionMessage =>
      'This app needs permission to continue. Please grant the required permission.';

  @override
  String get errorPermissionTitle => 'Permission Required';

  @override
  String get errorProcessingRequest => 'Error processing request';

  @override
  String errorRawMessage(Object message) {
    return '$message';
  }

  @override
  String get errorRoleInvalid => 'Please select a valid role';

  @override
  String get errorRoleRequired => 'Role selection is required';

  @override
  String get errorServerGeneral => 'Server error. Please try again later.';

  @override
  String get errorServerMessage =>
      'The server is currently experiencing issues. Please try again later.';

  @override
  String get errorServerTitle => 'Server Error';

  @override
  String get errorStorageMessage =>
      'There was a problem saving your data. Please try again.';

  @override
  String get errorStorageTitle => 'Storage Problem';

  @override
  String get errorSyncMessage =>
      'Unable to sync your data. Your changes will be saved when connection is restored.';

  @override
  String get errorSyncTitle => 'Sync Failed';

  @override
  String get errorSystemMessage =>
      'An unexpected system error occurred. Please try again.';

  @override
  String get errorSystemTitle => 'System Error';

  @override
  String get errorTitle => 'Error';

  @override
  String get errorUnexpected => 'An error occurred.';

  @override
  String get errorUnexpectedMessage =>
      'Something went wrong. Please try again or contact support if the problem continues.';

  @override
  String get errorUnexpectedTitle => 'Unexpected Error';

  @override
  String get errorUnknown => 'An unknown error occurred';

  @override
  String get errorValidation => 'Validation error';

  @override
  String get errorValidationMessage =>
      'Please check the information you entered and try again.';

  @override
  String get errorValidationTitle => 'Invalid Information';

  @override
  String get errorVehicleCapacityNotNumber =>
      'Vehicle capacity must be a number';

  @override
  String get errorVehicleCapacityRequired => 'Vehicle capacity is required';

  @override
  String get errorVehicleCapacityTooHigh => 'Vehicle capacity cannot exceed 10';

  @override
  String get errorVehicleCapacityTooLow =>
      'Vehicle capacity must be at least 1';

  @override
  String get errorVehicleDescriptionTooLong =>
      'Vehicle description is too long';

  @override
  String get errorVehicleNameInvalidChars =>
      'Vehicle name contains invalid characters';

  @override
  String get errorVehicleNameMaxLength =>
      'Vehicle name cannot exceed 50 characters';

  @override
  String get errorVehicleNameMinLength =>
      'Vehicle name must be at least 2 characters';

  @override
  String get errorVehicleNameRequired => 'Vehicle name is required';

  @override
  String estimatedLogSize(String sizeMB) {
    return 'Estimated log size: ${sizeMB}MB';
  }

  @override
  String get event => 'Event';

  @override
  String get expired => 'Expired';

  @override
  String get expiredLabel => 'Expired';

  @override
  String expires(String date) {
    return 'Expires: $date';
  }

  @override
  String get expiresAtOptional => 'Expires At (Optional)';

  @override
  String expiresIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Expires in $days days',
      one: 'Expires tomorrow',
      zero: 'Expires today',
    );
    return '$_temp0';
  }

  @override
  String expiresInDays(int days) {
    return 'Expires in $days days';
  }

  @override
  String expiresInDaysHours(int days, int hours) {
    return 'Expires in $days days and $hours hours';
  }

  @override
  String get dayLabel => 'Day';

  @override
  String expiresInHours(int hours) {
    return 'Expires in $hours hours';
  }

  @override
  String expiresInHoursMinutes(int hours, int minutes) {
    return 'Expires in $hours hours and $minutes minutes';
  }

  @override
  String expiresInMinutes(int minutes) {
    return 'Expires in $minutes minutes';
  }

  @override
  String expiresOn(String date) {
    return 'Expires: $date';
  }

  @override
  String get expiringIn3Days => 'Expiring in 3 Days';

  @override
  String get expiringSoon => 'Expiring Soon';

  @override
  String get expiringThisWeek => 'Expiring This Week';

  @override
  String get expiringVeryShortly => 'Expiring Very Soon';

  @override
  String get exportIncludesComprehensive =>
      'Export includes comprehensive diagnostic information for support';

  @override
  String get exportIncludesInfo =>
      'Export includes app version, device info, recent logs, and diagnostic data';

  @override
  String get exportLogsForSupport => 'Export Logs for Support';

  @override
  String get exporting => 'Exporting...';

  @override
  String get extend => 'Extend';

  @override
  String get extended => 'Extended';

  @override
  String get failed => 'Failed';

  @override
  String failedToAssignChildren(String error) {
    return 'Failed to assign children: $error';
  }

  @override
  String failedToCancel(String error) {
    return 'Failed to cancel: $error';
  }

  @override
  String failedToCopyCode(String error) {
    return 'Failed to copy code: $error';
  }

  @override
  String failedToExportLogs(String error) {
    return 'Failed to export logs: $error';
  }

  @override
  String failedToLeaveFamily(String error) {
    return 'Failed to leave family: $error';
  }

  @override
  String get failedToLoadGroups => 'Failed to load groups';

  @override
  String get failedToLoadSchedule => 'Failed to Load Schedule';

  @override
  String failedToLoadVehicles(String error) {
    return 'Failed to load vehicles: $error';
  }

  @override
  String failedToRemoveMember(String error) {
    return 'Failed to remove member: $error';
  }

  @override
  String get failedToSendInvitation => 'Failed to send invitation';

  @override
  String failedToUpdateRole(String error) {
    return 'Failed to update role: $error';
  }

  @override
  String get family => 'Family';

  @override
  String get familyConflictTitle => 'Family Conflict';

  @override
  String familyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count families',
      one: '$count family',
    );
    return '$_temp0';
  }

  @override
  String get familyInvitation => 'Family invitation';

  @override
  String get familyInvitations => 'Family Invitations';

  @override
  String get familyMember => 'Family Member';

  @override
  String get familyMemberActions => 'Family Member Actions';

  @override
  String get familyMemberDescription =>
      'Regular family member with basic access';

  @override
  String get familyMembers => 'Family Members';

  @override
  String familyMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Family Members ($count)',
      one: 'Family Members ($count)',
      zero: 'Family Members',
    );
    return '$_temp0';
  }

  @override
  String get currentUserLabel => ', current user';

  @override
  String get youLabel => '(You)';

  @override
  String weeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks ago',
      one: '$count week ago',
    );
    return '$_temp0';
  }

  @override
  String monthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months ago',
      one: '$count month ago',
    );
    return '$_temp0';
  }

  @override
  String yearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years ago',
      one: '$count year ago',
    );
    return '$_temp0';
  }

  @override
  String get removeAdminRole => 'Remove Admin Role';

  @override
  String get changeToRegularMember => 'Change to regular member';

  @override
  String get grantAdminPermissions => 'Grant admin permissions';

  @override
  String get adminPermissionsInclude => 'Admin permissions include:';

  @override
  String get adminPermissionManageMembers => '• Manage family members';

  @override
  String get adminPermissionSendInvitations => '• Send invitations';

  @override
  String get adminPermissionManageVehiclesChildren =>
      '• Manage vehicles and children';

  @override
  String get adminPermissionConfigureSettings => '• Configure family settings';

  @override
  String get familyNameRequired => 'Family name is required';

  @override
  String get familyNameTooLong => 'Family name must be less than 50 characters';

  @override
  String get familyNameTooShort => 'Family name must be at least 2 characters';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get filter => 'Filter';

  @override
  String get filterAll => 'All';

  @override
  String get filterExpired => 'Expired';

  @override
  String get filterExpiringSoon => 'Expiring Soon';

  @override
  String get filterOptions => 'Filter Options';

  @override
  String get filterPending => 'Pending';

  @override
  String get firstName => 'First name *';

  @override
  String get firstNameRequired => 'First name is required';

  @override
  String get french => 'French';

  @override
  String get fri => 'Fri';

  @override
  String get friday => 'Friday';

  @override
  String get fridayShort => 'Fri';

  @override
  String get fullName => 'Full name';

  @override
  String get generate => 'Generate';

  @override
  String get generateCodes => 'Generate codes';

  @override
  String get generateCodesTooltip => 'Generate codes';

  @override
  String get generateNewCode => 'Generate new code';

  @override
  String get giveUpAdminPrivileges => '• Give up admin privileges';

  @override
  String get goBack => 'Go Back';

  @override
  String get goBackButton => 'Go Back';

  @override
  String get goToGroups => 'Go to Groups';

  @override
  String get gotItButton => 'Got it';

  @override
  String get grantAdminRole => 'Grant Admin Role';

  @override
  String get groupCreated => 'Group created successfully';

  @override
  String get groupCreatedSuccessfully => 'Group created successfully\\!';

  @override
  String get groupCreatorInfo =>
      'As the creator, you\'ll be the group administrator and can invite other families.';

  @override
  String get groupDescription => 'Group Description';

  @override
  String get groupDescriptionMaxLength =>
      'Description cannot exceed 500 characters';

  @override
  String get groupDetails => 'Group Details';

  @override
  String get groupInvitation => 'Group invitation';

  @override
  String get groupInvitations => 'Group Invitations';

  @override
  String get groupJoined => 'Joined group successfully';

  @override
  String get groupName => 'Group Name';

  @override
  String get groupNameMaxLength => 'Group name must be less than 50 characters';

  @override
  String get groupNameMinLength => 'Group name must be at least 3 characters';

  @override
  String get groupNameRequired => 'Group name is required';

  @override
  String get groupNotFound => 'Group Not Found';

  @override
  String get groupNotFoundMessage =>
      'The selected group could not be found or you no longer have access to it.';

  @override
  String groups(int count) {
    return 'Groups: $count';
  }

  @override
  String get groupsLabel => 'Groups';

  @override
  String get help => 'Help';

  @override
  String helperTextDefaultSeats(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'seats',
      one: 'seat',
    );
    return 'Default: $count $_temp0';
  }

  @override
  String get hideVehicles => 'Hide Vehicles';

  @override
  String highExpiringCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expiring within 24 hours',
      one: '$count expiring within 24 hours',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '$count hour ago',
    );
    return '$_temp0';
  }

  @override
  String get implementationComingSoon => 'Implementation coming soon';

  @override
  String get incorrectConfirmation => 'Confirmation text does not match';

  @override
  String get instructionStep1 => '1. Open your email app';

  @override
  String get instructionStep2 => '2. Look for the EduLift email';

  @override
  String get instructionStep3 => '3. Click the login link';

  @override
  String get instructionStep4 => '4. You will be automatically logged in';

  @override
  String get instructionsTitle => 'Instructions:';

  @override
  String get invalid => 'Invalid';

  @override
  String get invalidCapacityRange =>
      'Please enter a valid capacity between 1 and 50';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get invalidEmailFormat => 'Please enter a valid email address';

  @override
  String get invalidDeepLinkTitle => 'Invalid Link';

  @override
  String get invalidDeepLinkMessage =>
      'The link you followed is not valid or has expired. Please check the link and try again.';

  @override
  String get invalidInvitationTitle => 'Invalid Invitation';

  @override
  String get invalidTimeFormat => 'Invalid time format. Use HH:MM (24-hour)';

  @override
  String get invitationActions => 'Invitation Actions';

  @override
  String invitationActionsTooltip(String email) {
    return 'Invitation actions for $email';
  }

  @override
  String get invitationAnalytics => 'Invitation Analytics';

  @override
  String invitationCancelledFor(String email) {
    return 'Invitation cancelled for $email';
  }

  @override
  String get invitationCancelledSuccessfully =>
      'Invitation cancelled successfully';

  @override
  String get invitationCode => 'Invitation Code';

  @override
  String get invitationCodeCopied => 'Invitation code copied to clipboard';

  @override
  String get invitationCodeNotAvailable => 'Invitation code not available';

  @override
  String get invitationCodeRequired => 'Invitation code is required';

  @override
  String get invitationExpired => 'This invitation has expired';

  @override
  String get invitationExpiredDesc =>
      'This invitation has expired and is no longer valid';

  @override
  String invitationSentTo(String email) {
    return 'Invitation sent to $email';
  }

  @override
  String get invitationStatistics => 'Invitation statistics';

  @override
  String get invitationType => 'Invitation Type';

  @override
  String get invitations => 'Invitations';

  @override
  String invitationsCount(int count) {
    return 'Invitations ($count)';
  }

  @override
  String invitationsExpiring(int count) {
    return '$count invitations expiring soon';
  }

  @override
  String get invite => 'Invite';

  @override
  String get inviteFamilyMember => 'Invite Family Member';

  @override
  String get inviteFamilyMembers => 'Invite to family';

  @override
  String get inviteMembersToStart => 'Invite members to get started';

  @override
  String get inviteNewMember => 'Invite New Member';

  @override
  String get inviteToGroup => 'Invite to group';

  @override
  String invitedToFamily(String familyName) {
    return 'Invited to join: $familyName';
  }

  @override
  String get join => 'Join';

  @override
  String joinFamily(String familyName) {
    return 'Join $familyName';
  }

  @override
  String joinFamilyName(String familyName) {
    return 'Join $familyName';
  }

  @override
  String get joinGroup => 'Join Group';

  @override
  String joinGroupName(String groupName) {
    return 'Join $groupName';
  }

  @override
  String get joinWithCode => 'Join with code';

  @override
  String get joined => 'Joined';

  @override
  String get joiningInProgress => 'Joining in progress...';

  @override
  String get justNow => 'just now';

  @override
  String get keepInvitation => 'Keep Invitation';

  @override
  String get labelFieldLabel => 'Label';

  @override
  String get labelHint => 'School Drop-off';

  @override
  String get labelRequired => 'Label cannot be empty';

  @override
  String get labelTooLong => 'Label must be 50 characters or less';

  @override
  String get language => 'Language';

  @override
  String get languageChanged => 'Language changed successfully';

  @override
  String get lastAdminProtection => 'Last Admin Protection';

  @override
  String get lastAdminWarning =>
      'You are the last admin of this family. You must assign a new admin or transfer ownership before leaving.';

  @override
  String lastExported(String timeAgo) {
    return 'Last exported: $timeAgo';
  }

  @override
  String get lastName => 'Last name *';

  @override
  String get lastUpdated => 'Last Updated';

  @override
  String get leave => 'Leave';

  @override
  String get leaveButton => 'Leave';

  @override
  String typeNameToConfirm(String name) {
    return 'To confirm, type the name exactly: $name';
  }

  @override
  String pleaseTypeNameExactly(String name) {
    return 'Please type \"$name\" exactly';
  }

  @override
  String get leaveFamily => 'Leave Family';

  @override
  String leaveFamilyAndJoinFamilyName(String familyName) {
    return 'Leave current family and join $familyName';
  }

  @override
  String get leaveFamilyConfirmation =>
      'Are you sure you want to leave this family?';

  @override
  String get leaveFamilyTitle => 'Leave Family';

  @override
  String get warning => 'Warning';

  @override
  String get leaveFamilyWarningMessage =>
      'You will lose access to all family data, schedules, and vehicles. This action cannot be undone.';

  @override
  String get removeMemberWarningMessage =>
      'This member will lose access to all family data. This action cannot be undone.';

  @override
  String memberActionsFor(String memberName) {
    return 'Member actions for $memberName';
  }

  @override
  String get leaveGroup => 'Leave Group';

  @override
  String get leaveGroupTitle => 'Leave Group';

  @override
  String get byLeavingGroupYouWill => 'By leaving this group, you will:';

  @override
  String get loseAccessGroupSchedules => '• Lose access to all group schedules';

  @override
  String get noLongerSeeGroupMembers =>
      '• No longer see group families and members';

  @override
  String get giveUpGroupAdminPrivileges => '• Give up group admin privileges';

  @override
  String get ownerFamilyCannotLeave =>
      'Note: The owner family cannot leave the group. Only members can leave.';

  @override
  String failedToLeaveGroup(String error) {
    return 'Failed to leave group: $error';
  }

  @override
  String get linkExpiryInfo =>
      'The link expires in 15 minutes for your security.';

  @override
  String get loading => 'Loading...';

  @override
  String get loadingError => 'Loading error';

  @override
  String get loadingErrorText => 'Loading error';

  @override
  String get loadingInvitations => 'Loading invitations...';

  @override
  String get loadingSentInvitations => 'Loading sent invitations...';

  @override
  String get loadingStatistics => 'Loading statistics...';

  @override
  String get loadingVehicles => 'Loading vehicles...';

  @override
  String get logExport => 'Log Export';

  @override
  String get logLevel => 'Log Level';

  @override
  String logLevelChangeFailed(String error) {
    return 'Failed to change log level: $error';
  }

  @override
  String logLevelChanged(String level) {
    return 'Log level changed to: $level';
  }

  @override
  String get logLevelDescription =>
      'Controls verbosity of app logging for debugging';

  @override
  String get logout => 'Sign Out';

  @override
  String get logsExportedSuccess =>
      '📤 Logs exported and uploaded to Firebase successfully!';

  @override
  String get logExportUnsupportedPlatform =>
      'Log export is only supported on mobile platforms (Android/iOS)';

  @override
  String get logExportNoDirectory => 'No export directory found';

  @override
  String get logExportNoFiles => 'No log files found after export';

  @override
  String get loseAccessSchedules => '• Lose access to all family schedules';

  @override
  String get loseAccessVehicles =>
      '• Lose access to family vehicles and assignments';

  @override
  String get magicLinkExpired =>
      'Magic link has expired. Please request a new one.';

  @override
  String get magicLinkResent => 'Login link resent';

  @override
  String get magicLinkSent => 'Magic link sent to your email';

  @override
  String get magicLinkSentDescription =>
      'A secure login link has been sent to:';

  @override
  String get magicLinkSentTitle => 'Login link sent';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get makeAdmin => 'Make Admin';

  @override
  String makeAdminConfirmation(String name) {
    return 'Grant admin privileges to $name?';
  }

  @override
  String get manage => 'Manage';

  @override
  String get manageChildren => 'Manage Children';

  @override
  String get manageFamily => 'Manage Family';

  @override
  String get manageVehicles => 'Manage Vehicles';

  @override
  String maxSeatsLabel(int max) {
    return 'Max: $max';
  }

  @override
  String get maxVehicles => 'Max Vehicles';

  @override
  String maximumTimeSlotsAllowed(int count) {
    return 'Maximum $count time slots allowed';
  }

  @override
  String get member => 'Member';

  @override
  String get memberActions => 'Member Actions';

  @override
  String memberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String get memberDetails => 'Member Details';

  @override
  String memberRemovedFromFamily(String memberName) {
    return '$memberName removed from family';
  }

  @override
  String get memberRole => 'MEMBER';

  @override
  String get members => 'members';

  @override
  String get membersTabLabel => 'Members';

  @override
  String minSeatsLabel(int min) {
    return 'Min: $min';
  }

  @override
  String minimumIntervalRequired(int minutes) {
    return 'Minimum $minutes minutes required between time slots';
  }

  @override
  String minutesAgo(int count) {
    return '${count}min ago';
  }

  @override
  String modifiedFrom(int original) {
    return 'modified from $original';
  }

  @override
  String get modifyTooltip => 'Modifier';

  @override
  String get mon => 'Mon';

  @override
  String get monday => 'Monday';

  @override
  String get mondayShort => 'Mon';

  @override
  String get mondayToFridayShort => 'Mon - Fri';

  @override
  String get monthView => 'Month';

  @override
  String get monthViewImplementation => 'Month view implementation';

  @override
  String get moreActionsFor => 'More actions for';

  @override
  String get morning => 'Morning';

  @override
  String get monthLabel => 'Month';

  @override
  String get myFamily => 'My family';

  @override
  String get name => 'Name';

  @override
  String get nameMaxLength => 'Name cannot exceed 50 characters';

  @override
  String get nameMinLength => 'Name must contain at least 2 characters';

  @override
  String get nameOptional => 'Name (optional)';

  @override
  String get navigationDashboard => 'Dashboard';

  @override
  String get navigationFamily => 'Family';

  @override
  String get navigationGroups => 'Groups';

  @override
  String get navigationProfile => 'Profile';

  @override
  String get navigationSchedule => 'Schedule';

  @override
  String get needGroupForSchedules =>
      'You need to join or create a transport group to view schedules.';

  @override
  String get newAdminEmail => 'New Admin Email';

  @override
  String get newChild => 'New child';

  @override
  String get newFamilyInvitation => 'New Family Invitation';

  @override
  String get newInvitationUpdate => 'New invitation update received';

  @override
  String get nextWeek => 'Next Week';

  @override
  String get currentWeek => 'Current Week';

  @override
  String get lastWeek => 'Last Week';

  @override
  String inWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count weeks',
      one: 'In $count week',
    );
    return '$_temp0';
  }

  @override
  String get noChildren => 'No children';

  @override
  String get noChildrenAssigned => 'No children assigned';

  @override
  String vehiclesPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vehicles',
      one: '$count vehicle',
    );
    return '$_temp0';
  }

  @override
  String get unknownVehicle => 'Unknown Vehicle';

  @override
  String moreItems(int count) {
    return '+$count more';
  }

  @override
  String get noDaysConfigured => 'No days configured';

  @override
  String get noDepartureTimesSelected => 'No departure times selected';

  @override
  String get noExpiryDate => 'No expiry (single use)';

  @override
  String get noExpiryIssues => 'No Expiry Issues';

  @override
  String get noFamily => 'No family';

  @override
  String get noFamilyFound => 'No family found';

  @override
  String get noFamilyIdAvailable => 'No family ID available';

  @override
  String noFilteredInvitations(String filterType) {
    return 'No $filterType invitations';
  }

  @override
  String get noInvitationCodes => 'No invitation codes';

  @override
  String get noInvitationCodesMessage =>
      'Generate invitation codes\nto facilitate joining.';

  @override
  String get noInvitations => 'No invitations';

  @override
  String get noInvitationsMessage =>
      'You have no pending invitations.\nNew invitations will appear here.';

  @override
  String get noInvitationsYet => 'No invitations yet';

  @override
  String get noLongerSeeFamilyMembers =>
      '• No longer see family members and children';

  @override
  String get noPendingInvitations => 'No pending invitations';

  @override
  String get noRecentActivity => 'No recent activity';

  @override
  String get noSentInvitations => 'No sent invitations';

  @override
  String get noSentInvitationsMessage =>
      'Invite members to your family\nor groups to get started.';

  @override
  String get noScheduleConfigured => 'No schedule configured for this day';

  @override
  String get noTimeSlotsConfigured => 'No time slots configured';

  @override
  String get noTransportGroups => 'No Transport Groups';

  @override
  String get noTransportGroupsDescription =>
      'Create or join a transport group to coordinate school trips with other families.';

  @override
  String get noVehicles => 'No vehicles';

  @override
  String get none => 'None';

  @override
  String get notAvailable => 'Non disponible';

  @override
  String get notes => 'Notes';

  @override
  String get notifications => 'Notifications';

  @override
  String get optionalDescription => 'Optional description';

  @override
  String get overrideCapacity => 'Override capacity';

  @override
  String overrideCapacityDisplay(int count) {
    return 'Override: $count';
  }

  @override
  String get overrideHistory => 'Override History';

  @override
  String get overrideType => 'Override Type';

  @override
  String get pasteFromClipboard => 'Paste from clipboard';

  @override
  String get pending => 'Pending';

  @override
  String get pendingInvitations => 'Pending Invitations';

  @override
  String get pendingInvitationsStats => 'Pending';

  @override
  String get personalInformation => 'Personal information';

  @override
  String get pleaseEnterNewAdminEmail =>
      'Please enter an email for the new admin';

  @override
  String get pleaseEnterValidNumber => 'Please enter a valid number';

  @override
  String get previousWeek => 'Previous Week';

  @override
  String get privacy => 'Privacy';

  @override
  String get processing => 'Processing...';

  @override
  String get profile => 'Profile';

  @override
  String get promoteAnotherAdmin => 'Promote Another Admin';

  @override
  String get promoteAnotherAdminDesc =>
      'Choose a family member to promote to admin role';

  @override
  String get promoteToAdmin => 'Promote to Admin';

  @override
  String get quickConfigurations => 'Quick Configurations';

  @override
  String get realTimeUpdatesUnavailable =>
      'Real-time updates unavailable. Tap refresh to load latest invitations.';

  @override
  String get reason => 'Reason';

  @override
  String get received => 'Received';

  @override
  String get recentActivity => 'Recent activity';

  @override
  String get refresh => 'Refresh';

  @override
  String get rejected => 'Rejected';

  @override
  String get rejectedInvitations => 'Rejected';

  @override
  String get removeAdmin => 'Remove Admin';

  @override
  String removeAdminConfirmation(String name) {
    return 'Remove admin privileges from $name?';
  }

  @override
  String get removeAdminNote => 'Note: This member will lose admin privileges';

  @override
  String get removeMember => 'Remove Member';

  @override
  String removeMemberConfirmation(String memberName) {
    return 'Are you sure you want to remove $memberName from the family?';
  }

  @override
  String get removeMemberDialogAccessibilityLabel =>
      'Remove Member Confirmation Dialog';

  @override
  String get removeMemberFromFamily => 'Remove member from this family';

  @override
  String get removeThisInvitation => 'Remove this invitation';

  @override
  String get removeTooltip => 'Supprimer';

  @override
  String get removeYourselfFromFamily => 'Remove yourself from this family';

  @override
  String get resend => 'Resend';

  @override
  String get resendLink => 'Resend link';

  @override
  String get reset => 'Reset';

  @override
  String get retry => 'Retry';

  @override
  String get retryExport => 'Retry Export';

  @override
  String get revoke => 'Revoke';

  @override
  String get revoked => 'Revoked';

  @override
  String get reconnect => 'Reconnect';

  @override
  String get resolve => 'Resolve';

  @override
  String get role => 'Role';

  @override
  String roleLabel(String role) {
    return 'Role: $role';
  }

  @override
  String roleUpdatedSuccessfully(String name) {
    return 'Role updated successfully for $name';
  }

  @override
  String get sat => 'Sat';

  @override
  String get saturday => 'Saturday';

  @override
  String get saturdayShort => 'Sat';

  @override
  String get saturdayToSundayShort => 'Sat - Sun';

  @override
  String get save => 'Save';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get saved => 'Saved';

  @override
  String get saving => 'Saving...';

  @override
  String get schedule => 'Schedule';

  @override
  String get scheduleLabel => 'Schedule';

  @override
  String get scheduleConfiguration => 'Schedule Configuration';

  @override
  String get scheduleConfigurationUpdatedSuccessfully =>
      'Schedule configuration updated successfully';

  @override
  String get scheduleCoordination => 'Schedule Coordination';

  @override
  String scheduleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count schedules',
      one: '$count schedule',
    );
    return '$_temp0';
  }

  @override
  String get schedulePreview => 'Schedule Preview';

  @override
  String get scheduleRefreshed => 'Schedule refreshed';

  @override
  String get school => 'School';

  @override
  String get schoolName => 'School name';

  @override
  String get search => 'Search';

  @override
  String get searchInvitations => 'Search invitations...';

  @override
  String get seatCapacityManagement => 'Seat Capacity Management';

  @override
  String get seatingConfiguration => 'Seating Configuration';

  @override
  String get seats => 'seats';

  @override
  String get secureLogin => 'Secure magic link login';

  @override
  String get seeMemberInformation => 'See member information and activity';

  @override
  String get select => 'Select';

  @override
  String get selectAnotherGroup => 'Select Another Group';

  @override
  String get selectGroup => 'Select a Group';

  @override
  String get selectLanguage => 'Select your preferred language';

  @override
  String get selectMemberToPromote => 'Select Member to Promote';

  @override
  String get selectNewAdmin => 'Select New Admin';

  @override
  String get sendInvitation => 'Send Invitation';

  @override
  String get sendInvitationTooltip => 'Send invitation';

  @override
  String get sendMagicLink => 'Send Magic Link';

  @override
  String get sendingButton => 'Sending...';

  @override
  String get sent => 'Sent';

  @override
  String get serverError => 'Server error. Please try again later';

  @override
  String get settings => 'Settings';

  @override
  String get showInvitationCode => 'Show Invitation Code';

  @override
  String get showVehicles => 'Show Vehicles';

  @override
  String signInToJoin(String familyName) {
    return 'Sign In to Join $familyName';
  }

  @override
  String signInToJoinFamilyName(String familyName) {
    return 'Sign In to Join $familyName';
  }

  @override
  String signInToJoinGroupName(String groupName) {
    return 'Sign In to Join $groupName';
  }

  @override
  String slotsConfigured(int current, int max, int active) {
    return '$current/$max slots configured • $active active';
  }

  @override
  String slotsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count slots',
      one: '$count slot',
    );
    return '$_temp0';
  }

  @override
  String get stackTrace => 'Stack Trace';

  @override
  String get standard => 'Standard';

  @override
  String get statistics => 'Statistics';

  @override
  String get statusAccepted => 'ACCEPTED';

  @override
  String get statusActive => 'Active';

  @override
  String get statusCancelled => 'CANCELLED';

  @override
  String get statusDeclined => 'DECLINED';

  @override
  String get statusExpired => 'EXPIRED';

  @override
  String get statusExpiringSoon => 'EXPIRING SOON';

  @override
  String get statusFailed => 'FAILED';

  @override
  String get statusInvalid => 'INVALID';

  @override
  String get statusPending => 'PENDING';

  @override
  String get statusRevoked => 'REVOKED';

  @override
  String get stay => 'Stay';

  @override
  String get stayButton => 'Stay';

  @override
  String get stayInCurrentFamily => 'Stay in Current Family';

  @override
  String get stayInCurrentFamilyDesc =>
      'Decline the new invitation and remain in your current family';

  @override
  String get successfullyJoinedGroup => 'Successfully joined group\\!';

  @override
  String get sun => 'Sun';

  @override
  String get sunday => 'Sunday';

  @override
  String get sundayShort => 'Sun';

  @override
  String get suv => 'SUV';

  @override
  String get switchToNewFamily => 'Switch to New Family';

  @override
  String get switchToNewFamilyDesc =>
      'Leave your current family and join the new one';

  @override
  String get sync => 'Sync';

  @override
  String get tapToAddFirstTimeSlot => 'Tap to add first time slot';

  @override
  String get temporary => 'Temporary';

  @override
  String get thu => 'Thu';

  @override
  String get thursday => 'Thursday';

  @override
  String get thursdayShort => 'Thu';

  @override
  String get time => 'Time';

  @override
  String timeAgoDays(int days, String plural) {
    return '$days day$plural ago';
  }

  @override
  String timeAgoHours(int hours, String plural) {
    return '$hours hour$plural ago';
  }

  @override
  String timeAgoMinutes(int minutes, String plural) {
    return '$minutes minute$plural ago';
  }

  @override
  String timeAlreadySelected(String time) {
    return 'Time $time is already selected';
  }

  @override
  String get timeHint => '08:00';

  @override
  String get timeIntervalError =>
      'Time must be in 15-minute intervals (00, 15, 30, 45)';

  @override
  String get timeLabel => 'Time (HH:MM)';

  @override
  String get timePickerInstructions =>
      'Select departure times by tapping on the time slots';

  @override
  String timeRange(String range) {
    return 'Time range: $range';
  }

  @override
  String get timeSlotExists => 'This time slot already exists';

  @override
  String get timeSlots => 'Time Slots';

  @override
  String timeSlotsSelected(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count time slots selected',
      one: '$count time slot selected',
      zero: 'No time slots selected',
    );
    return '$_temp0';
  }

  @override
  String get today => 'Today';

  @override
  String get total => 'Total';

  @override
  String totalChildrenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count children',
      one: '1 child',
      zero: 'No children',
    );
    return '$_temp0';
  }

  @override
  String totalMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
      zero: 'No members',
    );
    return '$_temp0';
  }

  @override
  String totalVehiclesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vehicles',
      one: '1 vehicle',
      zero: 'No vehicles',
    );
    return '$_temp0';
  }

  @override
  String get totalCapacity => 'Total capacity';

  @override
  String totalSeats(int count) {
    return 'Total: $count';
  }

  @override
  String get totalSeatsHint => 'Total number of seats';

  @override
  String get transferOwnership => 'Transfer Ownership';

  @override
  String get transferOwnershipDesc =>
      'Transfer full ownership of the family to another member';

  @override
  String get transferOwnershipWarning =>
      'This will transfer full ownership and admin rights to the selected member. This action cannot be undone.';

  @override
  String get transportGroups => 'Transport Groups';

  @override
  String get tripCreationFormToImplement => 'Trip creation form to implement';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get tue => 'Tue';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get tuesdayShort => 'Tue';

  @override
  String typeToConfirm(String confirmText) {
    return 'Type \'$confirmText\' to confirm:';
  }

  @override
  String get universalInvitation => 'Universal invitation';

  @override
  String get unknownFamily => 'Unknown Family';

  @override
  String get unsavedChanges => 'Unsaved Changes';

  @override
  String get unsavedChangesTitle => 'Unsaved Changes';

  @override
  String get updateVehicle => 'Update Vehicle';

  @override
  String get updating => 'Updating';

  @override
  String get usage => 'Usage';

  @override
  String get userMenu => 'User Menu';

  @override
  String get userProfileOptions => 'User profile options would appear here';

  @override
  String userRole(String role) {
    return 'Role: $role';
  }

  @override
  String get validateCode => 'Validate Code';

  @override
  String get validatingGroupInvitation => 'Validating group invitation...';

  @override
  String get validatingInvitation => 'Validating invitation...';

  @override
  String get van => 'Van';

  @override
  String get vehicleAddedSuccessfully => 'Vehicle added successfully';

  @override
  String vehicleAssignment(String vehicleId) {
    return 'Vehicle Assignment: $vehicleId';
  }

  @override
  String vehicleCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vehicles',
      one: '$count vehicle',
    );
    return '$_temp0';
  }

  @override
  String get vehicleDetails => 'Vehicle details';

  @override
  String get vehicleId => 'Vehicle ID';

  @override
  String get vehicleInformation => 'Vehicle Information';

  @override
  String get vehicleName => 'Vehicle Name';

  @override
  String get vehicleNameRequired => 'Vehicle name *';

  @override
  String get vehicleNotFound => 'Vehicle not found';

  @override
  String get vehicleType => 'Vehicle type';

  @override
  String get vehicleUpdatedSuccessfully => 'Vehicle updated successfully';

  @override
  String get vehicles => 'Vehicles';

  @override
  String vehicleAddedSuccess(String vehicleName) {
    return '$vehicleName added successfully';
  }

  @override
  String vehicleFailedToAdd(String error) {
    return 'Failed to add vehicle: $error';
  }

  @override
  String vehicleAlreadyAssigned(String vehicleName) {
    return '$vehicleName is already assigned to this slot';
  }

  @override
  String vehicleFailedToRemove(String error) {
    return 'Failed to remove vehicle: $error';
  }

  @override
  String vehicleRemovedSuccess(String vehicleName) {
    return '$vehicleName removed successfully';
  }

  @override
  String get verificationFailedTitle => 'Verification failed';

  @override
  String get view => 'View';

  @override
  String get viewAll => 'View All';

  @override
  String get viewDetails => 'View details';

  @override
  String get viewGroupSchedule => 'View Group Schedule';

  @override
  String get viewMemberDetails => 'View Member Details';

  @override
  String get wed => 'Wed';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get wednesdayShort => 'Wed';

  @override
  String get weekLabel => 'Week';

  @override
  String get weekView => 'Week';

  @override
  String get weekViewImplementation => 'Week view implementation';

  @override
  String weekdaysCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weekdays',
      one: '$count weekday',
    );
    return '$_temp0';
  }

  @override
  String get weekdaysOnly => 'Weekdays Only';

  @override
  String weekendDaysCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weekend days',
      one: '$count weekend day',
    );
    return '$_temp0';
  }

  @override
  String get weekendsOnly => 'Weekends Only';

  @override
  String get weeklySchedule => 'Weekly Schedule';

  @override
  String weeklySlotTotal(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count slots per week',
      one: '$count slot per week',
    );
    return '$_temp0';
  }

  @override
  String get welcomeNewUser =>
      'Welcome! We see you\'re new. Please provide your name to complete your account.';

  @override
  String get welcomeToEduLiftLogin => 'Welcome to EduLift';

  @override
  String get whyOverrideNeeded => 'Why is this override needed?';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get you => 'You';

  @override
  String get youAreLastAdmin => 'You are the last admin';

  @override
  String youAreLeavingAs(String role) {
    return 'You are leaving as: $role';
  }

  @override
  String get youHaveLeftFamily => 'You have left the family';

  @override
  String get youveBeenInvitedToJoin => 'You\'ve been invited to join';

  @override
  String get validGroupInvitation =>
      'This group invitation is valid and ready to use.';

  @override
  String get verifyingMagicLink => 'Verifying Magic Link';

  @override
  String get verifyingMagicLinkMessage =>
      'Please wait while we verify your magic link...';

  @override
  String get verificationSuccessful => 'Verification Successful';

  @override
  String get welcomeAfterMagicLinkSuccess =>
      'Welcome to EduLift! Taking you to your dashboard...';

  @override
  String get secureAuthentication => 'Secure Authentication';

  @override
  String get cancelChanges => 'Cancel Changes';

  @override
  String get saveConfiguration => 'Save Configuration';

  @override
  String get validation => 'Validation';

  @override
  String get quickSelectionOptions => 'Quick selection options';

  @override
  String get activeScheduleDays => 'Active Schedule Days';

  @override
  String daysSelected(int count) {
    return '$count/7 days selected';
  }

  @override
  String get atLeastOneDayRequired => 'At least one day must be selected';

  @override
  String get noDaysSelectedWarning =>
      'No days selected. Schedule will be disabled.';

  @override
  String get scheduleActive => 'Schedule Active';

  @override
  String get weekdayAbbrevMon => 'Mon';

  @override
  String get weekdayAbbrevTue => 'Tue';

  @override
  String get weekdayAbbrevWed => 'Wed';

  @override
  String get weekdayAbbrevThu => 'Thu';

  @override
  String get weekdayAbbrevFri => 'Fri';

  @override
  String get weekdayAbbrevSat => 'Sat';

  @override
  String get weekdayAbbrevSun => 'Sun';

  @override
  String get weekendLabel => 'Weekend';

  @override
  String get enterEmailAddress => 'Enter email address';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get invitationSentSuccessfully => 'Invitation sent successfully';

  @override
  String get addChildButton => 'Add Child';

  @override
  String get saveVehicle => 'Save Vehicle';

  @override
  String get selectTimeSlot => 'Select Time Slot';

  @override
  String get confirmSchedule => 'Confirm Schedule';

  @override
  String get scheduleConfirmed => 'Schedule confirmed';

  @override
  String get scheduleDetails => 'Schedule Details';

  @override
  String get editSchedule => 'Edit Schedule';

  @override
  String get welcomeOnboarding => 'Welcome';

  @override
  String get getStarted => 'Get Started';

  @override
  String get skipOnboarding => 'Skip';

  @override
  String get nextOnboarding => 'Next';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get createFamilyButton => 'Create Family';

  @override
  String get familyNameLabel => 'Family Name';

  @override
  String get scheduleConfigSavedSuccess =>
      'Schedule configuration saved successfully';

  @override
  String scheduleConfigSaveFailed(String error) {
    return 'Failed to save configuration: $error';
  }

  @override
  String get saveOperationFailed =>
      'Save operation did not complete successfully';

  @override
  String scheduleConfigSaveException(String exception, Object error) {
    return 'Failed to save configuration: $error';
  }

  @override
  String get changesCanceledReverted =>
      'Changes canceled - reverted to original configuration';

  @override
  String get unsavedChangesScheduleMessage =>
      'You have unsaved changes to the schedule configuration. Are you sure you want to leave without saving?';

  @override
  String get groupNotFoundOrNoAccess =>
      'The group could not be found or you no longer have access to it.';

  @override
  String get failedToLoadGroupDetails => 'Failed to load group details';

  @override
  String get yourNameLabel => 'Your Name';

  @override
  String get enterFullNameHint => 'Enter your full name';

  @override
  String get personalMessageOptionalLabel => 'Personal Message (Optional)';

  @override
  String get addPersonalMessageHint =>
      'Add a personal message to your invitation...';

  @override
  String get ageOptionalLabel => 'Age (optional)';

  @override
  String get enterAgeHint => 'Enter age';

  @override
  String get yearsUnit => 'years';

  @override
  String get enterFamilyNameHint => 'Enter family name (e.g., Smith Family)';

  @override
  String get describeFamilyOptionalHint => 'Describe your family (optional)';

  @override
  String get familyInvitationCodeHint => 'Family invitation code';

  @override
  String get enterEmailAddressHint => 'Enter your email address';

  @override
  String get nameTooShort => 'Name must be at least 2 characters';

  @override
  String get familyNameCannotBeEmpty => 'Family name cannot be empty';

  @override
  String get familyNameTooShortValidation =>
      'Family name must be at least 2 characters';

  @override
  String get defaultGroupConfigInfo =>
      'No schedule configured yet. Configure departure hours for each day and save to activate the schedule.';

  @override
  String get makeAdminTitle => 'Make Admin';

  @override
  String get removeAdminRoleTitle => 'Remove Admin Role';

  @override
  String get makeAdminButton => 'Make Admin';

  @override
  String get removeAdminButton => 'Remove Admin';

  @override
  String get addChildAction => 'Add Child';

  @override
  String get joinGroupAction => 'Join a Group';

  @override
  String get addVehicleAction => 'Add Vehicle';

  @override
  String get configureScheduleTooltip => 'Configure Schedule';

  @override
  String get manageChildrenTooltip => 'Manage Children';

  @override
  String get removeVehicleTooltip => 'Remove Vehicle';

  @override
  String get editTimeTooltip => 'Edit time';

  @override
  String get deleteTimeTooltip => 'Delete time';

  @override
  String get resolveScheduleConflictsTooltip => 'Resolve schedule conflicts';

  @override
  String get refreshScheduleTooltip => 'Refresh schedule';

  @override
  String get filterAndSortOptionsTooltip => 'Filter and sort options';

  @override
  String get logoutTooltip => 'Logout';

  @override
  String get tryLoadingConfigAgainLabel => 'Try loading configuration again';

  @override
  String switchToDayConfigurationLabel(String day) {
    return 'Switch to $day configuration';
  }

  @override
  String departureHoursConfiguredHint(int count) {
    return '$count departure hours configured';
  }

  @override
  String get noDepartureHoursConfiguredHint => 'No departure hours configured';

  @override
  String get viewScheduleConflictsLabel => 'View schedule conflicts';

  @override
  String get refreshScheduleLabel => 'Refresh schedule';

  @override
  String get filterScheduleLabel => 'Filter schedule';

  @override
  String eventAtTimeLabel(String eventTitle, String time) {
    return '$eventTitle at $time';
  }

  @override
  String get familyNameInputFieldLabel => 'Family name input field';

  @override
  String get familyDescriptionInputFieldLabel =>
      'Family description input field';

  @override
  String get createFamilyButtonLabel => 'Create family button';

  @override
  String get cancelButtonLabel => 'Cancel button';

  @override
  String get removeVehicle => 'Remove Vehicle';

  @override
  String get editTime => 'Edit time';

  @override
  String get deleteTime => 'Delete time';

  @override
  String get resolveScheduleConflicts => 'Resolve schedule conflicts';

  @override
  String get refreshSchedule => 'Refresh schedule';

  @override
  String get filterAndSortOptions => 'Filter and sort options';

  @override
  String get joinedDate => 'Joined';

  @override
  String get enterAge => 'Enter age';

  @override
  String get enterYourEmailAddress => 'Enter your email address';

  @override
  String get biometricAuthenticationButton => 'Biometric authentication button';

  @override
  String get websocketConnectionStatus => 'WebSocket connection status';

  @override
  String get welcomeSection => 'Welcome Section';

  @override
  String get currentDateAndDashboardDescription =>
      'Current date and dashboard description';

  @override
  String get familyOverviewSection => 'Family Overview Section';

  @override
  String get welcomeIcon => 'Welcome icon';

  @override
  String get familyIcon => 'Family icon';

  @override
  String get loadingFamilyInformation => 'Loading family information';

  @override
  String get errorLoadingFamilyInformation =>
      'Error loading family information';

  @override
  String get errorIcon => 'Error icon';

  @override
  String get quickActionsSection => 'Quick Actions Section';

  @override
  String get recentActivitiesSection => 'Recent Activities Section';

  @override
  String get noRecentActivityIcon => 'No recent activity icon';

  @override
  String get upcomingTripsSection => 'Upcoming Trips Section';

  @override
  String get noTripsScheduledIcon => 'No trips scheduled icon';

  @override
  String get unexpectedErrorOccurred => 'An unexpected error occurred.';

  @override
  String get failedToSendMagicLink =>
      'Failed to send magic link - empty response';

  @override
  String get vehicleNearCapacity => 'Vehicle Near Capacity';

  @override
  String get familyInvitationExpired => 'Family Invitation Expired';

  @override
  String get groupMembershipUpdated => 'Group Membership Updated';

  @override
  String get dataRefresh => 'Data Refresh';

  @override
  String get viewConflictDetails => 'View conflict details';

  @override
  String get attemptingToReconnect => 'Attempting to reconnect...';

  @override
  String get realtimeUpdatesActive => 'Real-time updates are active';

  @override
  String get connectingToRealtimeUpdates =>
      'Connecting to real-time updates...';

  @override
  String get synchronizingData => 'Synchronizing data...';

  @override
  String userAvatarFor(String userName) {
    return 'User avatar for $userName';
  }

  @override
  String welcomeBackUser(String userName) {
    return 'Welcome back, $userName!';
  }

  @override
  String get currentDateAndDashboardDesc =>
      'Current date and dashboard description';

  @override
  String yourTransportDashboard(String date) {
    return 'Your transport dashboard • $date';
  }

  @override
  String familyStatistics(int members, int children, int vehicles) {
    return 'Family statistics: $members members, $children children, $vehicles vehicles';
  }

  @override
  String get registerForTransport => 'Register for transport';

  @override
  String get connectWithOtherFamilies => 'Connect with other families';

  @override
  String get offerRidesToOthers => 'Offer rides to others';

  @override
  String get loggedInAs => 'Logged in as';

  @override
  String get toGetStartedSetupFamily =>
      'To get started, you need to set up your family.';

  @override
  String get settingUpOnboarding => 'Setting up your onboarding...';

  @override
  String get youveBeenInvitedToJoinFamily =>
      'You\'ve been invited to join a family!';

  @override
  String get acceptInvitationToCoordinate =>
      'Accept the invitation to start coordinating with other families.';

  @override
  String get chooseYourFamilySetup => 'Choose Your Family Setup';

  @override
  String get joinExistingFamily => 'Join Existing Family';

  @override
  String groupMembersPageTitle(String groupName) {
    return '$groupName - Members';
  }

  @override
  String promoteToAdminConfirm(String familyName) {
    return 'Are you sure you want to promote \"$familyName\" to Administrator? They will be able to manage group members and settings.';
  }

  @override
  String get promote => 'Promote';

  @override
  String get familyPromotedSuccess => 'Family promoted to Admin successfully';

  @override
  String get failedToPromoteFamily => 'Failed to promote family';

  @override
  String get demoteToMember => 'Demote to Member';

  @override
  String demoteToMemberConfirm(String familyName) {
    return 'Are you sure you want to demote \"$familyName\" to Member? They will lose administrative privileges.';
  }

  @override
  String get demote => 'Demote';

  @override
  String get familyDemotedSuccess => 'Family demoted to Member successfully';

  @override
  String get failedToDemoteFamily => 'Failed to demote family';

  @override
  String get removeFamily => 'Remove Family';

  @override
  String removeFamilyConfirm(String familyName) {
    return 'Are you sure you want to remove \"$familyName\" from the group? This action cannot be undone.';
  }

  @override
  String get removeFamilyAction => 'Remove';

  @override
  String get familyRemovedSuccess => 'Family removed successfully';

  @override
  String failedToRemoveFamily(String error) {
    return 'Failed to remove family: $error';
  }

  @override
  String get removeFromGroup => 'Remove from Group';

  @override
  String cancelInvitationConfirm(String familyName) {
    return 'Are you sure you want to cancel the invitation for \"$familyName\"?';
  }

  @override
  String get invitationCanceledSuccess => 'Invitation canceled successfully';

  @override
  String failedToCancelInvitation(String error) {
    return 'Failed to cancel invitation: $error';
  }

  @override
  String get noInvitationIdFound => 'No invitation ID found';

  @override
  String anErrorOccurred(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get roleOwner => 'OWNER';

  @override
  String get roleAdmin => 'ADMIN';

  @override
  String get roleMember => 'MEMBER';

  @override
  String get rolePending => 'PENDING';

  @override
  String get roleMemberDescription => 'Can view and join group trips';

  @override
  String get roleAdminDescription => 'Can manage group and invite members';

  @override
  String get noAdmins => 'No admins';

  @override
  String adminCountMore(String firstName, int count) {
    return '$firstName (+$count more)';
  }

  @override
  String get yourFamily => 'Your Family';

  @override
  String get inviteFamily => 'Invite Family';

  @override
  String get inviteFamilyComingSoon => 'Invite family feature coming soon';

  @override
  String get noFamiliesYet => 'No families yet';

  @override
  String get inviteFamiliesToGetStarted => 'Invite families to get started';

  @override
  String get loadingFamilies => 'Loading families...';

  @override
  String get failedToLoadFamilies => 'Failed to load families';

  @override
  String get inviteFamilyToGroup => 'Invite Family to Group';

  @override
  String get inviteFamilyToGroupSubtitle =>
      'Search and invite families to join this group';

  @override
  String get searchFamilies => 'Search Families';

  @override
  String get enterFamilyName => 'Enter family name...';

  @override
  String get inviteAs => 'Invite as:';

  @override
  String get personalMessageOptional => 'Personal Message (Optional)';

  @override
  String get searchResults => 'Search Results';

  @override
  String get refineSearchForMoreResults =>
      'Showing maximum results. Refine your search to see more specific matches.';

  @override
  String andXMore(int count) {
    return '+$count more';
  }

  @override
  String get enterAtLeast2Characters => 'Enter at least 2 characters to search';

  @override
  String get noFamiliesFound => 'No families found';

  @override
  String get alreadyInvited => 'Already invited';

  @override
  String get inviting => 'Inviting...';

  @override
  String searchFailed(String error) {
    return 'Search failed: $error';
  }

  @override
  String invitationSent(String familyName) {
    return 'Invitation sent to $familyName';
  }

  @override
  String invitationFailed(String error) {
    return 'Invitation failed: $error';
  }

  @override
  String get manageMembers => 'Manage Members';

  @override
  String get manageMembersDescription =>
      'Manage family members, roles, and invitations for this group';

  @override
  String get pendingInvitation => 'Pending Invitation';

  @override
  String get cancelInvitationDescription => 'Revoke this pending invitation';

  @override
  String get promoteToAdminDescription =>
      'Grant admin permissions to this family';

  @override
  String get demoteToMemberDescription =>
      'Remove admin permissions from this family';

  @override
  String get removeFamilyFromGroupDescription =>
      'Remove this family from the group';

  @override
  String promoteToAdminConfirmation(String familyName) {
    return 'Are you sure you want to promote $familyName to group admin?';
  }

  @override
  String get adminCanManageGroupMembers =>
      'Admins can manage group members and schedules';

  @override
  String demoteToMemberConfirmation(String familyName) {
    return 'Are you sure you want to demote $familyName to member?';
  }

  @override
  String get demoteToMemberNote => 'This family will lose admin permissions';

  @override
  String get removeFamilyDialogAccessibilityLabel => 'Remove family from group';

  @override
  String removeFamilyConfirmation(String familyName) {
    return 'Are you sure you want to remove $familyName from this group?';
  }

  @override
  String get removeAdminFamilyNote =>
      'Warning: This admin family will be removed from the group';

  @override
  String invitedOn(String date) {
    return 'Invited on $date';
  }

  @override
  String cancelInvitationConfirmation(String familyName) {
    return 'Are you sure you want to cancel the invitation for $familyName?';
  }

  @override
  String get cancelInvitationNote =>
      'The family will not be able to join with this invitation link';

  @override
  String get familyAlreadyInvited =>
      'This family has already been invited to this group';

  @override
  String get familyAlreadyMember =>
      'This family is already a member of this group';

  @override
  String get familyNotFound => 'Family not found';

  @override
  String get invalidInvitationCode => 'Invalid or expired invitation code';

  @override
  String get insufficientPermissions =>
      'You don\'t have permission to perform this action';

  @override
  String get invalidRequest => 'Invalid request. Please check your input';

  @override
  String get authenticationRequired => 'Authentication required';

  @override
  String get resourceNotFound => 'Resource not found';

  @override
  String get conflictError => 'This action conflicts with existing data';

  @override
  String get networkError =>
      'Network connection error. Please check your internet connection';

  @override
  String get requestTimeout => 'Request timed out. Please try again';

  @override
  String get unexpectedError => 'An unexpected error occurred';

  @override
  String get groupManagement => 'Group Management';

  @override
  String get invitationIsValid =>
      'This group invitation is valid and ready to use.';

  @override
  String get invitedBy => 'Invited by:';

  @override
  String get aGroup => 'a group';

  @override
  String get connectionFullyConnected => 'Fully Connected';

  @override
  String get connectionLimitedConnectivity => 'Limited Connectivity';

  @override
  String get connectionOffline => 'Offline';

  @override
  String get connectionStatusTitle => 'Connection Status';

  @override
  String get connectionHttpStatus => 'Internet Connection';

  @override
  String get connectionWebSocketStatus => 'Real-time Updates';

  @override
  String get connectionConnected => 'Connected';

  @override
  String get connectionDisconnected => 'Disconnected';

  @override
  String get snackbarBackOnline => 'Back online. Syncing...';

  @override
  String get snackbarLimitedConnectivity =>
      'Limited connectivity. Real-time updates may be delayed.';

  @override
  String get snackbarOffline =>
      'You\'re offline. Changes will sync when reconnected.';

  @override
  String get midday => 'Midday';

  @override
  String get evening => 'Evening';

  @override
  String get night => 'Night';

  @override
  String get unknown => 'Unknown';

  @override
  String get currentlyAssigned => 'Currently Assigned';

  @override
  String get availableVehicles => 'Available Vehicles';

  @override
  String get noVehiclesAvailable => 'No Vehicles Available';

  @override
  String get addVehiclesToFamily =>
      'Add vehicles to your family to assign them to schedules';

  @override
  String get errorLoadingVehicles => 'Error Loading Vehicles';

  @override
  String vehiclesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vehicles',
      one: '1 vehicle',
      zero: 'No vehicles',
    );
    return '$_temp0';
  }

  @override
  String get assigned => 'Assigned';

  @override
  String get assignVehicle => 'Assign Vehicle';

  @override
  String availableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count available',
      one: '1 available',
      zero: 'None available',
    );
    return '$_temp0';
  }

  @override
  String get noVehiclesAssignedToTimeSlot =>
      'No vehicles assigned to this time slot';

  @override
  String get allVehiclesAssigned => 'All available vehicles are assigned';

  @override
  String expandTimeSlot(String timeSlot) {
    return 'Expand $timeSlot';
  }

  @override
  String seatsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seats',
      one: '1 seat',
      zero: 'No seats',
    );
    return '$_temp0';
  }

  @override
  String get seatOverride => 'Seat Override';

  @override
  String get adjustCapacityForTrip => 'Adjust capacity for this trip';

  @override
  String get temporarilyAdjustCapacity =>
      'Temporarily adjust vehicle capacity (e.g., wheelchair configuration)';

  @override
  String leaveEmptyForDefault(int capacity) {
    String _temp0 = intl.Intl.pluralLogic(
      capacity,
      locale: localeName,
      other: '$capacity seats',
      one: '1 seat',
      zero: 'no seats',
    );
    return 'Leave empty for default ($_temp0)';
  }

  @override
  String get overrideMustBeBetween => 'Override must be between 0 and 50 seats';

  @override
  String get cannotDetermineWeek => 'Cannot determine week for schedule';

  @override
  String get seatOverrideUpdated => 'Seat override updated';

  @override
  String get seatOverrideActive => 'Seat override active';

  @override
  String overrideDetails(int override, int base) {
    return 'Override: $override ($base base)';
  }

  @override
  String get scheduleConfigurationRequired => 'Schedule configuration required';

  @override
  String get setupTimeSlotsToEnableScheduling =>
      'This group needs schedule configuration. Set up time slots to enable scheduling.';

  @override
  String get contactAdministratorToSetupTimeSlots =>
      'Contact a group administrator to set up time slots.';

  @override
  String get navigateToPreviousWeek => 'Navigate to previous week';

  @override
  String get navigateToNextWeek => 'Navigate to next week';

  @override
  String emptySlotTapToAddVehicle(String day, String time) {
    return 'Empty slot for $day at $time, tap to add vehicle';
  }

  @override
  String slotWithVehiclesTapToManage(String day, String time, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vehicles',
      one: '1 vehicle',
    );
    return '$day at $time with $_temp0, tap to manage';
  }

  @override
  String manageChildrenForVehicle(String vehicleName) {
    return 'Manage children for $vehicleName';
  }

  @override
  String removeVehicleFromSlot(String vehicleName) {
    return 'Remove $vehicleName from this slot';
  }

  @override
  String assignChildToVehicle(String childName) {
    return 'Assign $childName to vehicle';
  }

  @override
  String removeChildFromVehicle(String childName) {
    return 'Remove $childName from vehicle';
  }

  @override
  String get hasPendingChanges => 'Has pending offline changes';

  @override
  String get childAssignmentComingSoon =>
      'Child assignment feature coming soon';

  @override
  String seatOverrideUpdateFailed(String error) {
    return 'Failed to update seat override: $error';
  }

  @override
  String saveAssignments(int count) {
    return 'Save ($count)';
  }

  @override
  String get vehicleCapacityFull => 'Cannot assign child: vehicle full';

  @override
  String get assignmentsSavedSuccessfully => 'Assignments saved successfully';

  @override
  String get selectWeekHelpText => 'Select week';

  @override
  String get weekPickerHelperText => 'Select any date to jump to that week';

  @override
  String vehiclesAssigned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vehicles',
      one: '1 vehicle',
      zero: 'No vehicles',
    );
    return '$_temp0';
  }

  @override
  String get noVehiclesAssigned => 'No vehicles assigned';

  @override
  String collapseTimeSlot(String timeSlot) {
    return 'Collapse $timeSlot';
  }

  @override
  String get cannotAddVehiclesToPastSlots =>
      'Cannot add vehicles to past time slots';

  @override
  String vehicleNotFoundInFamily(String vehicleName, String vehicleId) {
    return 'The vehicle \"$vehicleName\" (ID: $vehicleId) is assigned to this time slot but no longer exists in your family.';
  }

  @override
  String get contactSupportOrRemoveAssignment =>
      'Please contact support or remove this assignment.';

  @override
  String get removeAssignment => 'Remove Assignment';

  @override
  String get timesShownInYourTimezone => 'Times shown in your timezone';

  @override
  String get timezoneLabel => 'Timezone';

  @override
  String timesShownInTimezone(String timezone) {
    return 'Times shown in your timezone ($timezone)';
  }

  @override
  String get todayTransports => 'Today\'s Transports';

  @override
  String get noTransportsToday => 'No transports scheduled today';

  @override
  String get seeFullSchedule => 'See full schedule →';

  @override
  String get refreshFailed => 'Failed to refresh transport data';

  @override
  String get loadingTodayTransports => 'Loading today\'s transports...';

  @override
  String get errorLoadingTransports => 'Error loading transports';

  @override
  String get todayTransportList => 'Today\'s transport list';

  @override
  String get next7Days => 'Next 7 days';

  @override
  String get weekViewExpanded => 'Week view expanded';

  @override
  String dayWithTransports(String day, int count) {
    return '$day • $count transports';
  }

  @override
  String get noTransportsWeek => 'No transports this week';

  @override
  String get expandWeekView => 'Expand week view';

  @override
  String get collapseWeekView => 'Collapse week view';
}
