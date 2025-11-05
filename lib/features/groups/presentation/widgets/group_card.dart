import 'package:flutter/material.dart';
import 'package:edulift/generated/l10n/app_localizations.dart';
import '../../../../core/domain/entities/groups/group.dart';
import '../../../../core/presentation/utils/responsive_breakpoints.dart';
import '../../../../core/presentation/themes/app_colors.dart';

class GroupCard extends StatelessWidget {
  final dynamic group; // Can be Group entity or group model
  final VoidCallback onSelect;
  final VoidCallback onManage;

  const GroupCard({
    super.key,
    required this.group,
    required this.onSelect,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = context.isTablet;

    // Extract properties safely from dynamic group object
    // Extract group ID (currently unused but needed for future features)
    _getProperty('id') ?? '';
    final groupName = _getProperty('name') ?? 'Unnamed Group';
    final userRole =
        (_getProperty('userRole') as GroupMemberRole?)?.displayName ?? 'Member';
    final familyCount =
        _getProperty('familyCount') ?? _getProperty('memberCount') ?? 0;
    final String? description = _getProperty('description');

    return Card(
      elevation: isTablet ? 3 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      ),
      child: InkWell(
        key: Key('groupCard_inkwell_${_getProperty('id')}'),
        onTap: onSelect,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        child: Padding(
          padding: context.getAdaptivePadding(
            mobileHorizontal: 16,
            mobileVertical: 16,
            tabletHorizontal: 20,
            tabletVertical: 18,
            desktopHorizontal: 24,
            desktopVertical: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with group icon and role
              // Use a layout that adapts to small screens
              if (MediaQuery.of(context).size.width < 120)
                // Very small screen - stack elements vertically with compact layout
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32, // Smaller for very small screens
                      height: 32, // Smaller for very small screens
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.groups,
                        color: theme.colorScheme.primary,
                        size: 18, // Smaller icon
                      ),
                    ),
                    const SizedBox(height: 2), // Minimal spacing
                    Center(child: _buildRoleBadge(userRole, theme, context)),
                  ],
                )
              else
                // Normal screen - use horizontal layout with flexible width
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        width: context.getAdaptiveIconSize(
                          mobile: 40,
                          tablet: 48,
                          desktop: 52,
                        ),
                        height: context.getAdaptiveIconSize(
                          mobile: 40,
                          tablet: 48,
                          desktop: 52,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(
                            context.getAdaptiveIconSize(
                              mobile: 8,
                              tablet: 10,
                              desktop: 12,
                            ),
                          ),
                        ),
                        child: Icon(
                          Icons.groups,
                          color: theme.colorScheme.primary,
                          size: context.getAdaptiveIconSize(
                            mobile: 24,
                            tablet: 28,
                            desktop: 32,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Flexible(child: _buildRoleBadge(userRole, theme, context)),
                  ],
                ),

              SizedBox(
                height: context.getAdaptiveSpacing(
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                ),
              ),

              // Group name
              Text(
                groupName,
                style:
                    (isTablet
                            ? theme.textTheme.titleLarge
                            : theme.textTheme.titleMedium)
                        ?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize:
                              (MediaQuery.of(context).size.width < 120
                                  ? 12 // Very small text for tiny screens
                                  : (isTablet ? 20 : 18)) *
                              context.fontScale,
                        ),
                maxLines: MediaQuery.of(context).size.width < 120 ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(
                height: MediaQuery.of(context).size.width < 120
                    ? 2 // Minimal spacing for tiny screens
                    : context.getAdaptiveSpacing(
                        mobile: 8,
                        tablet: 10,
                        desktop: 12,
                      ),
              ),

              // Description or member count
              if (MediaQuery.of(context).size.width < 120)
                // Very compact display for tiny screens
                Text(
                  '$familyCount',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryThemed(context),
                    fontSize: 10, // Very small text
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              else if (description != null && description.isNotEmpty)
                Text(
                  description,
                  style:
                      (isTablet
                              ? theme.textTheme.bodyMedium
                              : theme.textTheme.bodySmall)
                          ?.copyWith(
                            color: AppColors.textSecondaryThemed(context),
                            fontSize: (isTablet ? 16 : 14) * context.fontScale,
                          ),
                  maxLines: isTablet ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                )
              else
                Text(
                  '$familyCount ${familyCount == 1 ? 'family' : 'families'}',
                  style:
                      (isTablet
                              ? theme.textTheme.bodyMedium
                              : theme.textTheme.bodySmall)
                          ?.copyWith(
                            color: AppColors.textSecondaryThemed(context),
                            fontSize: (isTablet ? 16 : 14) * context.fontScale,
                          ),
                ),

              SizedBox(
                height: MediaQuery.of(context).size.width < 120
                    ? 4 // Reduced spacing for tiny screens
                    : context.getAdaptiveSpacing(
                        mobile: 16,
                        tablet: 20,
                        desktop: 24,
                      ),
              ),

              // Action buttons
              Row(
                children: [
                  const Expanded(child: SizedBox.shrink()),
                  if (_canManage(userRole))
                    IconButton(
                      key: Key('groupCard_manage_${_getProperty('id')}'),
                      onPressed: onManage,
                      icon: Icon(
                        Icons.settings,
                        size: context.getAdaptiveIconSize(
                          mobile: 20,
                          tablet: 22,
                          desktop: 24,
                        ),
                      ),
                      tooltip: AppLocalizations.of(context).configureSchedule,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(
                        minWidth: context.getAdaptiveIconSize(
                          mobile: 32,
                          tablet: 36,
                          desktop: 40,
                        ),
                        minHeight: context.getAdaptiveIconSize(
                          mobile: 32,
                          tablet: 36,
                          desktop: 40,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role, ThemeData theme, BuildContext context) {
    final isTablet = context.isTablet;
    final isSmallScreen = MediaQuery.of(context).size.width < 120;

    Color backgroundColor;
    Color textColor;
    String displayRole;

    final colorScheme = Theme.of(context).colorScheme;

    switch (role.toUpperCase()) {
      case 'ADMIN':
        backgroundColor = colorScheme.errorContainer;
        textColor = colorScheme.error;
        displayRole = 'Adm'; // Shorter text for small screens
        break;
      case 'COORDINATOR':
        backgroundColor = colorScheme.tertiaryContainer;
        textColor = colorScheme.tertiary;
        displayRole = 'Coord'; // Shorter text for small screens
        break;
      case 'MEMBER':
      default:
        backgroundColor = AppColors.surfaceVariantThemed(context);
        textColor = AppColors.textSecondaryThemed(context);
        displayRole = 'Mem'; // Shorter text for small screens
        break;
    }

    // Use even shorter text for very small screens
    if (isSmallScreen) {
      switch (role.toUpperCase()) {
        case 'ADMIN':
          displayRole = 'A';
          break;
        case 'COORDINATOR':
          displayRole = 'C';
          break;
        case 'MEMBER':
        default:
          displayRole = 'M';
          break;
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen
            ? 4
            : context.getAdaptiveSpacing(mobile: 8, tablet: 10, desktop: 12),
        vertical: isSmallScreen
            ? 2
            : context.getAdaptiveSpacing(mobile: 4, tablet: 6, desktop: 8),
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          isSmallScreen ? 6 : (isTablet ? 16 : 12),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          displayRole,
          style: TextStyle(
            color: textColor,
            fontSize: isSmallScreen
                ? 10
                : ((isTablet ? 13 : 11) * context.fontScale),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  bool _canManage(String role) {
    return ['ADMIN', 'COORDINATOR'].contains(role.toUpperCase());
  }

  dynamic _getProperty(String key) {
    if (group == null) return null;

    // Handle both Map and object types
    if (group is Map<String, dynamic>) {
      return group[key];
    } else {
      // Handle Group entity or other objects with properties
      switch (key) {
        case 'id':
          return group?.id;
        case 'name':
          return group?.name;
        case 'description':
          return group?.description;
        case 'userRole':
        case 'role':
          return group?.userRole;
        case 'familyCount':
        case 'memberCount':
          return group?.memberCount;
        default:
          return null;
      }
    }
  }
}
