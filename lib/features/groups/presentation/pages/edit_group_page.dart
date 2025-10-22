import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/presentation/utils/responsive_breakpoints.dart';
import '../../providers.dart';

/// Mobile-first page for editing group name and description
class EditGroupPage extends ConsumerStatefulWidget {
  final String groupId;
  final String currentName;
  final String? currentDescription;

  const EditGroupPage({
    super.key,
    required this.groupId,
    required this.currentName,
    this.currentDescription,
  });

  @override
  ConsumerState<EditGroupPage> createState() => _EditGroupPageState();
}

class _EditGroupPageState extends ConsumerState<EditGroupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.currentName;
    _descriptionController.text = widget.currentDescription ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      await ref.read(groupsComposedProvider.notifier).updateGroup(
        widget.groupId,
        {
          'name': name,
          'description': description.isEmpty ? null : description,
        },
      );
      // updateGroup() already calls loadUserGroups() internally
      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleCancel() {
    if (!_isLoading) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isTablet = context.isTablet;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('editGroup_back_button'),
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : _handleCancel,
        ),
        title: Text(l10n.editGroup),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: context.getAdaptivePadding(
            mobileHorizontal: 16,
            mobileVertical: 16,
            tabletHorizontal: 24,
            tabletVertical: 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Group Name Field
                TextFormField(
                  key: const Key('editGroup_name_field'),
                  controller: _nameController,
                  enabled: !_isLoading,
                  style: TextStyle(
                    fontSize: (isTablet ? 18 : 16) * context.fontScale,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.groupName,
                    hintText: l10n.enterGroupName,
                    prefixIcon: Icon(
                      Icons.label_outline,
                      size: context.getAdaptiveIconSize(
                        mobile: 24,
                        tablet: 26,
                        desktop: 28,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        isTablet ? 12 : 8,
                      ),
                    ),
                    contentPadding: context.getAdaptivePadding(
                      mobileHorizontal: 16,
                      mobileVertical: 12,
                      tabletHorizontal: 20,
                      tabletVertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.groupNameRequired;
                    }
                    if (value.trim().length < 3) {
                      return l10n.groupNameMinLength;
                    }
                    if (value.trim().length > 50) {
                      return l10n.groupNameMaxLength;
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),

                const SizedBox(height: 16),

                // Group Description Field
                TextFormField(
                  key: const Key('editGroup_description_field'),
                  controller: _descriptionController,
                  enabled: !_isLoading,
                  style: TextStyle(
                    fontSize: (isTablet ? 18 : 16) * context.fontScale,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.groupDescription,
                    // Note: Original dialog had hardcoded English text, omitting hint for now
                    prefixIcon: Icon(
                      Icons.description_outlined,
                      size: context.getAdaptiveIconSize(
                        mobile: 24,
                        tablet: 26,
                        desktop: 28,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        isTablet ? 12 : 8,
                      ),
                    ),
                    contentPadding: context.getAdaptivePadding(
                      mobileHorizontal: 16,
                      mobileVertical: 12,
                      tabletHorizontal: 20,
                      tabletVertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.trim().length > 500) {
                      return l10n.groupDescriptionMaxLength;
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  maxLength: 500,
                ),

                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .error
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        key: const Key('editGroup_cancel_button'),
                        onPressed: _isLoading ? null : _handleCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        key: const Key('editGroup_submit_button'),
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.onPrimary),
                                ),
                              )
                            : Text(l10n.save),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
