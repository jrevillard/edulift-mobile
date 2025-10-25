// EduLift Mobile - Create Group Page
// Following established patterns from CreateFamilyPage for mobile-first design

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/navigation/navigation_state.dart';
import '../../providers.dart';
import '../utils/groups_error_translation_helper.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/presentation/mixins/navigation_cleanup_mixin.dart';
import '../../../../core/presentation/utils/responsive_breakpoints.dart';

class CreateGroupPage extends ConsumerStatefulWidget {
  const CreateGroupPage({super.key});

  @override
  ConsumerState<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends ConsumerState<CreateGroupPage>
    with NavigationCleanupMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Navigate back to groups page with proper state cleanup
  void _navigateBackToGroups() {
    // Clear pending navigation state to prevent automatic redirection
    ref.read(navigationStateProvider.notifier).clearNavigation();

    // Navigate back to groups page
    ref
        .read(navigationStateProvider.notifier)
        .navigateTo(
          route: '/groups',
          trigger: NavigationTrigger.userNavigation,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(groupsComposedProvider);

    // Listen for successful creation and navigate
    ref.listen(groupsComposedProvider, (previous, current) {
      if (current.isCreateSuccess && mounted) {
        // Group creation succeeded - clear previous navigation and navigate back to groups
        ref.read(navigationStateProvider.notifier).clearNavigation();
        ref
            .read(navigationStateProvider.notifier)
            .navigateTo(
              route: '/groups',
              trigger: NavigationTrigger.userNavigation,
            );
        // Reset success flag to prevent rebuild loops after navigation
        ref.read(groupsComposedProvider.notifier).resetCreateSuccess();
      }
      if (current.createError != null && current.createError!.isNotEmpty) {
        // Show error in snackbar for better user feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              GroupsErrorTranslationHelper.translateError(
                l10n,
                current.createError!,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.createGroup),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          key: const Key('createGroup_back_button'),
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateBackToGroups,
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Use established responsive utilities
            final isTablet = context.isTablet;
            final isDesktop = context.isDesktop;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      constraints.maxHeight -
                      MediaQuery.of(context).viewInsets.bottom,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: context.getAdaptivePadding(
                      mobileHorizontal: 16,
                      tabletHorizontal: 24,
                      desktopHorizontal: 32,
                      mobileVertical: 16,
                      tabletVertical: 24,
                      desktopVertical: 32,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Section
                          SizedBox(
                            height: context.getAdaptiveSpacing(
                              mobile: 8,
                              tablet: 16,
                              desktop: 20,
                            ),
                          ),
                          Text(
                            l10n.createNewGroup,
                            key: const Key('create_new_group_header'),
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: context.getAdaptiveSpacing(
                              mobile: 4,
                              tablet: 8,
                              desktop: 12,
                            ),
                          ),
                          Text(
                            l10n.createTransportGroupDescription,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          SizedBox(
                            height: context.getAdaptiveSpacing(
                              mobile: 16,
                              tablet: 32,
                              desktop: 40,
                            ),
                          ),

                          // Group Name Field
                          Text(
                            l10n.groupName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: context.getAdaptiveSpacing(
                              mobile: 4,
                              tablet: 8,
                              desktop: 12,
                            ),
                          ),
                          Semantics(
                            label: l10n.groupName,
                            child: TextFormField(
                              key: const Key('createGroup_name_field'),
                              controller: _nameController,
                              onChanged: (_) {
                                // Clear error when user starts typing
                                if (state.createError != null) {
                                  ref
                                      .read(groupsComposedProvider.notifier)
                                      .clearCreateError();
                                }
                              },
                              decoration: InputDecoration(
                                hintText: l10n.enterGroupName,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.groupNameRequired;
                                }
                                if (value.trim().length < 2) {
                                  return l10n.nameTooShort;
                                }
                                if (value.trim().length > 50) {
                                  return l10n.groupNameMaxLength;
                                }
                                return null;
                              },
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                          SizedBox(
                            height: context.getAdaptiveSpacing(
                              mobile: 12,
                              tablet: 24,
                              desktop: 32,
                            ),
                          ),

                          // Error Display removed - using SnackBar only for better UX

                          // Flexible spacer that adapts to content
                          if (!isTablet && !isDesktop) const Spacer(),
                          if (isTablet || isDesktop)
                            const SizedBox(height: 16.0),

                          // Action Buttons - Responsive layout
                          if (context.isMobile)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Semantics(
                                  label: l10n.createGroup,
                                  child: ElevatedButton(
                                    key: const Key('createGroup_submit_button'),
                                    onPressed: state.isLoading
                                        ? null
                                        : _handleCreateGroup,
                                    style: ElevatedButton.styleFrom(
                                      padding: context.getAdaptivePadding(
                                        mobileVertical: 16,
                                        tabletVertical: 18,
                                        desktopVertical: 20,
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
                                              Text(l10n.creating),
                                            ],
                                          )
                                        : Text(l10n.createGroup),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Semantics(
                                  label: l10n.cancel,
                                  child: OutlinedButton(
                                    key: const Key('createGroup_cancel_button'),
                                    onPressed: state.isLoading
                                        ? null
                                        : _navigateBackToGroups,
                                    style: OutlinedButton.styleFrom(
                                      padding: context.getAdaptivePadding(
                                        mobileVertical: 16,
                                        tabletVertical: 18,
                                        desktopVertical: 20,
                                      ),
                                    ),
                                    child: Text(l10n.cancel),
                                  ),
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: Semantics(
                                    label: l10n.cancel,
                                    child: OutlinedButton(
                                      key: const Key(
                                        'createGroup_cancel_button',
                                      ),
                                      onPressed: state.isLoading
                                          ? null
                                          : _navigateBackToGroups,
                                      style: OutlinedButton.styleFrom(
                                        padding: context.getAdaptivePadding(
                                          mobileVertical: 16,
                                          tabletVertical: 18,
                                          desktopVertical: 20,
                                        ),
                                      ),
                                      child: Text(l10n.cancel),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: Semantics(
                                    label: l10n.createGroup,
                                    child: ElevatedButton(
                                      key: const Key(
                                        'createGroup_submit_button',
                                      ),
                                      onPressed: state.isLoading
                                          ? null
                                          : _handleCreateGroup,
                                      style: ElevatedButton.styleFrom(
                                        padding: context.getAdaptivePadding(
                                          mobileVertical: 16,
                                          tabletVertical: 18,
                                          desktopVertical: 20,
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
                                                Text(l10n.creating),
                                              ],
                                            )
                                          : Text(l10n.createGroup),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(
                            height: context.getAdaptiveSpacing(
                              mobile: 16,
                              tablet: 24,
                              desktop: 32,
                            ),
                          ),
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

  /// Handle form submission and group creation
  void _handleCreateGroup() {
    // Clear any previous errors
    ref.read(groupsComposedProvider.notifier).clearCreateError();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Call provider to create group
    final groupName = _nameController.text.trim();
    ref.read(groupsComposedProvider.notifier).createGroup(groupName);
  }
}
