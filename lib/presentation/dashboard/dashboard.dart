import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/active_projects_widget.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/quick_add_bottom_sheet.dart';
import './widgets/recent_activity_widget.dart';
import './widgets/today_tasks_widget.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  int _currentBottomNavIndex = 0;
  bool _isRefreshing = false;
  DateTime _lastSyncTime = DateTime.now();

  // Mock data for dashboard
  final List<Map<String, dynamic>> _todayTasks = [
    {
      "id": 1,
      "title": "Review project proposal",
      "description": "Check the new client requirements and timeline",
      "time": "9:00 AM",
      "priority": "high",
      "completed": false,
    },
    {
      "id": 2,
      "title": "Team standup meeting",
      "description": "Daily sync with development team",
      "time": "10:30 AM",
      "priority": "medium",
      "completed": false,
    },
    {
      "id": 3,
      "title": "Update project documentation",
      "description": "Add new API endpoints to documentation",
      "time": "2:00 PM",
      "priority": "low",
      "completed": false,
    },
    {
      "id": 4,
      "title": "Client presentation prep",
      "description": "Prepare slides for tomorrow's client meeting",
      "time": "4:00 PM",
      "priority": "high",
      "completed": false,
    },
  ];

  final List<Map<String, dynamic>> _activeProjects = [
    {
      "id": 1,
      "name": "Mobile App Redesign",
      "progress": 75.0,
      "nodeCount": 24,
      "color": "#2563EB",
      "icon": "phone_android",
      "lastUpdated": "2 hours ago",
    },
    {
      "id": 2,
      "name": "E-commerce Platform",
      "progress": 45.0,
      "nodeCount": 18,
      "color": "#059669",
      "icon": "shopping_cart",
      "lastUpdated": "1 day ago",
    },
    {
      "id": 3,
      "name": "Marketing Campaign",
      "progress": 90.0,
      "nodeCount": 12,
      "color": "#D97706",
      "icon": "campaign",
      "lastUpdated": "3 hours ago",
    },
    {
      "id": 4,
      "name": "Data Analytics Dashboard",
      "progress": 30.0,
      "nodeCount": 8,
      "color": "#7C3AED",
      "icon": "analytics",
      "lastUpdated": "5 days ago",
    },
  ];

  final List<Map<String, dynamic>> _recentActivities = [
    {
      "id": 1,
      "type": "task_completed",
      "title": "Completed user interface mockups",
      "description": "Finished designing the main dashboard layout",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 30)),
      "workspace": "Design Team",
    },
    {
      "id": 2,
      "type": "project_created",
      "title": "Created new project: API Integration",
      "description": "Set up project structure and initial nodes",
      "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
      "workspace": "Development",
    },
    {
      "id": 3,
      "type": "reminder_added",
      "title": "Added reminder for client meeting",
      "description": "Meeting scheduled for tomorrow at 10 AM",
      "timestamp": DateTime.now().subtract(const Duration(hours: 4)),
      "workspace": "Sales",
    },
    {
      "id": 4,
      "type": "node_updated",
      "title": "Updated database schema node",
      "description": "Added new fields for user preferences",
      "timestamp": DateTime.now().subtract(const Duration(hours: 6)),
      "workspace": "Development",
    },
    {
      "id": 5,
      "type": "workspace_created",
      "title": "Created Marketing workspace",
      "description": "New workspace for campaign management",
      "timestamp": DateTime.now().subtract(const Duration(days: 1)),
      "workspace": "Marketing",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: GreetingHeaderWidget(
                  userName: "Alex Johnson",
                  userAvatarUrl:
                      "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
                  onAvatarTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: TodayTasksWidget(
                  tasks: _todayTasks,
                  onTaskComplete: _handleTaskComplete,
                  onTaskSnooze: _handleTaskSnooze,
                  onTaskTap: _handleTaskTap,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 2.h),
              ),
              SliverToBoxAdapter(
                child: ActiveProjectsWidget(
                  projects: _activeProjects,
                  onProjectTap: _handleProjectTap,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 2.h),
              ),
              SliverToBoxAdapter(
                child: RecentActivityWidget(
                  activities: _recentActivities,
                  onActivityTap: _handleActivityTap,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 10.h),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickAddBottomSheet,
        child: CustomIconWidget(
          iconName: 'add',
          color: theme.colorScheme.onPrimary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final theme = Theme.of(context);

    return BottomNavigationBar(
      currentIndex: _currentBottomNavIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
      selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
      unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
      onTap: _handleBottomNavTap,
      items: [
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'dashboard',
            color: _currentBottomNavIndex == 0
                ? theme.bottomNavigationBarTheme.selectedItemColor ??
                    theme.colorScheme.primary
                : theme.bottomNavigationBarTheme.unselectedItemColor ??
                    theme.colorScheme.onSurface.withValues(alpha: 0.6),
            size: 24,
          ),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'folder',
            color: _currentBottomNavIndex == 1
                ? theme.bottomNavigationBarTheme.selectedItemColor ??
                    theme.colorScheme.primary
                : theme.bottomNavigationBarTheme.unselectedItemColor ??
                    theme.colorScheme.onSurface.withValues(alpha: 0.6),
            size: 24,
          ),
          label: 'Workspaces',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'calendar_today',
            color: _currentBottomNavIndex == 2
                ? theme.bottomNavigationBarTheme.selectedItemColor ??
                    theme.colorScheme.primary
                : theme.bottomNavigationBarTheme.unselectedItemColor ??
                    theme.colorScheme.onSurface.withValues(alpha: 0.6),
            size: 24,
          ),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'search',
            color: _currentBottomNavIndex == 3
                ? theme.bottomNavigationBarTheme.selectedItemColor ??
                    theme.colorScheme.primary
                : theme.bottomNavigationBarTheme.unselectedItemColor ??
                    theme.colorScheme.onSurface.withValues(alpha: 0.6),
            size: 24,
          ),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'person',
            color: _currentBottomNavIndex == 4
                ? theme.bottomNavigationBarTheme.selectedItemColor ??
                    theme.colorScheme.primary
                : theme.bottomNavigationBarTheme.unselectedItemColor ??
                    theme.colorScheme.onSurface.withValues(alpha: 0.6),
            size: 24,
          ),
          label: 'Profile',
        ),
      ],
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    HapticFeedback.lightImpact();

    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
      _lastSyncTime = DateTime.now();
    });

    HapticFeedback.selectionClick();
  }

  void _handleBottomNavTap(int index) {
    HapticFeedback.lightImpact();

    setState(() {
      _currentBottomNavIndex = index;
    });

    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        Navigator.pushNamed(context, '/workspace-list');
        break;
      case 2:
        Navigator.pushNamed(context, '/calendar-view');
        break;
      case 3:
        Navigator.pushNamed(context, '/search-results');
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  void _handleTaskComplete(int index) {
    HapticFeedback.mediumImpact();

    setState(() {
      _todayTasks[index]['completed'] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${_todayTasks[index]['title']}" completed!'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _todayTasks[index]['completed'] = false;
            });
          },
        ),
      ),
    );

    // Remove completed task after a delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _todayTasks[index]['completed'] == true) {
        setState(() {
          _todayTasks.removeAt(index);
        });
      }
    });
  }

  void _handleTaskSnooze(int index) {
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Task "${_todayTasks[index]['title']}" snoozed for 1 hour'),
      ),
    );

    // Remove task temporarily
    setState(() {
      _todayTasks.removeAt(index);
    });
  }

  void _handleTaskTap(int index) {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_todayTasks[index]['title'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_todayTasks[index]['description'] != null)
              Text(_todayTasks[index]['description'] as String),
            SizedBox(height: 2.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'schedule',
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  _todayTasks[index]['time'] as String,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleTaskComplete(index);
            },
            child: const Text('Mark Complete'),
          ),
        ],
      ),
    );
  }

  void _handleProjectTap(int index) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/project-list');
  }

  void _handleActivityTap(int index) {
    HapticFeedback.lightImpact();

    final activity = _recentActivities[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activity['title'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (activity['description'] != null)
              Text(activity['description'] as String),
            SizedBox(height: 2.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'folder',
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  activity['workspace'] as String? ?? 'Unknown',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showQuickAddBottomSheet() {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickAddBottomSheet(
        onCreateReminder: _handleCreateReminder,
        onCreateProject: _handleCreateProject,
      ),
    );
  }

  void _handleCreateReminder(String title) {
    HapticFeedback.lightImpact();

    setState(() {
      _todayTasks.add({
        "id": _todayTasks.length + 1,
        "title": title,
        "description": "Quick reminder created from dashboard",
        "time": "Now",
        "priority": "medium",
        "completed": false,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder "$title" added successfully!'),
      ),
    );
  }

  void _handleCreateProject(String title) {
    HapticFeedback.lightImpact();

    setState(() {
      _activeProjects.add({
        "id": _activeProjects.length + 1,
        "name": title,
        "progress": 0.0,
        "nodeCount": 0,
        "color": "#2563EB",
        "icon": "folder",
        "lastUpdated": "Just now",
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Project "$title" created successfully!'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            Navigator.pushNamed(context, '/project-list');
          },
        ),
      ),
    );
  }
}
