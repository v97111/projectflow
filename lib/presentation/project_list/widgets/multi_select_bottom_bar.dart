import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MultiSelectBottomBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onSelectAll;
  final VoidCallback onDeselectAll;
  final VoidCallback onDuplicate;
  final VoidCallback onArchive;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  const MultiSelectBottomBar({
    super.key,
    required this.selectedCount,
    required this.onSelectAll,
    required this.onDeselectAll,
    required this.onDuplicate,
    required this.onArchive,
    required this.onDelete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.12),
            offset: const Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selection info and controls
              Row(
                children: [
                  // Cancel button
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onCancel();
                    },
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),

                  // Selection count
                  Expanded(
                    child: Text(
                      '$selectedCount ${selectedCount == 1 ? 'project' : 'projects'} selected',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Select all/deselect all button
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // Logic to determine if we should select all or deselect all
                      // This would be handled by the parent widget
                      onSelectAll();
                    },
                    child: Text(
                      'Select All',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // Action buttons
              Row(
                children: [
                  // Duplicate button
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: 'content_copy',
                      label: 'Duplicate',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onDuplicate();
                      },
                      backgroundColor: AppTheme.getAccentColor(
                          theme.brightness == Brightness.light),
                    ),
                  ),
                  SizedBox(width: 3.w),

                  // Archive button
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: 'archive',
                      label: 'Archive',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onArchive();
                      },
                      backgroundColor: AppTheme.getWarningColor(
                          theme.brightness == Brightness.light),
                    ),
                  ),
                  SizedBox(width: 3.w),

                  // Delete button
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: 'delete',
                      label: 'Delete',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onDelete();
                      },
                      backgroundColor: colorScheme.error,
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

  Widget _buildActionButton(
    BuildContext context, {
    required String icon,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
  }) {
    final theme = Theme.of(context);

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: icon,
            color: Colors.white,
            size: 20,
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
