# Unified Notification System Implementation Roadmap

## Dependencies Required

### Add to pubspec.yaml

```yaml
dependencies:
  # Native notifications
  flutter_local_notifications: ^17.2.3
  
  # Background processing
  firebase_messaging: ^15.1.3  # For background message handling (optional)
  
  # Permissions
  permission_handler: ^11.3.1
  
  # Badge management (optional for Android)
  flutter_app_badger: ^1.5.0
  
  # JSON serialization (already included)
  json_annotation: ^4.9.0

dev_dependencies:
  # For Hive code generation (already included)
  hive_ce_generator: ^1.9.2
  build_runner: ^2.4.13
```

### Platform Configuration

#### Android Configuration
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <!-- Notification permissions -->
  <uses-permission android:name="android.permission.WAKE_LOCK" />
  <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
  <uses-permission android:name="android.permission.VIBRATE" />
  <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
  
  <application>
    <!-- Notification receivers -->
    <receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
    <receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
      <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.PACKAGE_REPLACED"/>
        <data android:scheme="package"/>
      </intent-filter>
    </receiver>
  </application>
</manifest>
```

#### iOS Configuration
```xml
<!-- ios/Runner/Info.plist -->
<key>UIBackgroundModes</key>
<array>
  <string>background-fetch</string>
  <string>background-processing</string>
  <string>remote-notification</string>
</array>

<key>NSUserNotificationAlertStyle</key>
<string>alert</string>
```

## Implementation Phases

### Phase 1: Core Services (2-3 days)

#### 1.1 Add Dependencies
```bash
flutter pub add flutter_local_notifications permission_handler
flutter pub get
```

#### 1.2 Create Base Interfaces
- [ ] Create `INotificationPermissionService`
- [ ] Create `INotificationChannelManager`
- [ ] Create `INotificationDeliveryService`
- [ ] Create `IUnifiedNotificationService`

#### 1.3 Implement Permission Service
```dart
// /lib/core/services/notifications/notification_permission_service.dart
// Implementation from NOTIFICATION_SERVICE_INTERFACES.md
```

#### 1.4 Implement Channel Manager
```dart
// /lib/core/services/notifications/notification_channel_manager.dart
// Implementation from NOTIFICATION_SERVICE_INTERFACES.md
```

#### 1.5 Implement Delivery Service
```dart
// /lib/core/services/notifications/notification_delivery_service.dart
// Implementation from NOTIFICATION_SERVICE_INTERFACES.md
```

### Phase 2: Integration & Actions (2-3 days)

#### 2.1 Create Action Service
```dart
// /lib/core/services/notifications/notification_action_service.dart
// Implementation from NOTIFICATION_SERVICE_INTERFACES.md
```

#### 2.2 Enhance WebSocket Service
```dart
// Add to existing RealtimeWebSocketService (5 lines only)
final StreamController<BackgroundNotificationEvent> _backgroundNotificationController =
    StreamController<BackgroundNotificationEvent>.broadcast();

Stream<BackgroundNotificationEvent> get backgroundNotifications =>
    _backgroundNotificationController.stream;

// In _handleIncomingMessage method, add:
if (event.priority == NotificationPriority.high || 
    event.priority == NotificationPriority.urgent) {
  _backgroundNotificationController.add(
    BackgroundNotificationEvent(
      originalEvent: event,
      shouldShowNative: !_isAppInForeground(),
    ),
  );
}
```

#### 2.3 Implement Unified Service
```dart
// /lib/core/services/notifications/unified_notification_service.dart
// Implementation from NOTIFICATION_SERVICE_INTERFACES.md
```

#### 2.4 Create Provider Integration
```dart
// /lib/core/di/providers/notification_providers.dart
// Implementation from NOTIFICATION_REMAINING_SERVICES.md
```

### Phase 3: Background & Persistence (2-3 days)

#### 3.1 Create Background Service
```dart
// /lib/core/services/notifications/background_notification_service.dart
// Implementation from NOTIFICATION_REMAINING_SERVICES.md
```

#### 3.2 Create Persistence Service
```dart
// /lib/core/services/notifications/notification_persistence_service.dart
// Implementation from NOTIFICATION_REMAINING_SERVICES.md
```

#### 3.3 Generate Hive Adapters
```bash
flutter packages pub run build_runner build
```

#### 3.4 Create Badge Service
```dart
// /lib/core/services/notifications/notification_badge_service.dart
// Implementation from NOTIFICATION_REMAINING_SERVICES.md
```

#### 3.5 Enhance Existing Badge Widget
```dart
// Modify /lib/core/presentation/widgets/realtime_notification_badge.dart
// Add persistence-aware badge counting
```

### Phase 4: App Integration (1-2 days)

#### 4.1 Update Main App Initialization
```dart
// In main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // ... existing initialization ...
  
  final container = ProviderContainer();
  final unifiedNotificationService = container.read(unifiedNotificationServiceProvider);
  await unifiedNotificationService.initialize();
  
  runApp(UncontrolledProviderScope(
    container: container,
    child: EduLiftApp(),
  ));
}
```

#### 4.2 Update Navigation Integration
```dart
// The existing NavigationIntent system already supports notification deep links
// No changes needed - the action service maps notifications to NavigationIntents
```

#### 4.3 Update Existing Badge Widgets
```dart
// Replace RealtimeNotificationBadge with EnhancedRealtimeNotificationBadge
// in app_router.dart navigation destinations
```

### Phase 5: Testing & Polish (1-2 days)

#### 5.1 Unit Tests
```dart
// Test files to create:
// test/unit/core/services/notifications/notification_permission_service_test.dart
// test/unit/core/services/notifications/notification_delivery_service_test.dart
// test/unit/core/services/notifications/notification_action_service_test.dart
// test/unit/core/services/notifications/unified_notification_service_test.dart
```

#### 5.2 Integration Tests
```dart
// test/integration/notification_websocket_integration_test.dart
// test/integration/notification_action_navigation_test.dart
// test/integration/background_notification_test.dart
```

#### 5.3 Platform Testing
- [ ] Test iOS notification categories and actions
- [ ] Test Android notification channels and importance levels
- [ ] Test permission flows on both platforms
- [ ] Test background notification handling

## File Structure

```
lib/core/services/notifications/
├── unified_notification_service.dart
├── notification_permission_service.dart
├── notification_delivery_service.dart
├── notification_channel_manager.dart
├── notification_action_service.dart
├── background_notification_service.dart
├── notification_persistence_service.dart
├── notification_badge_service.dart
└── models/
    ├── notification_channel_config.dart
    ├── persistent_notification_event.dart
    └── background_notification_event.dart

lib/core/di/providers/
└── notification_providers.dart

test/unit/core/services/notifications/
├── notification_permission_service_test.dart
├── notification_delivery_service_test.dart
├── notification_action_service_test.dart
├── unified_notification_service_test.dart
├── background_notification_service_test.dart
├── notification_persistence_service_test.dart
└── notification_badge_service_test.dart
```

## Testing Strategy

### Unit Tests
1. **Permission Service**: Test all permission states and platform differences
2. **Delivery Service**: Test notification conversion and platform-specific details
3. **Action Service**: Test NavigationIntent mapping from notification payloads
4. **Persistence Service**: Test Hive storage, cleanup, and stream emissions
5. **Badge Service**: Test badge count updates and platform integration

### Integration Tests
1. **WebSocket → Native Flow**: Test end-to-end WebSocket event to native notification
2. **Action Navigation**: Test notification tap → NavigationIntent → router navigation
3. **Background Handling**: Test app lifecycle changes and background notifications
4. **Badge Synchronization**: Test badge count sync between WebSocket and persistence

### Platform Tests
1. **iOS Categories**: Test notification actions and category configuration
2. **Android Channels**: Test channel creation and importance levels
3. **Permission Flows**: Test permission request and settings navigation
4. **Background Permissions**: Test background notification permissions

## Migration Considerations

### Breaking Changes: NONE
- All existing WebSocket infrastructure preserved
- All existing NavigationIntent routing preserved
- All existing badge widget functionality preserved
- All existing provider patterns maintained

### Additive Changes Only
1. **New Dependencies**: Added to pubspec.yaml
2. **New Services**: All new service files
3. **Enhanced Features**: Existing widgets get additional functionality
4. **Platform Configuration**: New manifest permissions

### Backward Compatibility
- Existing code continues to work unchanged
- New notification features are opt-in
- Progressive enhancement approach
- No disruption to current user experience

## Success Metrics

### Functional Requirements
- [ ] Native notifications display for high-priority WebSocket events
- [ ] Notification actions navigate correctly via NavigationIntent system
- [ ] Background notifications work when app is closed/backgrounded
- [ ] Badge counts sync between WebSocket and persistent storage
- [ ] Permissions handled gracefully on both platforms

### Performance Requirements
- [ ] No impact on existing WebSocket performance
- [ ] Efficient notification storage with automatic cleanup
- [ ] Minimal battery impact from background processing
- [ ] Fast notification display (< 500ms from WebSocket event)

### User Experience Requirements
- [ ] Seamless integration with existing in-app notifications
- [ ] Clear notification categories and priorities
- [ ] Intuitive notification actions (Accept/Decline invitations)
- [ ] Consistent badge counts across app lifecycle states

## Risk Mitigation

### Technical Risks
1. **Permission Denial**: Graceful degradation to in-app notifications only
2. **Platform Differences**: Platform-specific implementations with fallbacks
3. **Background Limitations**: Respects platform background execution limits
4. **Storage Overflow**: Automatic cleanup and size limits implemented

### Integration Risks
1. **WebSocket Disruption**: Minimal changes to preserve existing functionality
2. **Navigation Conflicts**: Uses existing NavigationIntent patterns
3. **Provider Conflicts**: Follows established DI patterns
4. **State Synchronization**: Robust stream-based state management

This roadmap provides a complete, step-by-step implementation plan that preserves all existing functionality while adding comprehensive native notification capabilities.