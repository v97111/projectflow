import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

enum SortOption {
  recent,
  alphabetical,
  progress,
  nodeCount,
}

class SortBottomSheet extends StatelessWidget {
  final SortOption currentSort;
  final Function(SortOption) onSortChanged;

  const SortBottomSheet({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 10.w,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: colorScheme.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Row(
              children: [
                Text(
                  'Sort Projects',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Sort options
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            child: Column(
              children: [
                _buildSortOption(
                  context,
                  SortOption.recent,
                  'Recent',
                  'Sort by last updated',
                  Icons.schedule,
                ),
                _buildSortOption(
                  context,
                  SortOption.alphabetical,
                  'Alphabetical',
                  'Sort by project name A-Z',
                  Icons.sort_by_alpha,
                ),
                _buildSortOption(
                  context,
                  SortOption.progress,
                  'Progress',
                  'Sort by completion percentage',
                  Icons.trending_up,
                ),
                _buildSortOption(
                  context,
                  SortOption.nodeCount,
                  'Node Count',
                  'Sort by number of nodes',
                  Icons.account_tree,
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    SortOption option,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = currentSort == option;

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      child: ListTile(
        onTap: () {
          HapticFeedback.lightImpact();
          onSortChanged(option);
          Navigator.pop(context);
        },
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomIconWidget(
            iconName: _getIconName(icon),
            color: isSelected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface.withValues(alpha: 0.7),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? colorScheme.onSurface
                : colorScheme.onSurface.withValues(alpha: 0.9),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: isSelected
            ? CustomIconWidget(
                iconName: 'check_circle',
                color: colorScheme.primary,
                size: 24,
              )
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: isSelected
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 4.w,
          vertical: 1.h,
        ),
      ),
    );
  }

  String _getIconName(IconData icon) {
    switch (icon) {
      case Icons.schedule:
        return 'schedule';
      case Icons.sort_by_alpha:
        return 'sort_by_alpha';
      case Icons.trending_up:
        return 'trending_up';
      case Icons.account_tree:
        return 'account_tree';
      default:
        return 'sort';
    }
  }
}
