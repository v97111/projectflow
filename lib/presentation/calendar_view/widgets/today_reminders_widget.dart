import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TodayRemindersWidget extends StatefulWidget {
  final List<Map<String, dynamic>> todayReminders;
  final Function(Map<String, dynamic>) onReminderTap;
  final Function(Map<String, dynamic>) onReminderComplete;
  final Function(Map<String, dynamic>) onReminderDelete;

  const TodayRemindersWidget({
    super.key,
    required this.todayReminders,
    required this.onReminderTap,
    required this.onReminderComplete,
    required this.onReminderDelete,
  });

  @override
  State<TodayRemindersWidget> createState() => _TodayRemindersWidgetState();
}

class _TodayRemindersWidgetState extends State<TodayRemindersWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final urgentReminders = widget.todayReminders
        .where((reminder) =>
            reminder['priority'] == 'high' || _isOverdue(reminder))
        .toList();

    if (widget.todayReminders.isEmpty) {
      return Container();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isExpanded = !_isExpanded;
                if (_isExpanded) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              });
            },
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Container(
                    width: 10.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: urgentReminders.isNotEmpty
                          ? colorScheme.errorContainer
                          : colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: urgentReminders.isNotEmpty
                            ? 'priority_high'
                            : 'today',
                        color: urgentReminders.isNotEmpty
                            ? colorScheme.onErrorContainer
                            : colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          urgentReminders.isNotEmpty
                              ? 'Urgent Today (${urgentReminders.length})'
                              : 'Today\'s Reminders (${widget.todayReminders.length})',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: urgentReminders.isNotEmpty
                                ? colorScheme.error
                                : colorScheme.onSurface,
                          ),
                        ),
                        if (urgentReminders.isNotEmpty) ...[
                          SizedBox(height: 0.5.h),
                          Text(
                            '${urgentReminders.length} high priority items need attention',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.error.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: CustomIconWidget(
                      iconName: 'keyboard_arrow_down',
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _expandAnimation.value,
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  height: 1,
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(2.w),
                  itemCount: widget.todayReminders.length,
                  separatorBuilder: (context, index) => SizedBox(height: 1.h),
                  itemBuilder: (context, index) {
                    final reminder = widget.todayReminders[index];
                    return _buildReminderItem(context, reminder);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderItem(
      BuildContext context, Map<String, dynamic> reminder) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isOverdue = _isOverdue(reminder);
    final isHighPriority = reminder['priority'] == 'high';
    final isCompleted = reminder['isCompleted'] == true;

    return Dismissible(
      key: Key(reminder['id'].toString()),
      background: Container(
        decoration: BoxDecoration(
          color: AppTheme.getSuccessColor(theme.brightness == Brightness.light),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 4.w),
        child: CustomIconWidget(
          iconName: 'check',
          color: Colors.white,
          size: 24,
        ),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        child: CustomIconWidget(
          iconName: 'delete',
          color: Colors.white,
          size: 24,
        ),
      ),
      onDismissed: (direction) {
        HapticFeedback.mediumImpact();
        if (direction == DismissDirection.startToEnd) {
          widget.onReminderComplete(reminder);
        } else {
          widget.onReminderDelete(reminder);
        }
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onReminderTap(reminder);
        },
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: isCompleted
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isOverdue
                  ? colorScheme.error.withValues(alpha: 0.3)
                  : isHighPriority
                      ? colorScheme.tertiary.withValues(alpha: 0.3)
                      : colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: _getPriorityColor(
                      context, reminder['priority'] ?? 'medium'),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: isCompleted
                        ? 'check_circle'
                        : isOverdue
                            ? 'schedule'
                            : _getPriorityIcon(
                                reminder['priority'] ?? 'medium'),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder['title'] ?? 'Untitled Reminder',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isCompleted
                            ? colorScheme.onSurface.withValues(alpha: 0.6)
                            : colorScheme.onSurface,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'access_time',
                          color: isOverdue
                              ? colorScheme.error
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          _formatTime(reminder['dueDate'] as DateTime),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isOverdue
                                ? colorScheme.error
                                : colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight:
                                isOverdue ? FontWeight.w500 : FontWeight.w400,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: _getProjectColor(
                                    reminder['projectColor'] ?? '#2563EB')
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            reminder['projectName'] ?? 'No Project',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getProjectColor(
                                  reminder['projectColor'] ?? '#2563EB'),
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isOverdue) ...[
                SizedBox(width: 2.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'OVERDUE',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 9.sp,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _isOverdue(Map<String, dynamic> reminder) {
    final dueDate = reminder['dueDate'] as DateTime;
    final now = DateTime.now();
    return dueDate.isBefore(now) && reminder['isCompleted'] != true;
  }

  Color _getPriorityColor(BuildContext context, String priority) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (priority.toLowerCase()) {
      case 'high':
        return colorScheme.error;
      case 'medium':
        return colorScheme.tertiary;
      case 'low':
        return colorScheme.outline;
      default:
        return colorScheme.primary;
    }
  }

  String _getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'priority_high';
      case 'medium':
        return 'remove';
      case 'low':
        return 'keyboard_arrow_down';
      default:
        return 'circle';
    }
  }

  Color _getProjectColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF2563EB);
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}
