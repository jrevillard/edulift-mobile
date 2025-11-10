import 'package:flutter/material.dart';
import '../../../../core/domain/entities/groups/group.dart';

class GroupCard extends StatelessWidget {
  final Group group;
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

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        key: Key('groupCard_inkwell_${group.id}'),
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon and role
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.groups,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(child: _buildRoleBadge(group.userRole, theme)),
                ],
              ),

              const SizedBox(height: 6),

              // Group name
              Text(
                group.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 3),

              // Description or family count (direct Text, no Flexible)
              if (group.description?.isNotEmpty == true)
                Text(
                  group.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              else
                Text(
                  '${group.familyCount} ${group.familyCount == 1 ? "family" : "families"}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(GroupMemberRole? role, ThemeData theme) {
    Color backgroundColor;
    Color textColor;
    String displayRole;

    final safeRole = role ?? GroupMemberRole.member;

    switch (safeRole) {
      case GroupMemberRole.admin:
        backgroundColor = theme.colorScheme.errorContainer;
        textColor = theme.colorScheme.error;
        displayRole = 'Admin';
        break;
      case GroupMemberRole.owner:
        backgroundColor = theme.colorScheme.tertiaryContainer;
        textColor = theme.colorScheme.tertiary;
        displayRole = 'Owner';
        break;
      case GroupMemberRole.member:
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        textColor = theme.textTheme.bodySmall?.color ?? Colors.grey;
        displayRole = 'Member';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          displayRole,
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
