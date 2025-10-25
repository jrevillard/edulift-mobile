import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:edulift/core/presentation/themes/app_colors.dart';
import 'package:edulift/core/domain/entities/family.dart';

// COMPOSITION ROOT: Import ONLY from feature-level composition root
import '../../providers.dart';
import '../utils/vehicle_form_mode.dart';
import '../utils/vehicle_form_validator.dart';
import '../utils/vehicle_validation_localizer.dart';
import 'package:edulift/core/navigation/navigation_state.dart' as nav;

/// Unified vehicle form page for both add and edit operations
class VehicleFormPage extends ConsumerStatefulWidget {
  final VehicleFormMode mode;
  final Vehicle? vehicle;

  const VehicleFormPage({super.key, required this.mode, this.vehicle});

  @override
  ConsumerState<VehicleFormPage> createState() => _VehicleFormPageState();
}

class _VehicleFormPageState extends ConsumerState<VehicleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _descriptionController = TextEditingController();
  late final _focusNode = FocusNode();

  // Local form state (replaces VehicleFormProvider)
  bool _isSubmitting = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    // Initialize form fields if editing
    if (widget.mode.isEdit && widget.vehicle != null) {
      _populateFields(widget.vehicle!);
    }

    // CRITICAL FIX: Clear navigation state after page is displayed
    // Prevents "Navigation already processing" error on subsequent FAB clicks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(nav.navigationStateProvider.notifier).clearNavigation();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _populateFields(Vehicle vehicle) {
    _nameController.text = vehicle.name;
    _capacityController.text = vehicle.capacity.toString();
    _descriptionController.text = vehicle.description ?? '';
  }

  // Clean validation using extension method - no manual ARB mapping needed
  String? _validateName(String? value) {
    final error = VehicleFormValidator.validateName(value);
    if (error == null) return null;
    return error.toLocalizedMessage(AppLocalizations.of(context));
  }

  String? _validateCapacity(String? value) {
    final error = VehicleFormValidator.validateCapacity(value);
    if (error == null) return null;
    return error.toLocalizedMessage(AppLocalizations.of(context));
  }

  String? _validateDescription(String? value) {
    final error = VehicleFormValidator.validateDescription(value);
    if (error == null) return null;
    return error.toLocalizedMessage(AppLocalizations.of(context));
  }

  @override
  Widget build(BuildContext context) {
    // Responsive design detection
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode.title(context)),
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfoSection(isTablet, isSmallScreen),
                    SizedBox(height: isTablet ? 32 : 24),
                    _buildCapacityInfoSection(isTablet, isSmallScreen),
                    if (_formError != null) ...[
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      _buildErrorWidget(
                        _formError!,
                        () => setState(() => _formError = null),
                        isTablet,
                        isSmallScreen,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _buildActionButtons(isTablet, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(
    String message,
    VoidCallback onDismiss,
    bool isTablet,
    bool isSmallScreen,
  ) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      elevation: isTablet ? 4 : 2,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 16.0 : 12.0),
        child: Row(
          children: [
            Icon(
              Icons.error,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(bool isTablet, bool isSmallScreen) {
    final l10n = AppLocalizations.of(context);
    return Card(
      elevation: isTablet ? 4 : 2,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.basicInformation,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: isTablet ? 18 : null,
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            TextFormField(
              key: const Key('vehicle_name_field'),
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.vehicleName,
                hintText: l10n.enterVehicleName,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.directions_car),
              ),
              validator: _validateName,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.description,
                hintText: l10n.optionalDescription,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              validator: _validateDescription,
              textInputAction: TextInputAction.next,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapacityInfoSection(bool isTablet, bool isSmallScreen) {
    final l10n = AppLocalizations.of(context);
    return Card(
      elevation: isTablet ? 4 : 2,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.capacityInformation,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: isTablet ? 18 : null,
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            TextFormField(
              key: const Key('vehicle_capacity_field'),
              controller: _capacityController,
              decoration: InputDecoration(
                labelText: l10n.totalSeatsHint,
                hintText: l10n.enterTotalSeats,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.airline_seat_recline_normal),
                suffixText: l10n.seats,
              ),
              keyboardType: TextInputType.number,
              validator: _validateCapacity,
              textInputAction: TextInputAction.done,
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            Container(
              padding: EdgeInsets.all(isTablet ? 16.0 : 12.0),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Expanded(
                    child: Text(
                      l10n.capacityHelpText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isTablet, bool isSmallScreen) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : () => context.pop(),
                child: Text(l10n.cancel),
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                key: Key(
                  '${widget.mode.isEdit ? 'update' : 'create'}_vehicle_button',
                ),
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              widget.mode.isEdit
                                  ? l10n.updating
                                  : l10n.creating,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.mode.isEdit ? Icons.update : Icons.add,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              widget.mode.isEdit
                                  ? l10n.updateVehicle
                                  : l10n.saveVehicle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _formError = null;
    });

    try {
      final capacity = int.parse(_capacityController.text);
      final description = _descriptionController.text.trim();

      if (widget.mode.isEdit) {
        // Update existing vehicle
        await ref
            .read(familyComposedProvider.notifier)
            .updateVehicle(
              vehicleId: widget.vehicle!.id,
              name: _nameController.text.trim(),
              capacity: capacity,
              description: description.isEmpty ? null : description,
            );
      } else {
        // Create new vehicle
        await ref
            .read(familyComposedProvider.notifier)
            .addVehicle(
              name: _nameController.text.trim(),
              capacity: capacity,
              description: description.isEmpty ? null : description,
            );
      }

      // Check for errors after operation
      final familyState = ref.read(familyComposedProvider);
      if (familyState.error != null) {
        setState(() => _formError = familyState.error);
      } else {
        // Success - navigate back
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.mode.isEdit
                    ? l10n.vehicleUpdatedSuccessfully
                    : l10n.vehicleAddedSuccessfully,
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          context.pop();
        }
      }
    } catch (e) {
      setState(() => _formError = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
