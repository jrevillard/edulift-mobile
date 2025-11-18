import 'package:flutter/material.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/domain/entities/groups/group.dart';
import '../../../../core/presentation/utils/responsive_breakpoints.dart';

class UnifiedGroupCard extends StatelessWidget {
  final Group group;
  final VoidCallback onTap;
  final String? userRoleText;

  const UnifiedGroupCard({
    super.key,
    required this.group,
    required this.onTap,
    this.userRoleText,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      margin: context.getAdaptivePadding(
        mobileAll: 8,
        tabletAll: 10,
        desktopAll: 12,
      ),
      child: InkWell(
        key: Key('unifiedGroupCard_inkwell_${group.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          context.getAdaptiveBorderRadius(mobile: 12, tablet: 14, desktop: 16),
        ),
        child: Padding(
          padding: context.getAdaptivePadding(
            mobileAll: 10,
            tabletAll: 12,
            desktopAll: 14,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon and role badge
              Row(
                children: [
                  Container(
                    width: context.getAdaptiveIconSize(
                      mobile: 28,
                      tablet: 32,
                      desktop: 36,
                    ),
                    height: context.getAdaptiveIconSize(
                      mobile: 28,
                      tablet: 32,
                      desktop: 36,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.groups,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: context.getAdaptiveIconSize(
                        mobile: 16,
                        tablet: 18,
                        desktop: 20,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: context.getAdaptiveSpacing(mobile: 6, tablet: 8),
                  ),
                  Expanded(child: _buildRoleBadge(context, theme, l10n)),
                ],
              ),
              SizedBox(
                height: context.getAdaptiveSpacing(
                  mobile: 6,
                  tablet: 8,
                  desktop: 10,
                ),
              ),
              // Group name
              Flexible(
                child: Text(
                  group.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: context.getAdaptiveSpacing(
                      mobile: 14,
                      tablet: 15,
                      desktop: 16,
                    ),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                height: context.getAdaptiveSpacing(
                  mobile: 3,
                  tablet: 4,
                  desktop: 5,
                ),
              ),
              // Family count and user role
              Text(
                l10n.familyCount(group.familyCount),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: context.getAdaptiveSpacing(
                    mobile: 11,
                    tablet: 12,
                    desktop: 13,
                  ),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (userRoleText != null) ...[
                SizedBox(height: context.getAdaptiveSpacing(mobile: 2)),
                Text(
                  l10n.userRole(userRoleText!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: context.getAdaptiveSpacing(
                      mobile: 11,
                      tablet: 12,
                      desktop: 13,
                    ),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    Color backgroundColor;
    Color textColor;
    String displayRole;

    final safeRole = group.userRole ?? GroupMemberRole.member;

    switch (safeRole) {
      case GroupMemberRole.admin:
        backgroundColor = theme.colorScheme.errorContainer;
        textColor = theme.colorScheme.error;
        displayRole = l10n.roleAdmin;
        break;
      case GroupMemberRole.owner:
        backgroundColor = theme.colorScheme.tertiaryContainer;
        textColor = theme.colorScheme.tertiary;
        displayRole = l10n.roleOwner;
        break;
      case GroupMemberRole.member:
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        textColor = theme.textTheme.bodySmall?.color ?? Colors.grey;
        displayRole = l10n.roleMember;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.getAdaptiveSpacing(mobile: 6, tablet: 8),
        vertical: context.getAdaptiveSpacing(mobile: 3, tablet: 4),
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          context.getAdaptiveBorderRadius(mobile: 10, tablet: 12),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          displayRole,
          style: TextStyle(
            color: textColor,
            fontSize: context.isMobile ? 10 : 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
