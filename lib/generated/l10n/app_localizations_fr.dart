// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get about => 'À propos';

  @override
  String get accept => 'Accepter';

  @override
  String get accepted => 'Acceptées';

  @override
  String get acceptedInvitations => 'Acceptées';

  @override
  String get actionCannotBeUndone => 'Cette action ne peut pas être annulée';

  @override
  String get actionCheckConnection => 'Vérifiez votre connexion internet';

  @override
  String get actionCheckEmail =>
      'Vérifiez votre e-mail pour un nouveau lien de connexion';

  @override
  String get actionFillRequired =>
      'Assurez-vous que tous les champs obligatoires sont remplis';

  @override
  String get actionRestartApp =>
      'Redémarrez l\'application si le problème persiste';

  @override
  String get actionReviewInfo =>
      'Vérifiez les informations que vous avez saisies';

  @override
  String get actionSignOutSignIn => 'Déconnectez-vous et reconnectez-vous';

  @override
  String get actionSwitchNetwork =>
      'Basculez vers les données mobiles si vous utilisez le WiFi';

  @override
  String get actionTryAgain => 'Réessayez';

  @override
  String get active => 'Actifs';

  @override
  String get activeDays => 'Jours Actifs';

  @override
  String get activeOverride => 'Ajustement Actif';

  @override
  String get add => 'Ajouter';

  @override
  String get addChild => 'Ajouter un enfant';

  @override
  String get addEvent => 'Ajouter événement';

  @override
  String get addFirstTimeSlot => 'Ajouter le Premier Créneau';

  @override
  String get addFirstVehicle =>
      'Ajoutez votre premier véhicule pour commencer\\nà organiser les trajets.';

  @override
  String get addOrRemoveVehicles => 'Ajouter ou supprimer des véhicules';

  @override
  String get addOverride => 'Ajouter Ajustement';

  @override
  String get addSlot => 'Ajouter Créneau';

  @override
  String get addTimeSlot => 'Ajouter un Créneau';

  @override
  String get addTimeSlotsDescription =>
      'Ajoutez des créneaux pour définir quand les véhicules peuvent être programmés';

  @override
  String get addVehicle => 'Ajouter un véhicule';

  @override
  String get addVehicleTitle => 'Ajouter un véhicule';

  @override
  String get addVehicleToSlot => 'Ajouter un véhicule';

  @override
  String get addVehiclesToFamilyToStartScheduling =>
      'Ajoutez des véhicules à votre famille pour commencer la planification';

  @override
  String get additionalInformation => 'Toute information supplémentaire...';

  @override
  String get additionalNavigationOptions =>
      'Des options de navigation supplémentaires apparaîtraient ici';

  @override
  String get additionalNotesOptional => 'Notes Supplémentaires (Optionnel)';

  @override
  String get adjustCapacity => 'Ajuster la capacité';

  @override
  String get adjustedCapacity => 'Capacité ajustée';

  @override
  String get adjustmentReason => 'Raison de l\'ajustement';

  @override
  String get adjustmentReasonHint => 'Ex: siège enfant, équipement...';

  @override
  String get adminCanManageMembers =>
      'L\'admin peut gérer les membres de la famille';

  @override
  String get administrator => 'Administrateur';

  @override
  String get afternoon => 'Après-midi';

  @override
  String age(int years) {
    return 'Âge: $years ans';
  }

  @override
  String get all => 'Tout';

  @override
  String get allDays => 'Tous les jours';

  @override
  String get allDaysSubtitle => 'Chaque jour';

  @override
  String get appName => 'EduLift';

  @override
  String get appVersion => 'Version 1.0.0';

  @override
  String get applyChanges => 'Appliquer les modifications';

  @override
  String assignChildrenButton(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Enfants',
      one: '$count Enfant',
    );
    return 'Assigner $_temp0';
  }

  @override
  String get assignChildrenToVehicles => 'Assigner des enfants aux véhicules';

  @override
  String get assignNewAdminAndSwitch => 'Assigner un nouvel admin et changer';

  @override
  String get assignNewAdminDesc =>
      'Promouvoir un autre membre en admin, puis rejoindre la nouvelle famille';

  @override
  String get assignVehicleToSlot => 'Assigner un véhicule à ce créneau';

  @override
  String get assignedChildren => 'Enfant assigné';

  @override
  String get availableOptions => 'Options disponibles';

  @override
  String get availableSeats => 'Places disponibles';

  @override
  String get backToHome => 'Retour à l\'accueil';

  @override
  String get backToLogin => 'Retour à la connexion';

  @override
  String get basicInformation => 'Informations de base';

  @override
  String get biometricAuthentication => 'Authentification biométrique';

  @override
  String get byLeavingFamilyYouWill =>
      'En quittant cette famille, vous allez :';

  @override
  String get cancel => 'Annuler';

  @override
  String get cancelInvitation => 'Annuler l\'Invitation';

  @override
  String get cancelInvitationMessage =>
      'Ils ne pourront plus rejoindre votre famille avec cette invitation.';

  @override
  String get cancelInvitationTitle => 'Annuler l\'Invitation';

  @override
  String get cancelled => 'Annulées';

  @override
  String get capacity => 'Capacité';

  @override
  String get capacityAdjustmentHint =>
      'Vous pouvez ajuster temporairement la capacité';

  @override
  String get capacityAndReasonRequired =>
      'La capacité et la raison sont requises';

  @override
  String capacityExceeded(int count) {
    return 'Capacité dépassée de $count';
  }

  @override
  String get capacityHelpText =>
      'Nombre de places pour enfants (ne pas inclure le conducteur)';

  @override
  String get capacityInformation => 'Informations de capacité';

  @override
  String get car => 'Voiture';

  @override
  String get checkBackLater =>
      'Revenez plus tard pour de nouvelles invitations';

  @override
  String get checkYourEmail => 'Vérifiez votre email';

  @override
  String get checkingUser => 'Vérification de l\'utilisateur...';

  @override
  String childAddedSuccessfully(String childName) {
    return 'Enfant \"$childName\" ajouté avec succès';
  }

  @override
  String get childDetailsTitle => 'Détails de l\'enfant';

  @override
  String childIdLabel(String childId) {
    return 'ID Enfant : $childId';
  }

  @override
  String get childInfoDescription =>
      'Ajoutez les informations de votre enfant pour l\'inclure dans la gestion familiale.';

  @override
  String get childNameHint => 'Prénom ou nom de famille';

  @override
  String get childAgeOptional => 'Âge (facultatif)';

  @override
  String get enterChildAge => 'Saisir l\'âge';

  @override
  String get childNameInvalidCharacters =>
      'Le nom ne peut contenir que des lettres, des espaces, des tirets et des apostrophes';

  @override
  String get childNotFound => 'Enfant non trouvé';

  @override
  String get years => 'ans';

  @override
  String childTransportCapacity(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ce véhicule peut transporter jusqu\'à $count enfants',
      one: 'Ce véhicule peut transporter jusqu\'à $count enfant',
      zero: 'Ce véhicule ne peut pas transporter d\'enfants',
    );
    return '$_temp0';
  }

  @override
  String get childUpdatedSuccessfully => 'Enfant mis à jour avec succès';

  @override
  String get children => 'Enfants';

  @override
  String childrenAssigned(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enfants assignés avec succès',
      one: '$count enfant assigné avec succès',
    );
    return '$_temp0';
  }

  @override
  String childrenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enfants',
      one: '$count enfant',
    );
    return '$_temp0';
  }

  @override
  String childrenSelected(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enfants sélectionnés',
      one: '$count enfant sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get chooseGroupForSchedule =>
      'Choisissez un groupe de transport pour voir son planning hebdomadaire';

  @override
  String get chooseResolution => 'Choisir une résolution';

  @override
  String get clearAll => 'Tout effacer';

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String get close => 'Fermer';

  @override
  String get codeCopiedToClipboard => 'Code copié dans le presse-papiers';

  @override
  String get codeExpired => 'Ce code a expiré';

  @override
  String codeForEmail(String email) {
    return 'Code pour $email :';
  }

  @override
  String get codeJoining => 'Adhésion par code';

  @override
  String get codes => 'Codes';

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String get commonDepartureTimes => 'Heures de départ courantes';

  @override
  String get compact => 'Compact';

  @override
  String get configuration => 'Configuration';

  @override
  String get configureSchedule => 'Configurer le planning';

  @override
  String get configureTimeSlots => 'Configurer les Créneaux';

  @override
  String configureWeekdaySchedule(String weekday) {
    return 'Configurer l\'horaire du $weekday';
  }

  @override
  String get confirm => 'Confirmer';

  @override
  String get confirmDelete => 'Êtes-vous sûr de vouloir supprimer';

  @override
  String get confirmLogout => 'Confirmer la déconnexion';

  @override
  String get confirmLogoutMessage =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String confirmVehicleDeletion(String vehicleName) {
    return 'Êtes-vous sûr de vouloir supprimer \"$vehicleName\" ?\\n\\nCette action est irréversible et supprimera également\\ntoutes les assignations de ce véhicule.';
  }

  @override
  String get conflictResolution => 'Résolution de conflit';

  @override
  String get conflictResolutionComingSoon =>
      'Fonctionnalité de résolution de conflit bientôt disponible';

  @override
  String get continueButton => 'Continuer';

  @override
  String get copyCode => 'Copier le Code';

  @override
  String get createAccount => 'Créer le compte';

  @override
  String get createFamily => 'Créer une famille';

  @override
  String get createGroup => 'Créer un Groupe';

  @override
  String get createNewGroup => 'Créer un Nouveau Groupe';

  @override
  String get createOverride => 'Créer Ajustement';

  @override
  String get createOverrideError =>
      'Échec de la création du remplacement. Veuillez réessayer.';

  @override
  String get createSeatOverride => 'Créer un Ajustement de Siège';

  @override
  String get createTransportGroupDescription =>
      'Créez un groupe de transport pour coordonner avec d\'autres familles';

  @override
  String get createTrip => 'Créer un trajet';

  @override
  String get createVehicle => 'Créer le véhicule';

  @override
  String get createYourFamily => 'Créer votre famille';

  @override
  String get created => 'Créé';

  @override
  String createdOn(String date) {
    return 'Créée le $date';
  }

  @override
  String get creating => 'Création...';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String criticalExpiringCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expirent dans 2 heures ou moins',
      one: '$count expire dans 2 heures ou moins',
    );
    return '$_temp0';
  }

  @override
  String currentCapacity(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'sièges',
      one: 'siège',
      zero: 'siège',
    );
    return 'Actuel : $count $_temp0';
  }

  @override
  String currentFamily(String familyName) {
    return 'Famille actuelle : $familyName';
  }

  @override
  String currentSeatsLabel(int count) {
    return 'Actuel: $count sièges';
  }

  @override
  String get currentSituation => 'Situation actuelle';

  @override
  String get customTime => 'Heure personnalisée';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count jours',
      one: 'Hier',
      zero: 'Aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String daysCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '$count jour',
    );
    return '$_temp0';
  }

  @override
  String get decline => 'Refuser';

  @override
  String defaultCapacity(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'sièges',
      one: 'siège',
      zero: 'siège',
    );
    return 'Par défaut : $count $_temp0';
  }

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteAssignment => 'Supprimer l\'affectation';

  @override
  String get deleteAssignmentTooltip => 'Supprimer l\'Affectation';

  @override
  String get deleteFamily => 'Supprimer la famille';

  @override
  String get deleteFamilyAndSwitch => 'Supprimer la famille et changer';

  @override
  String get deleteFamilyConfirmation => 'Supprimer la famille';

  @override
  String get deleteFamilyDesc =>
      'Supprimer définitivement votre famille actuelle et rejoindre la nouvelle';

  @override
  String get deleteFamilyLastMemberDesc =>
      'Supprimer définitivement cette famille car vous êtes le seul membre';

  @override
  String deleteFamilyWarning(String familyName) {
    return 'Ceci supprimera définitivement la famille \'$familyName\' et toutes ses données. Cette action est irréversible.';
  }

  @override
  String get deleteTimeSlotTooltip => 'Supprimer le créneau';

  @override
  String get deleteVehicle => 'Supprimer le véhicule';

  @override
  String get demoteFromAdmin => 'Rétrograder de l\'administration';

  @override
  String departureTimesSelected(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count heures de départ sélectionnées',
      one: '$count heure de départ sélectionnée',
    );
    return '$_temp0';
  }

  @override
  String get departureHours => 'Heures de Départ';

  @override
  String get description => 'Description';

  @override
  String get developerTools => 'Outils de développement';

  @override
  String get displayInvitationCode => 'Afficher le code d\'invitation';

  @override
  String get dragVehiclesToTimeSlots =>
      'Glissez les véhicules vers les créneaux horaires';

  @override
  String get edit => 'Modifier';

  @override
  String get editAssignment => 'Modifier l\'affectation';

  @override
  String get editAssignmentTooltip => 'Modifier l\'Affectation';

  @override
  String get editFunctionalityComingSoon =>
      'Fonctionnalité de modification bientôt disponible';

  @override
  String get editGroup => 'Modifier le groupe';

  @override
  String get editTimeSlot => 'Modifier le Créneau';

  @override
  String get editTimeSlotTooltip => 'Modifier le créneau';

  @override
  String get editVehicle => 'Modifier le véhicule';

  @override
  String get editVehicleTitle => 'Modifier le véhicule';

  @override
  String get editVehicleTooltip => 'Modifier le véhicule';

  @override
  String get email => 'Email';

  @override
  String get emailAddress => 'Adresse email';

  @override
  String get emailLabel => 'Email : ';

  @override
  String get emailRequired => 'L\'e-mail est requis';

  @override
  String get emergency => 'Urgence';

  @override
  String get emergencyContact => 'Contact d\'urgence';

  @override
  String get english => 'Anglais';

  @override
  String get ensureOtherAdmins =>
      'En tant qu\'administrateur, assurez-vous qu\'il y a d\'autres administrateurs dans la famille avant de partir.';

  @override
  String get enterEmailOfFamilyMember =>
      'Entrez l\'email d\'un membre de la famille';

  @override
  String get enterFamilyInvitationInstruction =>
      'Veuillez entrer votre code d\'invitation familiale pour continuer';

  @override
  String get enterFullName => 'Saisissez votre nom complet';

  @override
  String get enterGroupInvitationCodeTitle =>
      'Entrer le code d\'invitation de groupe';

  @override
  String get enterGroupInvitationInstruction =>
      'Veuillez entrer votre code d\'invitation de groupe pour continuer';

  @override
  String get enterGroupName => 'Saisir le nom du groupe';

  @override
  String get enterInvitationCode => 'Saisir le code d\'invitation';

  @override
  String get enterInvitationCodeTitle => 'Entrer le code d\'invitation';

  @override
  String get enterMemberEmail => 'Entrez l\'email du membre';

  @override
  String get enterMemberName => 'Entrez le nom du membre';

  @override
  String get enterNewCapacity => 'Entrez la nouvelle capacité';

  @override
  String get enterReceivedCode => 'Entrez le code reçu';

  @override
  String get enterTotalSeats => 'Saisir le nombre total de sièges';

  @override
  String get enterVehicleName => 'Entrez le nom du véhicule';

  @override
  String get errorAuth => 'Erreur d\'authentification';

  @override
  String get errorAuthAccessDenied => 'Accès refusé';

  @override
  String get errorAuthAccountDisabled =>
      'Ce compte a été désactivé. Veuillez contacter le support';

  @override
  String get errorAuthAccountLocked =>
      'Ce compte a été verrouillé en raison d\'une activité suspecte';

  @override
  String get errorAuthAccountNotFound =>
      'Aucun compte trouvé avec cette adresse e-mail';

  @override
  String get errorAuthApiError => 'Erreur API. Veuillez réessayer';

  @override
  String get errorAuthBiometricAuthFailed =>
      'L\'authentification biométrique a échoué. Veuillez réessayer';

  @override
  String get errorAuthBiometricLockout =>
      'L\'authentification biométrique est temporairement verrouillée. Veuillez réessayer plus tard';

  @override
  String get errorAuthBiometricNotAvailable =>
      'L\'authentification biométrique n\'est pas disponible sur cet appareil';

  @override
  String get errorAuthBiometricNotEnabled =>
      'L\'authentification biométrique n\'est pas activée';

  @override
  String get errorAuthBiometricNotEnrolled =>
      'Aucune donnée biométrique enregistrée. Veuillez configurer l\'authentification biométrique dans les paramètres de votre appareil';

  @override
  String get errorAuthConfigurationError =>
      'Erreur de configuration de l\'authentification. Veuillez contacter le support';

  @override
  String get errorAuthConnectionLost =>
      'Connexion perdue. Veuillez vérifier votre connexion Internet';

  @override
  String get errorAuthCrossUserTokenAttempt =>
      'Jeton invalide pour cet utilisateur';

  @override
  String get errorAuthDecryptionError =>
      'Échec du déchiffrement des données d\'authentification';

  @override
  String get errorAuthDeviceNotRecognized =>
      'Appareil non reconnu. Veuillez vérifier votre identité';

  @override
  String get errorAuthEmailAlreadyExists =>
      'Un compte avec cette adresse e-mail existe déjà';

  @override
  String get errorAuthEmailInvalid =>
      'Veuillez saisir une adresse e-mail valide';

  @override
  String get errorAuthEmailNotVerified =>
      'L\'adresse e-mail n\'a pas été vérifiée';

  @override
  String get errorAuthEmailRequired => 'L\'adresse e-mail est requise';

  @override
  String get errorAuthEmailTooLong =>
      'L\'adresse e-mail est trop longue (maximum 254 caractères)';

  @override
  String get errorAuthEncryptionError =>
      'Échec du chiffrement des données d\'authentification';

  @override
  String get errorAuthInsufficientPermissions =>
      'Vous n\'avez pas la permission d\'effectuer cette action';

  @override
  String get errorAuthInvalidCredentials => 'E-mail ou mot de passe invalide';

  @override
  String get errorAuthInvalidEmail =>
      'Le format de l\'adresse e-mail est invalide';

  @override
  String get errorAuthInvalidMagicLink =>
      'Ce lien magique est invalide ou a déjà été utilisé';

  @override
  String get errorAuthInvalidRequest => 'Requête invalide. Veuillez réessayer';

  @override
  String get errorAuthInvalidToken =>
      'Le jeton d\'authentification est invalide';

  @override
  String get errorAuthInvalidVerificationCode =>
      'Code de vérification invalide';

  @override
  String get errorAuthInviteCodeExpired => 'Ce code d\'invitation a expiré';

  @override
  String get errorAuthInviteCodeInvalid =>
      'Veuillez saisir un code d\'invitation valide (au moins 6 caractères)';

  @override
  String get errorAuthIpBlocked =>
      'Accès temporairement bloqué. Veuillez réessayer plus tard';

  @override
  String get errorAuthMagicLinkAlreadyUsed =>
      'Ce lien magique a déjà été utilisé';

  @override
  String get errorAuthMagicLinkExpired =>
      'Ce lien magique a expiré. Veuillez en demander un nouveau';

  @override
  String get errorAuthMagicLinkTokenInvalid =>
      'Le jeton du lien magique est invalide ou a expiré';

  @override
  String get errorAuthMagicLinkTokenRequired =>
      'Le jeton du lien magique est requis';

  @override
  String get errorAuthMessage =>
      'Votre session a expiré. Veuillez vous reconnecter.';

  @override
  String get errorAuthMultipleSessions =>
      'Plusieurs sessions détectées. Veuillez vous reconnecter';

  @override
  String get errorAuthNameInvalidChars =>
      'Le nom ne peut contenir que des lettres, espaces, traits d\'union et apostrophes';

  @override
  String get errorAuthNameMaxLength =>
      'Le nom ne peut pas dépasser 50 caractères';

  @override
  String get errorAuthNameMinLength =>
      'Le nom doit contenir au moins 2 caractères';

  @override
  String get errorAuthNameRequired => 'Le nom complet est requis';

  @override
  String get errorAuthNetworkError =>
      'Erreur réseau. Veuillez vérifier votre connexion Internet';

  @override
  String get errorAuthOperationCancelled => 'Opération annulée';

  @override
  String get errorAuthPkceVerificationFailed =>
      'La vérification de l\'authentification a échoué';

  @override
  String get errorAuthResourceNotFound =>
      'La ressource demandée n\'a pas été trouvée';

  @override
  String get errorAuthSecureStorageUnavailable =>
      'Le stockage sécurisé n\'est pas disponible sur cet appareil';

  @override
  String get errorAuthSecurityValidationFailed =>
      'La validation de sécurité a échoué. Veuillez réessayer';

  @override
  String get errorAuthServerError =>
      'Erreur serveur. Veuillez réessayer plus tard';

  @override
  String get errorAuthSessionExpired =>
      'Votre session a expiré. Veuillez vous reconnecter';

  @override
  String get errorAuthStorageError =>
      'Échec de la sauvegarde des données d\'authentification. Veuillez réessayer';

  @override
  String get errorAuthSuspiciousActivity =>
      'Activité suspecte détectée. Veuillez vérifier votre identité';

  @override
  String get errorAuthTimeout => 'Délai d\'attente dépassé. Veuillez réessayer';

  @override
  String get errorAuthTitle => 'Authentification Requise';

  @override
  String get errorAuthTokenExpired =>
      'Votre session a expiré. Veuillez vous reconnecter';

  @override
  String get errorAuthTokenMissing =>
      'Le jeton d\'authentification est manquant';

  @override
  String get errorAuthTokenRefreshFailed =>
      'Échec du rafraîchissement de l\'authentification. Veuillez vous reconnecter';

  @override
  String get errorAuthTokenStorageError =>
      'Échec du stockage du jeton d\'authentification';

  @override
  String get errorAuthTooManyAttempts =>
      'Trop de tentatives échouées. Veuillez réessayer plus tard';

  @override
  String get errorAuthUnknown =>
      'Une erreur inattendue s\'est produite. Veuillez réessayer';

  @override
  String get errorAuthUserAlreadyInFamily =>
      'Cet utilisateur est déjà membre d\'une autre famille';

  @override
  String get errorAuthUserDataStorageError =>
      'Échec du stockage des données utilisateur';

  @override
  String get errorAuthorizationMessage =>
      'Vous n\'avez pas la permission d\'effectuer cette action.';

  @override
  String get errorAuthorizationTitle => 'Accès Refusé';

  @override
  String get errorBiometricMessage =>
      'L\'authentification biométrique a échoué. Veuillez réessayer ou utiliser votre code d\'accès.';

  @override
  String get errorBiometricTitle => 'Erreur Biométrique';

  @override
  String get errorChangingLanguage => 'Erreur lors du changement de langue';

  @override
  String get errorChildAgeNotNumber =>
      'L\'âge de l\'enfant doit être un nombre';

  @override
  String get errorChildAgeRequired => 'L\'âge de l\'enfant est requis';

  @override
  String errorChildAgeTooOld(int maxAge) {
    return 'L\'âge de l\'enfant ne peut pas dépasser $maxAge ans';
  }

  @override
  String errorChildAgeTooYoung(int minAge) {
    return 'L\'âge de l\'enfant doit être d\'au moins $minAge an(s)';
  }

  @override
  String get errorChildEmergencyContactInvalid =>
      'Le format du contact d\'urgence est invalide (téléphone ou e-mail requis)';

  @override
  String get errorChildEmergencyContactRequired =>
      'Le contact d\'urgence est requis';

  @override
  String get errorChildGradeInvalid =>
      'Le format du niveau scolaire est invalide';

  @override
  String errorChildMedicalInfoTooLong(int maxLength) {
    return 'Les informations médicales sont trop longues (maximum $maxLength caractères)';
  }

  @override
  String get errorChildNameInvalidChars =>
      'Le nom de l\'enfant contient des caractères non valides';

  @override
  String get errorChildNameMaxLength =>
      'Le nom de l\'enfant ne peut pas dépasser 30 caractères';

  @override
  String get errorChildNameMinLength =>
      'Le nom de l\'enfant doit contenir au moins 2 caractères';

  @override
  String get errorChildNameRequired => 'Le nom de l\'enfant est requis';

  @override
  String errorChildSchoolNameTooLong(int maxLength) {
    return 'Le nom de l\'école est trop long (maximum $maxLength caractères)';
  }

  @override
  String errorChildSpecialNeedsTooLong(int maxLength) {
    return 'Les informations sur les besoins spéciaux sont trop longues (maximum $maxLength caractères)';
  }

  @override
  String get errorConflictMessage =>
      'Vos données entrent en conflit avec des modifications récentes. Veuillez actualiser et réessayer.';

  @override
  String get errorConflictTitle => 'Conflit de Données';

  @override
  String get errorEmailAlreadyExists =>
      'Cette adresse e-mail est déjà enregistrée';

  @override
  String get errorEmailInvalid => 'Veuillez saisir une adresse e-mail valide';

  @override
  String get errorEmailRequired => 'L\'adresse e-mail est requise';

  @override
  String errorFailedToExportLogs(String error) {
    return 'Échec d\'export des logs : $error';
  }

  @override
  String errorFailedToLeaveFamily(String error) {
    return 'Échec de quitter la famille : $error';
  }

  @override
  String errorFailedToRemoveMember(String error) {
    return 'Échec du retrait du membre : $error';
  }

  @override
  String errorFailedToUpdateRole(String error) {
    return 'Échec de mise à jour du rôle : $error';
  }

  @override
  String get errorFamilyNameInvalidChars =>
      'Le nom de famille contient des caractères non valides';

  @override
  String get errorFamilyNameMaxLength =>
      'Le nom de famille ne peut pas dépasser 50 caractères';

  @override
  String get errorFamilyNameMinLength =>
      'Le nom de famille doit contenir au moins 2 caractères';

  @override
  String get errorFamilyNameRequired => 'Le nom de famille est requis';

  @override
  String get errorInsufficientPermissions =>
      'Vous n\'avez pas la permission d\'effectuer cette action';

  @override
  String get errorInvalidData =>
      'Données invalides fournies. Veuillez vérifier vos informations et réessayer.';

  @override
  String get errorInvitationCancelled => 'Cette invitation a été annulée';

  @override
  String get errorInvitationCodeInvalid =>
      'Veuillez saisir un code d\'invitation valide';

  @override
  String get errorInvitationCodeRequired => 'Le code d\'invitation est requis';

  @override
  String get errorInvitationEmailMismatch =>
      'Cette invitation a été envoyée à une adresse email différente. Veuillez utiliser l\'adresse email à laquelle l\'invitation a été envoyée.';

  @override
  String get errorInvitationExpired => 'Cette invitation a expiré';

  @override
  String get errorInvitationNotFound => 'Invitation introuvable ou révoquée';

  @override
  String get errorLoadingData => 'Erreur lors du chargement des données';

  @override
  String get errorLoadingLogLevel =>
      'Erreur lors du chargement du niveau de log';

  @override
  String get errorMemberAlreadyExists =>
      'Ce membre fait déjà partie de la famille';

  @override
  String get errorMemberNotFound => 'Membre non trouvé';

  @override
  String errorMessageTooLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Le message ne peut pas dépasser $count caractères',
      one: 'Le message ne peut pas dépasser 1 caractère',
    );
    return '$_temp0';
  }

  @override
  String get errorNetwork => 'Erreur réseau survenue';

  @override
  String get errorNetworkGeneral =>
      'Erreur de connexion. Vérifiez votre connexion internet.';

  @override
  String get errorNetworkMessage =>
      'Veuillez vérifier votre connexion internet et réessayer.';

  @override
  String get errorNetworkTitle => 'Problème de Connexion';

  @override
  String get errorOfflineMessage =>
      'Cette fonctionnalité n\'est pas disponible en mode hors ligne. Veuillez vous connecter à internet.';

  @override
  String get errorOfflineTitle => 'Mode Hors Ligne';

  @override
  String get errorPageTitle => 'Erreur';

  @override
  String get errorPendingInvitationExists =>
      'Une invitation à cette adresse email est déjà en attente';

  @override
  String get errorPermissionMessage =>
      'Cette application a besoin d\'une permission pour continuer. Veuillez accorder la permission requise.';

  @override
  String get errorPermissionTitle => 'Permission Requise';

  @override
  String get errorProcessingRequest =>
      'Erreur lors du traitement de la demande';

  @override
  String errorRawMessage(Object message) {
    return '$message';
  }

  @override
  String get errorRoleInvalid => 'Veuillez sélectionner un rôle valide';

  @override
  String get errorRoleRequired => 'La sélection d\'un rôle est requise';

  @override
  String get errorServerGeneral =>
      'Erreur serveur. Veuillez réessayer plus tard.';

  @override
  String get errorServerMessage =>
      'Le serveur rencontre actuellement des difficultés. Veuillez réessayer plus tard.';

  @override
  String get errorServerTitle => 'Erreur Serveur';

  @override
  String get errorStorageMessage =>
      'Un problème est survenu lors de la sauvegarde de vos données. Veuillez réessayer.';

  @override
  String get errorStorageTitle => 'Problème de Stockage';

  @override
  String get errorSyncMessage =>
      'Impossible de synchroniser vos données. Vos modifications seront sauvegardées lors de la restauration de la connexion.';

  @override
  String get errorSyncTitle => 'Échec de Synchronisation';

  @override
  String get errorSystemMessage =>
      'Une erreur système inattendue s\'est produite. Veuillez réessayer.';

  @override
  String get errorSystemTitle => 'Erreur Système';

  @override
  String get errorTitle => 'Erreur';

  @override
  String get errorUnexpected => 'Une erreur est survenue.';

  @override
  String get errorUnexpectedMessage =>
      'Une erreur s\'est produite. Veuillez réessayer ou contacter le support si le problème persiste.';

  @override
  String get errorUnexpectedTitle => 'Erreur Inattendue';

  @override
  String get errorUnknown => 'Une erreur inconnue s\'est produite';

  @override
  String get errorValidation => 'Erreur de validation';

  @override
  String get errorValidationMessage =>
      'Veuillez vérifier les informations saisies et réessayer.';

  @override
  String get errorValidationTitle => 'Informations Invalides';

  @override
  String get errorVehicleCapacityNotNumber =>
      'La capacité du véhicule doit être un nombre';

  @override
  String get errorVehicleCapacityRequired =>
      'La capacité du véhicule est requise';

  @override
  String get errorVehicleCapacityTooHigh =>
      'La capacité du véhicule ne peut pas dépasser 10';

  @override
  String get errorVehicleCapacityTooLow =>
      'La capacité du véhicule doit être d\'au moins 1';

  @override
  String get errorVehicleDescriptionTooLong =>
      'La description du véhicule est trop longue';

  @override
  String get errorVehicleNameInvalidChars =>
      'Le nom du véhicule contient des caractères non valides';

  @override
  String get errorVehicleNameMaxLength =>
      'Le nom du véhicule ne peut pas dépasser 50 caractères';

  @override
  String get errorVehicleNameMinLength =>
      'Le nom du véhicule doit contenir au moins 2 caractères';

  @override
  String get errorVehicleNameRequired => 'Le nom du véhicule est requis';

  @override
  String estimatedLogSize(String sizeMB) {
    return 'Taille estimée des logs: ${sizeMB}MB';
  }

  @override
  String get event => 'Événement';

  @override
  String get expired => 'Expiré';

  @override
  String get expiredLabel => 'Expirée';

  @override
  String expires(String date) {
    return 'Expire : $date';
  }

  @override
  String get expiresAtOptional => 'Expire le (Optionnel)';

  @override
  String expiresIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Expire dans $days jours',
      one: 'Expire demain',
      zero: 'Expire aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String expiresInDays(int days) {
    return 'Expire dans $days jours';
  }

  @override
  String expiresInDaysHours(int days, int hours) {
    return 'Expire dans $days jours et $hours heures';
  }

  @override
  String get dayLabel => 'Jour';

  @override
  String expiresInHours(int hours) {
    return 'Expire dans $hours heures';
  }

  @override
  String expiresInHoursMinutes(int hours, int minutes) {
    return 'Expire dans $hours heures et $minutes minutes';
  }

  @override
  String expiresInMinutes(int minutes) {
    return 'Expire dans $minutes minutes';
  }

  @override
  String expiresOn(String date) {
    return 'Expire : $date';
  }

  @override
  String get expiringIn3Days => 'Expirent dans 3 jours';

  @override
  String get expiringSoon => 'Expire bientôt';

  @override
  String get expiringThisWeek => 'Expirent cette semaine';

  @override
  String get expiringVeryShortly => 'Expirent très bientôt';

  @override
  String get exportIncludesComprehensive =>
      'L\'export inclut des informations de diagnostic complètes pour le support';

  @override
  String get exportIncludesInfo =>
      'L\'export inclut la version de l\'app, les infos de l\'appareil, les logs récents et les données de diagnostic';

  @override
  String get exportLogsForSupport => 'Exporter les logs pour le support';

  @override
  String get exporting => 'Exportation en cours...';

  @override
  String get extend => 'Prolonger';

  @override
  String get extended => 'Étendu';

  @override
  String get failed => 'Échouées';

  @override
  String failedToAssignChildren(String error) {
    return 'Échec de l\'assignation des enfants : $error';
  }

  @override
  String failedToCancel(String error) {
    return 'Échec de l\'annulation : $error';
  }

  @override
  String failedToCopyCode(String error) {
    return 'Échec de la copie du code : $error';
  }

  @override
  String failedToExportLogs(String error) {
    return 'Échec de l\'exportation des logs: $error';
  }

  @override
  String failedToLeaveFamily(String error) {
    return 'Échec de quitter la famille : $error';
  }

  @override
  String get failedToLoadGroups => 'Échec du chargement des groupes';

  @override
  String get failedToLoadSchedule => 'Impossible de charger le planning';

  @override
  String get failedToChangeWeek => 'Impossible de changer de semaine';

  @override
  String failedToLoadVehicles(String error) {
    return 'Impossible de charger les véhicules : $error';
  }

  @override
  String failedToRemoveMember(String error) {
    return 'Échec de suppression du membre : $error';
  }

  @override
  String get failedToSendInvitation => 'Échec de l\'envoi de l\'invitation';

  @override
  String failedToUpdateRole(String error) {
    return 'Échec de mise à jour du rôle : $error';
  }

  @override
  String get family => 'Famille';

  @override
  String get familyConflictTitle => 'Conflit familial';

  @override
  String familyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count familles',
      one: '$count famille',
    );
    return '$_temp0';
  }

  @override
  String get familyInvitation => 'Invitation famille';

  @override
  String get familyInvitations => 'Invitations Familiales';

  @override
  String get familyMember => 'Membre de famille';

  @override
  String get familyMemberActions => 'Actions des Membres de Famille';

  @override
  String get familyMemberDescription =>
      'Membre de famille ordinaire avec accès de base';

  @override
  String get familyMembers => 'Membres de la Famille';

  @override
  String familyMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Membres de la Famille ($count)',
      one: 'Membres de la Famille ($count)',
      zero: 'Membres de la Famille',
    );
    return '$_temp0';
  }

  @override
  String get currentUserLabel => ', utilisateur actuel';

  @override
  String get youLabel => '(Vous)';

  @override
  String weeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count semaines',
      one: 'Il y a $count semaine',
    );
    return '$_temp0';
  }

  @override
  String monthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count mois',
      one: 'Il y a $count mois',
    );
    return '$_temp0';
  }

  @override
  String yearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count ans',
      one: 'Il y a $count an',
    );
    return '$_temp0';
  }

  @override
  String get removeAdminRole => 'Retirer le rôle d\'administrateur';

  @override
  String get changeToRegularMember => 'Changer en membre régulier';

  @override
  String get grantAdminPermissions =>
      'Accorder les permissions d\'administrateur';

  @override
  String get adminPermissionsInclude =>
      'Les permissions d\'administrateur incluent :';

  @override
  String get adminPermissionManageMembers =>
      '• Gérer les membres de la famille';

  @override
  String get adminPermissionSendInvitations => '• Envoyer des invitations';

  @override
  String get adminPermissionManageVehiclesChildren =>
      '• Gérer les véhicules et les enfants';

  @override
  String get adminPermissionConfigureSettings =>
      '• Configurer les paramètres de la famille';

  @override
  String get familyNameRequired => 'Le nom de famille est requis';

  @override
  String get familyNameTooLong =>
      'Le nom de famille doit contenir moins de 50 caractères';

  @override
  String get familyNameTooShort =>
      'Le nom de famille doit contenir au moins 2 caractères';

  @override
  String get fieldRequired => 'Ce champ est obligatoire';

  @override
  String get filter => 'Filtrer';

  @override
  String get filterAll => 'Tout';

  @override
  String get filterExpired => 'Expiré';

  @override
  String get filterExpiringSoon => 'Expire bientôt';

  @override
  String get filterOptions => 'Options de filtre';

  @override
  String get filterPending => 'En attente';

  @override
  String get firstName => 'Prénom *';

  @override
  String get firstNameRequired => 'Le prénom est obligatoire';

  @override
  String get french => 'Français';

  @override
  String get fri => 'Ven';

  @override
  String get friday => 'Vendredi';

  @override
  String get fridayShort => 'Ven';

  @override
  String get fullName => 'Nom complet';

  @override
  String get generate => 'Générer';

  @override
  String get generateCodes => 'Générer des codes';

  @override
  String get generateCodesTooltip => 'Générer des codes';

  @override
  String get generateNewCode => 'Générer un nouveau code';

  @override
  String get giveUpAdminPrivileges =>
      '• Abandonner les privilèges d\'administrateur';

  @override
  String get goBack => 'Retour';

  @override
  String get goBackButton => 'Retour';

  @override
  String get goToGroups => 'Aller aux groupes';

  @override
  String get gotItButton => 'Compris';

  @override
  String get grantAdminRole => 'Accorder le Rôle d\'Admin';

  @override
  String get groupCreated => 'Groupe créé avec succès';

  @override
  String get groupCreatedSuccessfully => 'Groupe créé avec succès \\!';

  @override
  String get groupCreatorInfo =>
      'En tant que créateur, vous serez l\'administrateur du groupe et pourrez inviter d\'autres familles.';

  @override
  String get groupDescription => 'Description du Groupe';

  @override
  String get groupDescriptionMaxLength =>
      'La description ne peut pas dépasser 500 caractères';

  @override
  String get groupDetails => 'Détails du Groupe';

  @override
  String get groupInvitation => 'Invitation groupe';

  @override
  String get groupInvitations => 'Invitations de groupe';

  @override
  String get groupJoined => 'Groupe rejoint avec succès';

  @override
  String get groupName => 'Nom du Groupe';

  @override
  String get groupNameMaxLength =>
      'Le nom du groupe doit contenir moins de 50 caractères';

  @override
  String get groupNameMinLength =>
      'Le nom du groupe doit contenir au moins 3 caractères';

  @override
  String get groupNameRequired => 'Le nom du groupe est requis';

  @override
  String get groupNotFound => 'Groupe non trouvé';

  @override
  String get groupNotFoundMessage =>
      'Le groupe sélectionné n\'a pas pu être trouvé ou vous n\'y avez plus accès.';

  @override
  String groups(int count) {
    return 'Groupes : $count';
  }

  @override
  String get groupsLabel => 'Groupes';

  @override
  String get help => 'Aide';

  @override
  String helperTextDefaultSeats(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'sièges',
      one: 'siège',
      zero: 'siège',
    );
    return 'Par défaut : $count $_temp0';
  }

  @override
  String get hideVehicles => 'Masquer les véhicules';

  @override
  String highExpiringCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expirent dans les 24 heures',
      one: '$count expire dans les 24 heures',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count heures',
      one: 'Il y a $count heure',
    );
    return '$_temp0';
  }

  @override
  String get implementationComingSoon => 'Implémentation à venir';

  @override
  String get incorrectConfirmation =>
      'Le texte de confirmation ne correspond pas';

  @override
  String get instructionStep1 => '1. Ouvrez votre application email';

  @override
  String get instructionStep2 => '2. Recherchez l\'email d\'EduLift';

  @override
  String get instructionStep3 => '3. Cliquez sur le lien de connexion';

  @override
  String get instructionStep4 => '4. Vous serez automatiquement connecté';

  @override
  String get instructionsTitle => 'Instructions :';

  @override
  String get invalid => 'Invalides';

  @override
  String get invalidCapacityRange =>
      'Veuillez entrer une capacité valide entre 1 et 50';

  @override
  String get invalidEmail => 'Adresse email invalide';

  @override
  String get invalidEmailFormat => 'Veuillez entrer une adresse email valide';

  @override
  String get invalidDeepLinkTitle => 'Lien invalide';

  @override
  String get invalidDeepLinkMessage =>
      'Le lien que vous avez suivi n\'est pas valide ou a expiré. Veuillez vérifier le lien et réessayer.';

  @override
  String get invalidInvitationTitle => 'Invitation invalide';

  @override
  String get invalidTimeFormat =>
      'Format d\'heure invalide. Utilisez HH:MM (24h)';

  @override
  String get invitationActions => 'Actions d\'Invitation';

  @override
  String invitationActionsTooltip(String email) {
    return 'Actions d\'invitation pour $email';
  }

  @override
  String get invitationAnalytics => 'Analytiques des Invitations';

  @override
  String invitationCancelledFor(String email) {
    return 'Invitation annulée pour $email';
  }

  @override
  String get invitationCancelledSuccessfully =>
      'Invitation annulée avec succès';

  @override
  String get invitationCode => 'Code d\'Invitation';

  @override
  String get invitationCodeCopied =>
      'Code d\'invitation copié dans le presse-papiers';

  @override
  String get invitationCodeNotAvailable => 'Code d\'invitation non disponible';

  @override
  String get invitationCodeRequired => 'Le code d\'invitation est requis';

  @override
  String get invitationExpired => 'Cette invitation a expiré';

  @override
  String get invitationExpiredDesc =>
      'Cette invitation a expiré et n\'est plus valide';

  @override
  String invitationSentTo(String email) {
    return 'Invitation envoyée à $email';
  }

  @override
  String get invitationStatistics => 'Statistiques des invitations';

  @override
  String get invitationType => 'Type d\'invitation';

  @override
  String get invitations => 'Invitations';

  @override
  String invitationsCount(int count) {
    return 'Invitations ($count)';
  }

  @override
  String invitationsExpiring(int count) {
    return '$count invitations expirent bientôt';
  }

  @override
  String get invite => 'Inviter';

  @override
  String get inviteFamilyMember => 'Inviter un membre de famille';

  @override
  String get inviteFamilyMembers => 'Inviter dans la famille';

  @override
  String get inviteMembersToStart => 'Invitez des membres pour commencer';

  @override
  String get inviteNewMember => 'Inviter un Nouveau Membre';

  @override
  String get sendInvitationDescription =>
      'Envoyez une invitation pour rejoindre votre famille. Ils recevront un email avec des instructions pour accepter l\'invitation.';

  @override
  String get inviteToGroup => 'Inviter dans un groupe';

  @override
  String invitedToFamily(String familyName) {
    return 'Invité à rejoindre : $familyName';
  }

  @override
  String get join => 'Rejoindre';

  @override
  String joinFamily(String familyName) {
    return 'Rejoindre $familyName';
  }

  @override
  String joinFamilyName(String familyName) {
    return 'Rejoindre $familyName';
  }

  @override
  String get joinGroup => 'Rejoindre un Groupe';

  @override
  String joinGroupName(String groupName) {
    return 'Rejoindre $groupName';
  }

  @override
  String get joinWithCode => 'Rejoindre avec un code';

  @override
  String get joined => 'Rejoint';

  @override
  String get joiningInProgress => 'Adhésion en cours...';

  @override
  String get justNow => 'à l\'instant';

  @override
  String get keepInvitation => 'Garder l\'invitation';

  @override
  String get labelFieldLabel => 'Libellé';

  @override
  String get labelHint => 'Dépôt école';

  @override
  String get labelRequired => 'Le libellé ne peut pas être vide';

  @override
  String get labelTooLong => 'Le libellé doit faire 50 caractères maximum';

  @override
  String get language => 'Langue';

  @override
  String get languageAndToolsMore => 'Langue, Outils de développement & Plus';

  @override
  String get languageChanged => 'Langue changée avec succès';

  @override
  String get lastAdminProtection => 'Protection dernier admin';

  @override
  String get lastAdminWarning =>
      'Vous êtes le dernier admin de cette famille. Vous devez assigner un nouvel admin ou transférer la propriété avant de partir.';

  @override
  String lastExported(String timeAgo) {
    return 'Dernière exportation: $timeAgo';
  }

  @override
  String get lastName => 'Nom de famille *';

  @override
  String get lastUpdated => 'Dernière mise à jour';

  @override
  String get leave => 'Partir';

  @override
  String get leaveButton => 'Quitter';

  @override
  String typeNameToConfirm(String name) {
    return 'Pour confirmer, tapez le nom exactement : $name';
  }

  @override
  String pleaseTypeNameExactly(String name) {
    return 'Veuillez taper \"$name\" exactement';
  }

  @override
  String get leaveFamily => 'Quitter la famille';

  @override
  String leaveFamilyAndJoinFamilyName(String familyName) {
    return 'Quitter la famille actuelle et rejoindre $familyName';
  }

  @override
  String get leaveFamilyConfirmation =>
      'Êtes-vous sûr de vouloir quitter cette famille ?';

  @override
  String get leaveFamilyTitle => 'Quitter la Famille';

  @override
  String get warning => 'Avertissement';

  @override
  String get leaveFamilyWarningMessage =>
      'Vous perdrez l\'accès à toutes les données familiales, horaires et véhicules. Cette action est irréversible.';

  @override
  String get removeMemberWarningMessage =>
      'Ce membre perdra l\'accès à toutes les données familiales. Cette action est irréversible.';

  @override
  String memberActionsFor(String memberName) {
    return 'Actions pour $memberName';
  }

  @override
  String get leaveGroup => 'Quitter le Groupe';

  @override
  String get leaveGroupTitle => 'Quitter le Groupe';

  @override
  String get byLeavingGroupYouWill => 'En quittant ce groupe, vous allez :';

  @override
  String get loseAccessGroupSchedules =>
      '• Perdre l\'accès à tous les horaires du groupe';

  @override
  String get noLongerSeeGroupMembers =>
      '• Ne plus voir les familles et membres du groupe';

  @override
  String get giveUpGroupAdminPrivileges =>
      '• Abandonner les privilèges d\'administrateur du groupe';

  @override
  String get ownerFamilyCannotLeave =>
      'Note : La famille propriétaire ne peut pas quitter le groupe. Seuls les membres peuvent partir.';

  @override
  String failedToLeaveGroup(String error) {
    return 'Échec de la sortie du groupe : $error';
  }

  @override
  String get linkExpiryInfo =>
      'Le lien expire dans 15 minutes pour votre sécurité.';

  @override
  String get loading => 'Chargement...';

  @override
  String get loadingError => 'Erreur de chargement';

  @override
  String get loadingErrorText => 'Erreur de chargement';

  @override
  String get loadingInvitations => 'Chargement des invitations...';

  @override
  String get loadingSentInvitations => 'Chargement des invitations envoyées...';

  @override
  String get loadingStatistics => 'Chargement des statistiques...';

  @override
  String get loadingVehicles => 'Chargement des véhicules...';

  @override
  String get logExport => 'Export des logs';

  @override
  String get logLevel => 'Niveau de log';

  @override
  String logLevelChangeFailed(String error) {
    return 'Échec du changement de niveau de log : $error';
  }

  @override
  String logLevelChanged(String level) {
    return 'Niveau de log changé en : $level';
  }

  @override
  String get logLevelDescription =>
      'Contrôle la verbosité de la journalisation pour le débogage';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get logsExportedSuccess =>
      '📤 Logs exportés et envoyés à Firebase avec succès !';

  @override
  String get logExportUnsupportedPlatform =>
      'L\'export des logs n\'est supporté que sur mobile (Android/iOS)';

  @override
  String get logExportNoDirectory => 'Aucun répertoire d\'export trouvé';

  @override
  String get logExportNoFiles => 'Aucun fichier de log trouvé après l\'export';

  @override
  String get loseAccessSchedules =>
      '• Perdre l\'accès à tous les horaires familiaux';

  @override
  String get loseAccessVehicles =>
      '• Perdre l\'accès aux véhicules familiaux et aux affectations';

  @override
  String get magicLinkExpired =>
      'Le lien magique a expiré. Veuillez en demander un nouveau.';

  @override
  String get magicLinkResent => 'Lien de connexion renvoyé';

  @override
  String get magicLinkSent => 'Lien magique envoyé à votre e-mail';

  @override
  String get magicLinkSentDescription =>
      'Un lien de connexion sécurisé a été envoyé à :';

  @override
  String get magicLinkSentTitle => 'Lien de connexion envoyé';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get makeAdmin => 'Nommer administrateur';

  @override
  String makeAdminConfirmation(String name) {
    return 'Accorder les privilèges d\'admin à $name ?';
  }

  @override
  String get manage => 'Gérer';

  @override
  String get manageFamily => 'Gérer la Famille';

  @override
  String maxSeatsLabel(int max) {
    return 'Maximum: $max sièges';
  }

  @override
  String get maxVehicles => 'Véhicules Max';

  @override
  String maximumTimeSlotsAllowed(int count) {
    return 'Maximum $count créneaux horaires autorisés';
  }

  @override
  String get member => 'Membre';

  @override
  String get memberActions => 'Actions Membre';

  @override
  String get groupActions => 'Actions du Groupe';

  @override
  String get createNewGroupDescription =>
      'Créer un nouveau groupe de transport pour organiser les plannings familiaux';

  @override
  String get joinExistingGroupDescription =>
      'Rejoindre un groupe existant en utilisant un code ou un lien d\'invitation';

  @override
  String memberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres',
      one: '1 membre',
    );
    return '$_temp0';
  }

  @override
  String get memberDetails => 'Détails du Membre';

  @override
  String memberRemovedFromFamily(String memberName) {
    return '$memberName retiré(e) de la famille';
  }

  @override
  String get memberRole => 'MEMBRE';

  @override
  String get members => 'membres';

  @override
  String get membersTabLabel => 'Membres';

  @override
  String minSeatsLabel(int min) {
    return 'Minimum: $min sièges';
  }

  @override
  String minimumIntervalRequired(int minutes) {
    return 'Minimum $minutes minutes requis entre les créneaux';
  }

  @override
  String minutesAgo(int count) {
    return 'il y a ${count}min';
  }

  @override
  String modifiedFrom(int original) {
    return 'Modifié de $original';
  }

  @override
  String get modifyTooltip => 'Modifier';

  @override
  String get mon => 'Lun';

  @override
  String get monday => 'Lundi';

  @override
  String get mondayShort => 'Lun';

  @override
  String get mondayToFridayShort => 'Lun - Ven';

  @override
  String get monthView => 'Mois';

  @override
  String get monthViewImplementation => 'Implémentation vue mois';

  @override
  String get moreActionsFor => 'Plus d\'actions pour';

  @override
  String get morning => 'Matin';

  @override
  String get monthLabel => 'Mois';

  @override
  String get myFamily => 'Ma famille';

  @override
  String get name => 'Nom';

  @override
  String get nameMaxLength => 'Le nom ne peut pas dépasser 50 caractères';

  @override
  String get nameMinLength => 'Le nom doit contenir au moins 2 caractères';

  @override
  String get nameOptional => 'Nom (optionnel)';

  @override
  String get navigationDashboard => 'Tableau de bord';

  @override
  String get navigationDashboardShort => 'Accueil';

  @override
  String get navigationFamily => 'Famille';

  @override
  String get navigationGroups => 'Groupes';

  @override
  String get navigationProfile => 'Profil';

  @override
  String get navigationSchedule => 'Planning';

  @override
  String get needGroupForSchedules =>
      'Vous devez rejoindre ou créer un groupe de transport pour voir les plannings.';

  @override
  String get newAdminEmail => 'Email du nouvel admin';

  @override
  String get newChild => 'Nouvel enfant';

  @override
  String get newFamilyInvitation => 'Nouvelle invitation familiale';

  @override
  String get newInvitationUpdate => 'Nouvelle mise à jour d\'invitation reçue';

  @override
  String get nextWeek => 'Semaine suivante';

  @override
  String get currentWeek => 'Semaine actuelle';

  @override
  String get lastWeek => 'Semaine dernière';

  @override
  String inWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dans $count semaines',
      one: 'Dans $count semaine',
    );
    return '$_temp0';
  }

  @override
  String get noChildren => 'Aucun enfant';

  @override
  String get noChildrenAssigned => 'Aucun enfant assigné';

  @override
  String vehiclesPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count véhicules',
      one: '$count véhicule',
    );
    return '$_temp0';
  }

  @override
  String get unknownVehicle => 'Véhicule inconnu';

  @override
  String moreItems(int count) {
    return '+$count de plus';
  }

  @override
  String get noDaysConfigured => 'Aucun jour configuré';

  @override
  String get noDepartureTimesSelected => 'Aucune heure de départ sélectionnée';

  @override
  String get noExpiryDate => 'Aucune expiration (usage unique)';

  @override
  String get noExpiryIssues => 'Aucun problème d\'expiration';

  @override
  String get noFamily => 'Aucune famille';

  @override
  String get noFamilyFound => 'Aucune famille trouvée';

  @override
  String get noFamilyIdAvailable => 'Aucun ID de famille disponible';

  @override
  String noFilteredInvitations(String filterType) {
    return 'Aucune invitation $filterType';
  }

  @override
  String get noInvitationCodes => 'Aucun code d\'invitation';

  @override
  String get noInvitationCodesMessage =>
      'Générez des codes d\'invitation\npour faciliter l\'adhésion.';

  @override
  String get noInvitations => 'Aucune invitation';

  @override
  String get noInvitationsMessage =>
      'Vous n\'avez aucune invitation en attente.\nLes nouvelles invitations apparaîtront ici.';

  @override
  String get noInvitationsYet => 'Aucune invitation pour le moment';

  @override
  String get noLongerSeeFamilyMembers =>
      '• Ne plus voir les membres de la famille et les enfants';

  @override
  String get noPendingInvitations => 'Aucune invitation en attente';

  @override
  String get noRecentActivity => 'Aucune activité récente';

  @override
  String get noRecentActivityMessage => 'Votre activité apparaîtra ici';

  @override
  String get noSentInvitations => 'Aucune invitation envoyée';

  @override
  String get noSentInvitationsMessage =>
      'Invitez des membres dans votre famille\nou vos groupes pour commencer.';

  @override
  String get noScheduleConfigured => 'Aucun horaire configuré pour ce jour';

  @override
  String get noTimeSlotsConfigured => 'Aucun créneau horaire configuré';

  @override
  String get noTransportGroups => 'Aucun Groupe de Transport';

  @override
  String get noTransportGroupsDescription =>
      'Créez ou rejoignez un groupe de transport pour coordonner les trajets scolaires avec d\'autres familles.';

  @override
  String get noVehicles => 'Aucun véhicule';

  @override
  String get none => 'Aucun';

  @override
  String get notAvailable => 'Non disponible';

  @override
  String get notes => 'Notes';

  @override
  String get notifications => 'Notifications';

  @override
  String get optionalDescription => 'Description optionnelle';

  @override
  String get overrideCapacity => 'Capacité personnalisée';

  @override
  String overrideCapacityDisplay(int count) {
    return 'Ajustement : $count';
  }

  @override
  String get overrideHistory => 'Historique des Ajustements';

  @override
  String get overrideType => 'Type d\'Ajustement';

  @override
  String get pasteFromClipboard => 'Coller depuis le presse-papiers';

  @override
  String get pending => 'En attente';

  @override
  String get pendingInvitations => 'Invitations en attente';

  @override
  String get pendingInvitationsStats => 'En attente';

  @override
  String get personalInformation => 'Informations personnelles';

  @override
  String get pleaseEnterNewAdminEmail =>
      'Veuillez entrer un email pour le nouvel admin';

  @override
  String get pleaseEnterValidNumber => 'Veuillez entrer un nombre valide';

  @override
  String get previousWeek => 'Semaine précédente';

  @override
  String get privacy => 'Confidentialité';

  @override
  String get processing => 'Traitement en cours...';

  @override
  String get profile => 'Profil';

  @override
  String get promoteAnotherAdmin => 'Promouvoir un autre admin';

  @override
  String get promoteAnotherAdminDesc =>
      'Choisir un membre de la famille à promouvoir au rôle d\'admin';

  @override
  String get promoteToAdmin => 'Promouvoir en Administrateur';

  @override
  String get quickConfigurations => 'Configurations rapides';

  @override
  String get realTimeUpdatesUnavailable =>
      'Mises à jour en temps réel indisponibles. Appuyez sur actualiser pour charger les dernières invitations.';

  @override
  String get reason => 'Raison';

  @override
  String get received => 'Reçues';

  @override
  String get recentActivity => 'Activité récente';

  @override
  String get refresh => 'Actualiser';

  @override
  String get rejected => 'Refusées';

  @override
  String get rejectedInvitations => 'Refusées';

  @override
  String get removeAdmin => 'Retirer Admin';

  @override
  String removeAdminConfirmation(String name) {
    return 'Retirer les privilèges d\'admin à $name ?';
  }

  @override
  String get removeAdminNote =>
      'Note: Ce membre perdra les privilèges d\'administrateur';

  @override
  String get removeMember => 'Retirer le membre';

  @override
  String removeMemberConfirmation(String memberName) {
    return 'Êtes-vous sûr de vouloir retirer $memberName de la famille?';
  }

  @override
  String get removeMemberDialogAccessibilityLabel =>
      'Dialogue de confirmation de retrait de membre';

  @override
  String get removeMemberFromFamily => 'Retirer le membre de cette famille';

  @override
  String get removeThisInvitation => 'Supprimer cette invitation';

  @override
  String get removeTooltip => 'Supprimer';

  @override
  String get removeYourselfFromFamily => 'Vous retirer de cette famille';

  @override
  String get resend => 'Renvoyer';

  @override
  String get resendLink => 'Renvoyer le lien';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get retry => 'Réessayer';

  @override
  String get retryExport => 'Réessayer l\'export';

  @override
  String get revoke => 'Révoquer';

  @override
  String get revoked => 'Révoquées';

  @override
  String get reconnect => 'Reconnecter';

  @override
  String get resolve => 'Résoudre';

  @override
  String get role => 'Rôle';

  @override
  String roleLabel(String role) {
    return 'Rôle : $role';
  }

  @override
  String roleUpdatedSuccessfully(String name) {
    return 'Rôle mis à jour avec succès pour $name';
  }

  @override
  String get sat => 'Sam';

  @override
  String get saturday => 'Samedi';

  @override
  String get saturdayShort => 'Sam';

  @override
  String get saturdayToSundayShort => 'Sam - Dim';

  @override
  String get save => 'Enregistrer';

  @override
  String get saved => 'Enregistré';

  @override
  String get saving => 'Enregistrement...';

  @override
  String get schedule => 'Planning';

  @override
  String get scheduleLabel => 'Calendrier';

  @override
  String get scheduleConfiguration => 'Configuration du Planning';

  @override
  String get scheduleConfigurationUpdatedSuccessfully =>
      'Configuration horaire mise à jour avec succès';

  @override
  String get scheduleCoordination => 'Coordination d\'Horaire';

  @override
  String scheduleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count horaires',
      one: '$count horaire',
    );
    return '$_temp0';
  }

  @override
  String get schedulePreview => 'Aperçu du Planning';

  @override
  String get scheduleRefreshed => 'Horaire actualisé';

  @override
  String get school => 'École';

  @override
  String get schoolName => 'Nom de l\'école';

  @override
  String get search => 'Rechercher';

  @override
  String get searchInvitations => 'Rechercher les invitations...';

  @override
  String get seatCapacityManagement => 'Gestion de la Capacité des Sièges';

  @override
  String get seatingConfiguration => 'Configuration des sièges';

  @override
  String get seats => 'places';

  @override
  String get secureLogin => 'Connexion sécurisée par lien magique';

  @override
  String get seeMemberInformation =>
      'Voir les informations et l\'activité du membre';

  @override
  String get select => 'Sélectionner';

  @override
  String get selectAnotherGroup => 'Sélectionner un autre groupe';

  @override
  String get selectGroup => 'Sélectionner un groupe';

  @override
  String get selectLanguage => 'Sélectionnez votre langue préférée';

  @override
  String get selectMemberToPromote => 'Sélectionner le membre à promouvoir';

  @override
  String get selectNewAdmin => 'Sélectionner le nouvel admin';

  @override
  String get sendInvitation => 'Envoyer l\'Invitation';

  @override
  String get sendInvitationTooltip => 'Envoyer une invitation';

  @override
  String get sendMagicLink => 'Envoyer le lien magique';

  @override
  String get sendingButton => 'Envoi...';

  @override
  String get sent => 'Envoyées';

  @override
  String get serverError => 'Erreur serveur. Veuillez réessayer plus tard';

  @override
  String get settings => 'Paramètres';

  @override
  String get showInvitationCode => 'Afficher le Code d\'Invitation';

  @override
  String get showVehicles => 'Afficher les véhicules';

  @override
  String signInToJoin(String familyName) {
    return 'Se connecter pour rejoindre $familyName';
  }

  @override
  String signInToJoinFamilyName(String familyName) {
    return 'Se connecter pour rejoindre $familyName';
  }

  @override
  String signInToJoinGroupName(String groupName) {
    return 'Se connecter pour rejoindre $groupName';
  }

  @override
  String slotsConfigured(int current, int max, int active) {
    return '$current/$max créneaux configurés • $active actifs';
  }

  @override
  String slotsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count créneaux',
      one: '$count créneau',
    );
    return '$_temp0';
  }

  @override
  String get stackTrace => 'Trace de la pile';

  @override
  String get standard => 'Standard';

  @override
  String get statistics => 'Statistiques';

  @override
  String get statusAccepted => 'ACCEPTÉ';

  @override
  String get statusActive => 'Actif';

  @override
  String get statusCancelled => 'ANNULÉ';

  @override
  String get statusDeclined => 'REFUSÉ';

  @override
  String get statusExpired => 'EXPIRÉ';

  @override
  String get statusExpiringSoon => 'EXPIRE BIENTÔT';

  @override
  String get statusFailed => 'ÉCHOUÉ';

  @override
  String get statusInvalid => 'INVALIDE';

  @override
  String get statusPending => 'EN ATTENTE';

  @override
  String get statusRevoked => 'RÉVOQUÉ';

  @override
  String get stay => 'Rester';

  @override
  String get stayButton => 'Rester';

  @override
  String get stayInCurrentFamily => 'Rester dans la famille actuelle';

  @override
  String get stayInCurrentFamilyDesc =>
      'Refuser la nouvelle invitation et rester dans votre famille actuelle';

  @override
  String get successfullyJoinedGroup => 'Groupe rejoint avec succès \\!';

  @override
  String get sun => 'Dim';

  @override
  String get sunday => 'Dimanche';

  @override
  String get sundayShort => 'Dim';

  @override
  String get suv => 'SUV';

  @override
  String get switchToNewFamily => 'Changer pour la nouvelle famille';

  @override
  String get switchToNewFamilyDesc =>
      'Quitter votre famille actuelle et rejoindre la nouvelle';

  @override
  String get sync => 'Sync';

  @override
  String get tapToAddFirstTimeSlot =>
      'Appuyer pour ajouter le premier créneau horaire';

  @override
  String get temporary => 'Temporaire';

  @override
  String get thu => 'Jeu';

  @override
  String get thursday => 'Jeudi';

  @override
  String get thursdayShort => 'Jeu';

  @override
  String get time => 'Heure';

  @override
  String timeAgoDays(int days, String plural) {
    return 'Il y a $days jour$plural';
  }

  @override
  String timeAgoHours(int hours, String plural) {
    return 'Il y a $hours heure$plural';
  }

  @override
  String timeAgoMinutes(int minutes, String plural) {
    return 'Il y a $minutes minute$plural';
  }

  @override
  String timeAlreadySelected(String time) {
    return 'L\'heure $time est déjà sélectionnée';
  }

  @override
  String get timeHint => '08:00';

  @override
  String get timeIntervalError =>
      'L\'heure doit être par intervalles de 15 min (00, 15, 30, 45)';

  @override
  String get timeLabel => 'Heure (HH:MM)';

  @override
  String get timePickerInstructions =>
      'Sélectionnez les heures de départ en appuyant sur les créneaux horaires';

  @override
  String timeRange(String range) {
    return 'Plage horaire : $range';
  }

  @override
  String get timeSlotExists => 'Ce créneau horaire existe déjà';

  @override
  String get timeSlots => 'Créneaux Horaires';

  @override
  String timeSlotsSelected(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count créneaux horaires sélectionnés',
      one: '$count créneau horaire sélectionné',
      zero: 'Aucun créneau horaire sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get total => 'Total';

  @override
  String totalChildrenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enfants',
      one: '1 enfant',
      zero: 'Aucun enfant',
    );
    return '$_temp0';
  }

  @override
  String totalMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres',
      one: '1 membre',
      zero: 'Aucun membre',
    );
    return '$_temp0';
  }

  @override
  String totalVehiclesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count véhicules',
      one: '1 véhicule',
      zero: 'Aucun véhicule',
    );
    return '$_temp0';
  }

  @override
  String get totalCapacity => 'Capacité totale';

  @override
  String totalSeats(int count) {
    return 'Total : $count';
  }

  @override
  String get totalSeatsHint => 'Nombre de places pour enfants';

  @override
  String get transferOwnership => 'Transférer la propriété';

  @override
  String get transferOwnershipDesc =>
      'Transférer la propriété complète de la famille à un autre membre';

  @override
  String get transferOwnershipWarning =>
      'Ceci transférera la propriété complète et les droits d\'admin au membre sélectionné. Cette action est irréversible.';

  @override
  String get transportGroups => 'Groupes de Transport';

  @override
  String get tripCreationFormToImplement =>
      'Formulaire de création de trajet à implémenter';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get tue => 'Mar';

  @override
  String get tuesday => 'Mardi';

  @override
  String get tuesdayShort => 'Mar';

  @override
  String typeToConfirm(String confirmText) {
    return 'Tapez \'$confirmText\' pour confirmer :';
  }

  @override
  String get universalInvitation => 'Invitation universelle';

  @override
  String get unknownFamily => 'Famille inconnue';

  @override
  String get unsavedChanges => 'Modifications non enregistrées';

  @override
  String get unsavedChangesTitle => 'Modifications non enregistrées';

  @override
  String get updateVehicle => 'Modifier le véhicule';

  @override
  String get updating => 'Mise à jour';

  @override
  String get usage => 'Utilisation';

  @override
  String get userMenu => 'Menu Utilisateur';

  @override
  String get userProfileOptions =>
      'Les options du profil utilisateur apparaîtraient ici';

  @override
  String userRole(String role) {
    return 'Rôle : $role';
  }

  @override
  String get validateCode => 'Valider le code';

  @override
  String get validatingGroupInvitation =>
      'Validation de l\'invitation de groupe...';

  @override
  String get validatingInvitation => 'Validation de l\'invitation...';

  @override
  String get van => 'Fourgonnette';

  @override
  String get vehicleAddedSuccessfully => 'Véhicule ajouté avec succès';

  @override
  String vehicleAssignment(String vehicleId) {
    return 'Affectation de Véhicule : $vehicleId';
  }

  @override
  String vehicleCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count véhicules',
      one: '$count véhicule',
    );
    return '$_temp0';
  }

  @override
  String get vehicleDetails => 'Détails du véhicule';

  @override
  String get vehicleId => 'ID du véhicule';

  @override
  String get vehicleInformation => 'Informations du véhicule';

  @override
  String get vehicleName => 'Nom du véhicule';

  @override
  String get vehicleNameRequired => 'Nom du véhicule *';

  @override
  String get vehicleNotFound => 'Véhicule non trouvé';

  @override
  String get vehicleType => 'Type de véhicule';

  @override
  String get vehicleUpdatedSuccessfully => 'Véhicule mis à jour avec succès';

  @override
  String get vehicles => 'Véhicules';

  @override
  String vehicleAddedSuccess(String vehicleName) {
    return '$vehicleName ajouté avec succès';
  }

  @override
  String vehicleFailedToAdd(String error) {
    return 'Échec de l\'ajout du véhicule : $error';
  }

  @override
  String vehicleAlreadyAssigned(String vehicleName) {
    return '$vehicleName est déjà assigné à ce créneau';
  }

  @override
  String vehicleFailedToRemove(String error) {
    return 'Échec de la suppression du véhicule : $error';
  }

  @override
  String vehicleRemovedSuccess(String vehicleName) {
    return '$vehicleName supprimé avec succès';
  }

  @override
  String get verificationFailedTitle => 'Vérification échouée';

  @override
  String get view => 'Voir';

  @override
  String get viewAll => 'Voir tout';

  @override
  String get viewDetails => 'Voir les détails';

  @override
  String get viewGroupSchedule => 'Voir le planning du groupe';

  @override
  String get viewMemberDetails => 'Voir les détails du membre';

  @override
  String get wed => 'Mer';

  @override
  String get wednesday => 'Mercredi';

  @override
  String get wednesdayShort => 'Mer';

  @override
  String get weekLabel => 'Semaine';

  @override
  String get weekView => 'Semaine';

  @override
  String get weekViewImplementation => 'Implémentation vue semaine';

  @override
  String weekdaysCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours de semaine',
      one: '$count jour de semaine',
    );
    return '$_temp0';
  }

  @override
  String get weekdaysOnly => 'Jours de semaine uniquement';

  @override
  String weekendDaysCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours de week-end',
      one: '$count jour de week-end',
    );
    return '$_temp0';
  }

  @override
  String get weekendsOnly => 'Week-end uniquement';

  @override
  String get weeklySchedule => 'Planning hebdomadaire';

  @override
  String weeklySlotTotal(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count créneaux par semaine',
      one: '$count créneau par semaine',
    );
    return '$_temp0';
  }

  @override
  String get welcomeNewUser =>
      'Bienvenue ! Nous voyons que vous êtes nouveau. Veuillez renseigner votre nom pour finaliser votre compte.';

  @override
  String get welcomeToEduLiftLogin => 'Bienvenue sur EduLift';

  @override
  String get whyOverrideNeeded => 'Pourquoi cet ajustement est-il nécessaire ?';

  @override
  String get yesterday => 'Hier';

  @override
  String get you => 'Vous';

  @override
  String get youAreLastAdmin => 'Vous êtes le dernier admin';

  @override
  String youAreLeavingAs(String role) {
    return 'Vous quittez en tant que : $role';
  }

  @override
  String get youHaveLeftFamily => 'Vous avez quitté la famille';

  @override
  String get youveBeenInvitedToJoin => 'Vous avez été invité(e) à rejoindre';

  @override
  String get validGroupInvitation =>
      'Cette invitation de groupe est valide et prête à être utilisée.';

  @override
  String get verifyingMagicLink => 'Vérification du Lien Magique';

  @override
  String get verifyingMagicLinkMessage =>
      'Veuillez patienter pendant que nous vérifions votre lien magique...';

  @override
  String get verificationSuccessful => 'Vérification Réussie';

  @override
  String get welcomeAfterMagicLinkSuccess =>
      'Bienvenue sur EduLift ! Redirection vers votre tableau de bord...';

  @override
  String get secureAuthentication => 'Authentification Sécurisée';

  @override
  String get cancelChanges => 'Annuler les Modifications';

  @override
  String get saveConfiguration => 'Enregistrer la Configuration';

  @override
  String get validation => 'Validation';

  @override
  String get quickSelectionOptions => 'Options de sélection rapide';

  @override
  String get activeScheduleDays => 'Jours d\'Horaire Actifs';

  @override
  String daysSelected(int count) {
    return '$count/7 jours sélectionnés';
  }

  @override
  String get atLeastOneDayRequired => 'Au moins un jour doit être sélectionné';

  @override
  String get noDaysSelectedWarning =>
      'Aucun jour sélectionné. L\'horaire sera désactivé.';

  @override
  String get scheduleActive => 'Horaire Actif';

  @override
  String get weekdayAbbrevMon => 'Lun';

  @override
  String get weekdayAbbrevTue => 'Mar';

  @override
  String get weekdayAbbrevWed => 'Mer';

  @override
  String get weekdayAbbrevThu => 'Jeu';

  @override
  String get weekdayAbbrevFri => 'Ven';

  @override
  String get weekdayAbbrevSat => 'Sam';

  @override
  String get weekdayAbbrevSun => 'Dim';

  @override
  String get weekendLabel => 'Fin de semaine';

  @override
  String get enterEmailAddress => 'Entrez l\'adresse e-mail';

  @override
  String get pleaseEnterValidEmail =>
      'Veuillez entrer une adresse e-mail valide';

  @override
  String get invitationSentSuccessfully => 'Invitation envoyée avec succès';

  @override
  String get addChildButton => 'Ajouter un Enfant';

  @override
  String get saveVehicle => 'Enregistrer le Véhicule';

  @override
  String get selectTimeSlot => 'Sélectionner un Créneau';

  @override
  String get confirmSchedule => 'Confirmer l\'Horaire';

  @override
  String get scheduleConfirmed => 'Horaire confirmé';

  @override
  String get scheduleDetails => 'Détails de l\'Horaire';

  @override
  String get editSchedule => 'Modifier l\'Horaire';

  @override
  String get welcomeOnboarding => 'Bienvenue';

  @override
  String get getStarted => 'Commencer';

  @override
  String get skipOnboarding => 'Passer';

  @override
  String get nextOnboarding => 'Suivant';

  @override
  String get nameRequired => 'Le nom est requis';

  @override
  String get dashboardTitle => 'Tableau de Bord';

  @override
  String get createFamilyButton => 'Créer une Famille';

  @override
  String get familyNameLabel => 'Nom de Famille';

  @override
  String get scheduleConfigSavedSuccess =>
      'Configuration de l\'emploi du temps enregistrée avec succès';

  @override
  String scheduleConfigSaveFailed(String error) {
    return 'Échec de l\'enregistrement de la configuration : $error';
  }

  @override
  String get saveOperationFailed =>
      'L\'opération d\'enregistrement ne s\'est pas terminée avec succès';

  @override
  String scheduleConfigSaveException(String exception, Object error) {
    return 'Échec de l\'enregistrement de la configuration : $exception';
  }

  @override
  String get changesCanceledReverted =>
      'Modifications annulées - retour à la configuration d\'origine';

  @override
  String get unsavedChangesScheduleMessage =>
      'Vous avez des modifications non enregistrées dans la configuration de l\'emploi du temps. Êtes-vous sûr de vouloir quitter sans enregistrer ?';

  @override
  String get groupNotFoundOrNoAccess =>
      'Le groupe est introuvable ou vous n\'y avez plus accès.';

  @override
  String get failedToLoadGroupDetails =>
      'Échec du chargement des détails du groupe';

  @override
  String get yourNameLabel => 'Votre nom';

  @override
  String get enterFullNameHint => 'Entrez votre nom complet';

  @override
  String get personalMessageOptionalLabel => 'Message personnel (facultatif)';

  @override
  String get addPersonalMessageHint =>
      'Ajoutez un message personnel à votre invitation...';

  @override
  String get ageOptionalLabel => 'Âge (facultatif)';

  @override
  String get enterAgeHint => 'Entrez l\'âge';

  @override
  String get yearsUnit => 'ans';

  @override
  String get enterFamilyNameHint =>
      'Entrez le nom de famille (ex : Famille Dupont)';

  @override
  String get describeFamilyOptionalHint =>
      'Décrivez votre famille (facultatif)';

  @override
  String get familyInvitationCodeHint => 'Code d\'invitation familiale';

  @override
  String get enterEmailAddressHint => 'Entrez votre adresse e-mail';

  @override
  String get nameTooShort => 'Le nom doit contenir au moins 2 caractères';

  @override
  String get familyNameCannotBeEmpty =>
      'Le nom de famille ne peut pas être vide';

  @override
  String get familyNameTooShortValidation =>
      'Le nom de famille doit contenir au moins 2 caractères';

  @override
  String get defaultGroupConfigInfo =>
      'Configurez les heures de départ pour chaque jour et enregistrez pour activer l\'emploi du temps.';

  @override
  String get makeAdminTitle => 'Promouvoir administrateur';

  @override
  String get removeAdminRoleTitle => 'Retirer le rôle d\'administrateur';

  @override
  String get makeAdminButton => 'Promouvoir administrateur';

  @override
  String get removeAdminButton => 'Retirer administrateur';

  @override
  String get addChildAction => 'Ajouter un enfant';

  @override
  String get joinGroupAction => 'Rejoindre un groupe';

  @override
  String get addVehicleAction => 'Ajouter un véhicule';

  @override
  String get configureScheduleTooltip => 'Configurer l\'emploi du temps';

  @override
  String get removeVehicleTooltip => 'Retirer le véhicule';

  @override
  String get editTimeTooltip => 'Modifier l\'heure';

  @override
  String get deleteTimeTooltip => 'Supprimer l\'heure';

  @override
  String get resolveScheduleConflictsTooltip =>
      'Résoudre les conflits d\'emploi du temps';

  @override
  String get refreshScheduleTooltip => 'Actualiser l\'emploi du temps';

  @override
  String get filterAndSortOptionsTooltip => 'Options de filtrage et de tri';

  @override
  String get logoutTooltip => 'Déconnexion';

  @override
  String get tryLoadingConfigAgainLabel =>
      'Réessayer de charger la configuration';

  @override
  String switchToDayConfigurationLabel(String day) {
    return 'Basculer vers la configuration de $day';
  }

  @override
  String departureHoursConfiguredHint(int count) {
    return '$count heures de départ configurées';
  }

  @override
  String get noDepartureHoursConfiguredHint =>
      'Aucune heure de départ configurée';

  @override
  String get viewScheduleConflictsLabel =>
      'Voir les conflits d\'emploi du temps';

  @override
  String get refreshScheduleLabel => 'Actualiser l\'emploi du temps';

  @override
  String get filterScheduleLabel => 'Filtrer l\'emploi du temps';

  @override
  String eventAtTimeLabel(String eventTitle, String time) {
    return '$eventTitle à $time';
  }

  @override
  String get familyNameInputFieldLabel => 'Champ de saisie du nom de famille';

  @override
  String get familyDescriptionInputFieldLabel =>
      'Champ de saisie de la description de la famille';

  @override
  String get createFamilyButtonLabel => 'Bouton créer une famille';

  @override
  String get cancelButtonLabel => 'Bouton annuler';

  @override
  String get removeVehicle => 'Retirer le véhicule';

  @override
  String get editTime => 'Modifier l\'heure';

  @override
  String get deleteTime => 'Supprimer l\'heure';

  @override
  String get resolveScheduleConflicts => 'Résoudre les conflits d\'horaire';

  @override
  String get refreshSchedule => 'Actualiser l\'emploi du temps';

  @override
  String get filterAndSortOptions => 'Options de filtrage et de tri';

  @override
  String get joinedDate => 'Inscrit';

  @override
  String get enterAge => 'Entrez l\'âge';

  @override
  String get enterYourEmailAddress => 'Entrez votre adresse e-mail';

  @override
  String get biometricAuthenticationButton =>
      'Bouton d\'authentification biométrique';

  @override
  String get websocketConnectionStatus => 'État de la connexion WebSocket';

  @override
  String get welcomeSection => 'Section de bienvenue';

  @override
  String get currentDateAndDashboardDescription =>
      'Date actuelle et description du tableau de bord';

  @override
  String get familyOverviewSection => 'Section d\'aperçu familial';

  @override
  String get welcomeIcon => 'Icône de bienvenue';

  @override
  String get familyIcon => 'Icône de famille';

  @override
  String get loadingFamilyInformation =>
      'Chargement des informations familiales';

  @override
  String get errorLoadingFamilyInformation =>
      'Erreur lors du chargement des informations familiales';

  @override
  String get errorIcon => 'Icône d\'erreur';

  @override
  String get quickActionsSection => 'Section des actions rapides';

  @override
  String get recentActivitiesSection => 'Section des activités récentes';

  @override
  String get noRecentActivityIcon => 'Icône d\'absence d\'activité récente';

  @override
  String get upcomingTripsSection => 'Section des trajets à venir';

  @override
  String get noTripsScheduledIcon => 'Icône d\'absence de trajets planifiés';

  @override
  String get unexpectedErrorOccurred =>
      'Une erreur inattendue s\'est produite.';

  @override
  String get failedToSendMagicLink =>
      'Échec de l\'envoi du lien magique - réponse vide';

  @override
  String get vehicleNearCapacity => 'Véhicule près de la capacité maximale';

  @override
  String get familyInvitationExpired => 'Invitation familiale expirée';

  @override
  String get groupMembershipUpdated => 'Adhésion au groupe mise à jour';

  @override
  String get dataRefresh => 'Actualisation des données';

  @override
  String get viewConflictDetails => 'Voir les détails du conflit';

  @override
  String get attemptingToReconnect => 'Tentative de reconnexion...';

  @override
  String get realtimeUpdatesActive =>
      'Les mises à jour en temps réel sont actives';

  @override
  String get connectingToRealtimeUpdates =>
      'Connexion aux mises à jour en temps réel...';

  @override
  String get synchronizingData => 'Synchronisation des données...';

  @override
  String userAvatarFor(String userName) {
    return 'Avatar de l\'utilisateur pour $userName';
  }

  @override
  String welcomeBackUser(String userName) {
    return 'Bonjour, $userName !';
  }

  @override
  String get currentDateAndDashboardDesc =>
      'Date actuelle et description du tableau de bord';

  @override
  String yourTransportDashboard(String date) {
    return 'Votre tableau de bord transport • $date';
  }

  @override
  String familyStatistics(int members, int children, int vehicles) {
    return 'Statistiques familiales : $members membres, $children enfants, $vehicles véhicules';
  }

  @override
  String get registerForTransport => 'Inscription au transport';

  @override
  String get connectWithOtherFamilies =>
      'Connectez-vous avec d\'autres familles';

  @override
  String get offerRidesToOthers => 'Proposer des trajets aux autres';

  @override
  String get loggedInAs => 'Connecté en tant que';

  @override
  String get toGetStartedSetupFamily =>
      'Pour commencer, vous devez configurer votre famille.';

  @override
  String get settingUpOnboarding => 'Configuration de votre intégration...';

  @override
  String get youveBeenInvitedToJoinFamily =>
      'Vous avez été invité à rejoindre une famille !';

  @override
  String get acceptInvitationToCoordinate =>
      'Acceptez l\'invitation pour commencer à coordonner avec d\'autres familles.';

  @override
  String get chooseYourFamilySetup =>
      'Choisissez votre configuration familiale';

  @override
  String get joinExistingFamily => 'Rejoindre une famille existante';

  @override
  String groupMembersPageTitle(String groupName) {
    return '$groupName - Membres';
  }

  @override
  String promoteToAdminConfirm(String familyName) {
    return 'Êtes-vous sûr de vouloir promouvoir \"$familyName\" en Administrateur ? Ils pourront gérer les membres et les paramètres du groupe.';
  }

  @override
  String get promote => 'Promouvoir';

  @override
  String get familyPromotedSuccess =>
      'Famille promue en Administrateur avec succès';

  @override
  String get failedToPromoteFamily => 'Échec de la promotion de la famille';

  @override
  String get demoteToMember => 'Rétrograder en Membre';

  @override
  String demoteToMemberConfirm(String familyName) {
    return 'Êtes-vous sûr de vouloir rétrograder \"$familyName\" en Membre ? Ils perdront leurs privilèges d\'administrateur.';
  }

  @override
  String get demote => 'Rétrograder';

  @override
  String get familyDemotedSuccess =>
      'Famille rétrogradée en Membre avec succès';

  @override
  String get failedToDemoteFamily => 'Échec de la rétrogradation de la famille';

  @override
  String get removeFamily => 'Retirer la Famille';

  @override
  String removeFamilyConfirm(String familyName) {
    return 'Êtes-vous sûr de vouloir retirer \"$familyName\" du groupe ? Cette action ne peut pas être annulée.';
  }

  @override
  String get removeFamilyAction => 'Retirer';

  @override
  String get familyRemovedSuccess => 'Famille retirée avec succès';

  @override
  String failedToRemoveFamily(String error) {
    return 'Échec de la suppression de la famille : $error';
  }

  @override
  String get removeFromGroup => 'Retirer du Groupe';

  @override
  String cancelInvitationConfirm(String familyName) {
    return 'Êtes-vous sûr de vouloir annuler l\'invitation pour \"$familyName\" ?';
  }

  @override
  String get invitationCanceledSuccess => 'Invitation annulée avec succès';

  @override
  String failedToCancelInvitation(String error) {
    return 'Échec de l\'annulation de l\'invitation : $error';
  }

  @override
  String get noInvitationIdFound => 'Aucun ID d\'invitation trouvé';

  @override
  String anErrorOccurred(String error) {
    return 'Une erreur s\'est produite : $error';
  }

  @override
  String get roleOwner => 'PROPRIÉTAIRE';

  @override
  String get roleAdmin => 'ADMIN';

  @override
  String get roleMember => 'MEMBRE';

  @override
  String get rolePending => 'EN ATTENTE';

  @override
  String get roleMemberDescription =>
      'Peut voir et rejoindre les trajets du groupe';

  @override
  String get roleAdminDescription =>
      'Peut gérer le groupe et inviter des membres';

  @override
  String get noAdmins => 'Aucun administrateur';

  @override
  String adminCountMore(String firstName, int count) {
    return '$firstName (+$count de plus)';
  }

  @override
  String get yourFamily => 'Votre Famille';

  @override
  String get inviteFamily => 'Inviter une Famille';

  @override
  String get inviteFamilyComingSoon =>
      'Fonctionnalité d\'invitation de famille bientôt disponible';

  @override
  String get noFamiliesYet => 'Aucune famille pour le moment';

  @override
  String get inviteFamiliesToGetStarted =>
      'Invitez des familles pour commencer';

  @override
  String get loadingFamilies => 'Chargement des familles...';

  @override
  String get failedToLoadFamilies => 'Échec du chargement des familles';

  @override
  String get inviteFamilyToGroup => 'Inviter une Famille au Groupe';

  @override
  String get inviteFamilyToGroupSubtitle =>
      'Recherchez et invitez des familles à rejoindre ce groupe';

  @override
  String get searchFamilies => 'Rechercher des Familles';

  @override
  String get enterFamilyName => 'Entrez le nom de la famille...';

  @override
  String get inviteAs => 'Inviter en tant que :';

  @override
  String get personalMessageOptional => 'Message Personnel (Optionnel)';

  @override
  String get searchResults => 'Résultats de Recherche';

  @override
  String get refineSearchForMoreResults =>
      'Affichage du nombre maximum de résultats. Affinez votre recherche pour voir des correspondances plus spécifiques.';

  @override
  String andXMore(int count) {
    return '+$count de plus';
  }

  @override
  String get enterAtLeast2Characters =>
      'Entrez au moins 2 caractères pour rechercher';

  @override
  String get noFamiliesFound => 'Aucune famille trouvée';

  @override
  String get alreadyInvited => 'Déjà invitée';

  @override
  String get inviting => 'Envoi en cours...';

  @override
  String searchFailed(String error) {
    return 'Échec de la recherche : $error';
  }

  @override
  String invitationSent(String familyName) {
    return 'Invitation envoyée à $familyName';
  }

  @override
  String invitationFailed(String error) {
    return 'Échec de l\'invitation : $error';
  }

  @override
  String get manageMembers => 'Gérer les Membres';

  @override
  String get manageMembersDescription =>
      'Gérez les familles membres, les rôles et les invitations pour ce groupe';

  @override
  String get pendingInvitation => 'Invitation en attente';

  @override
  String get cancelInvitationDescription =>
      'Révoquer cette invitation en attente';

  @override
  String get promoteToAdminDescription =>
      'Accorder les permissions admin à cette famille';

  @override
  String get demoteToMemberDescription =>
      'Retirer les permissions admin de cette famille';

  @override
  String get removeFamilyFromGroupDescription =>
      'Retirer cette famille du groupe';

  @override
  String promoteToAdminConfirmation(String familyName) {
    return 'Êtes-vous sûr de vouloir promouvoir $familyName administrateur du groupe ?';
  }

  @override
  String get adminCanManageGroupMembers =>
      'Les admins peuvent gérer les membres et les plannings du groupe';

  @override
  String demoteToMemberConfirmation(String familyName) {
    return 'Êtes-vous sûr de vouloir rétrograder $familyName en membre ?';
  }

  @override
  String get demoteToMemberNote =>
      'Cette famille perdra ses permissions d\'admin';

  @override
  String get removeFamilyDialogAccessibilityLabel =>
      'Retirer la famille du groupe';

  @override
  String removeFamilyConfirmation(String familyName) {
    return 'Êtes-vous sûr de vouloir retirer $familyName de ce groupe ?';
  }

  @override
  String get removeAdminFamilyNote =>
      'Attention : Cette famille admin sera retirée du groupe';

  @override
  String invitedOn(String date) {
    return 'Invité le $date';
  }

  @override
  String cancelInvitationConfirmation(String familyName) {
    return 'Êtes-vous sûr de vouloir annuler l\'invitation de $familyName ?';
  }

  @override
  String get cancelInvitationNote =>
      'La famille ne pourra pas rejoindre avec ce lien d\'invitation';

  @override
  String get familyAlreadyInvited =>
      'Cette famille a déjà été invitée à ce groupe';

  @override
  String get familyAlreadyMember =>
      'Cette famille est déjà membre de ce groupe';

  @override
  String get familyNotFound => 'Famille introuvable';

  @override
  String get invalidInvitationCode => 'Code d\'invitation invalide ou expiré';

  @override
  String get insufficientPermissions =>
      'Vous n\'avez pas la permission d\'effectuer cette action';

  @override
  String get invalidRequest =>
      'Requête invalide. Veuillez vérifier votre saisie';

  @override
  String get authenticationRequired => 'Authentification requise';

  @override
  String get resourceNotFound => 'Ressource introuvable';

  @override
  String get conflictError =>
      'Cette action est en conflit avec des données existantes';

  @override
  String get networkError =>
      'Erreur de connexion réseau. Veuillez vérifier votre connexion internet';

  @override
  String get requestTimeout => 'La requête a expiré. Veuillez réessayer';

  @override
  String get unexpectedError => 'Une erreur inattendue s\'est produite';

  @override
  String get groupManagement => 'Gestion des groupes';

  @override
  String get invitationIsValid =>
      'Cette invitation de groupe est valide et prête à être utilisée.';

  @override
  String get invitedBy => 'Invité par :';

  @override
  String get aGroup => 'un groupe';

  @override
  String get connectionFullyConnected => 'Entièrement connecté';

  @override
  String get connectionLimitedConnectivity => 'Connectivité limitée';

  @override
  String get connectionOffline => 'Hors ligne';

  @override
  String get connectionStatusTitle => 'État de la connexion';

  @override
  String get connectionHttpStatus => 'Connexion Internet';

  @override
  String get connectionWebSocketStatus => 'Mises à jour en temps réel';

  @override
  String get connectionConnected => 'Connecté';

  @override
  String get connectionDisconnected => 'Déconnecté';

  @override
  String get snackbarBackOnline => 'De retour en ligne. Synchronisation...';

  @override
  String get snackbarLimitedConnectivity =>
      'Connectivité limitée. Les mises à jour en temps réel peuvent être retardées.';

  @override
  String get snackbarOffline =>
      'Vous êtes hors ligne. Les modifications seront synchronisées lors de la reconnexion.';

  @override
  String get midday => 'Midi';

  @override
  String get evening => 'Soir';

  @override
  String get night => 'Nuit';

  @override
  String get unknown => 'Inconnu';

  @override
  String get unnamedGroup => 'Groupe sans nom';

  @override
  String get currentlyAssigned => 'Actuellement assignés';

  @override
  String get availableVehicles => 'Véhicules disponibles';

  @override
  String get noVehiclesAvailable => 'Aucun véhicule disponible';

  @override
  String get addVehiclesToFamily =>
      'Ajoutez des véhicules à votre famille pour les assigner aux plannings';

  @override
  String get errorLoadingVehicles => 'Erreur de chargement des véhicules';

  @override
  String vehiclesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count véhicules',
      one: '1 véhicule',
      zero: 'Aucun véhicule',
    );
    return '$_temp0';
  }

  @override
  String get assigned => 'Assignés';

  @override
  String get assignVehicle => 'Assigner un véhicule';

  @override
  String availableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count disponibles',
      one: '1 disponible',
      zero: 'Aucun disponible',
    );
    return '$_temp0';
  }

  @override
  String get noVehiclesAssignedToTimeSlot =>
      'Aucun véhicule assigné à ce créneau horaire';

  @override
  String get allVehiclesAssigned =>
      'Tous les véhicules disponibles sont assignés';

  @override
  String expandTimeSlot(String timeSlot) {
    return 'Déplier $timeSlot';
  }

  @override
  String seatsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places',
      one: '1 place',
      zero: 'Aucune place',
    );
    return '$_temp0';
  }

  @override
  String get seatOverride => 'Modification de capacité';

  @override
  String get adjustCapacityForTrip => 'Ajuster la capacité pour ce trajet';

  @override
  String get temporarilyAdjustCapacity =>
      'Ajustez temporairement la capacité du véhicule (ex: configuration fauteuil roulant)';

  @override
  String leaveEmptyForDefault(int capacity) {
    String _temp0 = intl.Intl.pluralLogic(
      capacity,
      locale: localeName,
      other: '$capacity places',
      one: '1 place',
      zero: 'aucune place',
    );
    return 'Laisser vide pour la valeur par défaut ($_temp0)';
  }

  @override
  String get overrideMustBeBetween =>
      'La modification doit être entre 0 et 50 places';

  @override
  String get cannotDetermineWeek =>
      'Impossible de déterminer la semaine pour le planning';

  @override
  String get seatOverrideUpdated => 'Modification de capacité mise à jour';

  @override
  String get seatOverrideActive => 'Modification de capacité active';

  @override
  String overrideDetails(int override, int base) {
    return 'Personnalisé: $override ($base de base)';
  }

  @override
  String get scheduleConfigurationRequired =>
      'Configuration du planning requise';

  @override
  String get setupTimeSlotsToEnableScheduling =>
      'Ce groupe nécessite une configuration du planning. Configurez les créneaux horaires pour activer la planification.';

  @override
  String get contactAdministratorToSetupTimeSlots =>
      'Contactez un administrateur du groupe pour configurer les créneaux horaires.';

  @override
  String get navigateToPreviousWeek => 'Naviguer vers la semaine précédente';

  @override
  String get navigateToNextWeek => 'Naviguer vers la semaine suivante';

  @override
  String emptySlotTapToAddVehicle(String day, String time) {
    return 'Créneau vide pour $day à $time, appuyez pour ajouter un véhicule';
  }

  @override
  String slotWithVehiclesTapToManage(String day, String time, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count véhicules',
      one: '1 véhicule',
    );
    return '$day à $time avec $_temp0, appuyez pour gérer';
  }

  @override
  String removeVehicleFromSlot(String vehicleName) {
    return 'Retirer $vehicleName de ce créneau';
  }

  @override
  String assignChildToVehicle(String childName) {
    return 'Assigner $childName au véhicule';
  }

  @override
  String removeChildFromVehicle(String childName) {
    return 'Retirer $childName du véhicule';
  }

  @override
  String get hasPendingChanges =>
      'Des modifications hors ligne sont en attente';

  @override
  String seatOverrideUpdateFailed(String error) {
    return 'Échec de la mise à jour du remplacement de siège : $error';
  }

  @override
  String saveAssignments(int count) {
    return 'Enregistrer ($count)';
  }

  @override
  String get vehicleCapacityFull =>
      'Impossible d\'assigner l\'enfant : véhicule plein';

  @override
  String get assignmentsSavedSuccessfully =>
      'Assignations enregistrées avec succès';

  @override
  String get selectWeekHelpText => 'Sélectionner la semaine';

  @override
  String get weekPickerHelperText =>
      'Sélectionnez une date pour aller à cette semaine';

  @override
  String vehiclesAssigned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count véhicules',
      one: '1 véhicule',
      zero: 'Aucun véhicule',
    );
    return '$_temp0';
  }

  @override
  String get noVehiclesAssigned => 'Aucun véhicule assigné';

  @override
  String collapseTimeSlot(String timeSlot) {
    return 'Replier $timeSlot';
  }

  @override
  String get cannotAddVehiclesToPastSlots =>
      'Impossible d\'ajouter des véhicules aux créneaux passés';

  @override
  String vehicleNotFoundInFamily(String vehicleName, String vehicleId) {
    return 'Le véhicule \"$vehicleName\" (ID: $vehicleId) est assigné à ce créneau mais n\'existe plus dans votre famille.';
  }

  @override
  String get contactSupportOrRemoveAssignment =>
      'Veuillez contacter le support ou supprimer cette assignment.';

  @override
  String get removeAssignment => 'Supprimer l\'assignment';

  @override
  String get timesShownInYourTimezone =>
      'Horaires affichés dans votre fuseau horaire';

  @override
  String get timezoneLabel => 'Fuseau horaire';

  @override
  String timesShownInTimezone(String timezone) {
    return 'Horaires affichés dans votre fuseau horaire ($timezone)';
  }

  @override
  String currentTimezone(String timezone) {
    return 'Actuel : $timezone';
  }

  @override
  String localTime(String time) {
    return 'Heure locale : $time';
  }

  @override
  String get searchTimezones => 'Rechercher des fuseaux horaires...';

  @override
  String get noTimezonesFound => 'Aucun fuseau horaire trouvé';

  @override
  String get selectTimezone => 'Sélectionner le fuseau horaire';

  @override
  String get tryDifferentSearchTerm => 'Essayez un autre terme de recherche';

  @override
  String timezonesAvailable(int count) {
    return '$count fuseaux horaires disponibles';
  }

  @override
  String get automaticallySyncTimezone =>
      'Synchroniser automatiquement le fuseau horaire';

  @override
  String get keepTimezoneSyncedWithDevice =>
      'Garder le fuseau horaire synchronisé avec l\'appareil';

  @override
  String get autoSyncEnabled => 'Synchronisation auto activée';

  @override
  String get autoSyncDisabled => 'Synchronisation auto désactivée';

  @override
  String get invalidTimezoneFormat => 'Format de fuseau horaire invalide';

  @override
  String get timezoneUpdatedSuccessfully =>
      'Fuseau horaire mis à jour avec succès';

  @override
  String get failedToUpdateTimezone =>
      'Échec de la mise à jour du fuseau horaire. Veuillez réessayer.';

  @override
  String get failedToDetectTimezone =>
      'Échec de la détection du fuseau horaire. Veuillez réessayer.';

  @override
  String get failedToUpdateAutoSyncPreference =>
      'Échec de la mise à jour de la préférence de synchronisation auto';

  @override
  String get unknownTimezone => 'Inconnu';

  @override
  String get todayTransports => 'Transports d\'aujourd\'hui';

  @override
  String get noTransportsToday => 'Aucun transport prévu aujourd\'hui';

  @override
  String get seeFullSchedule => 'Voir le planning complet →';

  @override
  String get refreshFailed =>
      'Échec du rafraîchissement des données de transport';

  @override
  String get loadingTodayTransports =>
      'Chargement des transports d\'aujourd\'hui...';

  @override
  String get errorLoadingTransports => 'Erreur de chargement des transports';

  @override
  String get todayTransportList => 'Liste des transports d\'aujourd\'hui';

  @override
  String get next7Days => 'Prochains 7 jours';

  @override
  String get weekViewExpanded => 'Vue semaine étendue';

  @override
  String dayWithTransports(String day, int count) {
    return '$day • $count transports';
  }

  @override
  String get noTransportsWeek => 'Aucun transport cette semaine';

  @override
  String get expandWeekView => 'Étendre la vue semaine';

  @override
  String get collapseWeekView => 'Réduire la vue semaine';

  @override
  String get scheduleSlotError =>
      'Impossible de compléter cette opération. Le créneau horaire n\'existe peut-être pas ou il peut y avoir un problème de connexion.';

  @override
  String get permissionError =>
      'Vous n\'avez pas la permission d\'effectuer cette action.';

  @override
  String get vehicleNotFoundError =>
      'Le véhicule sélectionné n\'a pas pu être trouvé. Veuillez réessayer.';
}
