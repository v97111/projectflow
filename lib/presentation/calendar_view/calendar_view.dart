import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/calendar_grid_widget.dart';
import './widgets/calendar_header_widget.dart';
import './widgets/create_reminder_bottom_sheet.dart';
import './widgets/day_detail_bottom_sheet.dart';
import './widgets/today_reminders_widget.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView>
    with TickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isWeekView = false;
  late AnimationController _refreshController;
  late Animation<double> _refreshAnimation;

  // Mock reminders data
  final List<Map<String, dynamic>> _reminders = [
    {
      'id': 1,
      'title': 'Team standup meeting',
      'description':
          'Daily sync with development team to discuss progress and blockers',
      'dueDate': DateTime.now().add(const Duration(hours: 2)),
      'priority': 'high',
      'projectName': 'Work Projects',
      'projectColor': '#059669',
      'isCompleted': false,
      'createdAt': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': 2,
      'title': 'Review project proposal',
      'description': 'Go through the new client proposal and provide feedback',
      'dueDate': DateTime.now().add(const Duration(hours: 4)),
      'priority': 'medium',
      'projectName': 'Work Projects',
      'projectColor': '#059669',
      'isCompleted': false,
      'createdAt': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'id': 3,
      'title': 'Gym workout session',
      'description':
          'Upper body strength training - chest, shoulders, and triceps',
      'dueDate': DateTime.now().add(const Duration(hours: 6)),
      'priority': 'medium',
      'projectName': 'Health & Fitness',
      'projectColor': '#DC2626',
      'isCompleted': false,
      'createdAt': DateTime.now().subtract(const Duration(hours: 12)),
    },
    {
      'id': 4,
      'title': 'Complete Flutter course module',
      'description':
          'Finish the state management chapter and complete the exercises',
      'dueDate': DateTime.now().add(const Duration(days: 1, hours: 3)),
      'priority': 'high',
      'projectName': 'Learning Goals',
      'projectColor': '#7C3AED',
      'isCompleted': false,
      'createdAt': DateTime.now().subtract(const Duration(hours: 8)),
    },
    {
      'id': 5,
      'title': 'Grocery shopping',
      'description':
          'Buy weekly groceries - vegetables, fruits, dairy, and household items',
      'dueDate': DateTime.now().add(const Duration(days: 1, hours: 10)),
      'priority': 'low',
      'projectName': 'Home & Family',
      'projectColor': '#D97706',
      'isCompleted': false,
      'createdAt': DateTime.now().subtract(const Duration(hours: 6)),
    },
    {
      'id': 6,
      'title': 'Client presentation prep',
      'description':
          'Prepare slides and demo for tomorrow\'s client presentation',
      'dueDate': DateTime.now().add(const Duration(days: 2, hours: 2)),
      'priority': 'high',
      'projectName': 'Work Projects',
      'projectColor': '#059669',
      'isCompleted': false,
      'createdAt': DateTime.now().subtract(const Duration(hours: 4)),
    },
    {
      'id': 7,
      'title': 'Read productivity book',
      'description': 'Continue reading "Atomic Habits" - Chapter 5-7',
      'dueDate': DateTime.now().add(const Duration(days: 3)),
      'priority': 'low',
      'projectName': 'Personal Tasks',
      'projectColor': '#2563EB',
      'isCompleted': false,
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'id': 8,
      'title': 'Doctor appointment',
      'description': 'Annual health checkup with Dr. Smith',
      'dueDate': DateTime.now().add(const Duration(days: 5, hours: 4)),
      'priority': 'medium',
      'projectName': 'Health & Fitness',
      'projectColor': '#DC2626',
      'isCompleted': false,
      'createdAt': DateTime.now().subtract(const Duration(hours: 1)),
    },
    {
      'id': 9,
      'title': 'Update portfolio website',
      'description': 'Add recent projects and update the design',
      'dueDate': DateTime.now().subtract(const Duration(hours: 2)),
      'priority': 'medium',
      'projectName': 'Personal Tasks',
      'projectColor': '#2563EB',
      'isCompleted': false,
      'createdAt': DateTime.now().subtract(const Duration(days: 3)),
    },
    {
      'id': 10,
      'title': 'Plan weekend trip',
      'description':
          'Research destinations and book accommodations for the weekend getaway',
      'dueDate': DateTime.now().add(const Duration(days: 7, hours: 8)),
      'priority': 'low',
      'projectName': 'Home & Family',
      'projectColor': '#D97706',
      'isCompleted': false,
      'createdAt': DateTime.now().subtract(const Duration(minutes: 30)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _refreshAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _refreshController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: colorScheme.primary,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: CalendarHeaderWidget(
                  currentDate: _focusedDay,
                  isWeekView: _isWeekView,
                  onPreviousMonth: _previousMonth,
                  onNextMonth: _nextMonth,
                  onToggleView: _toggleView,
                  onTodayTap: _goToToday,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 1.h),
              ),
              SliverToBoxAdapter(
                child: TodayRemindersWidget(
                  todayReminders: _getTodayReminders(),
                  onReminderTap: _handleReminderTap,
                  onReminderComplete: _handleReminderComplete,
                  onReminderDelete: _handleReminderDelete,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 2.h),
              ),
              SliverToBoxAdapter(
                child: CalendarGridWidget(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  isWeekView: _isWeekView,
                  reminders: _reminders,
                  onDaySelected: _handleDaySelected,
                  onDayLongPressed: _handleDayLongPressed,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 10.h),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          _showCreateReminderBottomSheet();
        },
        child: CustomIconWidget(
          iconName: 'add',
          color: colorScheme.onPrimary,
          size: 24,
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 4,
        onTap: _handleBottomNavTap,
      ),
    );
  }

  void _previousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    });
  }

  void _toggleView() {
    setState(() {
      _isWeekView = !_isWeekView;
    });
  }

  void _goToToday() {
    setState(() {
      _focusedDay = DateTime.now();
      _selectedDay = DateTime.now();
    });
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    _refreshController.forward().then((_) {
      _refreshController.reverse();
    });

    // Simulate data refresh
    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      // Refresh data here
    });
  }

  void _handleDaySelected(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = selectedDay;
    });

    final dayReminders = _getRemindersForDay(selectedDay);
    _showDayDetailBottomSheet(selectedDay, dayReminders);
  }

  void _handleDayLongPressed(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = selectedDay;
    });

    _showCreateReminderBottomSheet(preselectedDate: selectedDay);
  }

  void _handleReminderTap(Map<String, dynamic> reminder) {
    _showReminderDetailDialog(reminder);
  }

  void _handleReminderComplete(Map<String, dynamic> reminder) {
    setState(() {
      final index = _reminders.indexWhere((r) => r['id'] == reminder['id']);
      if (index != -1) {
        _reminders[index]['isCompleted'] = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder "${reminder['title']}" marked as complete'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              final index =
                  _reminders.indexWhere((r) => r['id'] == reminder['id']);
              if (index != -1) {
                _reminders[index]['isCompleted'] = false;
              }
            });
          },
        ),
      ),
    );
  }

  void _handleReminderDelete(Map<String, dynamic> reminder) {
    final reminderToDelete = Map<String, dynamic>.from(reminder);

    setState(() {
      _reminders.removeWhere((r) => r['id'] == reminder['id']);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder "${reminder['title']}" deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _reminders.add(reminderToDelete);
            });
          },
        ),
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushNamed(context, '/workspace-list');
        break;
      case 2:
        Navigator.pushNamed(context, '/project-list');
        break;
      case 3:
        Navigator.pushNamed(context, '/graph-view');
        break;
      case 4:
        // Already on calendar view
        break;
    }
  }

  List<Map<String, dynamic>> _getTodayReminders() {
    final today = DateTime.now();
    return _reminders.where((reminder) {
      final reminderDate = reminder['dueDate'] as DateTime;
      return _isSameDay(reminderDate, today) && reminder['isCompleted'] != true;
    }).toList()
      ..sort((a, b) {
        final aDate = a['dueDate'] as DateTime;
        final bDate = b['dueDate'] as DateTime;
        return aDate.compareTo(bDate);
      });
  }

  List<Map<String, dynamic>> _getRemindersForDay(DateTime day) {
    return _reminders.where((reminder) {
      final reminderDate = reminder['dueDate'] as DateTime;
      return _isSameDay(reminderDate, day);
    }).toList()
      ..sort((a, b) {
        final aDate = a['dueDate'] as DateTime;
        final bDate = b['dueDate'] as DateTime;
        return aDate.compareTo(bDate);
      });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _showDayDetailBottomSheet(
      DateTime selectedDate, List<Map<String, dynamic>> dayReminders) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DayDetailBottomSheet(
        selectedDate: selectedDate,
        dayReminders: dayReminders,
        onReminderTap: _handleReminderTap,
        onReminderComplete: _handleReminderComplete,
        onReminderDelete: _handleReminderDelete,
        onCreateReminder: () {
          Navigator.pop(context);
          _showCreateReminderBottomSheet(preselectedDate: selectedDate);
        },
      ),
    );
  }

  void _showCreateReminderBottomSheet({DateTime? preselectedDate}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateReminderBottomSheet(
        preselectedDate: preselectedDate,
        onCreateReminder: _handleCreateReminder,
      ),
    );
  }

  void _handleCreateReminder(Map<String, dynamic> reminderData) {
    setState(() {
      _reminders.add(reminderData);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Reminder "${reminderData['title']}" created successfully'),
        backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.light),
      ),
    );
  }

  void _showReminderDetailDialog(Map<String, dynamic> reminder) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
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
                  iconName: _getPriorityIcon(reminder['priority'] ?? 'medium'),
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                reminder['title'] ?? 'Untitled Reminder',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reminder['description'] != null &&
                reminder['description'].toString().isNotEmpty) ...[
              Text(
                reminder['description'],
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
            ],
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'access_time',
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  _formatDateTime(reminder['dueDate'] as DateTime),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'folder',
                  color:
                      _getProjectColor(reminder['projectColor'] ?? '#2563EB'),
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  reminder['projectName'] ?? 'No Project',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color:
                        _getProjectColor(reminder['projectColor'] ?? '#2563EB'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (reminder['isCompleted'] != true)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _handleReminderComplete(reminder);
              },
              child: const Text('Mark Complete'),
            ),
        ],
      ),
    );
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final selectedDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (selectedDay == today) {
      dateStr = 'Today';
    } else if (selectedDay == tomorrow) {
      dateStr = 'Tomorrow';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      dateStr =
          '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
    }

    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final timeStr =
        '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';

    return '$dateStr at $timeStr';
  }
}
