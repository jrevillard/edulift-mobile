// EduLift Mobile - App Text Styles
// Consistent typography throughout the application

import 'package:flutter/material.dart';

/// Application text styles
class AppTextStyles {
  AppTextStyles._(); // Private constructor to prevent instantiation

  // Base font family
  static const String fontFamily = 'Inter';

  // Heading styles
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    height: 1.44,
  );

  static const TextStyle h5 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static const TextStyle h6 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    height: 1.57,
  );

  // Body text styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.57,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.67,
  );

  // Label styles
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 1.57,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: 1.67,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    height: 1.82,
  );

  // Caption and overline
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.67,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10.0,
    fontWeight: FontWeight.w500,
    height: 1.6,
    letterSpacing: 0.5,
  );

  // Button text styles (without hardcoded colors)
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    height: 1.57,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    height: 1.67,
  );

  // Themed text styles that use context for colors
  static TextStyle getThemedH1(BuildContext context) =>
      h1.copyWith(color: Theme.of(context).colorScheme.onSurface);

  static TextStyle getThemedH2(BuildContext context) =>
      h2.copyWith(color: Theme.of(context).colorScheme.onSurface);

  static TextStyle getThemedH3(BuildContext context) =>
      h3.copyWith(color: Theme.of(context).colorScheme.onSurface);

  static TextStyle getThemedH4(BuildContext context) =>
      h4.copyWith(color: Theme.of(context).colorScheme.onSurface);

  static TextStyle getThemedH5(BuildContext context) =>
      h5.copyWith(color: Theme.of(context).colorScheme.onSurface);

  static TextStyle getThemedH6(BuildContext context) =>
      h6.copyWith(color: Theme.of(context).colorScheme.onSurface);

  static TextStyle getThemedBodyLarge(BuildContext context) =>
      bodyLarge.copyWith(color: Theme.of(context).colorScheme.onSurface);

  static TextStyle getThemedBodyMedium(BuildContext context) =>
      bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface);

  static TextStyle getThemedBodySmall(BuildContext context) =>
      bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);

  static TextStyle getThemedLabelLarge(BuildContext context) =>
      labelLarge.copyWith(color: Theme.of(context).colorScheme.onSurface);

  static TextStyle getThemedLabelMedium(BuildContext context) => labelMedium
      .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);

  static TextStyle getThemedLabelSmall(BuildContext context) => labelSmall
      .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);

  static TextStyle getThemedCaption(BuildContext context) =>
      caption.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);

  static TextStyle getThemedOverline(BuildContext context) =>
      overline.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);

  // Button styles with theme-appropriate colors
  static TextStyle getThemedButtonLarge(BuildContext context) =>
      buttonLarge.copyWith(color: Theme.of(context).colorScheme.onPrimary);

  static TextStyle getThemedButtonMedium(BuildContext context) =>
      buttonMedium.copyWith(color: Theme.of(context).colorScheme.onPrimary);

  static TextStyle getThemedButtonSmall(BuildContext context) =>
      buttonSmall.copyWith(color: Theme.of(context).colorScheme.onPrimary);
}
