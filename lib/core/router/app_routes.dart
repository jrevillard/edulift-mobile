class AppRoutes {
  // Authentication routes
  static const String splash = '/splash';
  static const String login = '/auth/login';
  static const String magicLink = '/auth/login/magic-link';
  static const String verifyMagicLink = '/auth/verify';

  // Main app routes
  static const String dashboard = '/dashboard';
  static const String family = '/family';
  static const String groups = '/groups';
  static const String schedule = '/schedule';
  static const String profile = '/profile';

  // Feature-specific routes
  static const String createFamily = '/family/create';
  static const String addChild = '/family/add-child';
  static const String manageChildren = '/family/manage';
  static const String vehicles = '/family/vehicles';
  static const String addVehicle = '/family/vehicles/add';
  static const String editVehicle = '/family/vehicles/edit';
  static const String inviteMember = '/family/invite';
  static const String createSchedule = '/schedule/create';

  // Invitation routes
  static const String familyInvitation = '/family-invitation';
  static const String groupInvitation = '/group-invitation';

  // Error routes
  static const String invalidDeepLink = '/invalid-link';

  // Dynamic routes (use with parameters)
  static String childDetails(String childId) => '/family/child/$childId';
  static String editChild(String childId) => '/family/children/$childId/edit';
  static String vehicleDetails(String vehicleId) =>
      '/family/vehicles/$vehicleId';
  static String vehicleEdit(String vehicleId) =>
      '/family/vehicles/$vehicleId/edit';
  static String groupDetails(String groupId) => '/groups/$groupId';
  static String invitation(String code) => '/invite/$code';
  static String verifyMagicLinkWithParams(
    String token, {
    String? email,
    String? inviteCode,
  }) {
    var url = '/auth/verify?token=$token';
    if (email != null) url += '&email=${Uri.encodeComponent(email)}';
    if (inviteCode != null) {
      url += '&inviteCode=${Uri.encodeComponent(inviteCode)}';
    }
    return url;
  }

}
