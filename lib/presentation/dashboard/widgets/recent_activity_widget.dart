import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentActivityWidget extends StatelessWidget {
  final List<Map<String, dynamic>> activities;
  final Function(int) onActivityTap;

  const RecentActivityWidget({
    super.key,
    required this.activities,
    required this.onActivityTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        children: [
          ListTile(
            leading: CustomIconWidget(
              iconName: 'history',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            title: Text(
              'Recent Activity',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Last ${activities.length} actions',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            trailing: TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                // Navigate to full activity log
              },
              child: Text(
                'View All',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          if (activities.isEmpty)
            Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  CustomIconWidget(
                    iconName: 'timeline',
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    size: 48,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'No recent activity',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Your recent actions will appear here',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length > 5 ? 5 : activities.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return _buildActivityItem(context, activity, index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
      BuildContext context, Map<String, dynamic> activity, int index) {
    final theme = Theme.of(context);
    final activityType = activity['type'] as String? ?? 'unknown';
    final activityIcon = _getActivityIcon(activityType);
    final activityColor = _getActivityColor(theme, activityType);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
      leading: Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(
          color: activityColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: activityIcon,
          color: activityColor,
          size: 20,
        ),
      ),
      title: Text(
        activity['title'] as String? ?? 'Unknown Activity',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activity['description'] != null) ...[
            SizedBox(height: 0.5.h),
            Text(
              activity['description'] as String,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
          SizedBox(height: 0.5.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                size: 12,
              ),
              SizedBox(width: 1.w),
              Text(
                _formatTimeAgo(
                    activity['timestamp'] as DateTime? ?? DateTime.now()),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              if (activity['workspace'] != null) ...[
                SizedBox(width: 3.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.2.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    activity['workspace'] as String,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      trailing: CustomIconWidget(
        iconName: 'chevron_right',
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        size: 16,
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        onActivityTap(index);
      },
    );
  }

  String _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'workspace_created':
        return 'folder_open';
      case 'project_created':
        return 'create_new_folder';
      case 'task_completed':
        return 'task_alt';
      case 'reminder_added':
        return 'notification_add';
      case 'node_created':
        return 'account_tree';
      case 'node_updated':
        return 'edit';
      case 'project_updated':
        return 'update';
      default:
        return 'info';
    }
  }

  Color _getActivityColor(ThemeData theme, String type) {
    switch (type.toLowerCase()) {
      case 'workspace_created':
      case 'project_created':
        return AppTheme.getSuccessColor(theme.brightness == Brightness.light);
      case 'task_completed':
        return theme.colorScheme.primary;
      case 'reminder_added':
        return AppTheme.getWarningColor(theme.brightness == Brightness.light);
      case 'node_created':
      case 'node_updated':
        return AppTheme.getAccentColor(theme.brightness == Brightness.light);
      case 'project_updated':
        return theme.colorScheme.secondary;
      default:
        return theme.colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}
