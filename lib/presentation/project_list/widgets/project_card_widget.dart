import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProjectCardWidget extends StatelessWidget {
  final Map<String, dynamic> project;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onShare;
  final VoidCallback onArchive;
  final VoidCallback onDelete;
  final bool isSelected;
  final VoidCallback? onLongPress;

  const ProjectCardWidget({
    super.key,
    required this.project,
    required this.onTap,
    required this.onEdit,
    required this.onDuplicate,
    required this.onShare,
    required this.onArchive,
    required this.onDelete,
    this.isSelected = false,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final projectColor = Color(project['color'] ?? 0xFF2563EB);
    final progress = (project['progress'] ?? 0.0) as double;
    final nodeCount = project['nodeCount'] ?? 0;
    final isCompleted = project['status'] == 'completed';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Slidable(
        key: ValueKey(project['id']),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) {
                HapticFeedback.lightImpact();
                onEdit();
              },
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              icon: Icons.edit,
              label: 'Edit',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) {
                HapticFeedback.lightImpact();
                onDuplicate();
              },
              backgroundColor:
                  AppTheme.getAccentColor(theme.brightness == Brightness.light),
              foregroundColor: Colors.white,
              icon: Icons.copy,
              label: 'Duplicate',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) {
                HapticFeedback.lightImpact();
                onShare();
              },
              backgroundColor: AppTheme.getSuccessColor(
                  theme.brightness == Brightness.light),
              foregroundColor: Colors.white,
              icon: Icons.share,
              label: 'Share',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) {
                HapticFeedback.lightImpact();
                onArchive();
              },
              backgroundColor: AppTheme.getWarningColor(
                  theme.brightness == Brightness.light),
              foregroundColor: Colors.white,
              icon: Icons.archive,
              label: 'Archive',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) {
                HapticFeedback.lightImpact();
                onDelete();
              },
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            onLongPress?.call();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                  : colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.1),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.08),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with color indicator and status
                Container(
                  padding: EdgeInsets.all(4.w),
                  child: Row(
                    children: [
                      // Color indicator
                      Container(
                        width: 4,
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: projectColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      // Project info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    project['name'] ?? 'Untitled Project',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isCompleted)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                      vertical: 0.5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.getSuccessColor(
                                              theme.brightness ==
                                                  Brightness.light)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CustomIconWidget(
                                          iconName: 'check_circle',
                                          color: AppTheme.getSuccessColor(
                                              theme.brightness ==
                                                  Brightness.light),
                                          size: 12,
                                        ),
                                        SizedBox(width: 1.w),
                                        Text(
                                          'Complete',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: AppTheme.getSuccessColor(
                                                theme.brightness ==
                                                    Brightness.light),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            if (project['description'] != null &&
                                (project['description'] as String).isNotEmpty)
                              Text(
                                project['description'],
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      // Selection indicator
                      if (isSelected)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: CustomIconWidget(
                            iconName: 'check',
                            color: colorScheme.onPrimary,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ),

                // Progress bar
                if (!isCompleted)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor:
                              colorScheme.outline.withValues(alpha: 0.2),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(projectColor),
                          minHeight: 4,
                        ),
                      ],
                    ),
                  ),

                // Footer with node count and last updated
                Container(
                  padding: EdgeInsets.all(4.w),
                  child: Row(
                    children: [
                      // Node count
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'account_tree',
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.7),
                              size: 14,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '$nodeCount nodes',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Last updated
                      Text(
                        _formatLastUpdated(project['lastUpdated']),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatLastUpdated(dynamic lastUpdated) {
    if (lastUpdated == null) return 'Never';

    final DateTime date = lastUpdated is DateTime
        ? lastUpdated
        : DateTime.parse(lastUpdated.toString());
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
