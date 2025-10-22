# Onboarding Route Refactoring Summary

**Date:** 2025-10-02
**Status:** ✅ Completed

## Overview

Removed the `/features/onboarding/` folder and inlined the single onboarding route directly into core routing infrastructure.

## Motivation

The `OnboardingRouteFactory` only defined a single route (`/onboarding/wizard`), and the page was already moved to core presentation (`/lib/core/presentation/pages/onboarding_wizard_page.dart`). Maintaining an entire feature folder for one route definition was unnecessary overhead.

## Changes Made

### 1. Created Core Routes File

**New file:** `/workspace/mobile_app/lib/core/router/core_routes.dart`

```dart
/// Core application routes (system/navigation pages, not feature-specific)
class CoreRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: '/onboarding/wizard',
      name: 'onboarding-wizard',
      builder: (context, state) {
        final invitationCode = state.uri.queryParameters['invitationCode'];
        return OnboardingWizardPage(invitationCode: invitationCode);
      },
    ),
  ];
}
```

This file provides a home for system/core routes that don't belong to specific features (e.g., onboarding, splash screens, error pages, etc.).

### 2. Updated Route Registration

**Modified:** `/workspace/mobile_app/lib/core/router/route_registration.dart`

- Removed import of `OnboardingRouteFactory`
- Added import of `CoreRoutes`
- Replaced `RouteRegistry.register(OnboardingRouteFactory())` with `RouteRegistry.registerAll(CoreRoutes.routes)`

### 3. Enhanced Route Registry

**Modified:** `/workspace/mobile_app/lib/core/router/route_factory.dart`

Added support for registering routes directly without a factory:

```dart
class RouteRegistry {
  static final _factories = <AppRouteFactory>[];
  static final _directRoutes = <RouteBase>[];

  /// Register routes directly (for core routes that don't need a factory)
  static void registerAll(List<RouteBase> routes) {
    _directRoutes.addAll(routes);
  }

  static List<RouteBase> getAllRoutes() {
    final factoryRoutes = _factories.expand((factory) => factory.routes);
    return [...factoryRoutes, ..._directRoutes];
  }
}
```

### 4. Deleted Onboarding Feature Folder

**Removed:** `/workspace/mobile_app/lib/features/onboarding/`

The folder contained only:
- `presentation/routing/onboarding_route_factory.dart`

## Verification

✅ **No broken imports:** Verified no references to `features/onboarding` remain
✅ **Route still accessible:** `/onboarding/wizard` route definition exists in `core_routes.dart`
✅ **Compilation successful:** `flutter analyze` passes with no new errors
✅ **Clean architecture:** Core routes now separated from feature routes

## Benefits

1. **Clearer separation:** System routes vs. feature routes
2. **Reduced complexity:** No factory overhead for single routes
3. **Better organization:** Core routes have dedicated file
4. **Easier maintenance:** Future core routes (splash, error) have clear home
5. **Less boilerplate:** Direct route registration for non-feature routes

## Future Considerations

The `CoreRoutes` class can now accommodate other system-level routes:
- Splash screen routes
- Error page routes
- System notification pages
- Other non-feature navigation

## Files Changed

- ✅ Created: `lib/core/router/core_routes.dart`
- ✅ Modified: `lib/core/router/route_registration.dart`
- ✅ Modified: `lib/core/router/route_factory.dart`
- ✅ Deleted: `lib/features/onboarding/` (entire folder)

## Backward Compatibility

✅ The `/onboarding/wizard` route remains fully functional with identical behavior:
- Same path: `/onboarding/wizard`
- Same name: `onboarding-wizard`
- Same query parameter handling: `invitationCode`
- Same page: `OnboardingWizardPage`
