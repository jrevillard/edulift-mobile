// EduLift Mobile - Responsive Breakpoints Utility
// Consistent responsive design breakpoints across the application

import 'package:flutter/material.dart';

/// Responsive breakpoints utility class following Material Design 3 guidelines
/// and patterns established in AUTH and DASHBOARD domains
class ResponsiveBreakpoints {
  /// Mobile breakpoint - screens smaller than this are considered mobile
  static const double mobile = 640;

  /// Tablet breakpoint - screens this size and above are considered tablet
  static const double tablet = 768;

  /// Desktop breakpoint - screens this size and above are considered desktop
  static const double desktop = 1024;

  /// Wide desktop breakpoint - screens this size and above are considered wide
  static const double wide = 1200;

  /// Check if current screen is mobile size
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  /// Check if current screen is tablet size
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < desktop;

  /// Check if current screen is desktop size
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;

  /// Check if current screen is wide desktop size
  static bool isWideDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= wide;

  /// Check if current screen is tablet or larger
  static bool isTabletOrLarger(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile;

  /// Check if current screen is desktop or larger
  static bool isDesktopOrLarger(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;

  /// Get adaptive padding based on screen size
  static EdgeInsets getAdaptivePadding(
    BuildContext context, {
    double? mobileHorizontal,
    double? mobileVertical,
    double? mobileAll,
    double? tabletHorizontal,
    double? tabletVertical,
    double? tabletAll,
    double? desktopHorizontal,
    double? desktopVertical,
    double? desktopAll,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= desktop) {
      if (desktopAll != null) {
        return EdgeInsets.all(desktopAll);
      }
      return EdgeInsets.symmetric(
        horizontal: desktopHorizontal ?? 32.0,
        vertical: desktopVertical ?? 24.0,
      );
    } else if (screenWidth >= mobile) {
      if (tabletAll != null) {
        return EdgeInsets.all(tabletAll);
      }
      return EdgeInsets.symmetric(
        horizontal: tabletHorizontal ?? 24.0,
        vertical: tabletVertical ?? 20.0,
      );
    } else {
      if (mobileAll != null) {
        return EdgeInsets.all(mobileAll);
      }
      return EdgeInsets.symmetric(
        horizontal: mobileHorizontal ?? 16.0,
        vertical: mobileVertical ?? 16.0,
      );
    }
  }

  /// Get adaptive spacing based on screen size
  static double getAdaptiveSpacing(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= ResponsiveBreakpoints.desktop) {
      return desktop ?? 24.0;
    } else if (screenWidth >= ResponsiveBreakpoints.mobile) {
      return tablet ?? 20.0;
    } else {
      return mobile ?? 16.0;
    }
  }

  /// Get adaptive icon size based on screen size
  static double getAdaptiveIconSize(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= ResponsiveBreakpoints.desktop) {
      return desktop ?? 28.0;
    } else if (screenWidth >= ResponsiveBreakpoints.mobile) {
      return tablet ?? 24.0;
    } else {
      return mobile ?? 20.0;
    }
  }

  /// Get adaptive font size scale based on screen size
  static double getFontScale(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= desktop) {
      return 1.1; // 10% larger on desktop
    } else if (screenWidth >= tablet) {
      return 1.05; // 5% larger on tablet
    } else {
      return 1.0; // Base size on mobile
    }
  }

  /// Get adaptive button height based on screen size
  static double getAdaptiveButtonHeight(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= ResponsiveBreakpoints.desktop) {
      return desktop ?? 56.0;
    } else if (screenWidth >= ResponsiveBreakpoints.mobile) {
      return tablet ?? 52.0;
    } else {
      return mobile ?? 48.0;
    }
  }

  /// Check if screen is in compact height mode (for adaptive layouts)
  static bool isCompactHeight(BuildContext context) {
    return MediaQuery.of(context).size.height < 600;
  }

  /// Check if screen is very compact height (for more aggressive layout changes)
  static bool isVeryCompactHeight(BuildContext context) {
    return MediaQuery.of(context).size.height < 500;
  }

  /// Get number of columns for grid layouts based on screen size
  static int getGridColumns(
    BuildContext context, {
    int? mobile,
    int? tablet,
    int? desktop,
    int? wide,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= ResponsiveBreakpoints.wide) {
      return wide ?? 4;
    } else if (screenWidth >= ResponsiveBreakpoints.desktop) {
      return desktop ?? 3;
    } else if (screenWidth >= ResponsiveBreakpoints.tablet) {
      return tablet ?? 2;
    } else {
      return mobile ?? 1;
    }
  }

  /// Get maximum content width for centered layouts
  static double getMaxContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= wide) {
      return 1200.0;
    } else if (screenWidth >= desktop) {
      return 1024.0;
    } else {
      return screenWidth;
    }
  }

  /// Get adaptive border radius based on screen size
  static double getAdaptiveBorderRadius(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= ResponsiveBreakpoints.desktop) {
      return desktop ?? tablet ?? mobile ?? 12.0;
    } else if (screenWidth >= ResponsiveBreakpoints.mobile) {
      return tablet ?? mobile ?? 10.0;
    } else {
      return mobile ?? 8.0;
    }
  }

  /// Get adaptive maximum height based on screen size and percentage
  static double getAdaptiveMaxHeight(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    double percentage;
    if (screenWidth >= ResponsiveBreakpoints.desktop) {
      percentage = desktop ?? tablet ?? mobile ?? 0.8;
    } else if (screenWidth >= ResponsiveBreakpoints.mobile) {
      percentage = tablet ?? mobile ?? 0.8;
    } else {
      percentage = mobile ?? 0.8;
    }

    return screenHeight * percentage;
  }

  /// Get adaptive font size based on screen size
  static double getAdaptiveFontSize(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= ResponsiveBreakpoints.desktop) {
      return desktop ?? tablet ?? mobile ?? 16.0;
    } else if (screenWidth >= ResponsiveBreakpoints.mobile) {
      return tablet ?? mobile ?? 16.0;
    } else {
      return mobile ?? 16.0;
    }
  }

  /// Get adaptive aspect ratio based on screen size
  static double getAdaptiveAspectRatio(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= ResponsiveBreakpoints.desktop) {
      return desktop ?? tablet ?? mobile ?? 1.0;
    } else if (screenWidth >= ResponsiveBreakpoints.mobile) {
      return tablet ?? mobile ?? 1.0;
    } else {
      return mobile ?? 1.0;
    }
  }
}

/// Extension to add responsive utilities to BuildContext
/// Provides all getAdaptive* methods as extension methods on BuildContext
extension ResponsiveContext on BuildContext {
  /// Check if current screen is mobile size
  bool get isMobile => ResponsiveBreakpoints.isMobile(this);

  /// Check if current screen is tablet size
  bool get isTablet => ResponsiveBreakpoints.isTablet(this);

  /// Check if current screen is desktop size
  bool get isDesktop => ResponsiveBreakpoints.isDesktop(this);

  /// Check if current screen is wide desktop size
  bool get isWideDesktop => ResponsiveBreakpoints.isWideDesktop(this);

  /// Check if current screen is tablet or larger
  bool get isTabletOrLarger => ResponsiveBreakpoints.isTabletOrLarger(this);

  /// Check if current screen is desktop or larger
  bool get isDesktopOrLarger => ResponsiveBreakpoints.isDesktopOrLarger(this);

  /// Check if screen is in compact height mode
  bool get isCompactHeight => ResponsiveBreakpoints.isCompactHeight(this);

  /// Check if screen is very compact height
  bool get isVeryCompactHeight =>
      ResponsiveBreakpoints.isVeryCompactHeight(this);

  /// Get adaptive padding
  EdgeInsets getAdaptivePadding({
    double? mobileHorizontal,
    double? mobileVertical,
    double? mobileAll,
    double? tabletHorizontal,
    double? tabletVertical,
    double? tabletAll,
    double? desktopHorizontal,
    double? desktopVertical,
    double? desktopAll,
  }) => ResponsiveBreakpoints.getAdaptivePadding(
    this,
    mobileHorizontal: mobileHorizontal,
    mobileVertical: mobileVertical,
    mobileAll: mobileAll,
    tabletHorizontal: tabletHorizontal,
    tabletVertical: tabletVertical,
    tabletAll: tabletAll,
    desktopHorizontal: desktopHorizontal,
    desktopVertical: desktopVertical,
    desktopAll: desktopAll,
  );

  /// Get adaptive spacing
  double getAdaptiveSpacing({
    double? mobile,
    double? tablet,
    double? desktop,
  }) => ResponsiveBreakpoints.getAdaptiveSpacing(
    this,
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
  );

  /// Get adaptive icon size
  double getAdaptiveIconSize({
    double? mobile,
    double? tablet,
    double? desktop,
  }) => ResponsiveBreakpoints.getAdaptiveIconSize(
    this,
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
  );

  /// Get font scale
  double get fontScale => ResponsiveBreakpoints.getFontScale(this);

  /// Get adaptive button height
  double getAdaptiveButtonHeight({
    double? mobile,
    double? tablet,
    double? desktop,
  }) => ResponsiveBreakpoints.getAdaptiveButtonHeight(
    this,
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
  );

  /// Get grid columns
  int getGridColumns({int? mobile, int? tablet, int? desktop, int? wide}) =>
      ResponsiveBreakpoints.getGridColumns(
        this,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
        wide: wide,
      );

  /// Get maximum content width
  double get maxContentWidth => ResponsiveBreakpoints.getMaxContentWidth(this);

  /// Get adaptive border radius
  double getAdaptiveBorderRadius({
    double? mobile,
    double? tablet,
    double? desktop,
  }) => ResponsiveBreakpoints.getAdaptiveBorderRadius(
    this,
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
  );

  /// Get adaptive maximum height
  double getAdaptiveMaxHeight({
    double? mobile,
    double? tablet,
    double? desktop,
  }) => ResponsiveBreakpoints.getAdaptiveMaxHeight(
    this,
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
  );

  /// Get adaptive font size
  double getAdaptiveFontSize({
    double? mobile,
    double? tablet,
    double? desktop,
  }) => ResponsiveBreakpoints.getAdaptiveFontSize(
    this,
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
  );

  /// Get adaptive aspect ratio
  double getAdaptiveAspectRatio({
    double? mobile,
    double? tablet,
    double? desktop,
  }) => ResponsiveBreakpoints.getAdaptiveAspectRatio(
    this,
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
  );
}
