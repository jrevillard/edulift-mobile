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
    _loadChildData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _loadChildData() {
    final familyState = ref.read(familyComposedProvider);
    _child = familyState.children.firstWhere(
      (child) => child.id == widget.childId,
      orElse: () => throw Exception('Child not found'),
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
      appBar: AppBar(
        title: Text(l10n.edit),
        centerTitle: true,
        actions: [
          TextButton(
            key: const Key('editChild_save_textButton'),
            onPressed: _isSubmitting ? null : _submitForm,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    l10n.saveChanges,
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
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
                // Header Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.child_care,
                          size: 48,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.newChild,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.childInfoDescription,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

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
                              return 'Name can only contain letters, spaces, hyphens, and apostrophes';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Age Field
                        TextFormField(
                          key: const Key('editChild_age_field'),
                          controller: _ageController,
                          decoration: const InputDecoration(
                            labelText: 'Age (optional)',
                            hintText: 'Enter age',
                            prefixIcon: Icon(Icons.cake),
                            border: OutlineInputBorder(),
                            suffixText: 'years',
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

                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    key: const Key('save_changes_button'),
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(l10n.saving),
                            ],
                          )
                        : Text(
                            l10n.save,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Cancel Button
                SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    key: const Key('editChild_cancel_button'),
                    onPressed: _isSubmitting ? null : () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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
            content: Text(
              () {
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
              }(),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else {
        // Operation completed without error - show success and navigate
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.childUpdatedSuccessfully),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate back to family page
        context.pop();
      }
    }
  }
}
