import 'package:flutter/material.dart';
import '../presentation/search_results/search_results.dart';
import '../presentation/graph_view/graph_view.dart';
import '../presentation/project_list/project_list.dart';
import '../presentation/workspace_list/workspace_list.dart';
import '../presentation/dashboard/dashboard.dart';
import '../presentation/calendar_view/calendar_view.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String searchResults = '/search-results';
  static const String graphView = '/graph-view';
  static const String projectList = '/project-list';
  static const String workspaceList = '/workspace-list';
  static const String dashboard = '/dashboard';
  static const String calendarView = '/calendar-view';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const Dashboard(),
    searchResults: (context) => const SearchResults(),
    graphView: (context) => const GraphView(),
    projectList: (context) => const ProjectList(),
    workspaceList: (context) => const WorkspaceList(),
    dashboard: (context) => const Dashboard(),
    calendarView: (context) => const CalendarView(),
    // TODO: Add your other routes here
  };
}