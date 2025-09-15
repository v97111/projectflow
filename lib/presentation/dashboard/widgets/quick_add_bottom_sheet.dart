import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickAddBottomSheet extends StatelessWidget {
  final Function(String) onCreateReminder;
  final Function(String) onCreateProject;

  const QuickAddBottomSheet({
    super.key,
    required this.onCreateReminder,
    required this.onCreateProject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 10.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 1.5.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Quick Add',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 24,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              children: [
                _buildQuickAddOption(
                  context,
                  icon: 'notification_add',
                  title: 'Add Reminder',
                  subtitle: 'Create a quick reminder with date and time',
                  color: AppTheme.getWarningColor(
                      theme.brightness == Brightness.light),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showReminderDialog(context);
                  },
                ),
                SizedBox(height: 2.h),
                _buildQuickAddOption(
                  context,
                  icon: 'create_new_folder',
                  title: 'New Project',
                  subtitle: 'Start a new project in your workspace',
                  color: AppTheme.getSuccessColor(
                      theme.brightness == Brightness.light),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showProjectDialog(context);
                  },
                ),
                SizedBox(height: 2.h),
                _buildQuickAddOption(
                  context,
                  icon: 'account_tree',
                  title: 'Add Node',
                  subtitle: 'Add a new node to existing project',
                  color: AppTheme.getAccentColor(
                      theme.brightness == Brightness.light),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/graph-view');
                  },
                ),
                SizedBox(height: 2.h),
                _buildQuickAddOption(
                  context,
                  icon: 'folder_open',
                  title: 'New Workspace',
                  subtitle: 'Create a new workspace for organizing projects',
                  color: theme.colorScheme.primary,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/workspace-list');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddOption(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showReminderDialog(BuildContext context) {
    final theme = Theme.of(context);
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Reminder',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Reminder Title',
                hintText: 'Enter reminder title...',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // Show date picker
                    },
                    icon: CustomIconWidget(
                      iconName: 'calendar_today',
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    label: const Text('Select Date'),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // Show time picker
                    },
                    icon: CustomIconWidget(
                      iconName: 'schedule',
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    label: const Text('Select Time'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                onCreateReminder(titleController.text);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add Reminder'),
          ),
        ],
      ),
    );
  }

  void _showProjectDialog(BuildContext context) {
    final theme = Theme.of(context);
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'New Project',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Project Name',
                hintText: 'Enter project name...',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // Show workspace selector
                    },
                    icon: CustomIconWidget(
                      iconName: 'folder',
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    label: const Text('Select Workspace'),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // Show color picker
                    },
                    icon: CustomIconWidget(
                      iconName: 'palette',
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    label: const Text('Choose Color'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                onCreateProject(titleController.text);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Create Project'),
          ),
        ],
      ),
    );
  }
}
