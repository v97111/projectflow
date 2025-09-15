import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ActiveProjectsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> projects;
  final Function(int) onProjectTap;

  const ActiveProjectsWidget({
    super.key,
    required this.projects,
    required this.onProjectTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'folder',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Active Projects',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/project-list');
                },
                child: Text(
                  'View All',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (projects.isEmpty)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                CustomIconWidget(
                  iconName: 'folder_open',
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  size: 48,
                ),
                SizedBox(height: 2.h),
                Text(
                  'No active projects',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Create your first project to get started',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, '/project-list');
                  },
                  icon: CustomIconWidget(
                    iconName: 'add',
                    color: theme.colorScheme.onPrimary,
                    size: 20,
                  ),
                  label: const Text('Create Project'),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 20.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: projects.length,
              separatorBuilder: (context, index) => SizedBox(width: 3.w),
              itemBuilder: (context, index) {
                final project = projects[index];
                return _buildProjectCard(context, project, index);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildProjectCard(
      BuildContext context, Map<String, dynamic> project, int index) {
    final theme = Theme.of(context);
    final progress = (project['progress'] as num?)?.toDouble() ?? 0.0;
    final nodeCount = project['nodeCount'] as int? ?? 0;
    final colorHex = project['color'] as String? ?? '#2563EB';
    final projectColor = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onProjectTap(index);
      },
      child: Container(
        width: 45.w,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.1),
              offset: const Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: projectColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: project['icon'] as String? ?? 'folder',
                    color: projectColor,
                    size: 20,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 12.w,
                  height: 12.w,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: progress / 100,
                        backgroundColor: projectColor.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(projectColor),
                        strokeWidth: 3,
                      ),
                      Center(
                        child: Text(
                          '${progress.toInt()}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: projectColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              project['name'] as String? ?? 'Untitled Project',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'account_tree',
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  '$nodeCount nodes',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            SizedBox(height: 0.5.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'schedule',
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  project['lastUpdated'] as String? ?? 'Never',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
