// EduLift Mobile - Family Feature Constants
// Extracted hardcoded values for better maintainability

/// Family-specific constants
class FamilyConstants {
  // ========================================
  // VALIDATION CONSTRAINTS
  // ========================================

  /// Maximum family name length
  static const int maxFamilyNameLength = 50;

  /// Minimum family name length
  static const int minFamilyNameLength = 2;

  /// Maximum child name length
  static const int maxChildNameLength = 50;

  /// Minimum child name length
  static const int minChildNameLength = 2;

  /// Maximum child age
  static const int maxChildAge = 18;

  /// Minimum child age
  static const int minChildAge = 0;

  /// Maximum vehicle name length
  static const int maxVehicleNameLength = 50;

  /// Minimum vehicle name length
  static const int minVehicleNameLength = 2;

  /// Maximum vehicle capacity
  static const int maxVehicleCapacity = 50;

  /// Minimum vehicle capacity
  static const int minVehicleCapacity = 1;

  /// Maximum vehicle description length
  static const int maxVehicleDescriptionLength = 200;

  // ========================================
  // CACHE SETTINGS
  // ========================================

  /// Family data cache duration
  static const Duration familyCacheDuration = Duration(hours: 24);

  /// Children data cache duration
  static const Duration childrenCacheDuration = Duration(hours: 12);

  /// Vehicles data cache duration
  static const Duration vehiclesCacheDuration = Duration(hours: 12);

  /// Invitations cache duration
  static const Duration invitationsCacheDuration = Duration(hours: 6);
  // ========================================
  // SYNC SETTINGS
  // ========================================

  /// Maximum pending changes to store
  static const int maxPendingChanges = 100;

  /// Sync retry interval
  static const Duration syncRetryInterval = Duration(minutes: 5);

  /// Maximum sync retry attempts
  static const int maxSyncRetryAttempts = 3;

  // ========================================
  // UI SETTINGS
  // ========================================

  /// Children list page size
  static const int childrenPageSize = 20;

  /// Vehicles list page size
  static const int vehiclesPageSize = 20;

  /// Default loading timeout
  static const Duration defaultLoadingTimeout = Duration(seconds: 30);

  /// Animation duration for family operations
  static const Duration familyAnimationDuration = Duration(milliseconds: 300);
  // ========================================
  // PERMISSIONS
  // ========================================

  /// Available family roles
  static const List<String> availableFamilyRoles = [
    'admin',
    'parent',
    'guardian',
    'viewer',
  ];

  /// Default role for new family members
  static const String defaultMemberRole = 'viewer';

  /// Admin role identifier
  static const String adminRole = 'admin';

  /// Parent role identifier
  static const String parentRole = 'parent';

  // ========================================
  // ERROR MESSAGES
  // ========================================

  /// Family name validation errors
  static const String familyNameTooShort =
      'Le nom de famille doit contenir au moins 2 caractères';
  static const String familyNameTooLong =
      'Le nom de famille ne peut pas dépasser 50 caractères';
  static const String familyNameRequired = 'Le nom de famille est requis';

  /// Child validation errors
  static const String childNameTooShort =
      'Le nom de l\'enfant doit contenir au moins 2 caractères';
  static const String childNameTooLong =
      'Le nom de l\'enfant ne peut pas dépasser 50 caractères';
  static const String childNameRequired = 'Le nom de l\'enfant est requis';
  static const String childAgeTooYoung =
      'L\'âge de l\'enfant ne peut pas être négatif';
  static const String childAgeTooOld =
      'L\'âge de l\'enfant ne peut pas dépasser 18 ans';

  /// Vehicle validation errors
  static const String vehicleNameTooShort =
      'Le nom du véhicule doit contenir au moins 2 caractères';
  static const String vehicleNameTooLong =
      'Le nom du véhicule ne peut pas dépasser 50 caractères';
  static const String vehicleNameRequired = 'Le nom du véhicule est requis';
  static const String vehicleCapacityTooSmall =
      'La capacité du véhicule doit être d\'au moins 1';
  static const String vehicleCapacityTooLarge =
      'La capacité du véhicule ne peut pas dépasser 50';
  static const String vehicleDescriptionTooLong =
      'La description du véhicule ne peut pas dépasser 200 caractères';

  /// General error messages
  static const String networkError = 'Erreur de connexion réseau';
  static const String serverError = 'Erreur serveur temporaire';
  static const String unauthorizedError =
      'Session expirée, veuillez vous reconnecter';
  static const String notFoundError = 'Élément non trouvé';
  static const String validationError = 'Données invalides';
  static const String offlineError =
      'Mode hors ligne - synchronisation en attente';

  // ========================================
  // SUCCESS MESSAGES
  // ========================================

  /// Success messages
  static const String familyCreatedSuccess = 'Famille créée avec succès';
  static const String familyUpdatedSuccess = 'Famille mise à jour avec succès';
  static const String childAddedSuccess = 'Enfant ajouté avec succès';
  static const String childUpdatedSuccess = 'Enfant mis à jour avec succès';
  static const String childRemovedSuccess = 'Enfant supprimé avec succès';
  static const String vehicleAddedSuccess = 'Véhicule ajouté avec succès';
  static const String vehicleUpdatedSuccess = 'Véhicule mis à jour avec succès';
  static const String vehicleRemovedSuccess = 'Véhicule supprimé avec succès';
  static const String syncCompletedSuccess =
      'Synchronisation terminée avec succès';

  // ========================================
  // FEATURE FLAGS
  // ========================================

  /// Enable offline mode for family features
  static const bool enableOfflineMode = true;

  /// Enable real-time sync for family data
  static const bool enableRealTimeSync = true;

  /// Enable family invitations
  static const bool enableFamilyInvitations = true;

  /// Enable vehicle management
  static const bool enableVehicleManagement = true;

  /// Enable child assignments
  static const bool enableChildAssignments = true;

  // ========================================
  // ANALYTICS EVENTS
  // ========================================

  /// Analytics event names
  static const String familyCreatedEvent = 'family_created';
  static const String childAddedEvent = 'child_added';
  static const String vehicleAddedEvent = 'vehicle_added';
  static const String invitationSentEvent = 'invitation_sent';
  static const String offlineSyncEvent = 'offline_sync_completed';
}
