import 'package:flutter/widgets.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';

/// Form modes for vehicle operations
enum VehicleFormMode {
  /// Adding a new vehicle
  add,

  /// Editing an existing vehicle
  edit;

  /// Whether this is an add operation
  bool get isAdd => this == VehicleFormMode.add;

  /// Whether this is an edit operation
  bool get isEdit => this == VehicleFormMode.edit;

  /// Get the title for the form mode
  String title(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case VehicleFormMode.add:
        return l10n.addVehicleTitle;
      case VehicleFormMode.edit:
        return l10n.editVehicleTitle;
    }
  }
}
