// EduLift Mobile - Edit Child Page
// Form for editing existing children with validation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// COMPOSITION ROOT: Import ONLY from feature-level composition root
import '../../providers.dart';
import '../../domain/requests/child_requests.dart';
import 'package:edulift/core/domain/entities/family.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:edulift/core/presentation/themes/app_colors.dart';
import '../../../../core/presentation/utils/responsive_breakpoints.dart';

class EditChildPage extends ConsumerStatefulWidget {
  final String childId;

  const EditChildPage({super.key, required this.childId});

  @override
  ConsumerState<EditChildPage> createState() => _EditChildPageState();
}

class _EditChildPageState extends ConsumerState<EditChildPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  bool _isSubmitting = false;
  bool _isLoading = true;
  Child? _child;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _loadChildData();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _loadChildData() {
    final l10n = AppLocalizations.of(context);
    final familyState = ref.read(familyComposedProvider);
    _child = familyState.children.firstWhere(
      (child) => child.id == widget.childId,
      orElse: () => throw Exception(l10n.childNotFound),
    );

    // Pre-populate form fields
    _nameController.text = _child!.name;
    _ageController.text = _child!.age?.toString() ?? '';

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.edit), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.edit), centerTitle: true),
      body: Form(
        key: _formKey,
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section - aligned with AddChildPage
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.child_care,
                          size: 28,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.newChild,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                l10n.childInfoDescription,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Form Fields
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.personalInformation,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Name Field
                        TextFormField(
                          key: const Key('editChild_name_field'),
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: l10n.fullName,
                            hintText: l10n.childNameHint,
                            prefixIcon: const Icon(Icons.person),
                            border: const OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.firstNameRequired;
                            }
                            if (value.trim().length < 2) {
                              return l10n.nameMinLength;
                            }
                            // Validate name format - only letters, spaces, hyphens, and apostrophes
                            final nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ\s\-']+$");
                            if (!nameRegex.hasMatch(value.trim())) {
                              return l10n.childNameInvalidCharacters;
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Age Field
                        TextFormField(
                          key: const Key('editChild_age_field'),
                          controller: _ageController,
                          decoration: InputDecoration(
                            labelText: l10n.childAgeOptional,
                            hintText: l10n.enterChildAge,
                            prefixIcon: const Icon(Icons.cake),
                            border: const OutlineInputBorder(),
                            suffixText: l10n.years,
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final age = int.tryParse(value);
                              if (age == null) {
                                return l10n.pleaseEnterValidNumber;
                              }
                              if (age < 0 || age > 25) {
                                return l10n.pleaseEnterValidNumber;
                              }
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _submitForm(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Action buttons - consistent with other forms
                Container(
                  padding: context.getAdaptivePadding(
                    mobileAll: 16,
                    tabletAll: 20,
                    desktopAll: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).shadowColor.withValues(alpha: 0.15),
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
                            onPressed: _isSubmitting
                                ? null
                                : () => context.pop(),
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
                              style: TextStyle(
                                fontSize: context.isMobile ? 14 : 16,
                              ),
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
                            key: const Key('save_changes_button'),
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
                                          l10n.updating,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: context.isMobile
                                                ? 14
                                                : 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.save,
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
                                          l10n.save,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: context.isMobile
                                                ? 14
                                                : 16,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      // Scroll to first error if validation fails
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Create update request
    final updateRequest = UpdateChildRequest(
      name: _nameController.text.trim(),
      age: _ageController.text.isNotEmpty
          ? int.parse(_ageController.text)
          : null,
    );

    // Submit to family provider
    await ref
        .read(familyComposedProvider.notifier)
        .updateChild(widget.childId, updateRequest);

    if (mounted) {
      // Check the state after the operation
      final currentState = ref.read(familyComposedProvider);

      setState(() {
        _isSubmitting = false;
      });

      // Check if there's an error in the provider state
      if (currentState.error != null && currentState.error!.isNotEmpty) {
        // Show error message from API
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(() {
              final errorKey = currentState.error ?? 'errorGeneral';
              switch (errorKey) {
                case 'errorNetwork':
                case 'errorNetworkGeneral':
                  return AppLocalizations.of(context).errorNetworkMessage;
                case 'errorServer':
                case 'errorServerGeneral':
                  return AppLocalizations.of(context).errorServerMessage;
                case 'errorAuth':
                  return AppLocalizations.of(context).errorAuthMessage;
                case 'errorValidation':
                  return AppLocalizations.of(context).errorValidationMessage;
                default:
                  return AppLocalizations.of(context).errorUnexpectedMessage;
              }
            }()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else {
        // Operation completed without error - show success and navigate
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.childUpdatedSuccessfully),
            backgroundColor: AppColors.successThemed(context),
          ),
        );

        // Navigate back to family page
        context.pop();
      }
    }
  }
}
