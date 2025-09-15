import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DayDetailBottomSheet extends StatelessWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>> dayReminders;
  final Function(Map<String, dynamic>) onReminderTap;
  final Function(Map<String, dynamic>) onReminderComplete;
  final Function(Map<String, dynamic>) onReminderDelete;
  final VoidCallback onCreateReminder;

  const DayDetailBottomSheet({
    super.key,
    required this.selectedDate,
    required this.dayReminders,
    required this.onReminderTap,
    required this.onReminderComplete,
    required this.onReminderDelete,
    required this.onCreateReminder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 70.h,
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
              color: colorScheme.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _buildHeader(context),
          SizedBox(height: 2.h),
          Expanded(
            child: dayReminders.isEmpty
                ? _buildEmptyState(context)
                : _buildRemindersList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isToday = _isSameDay(selectedDate, DateTime.now());

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: isToday
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getWeekdayName(selectedDate),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isToday
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${selectedDate.day}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isToday
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getFormattedDate(selectedDate),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  dayReminders.isEmpty
                      ? 'No reminders scheduled'
                      : '${dayReminders.length} reminder${dayReminders.length == 1 ? '' : 's'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onCreateReminder();
            },
            child: Container(
              width: 10.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'add',
                  color: colorScheme.onPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20.w,
            height: 10.h,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'event_available',
                color: colorScheme.onSurface.withValues(alpha: 0.4),
                size: 32,
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'No reminders for this day',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Tap the + button to create your first reminder',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              onCreateReminder();
            },
            icon: CustomIconWidget(
              iconName: 'add',
              color: colorScheme.onPrimary,
              size: 18,
            ),
            label: const Text('Create Reminder'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersList(BuildContext context) {
    final sortedReminders = List<Map<String, dynamic>>.from(dayReminders);
    sortedReminders.sort((a, b) {
      final aTime = a['dueDate'] as DateTime;
      final bTime = b['dueDate'] as DateTime;
      return aTime.compareTo(bTime);
    });

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      itemCount: sortedReminders.length,
      separatorBuilder: (context, index) => SizedBox(height: 1.5.h),
      itemBuilder: (context, index) {
        final reminder = sortedReminders[index];
        return _buildReminderCard(context, reminder);
      },
    );
  }

  Widget _buildReminderCard(
      BuildContext context, Map<String, dynamic> reminder) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCompleted = reminder['isCompleted'] == true;
    final isOverdue = _isOverdue(reminder);

    return Dismissible(
      key: Key(reminder['id'].toString()),
      background: Container(
        decoration: BoxDecoration(
          color: AppTheme.getSuccessColor(theme.brightness == Brightness.light),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 24,
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Complete',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'delete',
              color: Colors.white,
              size: 24,
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Delete',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        HapticFeedback.mediumImpact();
        if (direction == DismissDirection.startToEnd) {
          onReminderComplete(reminder);
        } else {
          onReminderDelete(reminder);
        }
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onReminderTap(reminder);
        },
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: isCompleted
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOverdue
                  ? colorScheme.error.withValues(alpha: 0.3)
                  : colorScheme.outline.withValues(alpha: 0.1),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: _getPriorityColor(
                          context, reminder['priority'] ?? 'medium'),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: isCompleted
                            ? 'check_circle'
                            : _getPriorityIcon(
                                reminder['priority'] ?? 'medium'),
                        color: Colors.white,
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
                          reminder['title'] ?? 'Untitled Reminder',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isCompleted
                                ? colorScheme.onSurface.withValues(alpha: 0.6)
                                : colorScheme.onSurface,
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'access_time',
                              color: isOverdue
                                  ? colorScheme.error
                                  : colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                              size: 16,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              _formatTime(reminder['dueDate'] as DateTime),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isOverdue
                                    ? colorScheme.error
                                    : colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                fontWeight: isOverdue
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                              ),
                            ),
                            if (isOverdue) ...[
                              SizedBox(width: 2.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 0.5.h),
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
                      ],
                    ),
                  ),
                ],
              ),
              if (reminder['description'] != null &&
                  reminder['description'].toString().isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  reminder['description'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 2.h),
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: _getProjectColor(
                              reminder['projectColor'] ?? '#2563EB')
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'folder',
                          color: _getProjectColor(
                              reminder['projectColor'] ?? '#2563EB'),
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          reminder['projectName'] ?? 'No Project',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getProjectColor(
                                reminder['projectColor'] ?? '#2563EB'),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(
                              context, reminder['priority'] ?? 'medium')
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      (reminder['priority'] ?? 'medium')
                          .toString()
                          .toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getPriorityColor(
                            context, reminder['priority'] ?? 'medium'),
                        fontWeight: FontWeight.w600,
                        fontSize: 9.sp,
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

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isOverdue(Map<String, dynamic> reminder) {
    final dueDate = reminder['dueDate'] as DateTime;
    final now = DateTime.now();
    return dueDate.isBefore(now) && reminder['isCompleted'] != true;
  }

  String _getWeekdayName(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  String _getFormattedDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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
