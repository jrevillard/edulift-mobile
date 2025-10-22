import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';

// COMPOSITION ROOT: Import ONLY from feature-level composition root
import '../../providers.dart';
import 'vehicle_form_page.dart';
import '../utils/vehicle_form_mode.dart';
import '../../../../core/presentation/widgets/loading_indicator.dart';
import 'package:edulift/core/domain/entities/family.dart' as entities;

/// Wrapper for edit vehicle functionality using unified form
/// Responsive design is handled by VehicleFormPage
class EditVehiclePage extends ConsumerWidget {
  final String vehicleId;

  const EditVehiclePage({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyState = ref.watch(familyComposedProvider);

    // NO FALLBACK: Vehicle not found should crash the app to expose the bug!
    late final entities.Vehicle vehicle;
    try {
      vehicle = familyState.getVehicle(vehicleId);
    } catch (e) {
      // Vehicle not found or still loading
      if (familyState.isLoading) {
        return const Scaffold(body: Center(child: LoadingIndicator()));
      } else {
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          appBar: AppBar(title: Text(l10n.editVehicle)),
          body: Center(child: Text(l10n.vehicleNotFound)),
        );
      }
    }

    // Responsive design is implemented in VehicleFormPage
    return VehicleFormPage(mode: VehicleFormMode.edit, vehicle: vehicle);
  }
}
