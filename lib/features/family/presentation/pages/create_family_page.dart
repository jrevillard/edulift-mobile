// TDD London School - CREATE FAMILY PAGE (GREEN PHASE)
// Following established patterns from AddChildPage and FamilyInvitationPage

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/navigation/navigation_state.dart';
// ARCHITECTURE FIX: Use composition root instead
import '../../providers.dart';
// Import state classes for type annotations
import '../providers/create_family_provider.dart' show CreateFamilyState;
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/presentation/mixins/navigation_cleanup_mixin.dart';

class CreateFamilyPage extends ConsumerStatefulWidget {
  const CreateFamilyPage({super.key});

  @override
  ConsumerState<CreateFamilyPage> createState() => _CreateFamilyPageState();
}

class _CreateFamilyPageState extends ConsumerState<CreateFamilyPage>
    with NavigationCleanupMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Navigate back to onboarding wizard with proper state cleanup
  void _navigateBackToOnboarding() {
    // Clear pending navigation state to prevent automatic redirection
    ref.read(navigationStateProvider.notifier).clearNavigation();

    // Navigate back to onboarding wizard
    ref.read(navigationStateProvider.notifier).navigateTo(
          route: '/onboarding/wizard',
          trigger: NavigationTrigger.userNavigation,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(createFamilyComposedProvider);

    // Listen for successful creation and navigate
    ref.listen<CreateFamilyState>(createFamilyComposedProvider, (
      previous,
      current,
    ) {
      if (current.isSuccess && mounted) {
        // Family creation succeeded - clear previous navigation and navigate to dashboard
        ref.read(navigationStateProvider.notifier).clearNavigation();
        ref.read(navigationStateProvider.notifier).navigateTo(
              route: '/dashboard',
              trigger: NavigationTrigger.userNavigation,
            );
        // Reset provider state to prevent rebuild loops after navigation
        ref.read(createFamilyComposedProvider.notifier).resetState();
      }
      if (current.error != null && current.error!.isNotEmpty) {
        // Show error in snackbar for better user feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(() {
              final errorKey = current.error ?? 'errorGeneral';
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
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).createYourFamily),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          key: const Key('createFamily_back_button'),
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateBackToOnboarding,
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxHeight < 600;
            final isNarrow = constraints.maxWidth < 400;
            final screenPadding = isNarrow ? 16.0 : 24.0;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight -
                      MediaQuery.of(context).viewInsets.bottom,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.all(screenPadding),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Section
                          SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                          Text(
                            AppLocalizations.of(context).createFamily,
                            key: const Key('create_your_family_header'),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: isSmallScreen ? 4.0 : 8.0),
                          Text(
                            'Set up your family to start coordinating transportation with other families.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          SizedBox(height: isSmallScreen ? 16.0 : 32.0),

                          // Family Name Field
                          Text(
                            'Family Name',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: isSmallScreen ? 4.0 : 8.0),
                          Semantics(
                            label: l10n.familyNameInputFieldLabel,
                            child: TextFormField(
                              key: const Key('familyNameField'),
                              controller: _nameController,
                              onChanged: (_) {
                                // Clear error when user starts typing
                                if (state.error != null) {
                                  ref
                                      .read(
                                        createFamilyComposedProvider.notifier,
                                      )
                                      .clearError();
                                }
                              },
                              decoration: InputDecoration(
                                hintText: l10n.enterFamilyNameHint,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.familyNameCannotBeEmpty;
                                }
                                if (value.trim().length < 2) {
                                  return l10n.familyNameTooShortValidation;
                                }
                                return null;
                              },
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 12.0 : 24.0),

                          // Description Field
                          Text(
                            'Description (Optional)',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: isSmallScreen ? 4.0 : 8.0),
                          Semantics(
                            label: l10n.familyDescriptionInputFieldLabel,
                            child: TextFormField(
                              key: const Key('createFamily_description_field'),
                              controller: _descriptionController,
                              onChanged: (_) {
                                // Clear error when user starts typing
                                if (state.error != null) {
                                  ref
                                      .read(
                                        createFamilyComposedProvider.notifier,
                                      )
                                      .clearError();
                                }
                              },
                              decoration: InputDecoration(
                                hintText: l10n.describeFamilyOptionalHint,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              maxLines: isSmallScreen ? 2 : 3,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 16.0 : 32.0),

                          // Error Display removed - using SnackBar only for better UX

                          // Flexible spacer that adapts to content
                          if (!isSmallScreen) const Spacer(),
                          if (isSmallScreen) const SizedBox(height: 16.0),

                          // Action Buttons - Responsive layout
                          if (isNarrow)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Semantics(
                                  label: l10n.createFamilyButtonLabel,
                                  child: ElevatedButton(
                                    key: const Key(
                                      'submit_create_family_button',
                                    ),
                                    onPressed: state.isLoading
                                        ? null
                                        : _handleCreateFamily,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                    child: state.isLoading
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                AppLocalizations.of(
                                                  context,
                                                ).creating,
                                              ),
                                            ],
                                          )
                                        : Text(
                                            AppLocalizations.of(
                                              context,
                                            ).createFamily,
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Semantics(
                                  label: l10n.cancelButtonLabel,
                                  child: OutlinedButton(
                                    key: const Key(
                                      'cancelFamilyCreationButton',
                                    ),
                                    onPressed: state.isLoading
                                        ? null
                                        : _navigateBackToOnboarding,
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context).cancel,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: Semantics(
                                    label: l10n.cancelButtonLabel,
                                    child: OutlinedButton(
                                      key: const Key(
                                        'cancelFamilyCreationButton',
                                      ),
                                      onPressed: state.isLoading
                                          ? null
                                          : _navigateBackToOnboarding,
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context).cancel,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: Semantics(
                                    label: l10n.createFamilyButtonLabel,
                                    child: ElevatedButton(
                                      key: const Key(
                                        'submit_create_family_button',
                                      ),
                                      onPressed: state.isLoading
                                          ? null
                                          : _handleCreateFamily,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                      ),
                                      child: state.isLoading
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  ).creating,
                                                ),
                                              ],
                                            )
                                          : Text(
                                              AppLocalizations.of(
                                                context,
                                              ).createFamily,
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: isSmallScreen ? 16.0 : 24.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Handle form submission and family creation
  /// TDD Green: Implements the behavior tested in RED phase
  void _handleCreateFamily() {
    // Clear any previous errors
    ref.read(createFamilyComposedProvider.notifier).clearError();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Call provider to create family
    final familyName = _nameController.text.trim();
    ref.read(createFamilyComposedProvider.notifier).createFamily(familyName);
  }
}
