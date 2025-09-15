import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import './project_card_widget.dart';

class ProjectGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> projects;
  final Function(Map<String, dynamic>) onProjectTap;
  final Function(Map<String, dynamic>) onProjectEdit;
  final Function(Map<String, dynamic>) onProjectDuplicate;
  final Function(Map<String, dynamic>) onProjectShare;
  final Function(Map<String, dynamic>) onProjectArchive;
  final Function(Map<String, dynamic>) onProjectDelete;
  final Set<String> selectedProjects;
  final Function(Map<String, dynamic>)? onProjectLongPress;
  final bool isMultiSelectMode;

  const ProjectGridWidget({
    super.key,
    required this.projects,
    required this.onProjectTap,
    required this.onProjectEdit,
    required this.onProjectDuplicate,
    required this.onProjectShare,
    required this.onProjectArchive,
    required this.onProjectDelete,
    required this.selectedProjects,
    this.onProjectLongPress,
    this.isMultiSelectMode = false,
  });

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return _buildEmptyState(context);
    }

    // Determine grid layout based on screen size
    final screenWidth = 100.w;
    final crossAxisCount = screenWidth > 600 ? 2 : 1;
    final childAspectRatio = screenWidth > 600 ? 1.2 : 1.8;

    return GridView.builder(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 1.h,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        final projectId = project['id'].toString();
        final isSelected = selectedProjects.contains(projectId);

        return ProjectCardWidget(
          project: project,
          isSelected: isSelected,
          onTap: () => onProjectTap(project),
          onEdit: () => onProjectEdit(project),
          onDuplicate: () => onProjectDuplicate(project),
          onShare: () => onProjectShare(project),
          onArchive: () => onProjectArchive(project),
          onDelete: () => onProjectDelete(project),
          onLongPress: isMultiSelectMode
              ? null
              : () => onProjectLongPress?.call(project),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Workspace-themed illustration
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'folder_open',
                color: colorScheme.primary,
                size: 20.w,
              ),
            ),
            SizedBox(height: 4.h),

            // Empty state title
            Text(
              'No Projects Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),

            // Empty state description
            Text(
              'Start organizing your work by creating your first project. Projects help you group related tasks and track progress.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),

            // CTA Button
            ElevatedButton.icon(
              onPressed: () {
                // This will be handled by the parent widget
                Navigator.of(context).pop('create_project');
              },
              icon: CustomIconWidget(
                iconName: 'add',
                color: colorScheme.onPrimary,
                size: 20,
              ),
              label: Text(
                'Add Your First Project',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(
                  horizontal: 6.w,
                  vertical: 2.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
