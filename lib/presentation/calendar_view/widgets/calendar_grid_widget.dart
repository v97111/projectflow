import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarGridWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final bool isWeekView;
  final List<Map<String, dynamic>> reminders;
  final Function(DateTime) onDaySelected;
  final Function(DateTime) onDayLongPressed;

  const CalendarGridWidget({
    super.key,
    required this.focusedDay,
    this.selectedDay,
    required this.isWeekView,
    required this.reminders,
    required this.onDaySelected,
    required this.onDayLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: TableCalendar<Map<String, dynamic>>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        calendarFormat: isWeekView ? CalendarFormat.week : CalendarFormat.month,
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        onDaySelected: (selectedDay, focusedDay) {
          HapticFeedback.lightImpact();
          onDaySelected(selectedDay);
        },
        onDayLongPressed: (selectedDay, focusedDay) {
          HapticFeedback.mediumImpact();
          onDayLongPressed(selectedDay);
        },
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ) ?? const TextStyle(),
          holidayTextStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.error,
          ) ?? const TextStyle(),
          defaultTextStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ) ?? const TextStyle(),
          selectedTextStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ) ?? const TextStyle(),
          todayTextStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.w600,
          ) ?? const TextStyle(),
          selectedDecoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: colorScheme.tertiary,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
          canMarkersOverflow: true,
          markersOffset: const PositionedOffset(bottom: 4),
          markerSize: 6,
          markerMargin: const EdgeInsets.symmetric(horizontal: 1),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: false,
          leftChevronVisible: false,
          rightChevronVisible: false,
          headerPadding: EdgeInsets.zero,
          headerMargin: EdgeInsets.zero,
          titleTextStyle: TextStyle(fontSize: 0),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ) ??
              const TextStyle(),
          weekendStyle: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ) ??
              const TextStyle(),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return null;

            return Positioned(
              bottom: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: events.take(3).map((event) {
                  final eventMap = event;
                  final priority = eventMap['priority'] as String? ?? 'medium';
                  final color = _getPriorityColor(context, priority);

                  return Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              ),
            );
          },
          defaultBuilder: (context, day, focusedDay) {
            final hasEvents = _getEventsForDay(day).isNotEmpty;
            final isToday = isSameDay(day, DateTime.now());

            return Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: hasEvents && !isToday
                    ? colorScheme.primaryContainer.withValues(alpha: 0.1)
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color:
                        hasEvents ? colorScheme.primary : colorScheme.onSurface,
                    fontWeight: hasEvents ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return reminders.where((reminder) {
      final reminderDate = reminder['dueDate'] as DateTime;
      return isSameDay(reminderDate, day);
    }).toList();
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
}