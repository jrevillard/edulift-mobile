import 'package:flutter/semantics.dart';

// ignore: deprecated_member_use
/// Comprehensive screen reader support utilities for WCAG 2.1 AA compliance
class ScreenReaderSupport {
  ScreenReaderSupport._();

  /// Announces a message to screen readers
  static void announce(String message, {TextDirection? textDirection}) {
    SemanticsService.announce(message, textDirection ?? TextDirection.ltr);
  }

  /// Announces navigation changes
  static void announceNavigation(String destination) {
    announce('Navigated to $destination');
  }

  /// Announces state changes
  static void announceStateChange(String change) {
    announce(change);
  }

  /// Announces form field focus
  static void announceFieldFocus(String fieldLabel) {
    announce('$fieldLabel field focused');
  }

  /// Announces form field error
  static void announceFieldError(String fieldLabel, String error) {
    announce('Error in $fieldLabel: $error');
  }

  /// Announces loading state
  static void announceLoading(String context) {
    announce('Loading $context');
  }

  /// Announces success state
  static void announceSuccess(String action) {
    announce('$action completed successfully');
  }

  /// Announces error state
  static void announceError(String error) {
    announce('Error: $error');
  }

  /// Announces completion state
  static void announceCompletion(String task) {
    announce('$task completed');
  }

  /// Announces button interaction
  static void announceButtonPress(String buttonLabel) {
    announce('$buttonLabel button pressed');
  }

  /// Announces tab selection
  static void announceTabSelection(String tabLabel) {
    announce('Selected $tabLabel tab');
  }

  /// Announces list item selection
  static void announceListItem(String item, int index) {
    announce('Selected item $index: $item');
  }
}
