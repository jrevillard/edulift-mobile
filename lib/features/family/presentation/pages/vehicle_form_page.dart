import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:edulift/core/domain/entities/family.dart';

// COMPOSITION ROOT: Import ONLY from feature-level composition root
import '../../providers.dart';
import '../utils/vehicle_form_mode.dart';
import '../utils/vehicle_form_validator.dart';
import '../utils/vehicle_validation_localizer.dart';
import 'package:edulift/core/navigation/navigation_state.dart' as nav;
import '../../../../core/presentation/utils/responsive_breakpoints.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode.title(context)),
        actions: [
          if (_isSubmitting)
            Padding(
              padding: context.getAdaptivePadding(
                mobileAll: 12,
                tabletAll: 16,
                desktopAll: 20,
              ),
              child: SizedBox(
                width: context.getAdaptiveIconSize(
                  mobile: 18,
                  tablet: 20,
                  desktop: 22,
                ),
                height: context.getAdaptiveIconSize(
                  mobile: 18,
                  tablet: 20,
                  desktop: 22,
                ),
                child: const CircularProgressIndicator(strokeWidth: 2),
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
                padding: context.getAdaptivePadding(
                  mobileAll: 16,
                  tabletAll: 24,
                  desktopAll: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfoSection(),
                    SizedBox(
                      height: context.getAdaptiveSpacing(
                        mobile: 24,
                        tablet: 32,
                        desktop: 40,
                      ),
                    ),
                    _buildCapacityInfoSection(),
                    if (_formError != null) ...[
                      SizedBox(
                        height: context.getAdaptiveSpacing(
                          mobile: 12,
                          tablet: 16,
                          desktop: 20,
                        ),
                      ),
                      _buildErrorWidget(_formError!),
                    ],
                  ],
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message, [VoidCallback? onDismiss]) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      elevation: context.isTabletOrLarger ? 4 : 2,
      child: Padding(
        padding: context.getAdaptivePadding(
          mobileAll: 12,
          tabletAll: 16,
          desktopAll: 20,
        ),
        child: Row(
          children: [
            Icon(
              Icons.error,
              color: Theme.of(context).colorScheme.onErrorContainer,
              size: context.getAdaptiveIconSize(
                mobile: 20,
                tablet: 22,
                desktop: 24,
              ),
            ),
            SizedBox(
              width: context.getAdaptiveSpacing(
                mobile: 8,
                tablet: 12,
                desktop: 16,
              ),
            ),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                ),
              ),
            ),
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.onErrorContainer,
                size: context.getAdaptiveIconSize(
                  mobile: 20,
                  tablet: 22,
                  desktop: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    final l10n = AppLocalizations.of(context);
    return Card(
      elevation: context.isTabletOrLarger ? 4 : 2,
      child: Padding(
        padding: context.getAdaptivePadding(
          mobileAll: 16,
          tabletAll: 20,
          desktopAll: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.basicInformation,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: context.isTabletOrLarger ? 18 : null,
              ),
            ),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
            ),
            TextFormField(
              key: const Key('vehicle_name_field'),
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.vehicleName,
                hintText: l10n.enterVehicleName,
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.directions_car,
                  size: context.getAdaptiveIconSize(
                    mobile: 20,
                    tablet: 22,
                    desktop: 24,
                  ),
                ),
                contentPadding: context.getAdaptivePadding(
                  mobileHorizontal: 16,
                  mobileVertical: 12,
                  tabletHorizontal: 20,
                  tabletVertical: 14,
                  desktopHorizontal: 24,
                  desktopVertical: 16,
                ),
              ),
              validator: _validateName,
              textInputAction: TextInputAction.next,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
              ),
            ),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.description,
                hintText: l10n.optionalDescription,
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.notes,
                  size: context.getAdaptiveIconSize(
                    mobile: 20,
                    tablet: 22,
                    desktop: 24,
                  ),
                ),
                alignLabelWithHint: true,
                contentPadding: context.getAdaptivePadding(
                  mobileHorizontal: 16,
                  mobileVertical: 12,
                  tabletHorizontal: 20,
                  tabletVertical: 14,
                  desktopHorizontal: 24,
                  desktopVertical: 16,
                ),
              ),
              maxLines: 3,
              validator: _validateDescription,
              textInputAction: TextInputAction.next,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapacityInfoSection() {
    final l10n = AppLocalizations.of(context);
    return Card(
      elevation: context.isTabletOrLarger ? 4 : 2,
      child: Padding(
        padding: context.getAdaptivePadding(
          mobileAll: 16,
          tabletAll: 20,
          desktopAll: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.capacityInformation,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: context.isTabletOrLarger ? 18 : null,
              ),
            ),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
            ),
            TextFormField(
              key: const Key('vehicle_capacity_field'),
              controller: _capacityController,
              decoration: InputDecoration(
                labelText: l10n.totalSeatsHint,
                hintText: l10n.enterTotalSeats,
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.airline_seat_recline_normal,
                  size: context.getAdaptiveIconSize(
                    mobile: 20,
                    tablet: 22,
                    desktop: 24,
                  ),
                ),
                suffixText: l10n.seats,
                contentPadding: context.getAdaptivePadding(
                  mobileHorizontal: 16,
                  mobileVertical: 12,
                  tabletHorizontal: 20,
                  tabletVertical: 14,
                  desktopHorizontal: 24,
                  desktopVertical: 16,
                ),
              ),
              keyboardType: TextInputType.number,
              validator: _validateCapacity,
              textInputAction: TextInputAction.done,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
              ),
            ),
            SizedBox(
              height: context.getAdaptiveSpacing(
                mobile: 8,
                tablet: 12,
                desktop: 16,
              ),
            ),
            Container(
              padding: context.getAdaptivePadding(
                mobileAll: 12,
                tabletAll: 16,
                desktopAll: 20,
              ),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(
                  context.getAdaptiveBorderRadius(
                    mobile: 8,
                    tablet: 10,
                    desktop: 12,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: context.getAdaptiveIconSize(
                      mobile: 18,
                      tablet: 20,
                      desktop: 22,
                    ),
                  ),
                  SizedBox(
                    width: context.getAdaptiveSpacing(
                      mobile: 8,
                      tablet: 12,
                      desktop: 16,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      l10n.capacityHelpText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: context.isMobile ? 12 : null,
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

  Widget _buildActionButtons() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: context.getAdaptivePadding(
        mobileAll: 16,
        tabletAll: 20,
        desktopAll: 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.15),
            blurRadius: context.isTabletOrLarger ? 6 : 4,
            offset: Offset(0, context.isTabletOrLarger ? -2 : -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : () => context.pop(),
                style: OutlinedButton.styleFrom(
                  padding: context.getAdaptivePadding(
                    mobileHorizontal: 16,
                    mobileVertical: 12,
                    tabletHorizontal: 20,
                    tabletVertical: 14,
                    desktopHorizontal: 24,
                    desktopVertical: 16,
                  ),
                  minimumSize: Size(
                    double.infinity,
                    context.getAdaptiveButtonHeight(
                      mobile: 44,
                      tablet: 48,
                      desktop: 52,
                    ),
                  ),
                ),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(fontSize: context.isMobile ? 14 : 16),
                ),
              ),
            ),
            SizedBox(
              width: context.getAdaptiveSpacing(
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
            ),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                key: Key(
                  '${widget.mode.isEdit ? 'update' : 'create'}_vehicle_button',
                ),
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: context.getAdaptivePadding(
                    mobileHorizontal: 16,
                    mobileVertical: 12,
                    tabletHorizontal: 20,
                    tabletVertical: 14,
                    desktopHorizontal: 24,
                    desktopVertical: 16,
                  ),
                  minimumSize: Size(
                    double.infinity,
                    context.getAdaptiveButtonHeight(
                      mobile: 44,
                      tablet: 48,
                      desktop: 52,
                    ),
                  ),
                ),
                child: _isSubmitting
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: context.getAdaptiveIconSize(
                              mobile: 14,
                              tablet: 16,
                              desktop: 18,
                            ),
                            height: context.getAdaptiveIconSize(
                              mobile: 14,
                              tablet: 16,
                              desktop: 18,
                            ),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(
                            width: context.getAdaptiveSpacing(
                              mobile: 6,
                              tablet: 8,
                              desktop: 10,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              widget.mode.isEdit
                                  ? l10n.updating
                                  : l10n.creating,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: context.isMobile ? 14 : 16,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.mode.isEdit ? Icons.update : Icons.add,
                            size: context.getAdaptiveIconSize(
                              mobile: 14,
                              tablet: 16,
                              desktop: 18,
                            ),
                          ),
                          SizedBox(
                            width: context.getAdaptiveSpacing(
                              mobile: 6,
                              tablet: 8,
                              desktop: 10,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              widget.mode.isEdit
                                  ? l10n.updateVehicle
                                  : l10n.saveVehicle,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: context.isMobile ? 14 : 16,
                              ),
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
