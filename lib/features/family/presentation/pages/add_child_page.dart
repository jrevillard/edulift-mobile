// EduLift Mobile - Add Child Page
// Form for adding new children with validation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// COMPOSITION ROOT: Import ONLY from feature-level composition root
import '../../providers.dart';
import '../../domain/requests/child_requests.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import 'package:edulift/core/navigation/navigation_state.dart' as nav;
import 'package:edulift/core/presentation/themes/app_colors.dart';
import '../utils/child_form_validator.dart';
import '../utils/child_validation_localizer.dart';
import '../../../../core/presentation/utils/responsive_breakpoints.dart';

class AddChildPage extends ConsumerStatefulWidget {
  const AddChildPage({super.key});

  @override
  ConsumerState<AddChildPage> createState() => _AddChildPageState();
}

class _AddChildPageState extends ConsumerState<AddChildPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // CRITICAL FIX: Clear navigation state after page is displayed
    // Prevents "Navigation already processing" error on subsequent FAB clicks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(nav.navigationStateProvider.notifier).clearNavigation();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive design detection
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;
    final isSmallScreen = screenSize.width < 600;

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).addChild),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          controller: _scrollController,
          padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
          children: [
            // Header card
            _buildHeaderCard(context, theme, isTablet, isSmallScreen),
            SizedBox(height: isSmallScreen ? 8 : 12),

            // Child information
            _buildChildInfoSection(context, theme, isTablet, isSmallScreen),
            SizedBox(height: isTablet ? 40 : 32),

            // Action buttons
            _buildActionButtons(context, theme, isTablet, isSmallScreen),
            SizedBox(height: isSmallScreen ? 12 : 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    ThemeData theme,
    bool isTablet,
    bool isSmallScreen,
  ) {
    return Card(
      elevation: isTablet ? 2 : 1,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 16.0 : 12.0),
        child: Row(
          children: [
            Icon(
              Icons.person_add,
              size: isTablet ? 32 : 28,
              color: theme.colorScheme.primary,
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).newChild,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 18 : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!isSmallScreen) ...[
                    const SizedBox(height: 2),
                    Text(
                      AppLocalizations.of(context).childInfoDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildInfoSection(
    BuildContext context,
    ThemeData theme,
    bool isTablet,
    bool isSmallScreen,
  ) {
    return Card(
      elevation: isTablet ? 4 : 2,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).personalInformation,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 18 : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),

            // Name
            TextFormField(
              key: const ValueKey('child_name_field'),
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).fullName,
                hintText: AppLocalizations.of(context).childNameHint,
                prefixIcon: const Icon(Icons.person_outline),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                final error = ChildFormValidator.validateName(value);
                if (error != null) {
                  return error.toLocalizedMessage(AppLocalizations.of(context));
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),

            // Age (Optional)
            TextFormField(
              key: const ValueKey('child_age_field'),
              controller: _ageController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).childAgeOptional,
                hintText: AppLocalizations.of(context).enterChildAge,
                prefixIcon: const Icon(Icons.cake),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                final error = ChildFormValidator.validateAge(value);
                if (error != null) {
                  return error.toLocalizedMessage(AppLocalizations.of(context));
                }
                return null;
              },
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ThemeData theme,
    bool isTablet,
    bool isSmallScreen,
  ) {
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
                key: const ValueKey('save_child_button'),
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
                              l10n.saving,
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
                            Icons.person_add,
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
                              l10n.addChild,
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
    setState(() {
      _isSubmitting = true;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = false;
      });

      // Scroll to first error
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    final age = _ageController.text.trim().isNotEmpty
        ? int.tryParse(_ageController.text.trim())
        : null;

    final request = CreateChildRequest(
      name: _nameController.text.trim(),
      age: age,
    );

    // Submit to family provider
    await ref.read(familyComposedProvider.notifier).addChild(request);

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).childAddedSuccessfully(_nameController.text.trim()),
            ),
            backgroundColor: AppColors.successThemed(context),
          ),
        );

        context.pop();
      }
    }
  }
}
