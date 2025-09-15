import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TodayTasksWidget extends StatefulWidget {
  final List<Map<String, dynamic>> tasks;
  final Function(int) onTaskComplete;
  final Function(int) onTaskSnooze;
  final Function(int) onTaskTap;

  const TodayTasksWidget({
    super.key,
    required this.tasks,
    required this.onTaskComplete,
    required this.onTaskSnooze,
    required this.onTaskTap,
  });

  @override
  State<TodayTasksWidget> createState() => _TodayTasksWidgetState();
}

class _TodayTasksWidgetState extends State<TodayTasksWidget> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        children: [
          ListTile(
            leading: CustomIconWidget(
              iconName: 'today',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            title: Text(
              'Today\'s Tasks',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${widget.tasks.length} tasks',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            trailing: IconButton(
              icon: CustomIconWidget(
                iconName: _isExpanded ? 'expand_less' : 'expand_more',
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 24,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          if (_isExpanded) ...[
            if (widget.tasks.isEmpty)
              Container(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    CustomIconWidget(
                      iconName: 'task_alt',
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      size: 48,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'No tasks for today',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Great job! You\'re all caught up.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
                itemCount: widget.tasks.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
                itemBuilder: (context, index) {
                  final task = widget.tasks[index];
                  return _buildTaskItem(context, task, index);
                },
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskItem(
      BuildContext context, Map<String, dynamic> task, int index) {
    final theme = Theme.of(context);
    final priority = task['priority'] as String? ?? 'medium';
    final priorityColor = _getPriorityColor(theme, priority);

    return Dismissible(
      key: Key('task_${task['id']}'),
      background: Container(
        color: AppTheme.getSuccessColor(theme.brightness == Brightness.light),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 4.w),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Complete',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        color: AppTheme.getWarningColor(theme.brightness == Brightness.light),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Snooze',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 2.w),
            CustomIconWidget(
              iconName: 'snooze',
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        HapticFeedback.mediumImpact();
        if (direction == DismissDirection.startToEnd) {
          widget.onTaskComplete(index);
        } else {
          widget.onTaskSnooze(index);
        }
      },
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        leading: Container(
          width: 4,
          height: 6.h,
          decoration: BoxDecoration(
            color: priorityColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(
          task['title'] as String? ?? 'Untitled Task',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task['description'] != null) ...[
              SizedBox(height: 0.5.h),
              Text(
                task['description'] as String,
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
                  size: 14,
                ),
                SizedBox(width: 1.w),
                Text(
                  task['time'] as String? ?? 'No time set',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                SizedBox(width: 3.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    priority.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: priorityColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: CustomIconWidget(
          iconName: 'chevron_right',
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          size: 20,
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTaskTap(index);
        },
      ),
    );
  }

  Color _getPriorityColor(ThemeData theme, String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return theme.colorScheme.error;
      case 'medium':
        return AppTheme.getWarningColor(theme.brightness == Brightness.light);
      case 'low':
        return AppTheme.getSuccessColor(theme.brightness == Brightness.light);
      default:
        return theme.colorScheme.primary;
    }
  }
}
