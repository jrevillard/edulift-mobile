import 'package:flutter/material.dart';
import 'vehicle_form_page.dart';
import '../utils/vehicle_form_mode.dart';

/// Wrapper for add vehicle functionality using unified form
/// Responsive design is handled by VehicleFormPage
class AddVehiclePage extends StatelessWidget {
  const AddVehiclePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Responsive design is implemented in VehicleFormPage
    return const VehicleFormPage(mode: VehicleFormMode.add);
  }
}
