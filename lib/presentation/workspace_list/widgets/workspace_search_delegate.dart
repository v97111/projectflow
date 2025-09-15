import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class WorkspaceSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> workspaces;
  final Function(Map<String, dynamic>) onWorkspaceSelected;

  WorkspaceSearchDelegate({
    required this.workspaces,
    required this.onWorkspaceSelected,
  });

  @override
  String get searchFieldLabel => 'Search workspaces...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (query.isEmpty) {
      return _buildRecentSearches(context);
    }

    final filteredWorkspaces = workspaces.where((workspace) {
      final name = (workspace['name'] ?? '').toLowerCase();
      final description = (workspace['description'] ?? '').toLowerCase();
      final searchQuery = query.toLowerCase();

      return name.contains(searchQuery) || description.contains(searchQuery);
    }).toList();

    if (filteredWorkspaces.isEmpty) {
      return _buildNoResults(context);
    }

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: filteredWorkspaces.length,
      itemBuilder: (context, index) {
        final workspace = filteredWorkspaces[index];
        return _buildWorkspaceSearchItem(context, workspace);
      },
    );
  }

  Widget _buildWorkspaceSearchItem(
      BuildContext context, Map<String, dynamic> workspace) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final workspaceColor = Color(workspace['color'] ?? 0xFF2563EB);
    final projectCount = workspace['projectCount'] ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(4.w),
        leading: Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: workspaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: workspace['icon'] ?? 'folder',
              color: Colors.white,
              size: 6.w,
            ),
          ),
        ),
        title: Text(
          workspace['name'] ?? 'Untitled Workspace',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$projectCount ${projectCount == 1 ? 'project' : 'projects'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (workspace['description'] != null &&
                workspace['description'].isNotEmpty) ...[
              SizedBox(height: 0.5.h),
              Text(
                workspace['description'],
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: CustomIconWidget(
          iconName: 'chevron_right',
          color: colorScheme.onSurface.withValues(alpha: 0.4),
          size: 5.w,
        ),
        onTap: () {
          close(context, workspace['name']);
          onWorkspaceSelected(workspace);
        },
      ),
    );
  }

  Widget _buildRecentSearches(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Mock recent searches - in real app, this would come from storage
    final recentSearches = [
      'Personal Projects',
      'Work',
      'Design',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(4.w),
          child: Text(
            'Recent Searches',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        ...recentSearches.map((search) => ListTile(
              leading: CustomIconWidget(
                iconName: 'history',
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                size: 5.w,
              ),
              title: Text(search),
              trailing: CustomIconWidget(
                iconName: 'north_west',
                color: colorScheme.onSurface.withValues(alpha: 0.4),
                size: 4.w,
              ),
              onTap: () {
                query = search;
                showResults(context);
              },
            )),
      ],
    );
  }

  Widget _buildNoResults(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              size: 15.w,
            ),
            SizedBox(height: 2.h),
            Text(
              'No workspaces found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Try searching with different keywords',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
