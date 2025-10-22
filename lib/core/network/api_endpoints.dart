// EduLift Mobile - API Endpoints
// Centralized endpoint definitions for WebSocket services

class ApiEndpoints {
  static const String websocketBase = '/ws';
  static const String invitationsSocket = '$websocketBase/invitations';
  static const String scheduleSocket = '$websocketBase/schedule';
  static const String groups = '/groups';
  static const String vehicles = '/vehicles';
  static const String seatOverrides = '/seat-overrides';
}
