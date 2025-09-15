import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class WorkspaceHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> workspace;
  final int projectCount;
  final VoidCallback onBackPressed;
  final VoidCallback onSortPressed;
  final VoidCallback onSearchPressed;

  const WorkspaceHeaderWidget({
    super.key,
    required this.workspace,
    required this.projectCount,
    required this.onBackPressed,
    required this.onSortPressed,
    required this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final workspaceColor = Color(workspace['color'] ?? 0xFF2563EB);

    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with back button and actions
            Row(
              children: [
                // Back button
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onBackPressed();
                  },
                  icon: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: colorScheme.onSurface,
                    size: 24,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const Spacer(),

                // Search button
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onSearchPressed();
                  },
                  icon: CustomIconWidget(
                    iconName: 'search',
                    color: colorScheme.onSurface,
                    size: 24,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),

                // Sort button
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onSortPressed();
                  },
                  icon: CustomIconWidget(
                    iconName: 'sort',
                    color: colorScheme.onSurface,
                    size: 24,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Workspace info section
            Row(
              children: [
                // Workspace color indicator
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: workspaceColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: workspaceColor.withValues(alpha: 0.3),
                        offset: const Offset(0, 4),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: workspace['icon'] != null
                      ? CustomIconWidget(
                          iconName: workspace['icon'],
                          color: Colors.white,
                          size: 6.w,
                        )
                      : CustomIconWidget(
                          iconName: 'folder',
                          color: Colors.white,
                          size: 6.w,
                        ),
                ),
                SizedBox(width: 4.w),

                // Workspace name and project count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workspace['name'] ?? 'Untitled Workspace',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),

                      // Project count badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: workspaceColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: workspaceColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'folder_open',
                              color: workspaceColor,
                              size: 14,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '$projectCount ${projectCount == 1 ? 'project' : 'projects'}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: workspaceColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Workspace description if available
            if (workspace['description'] != null &&
                (workspace['description'] as String).isNotEmpty) ...[
              SizedBox(height: 2.h),
              Text(
                workspace['description'],
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
