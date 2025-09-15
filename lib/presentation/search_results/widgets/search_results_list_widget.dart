import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import './search_result_item_widget.dart';
import 'search_result_item_widget.dart';

class SearchResultsListWidget extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> categorizedResults;
  final String searchQuery;
  final Function(Map<String, dynamic>) onResultTap;
  final Function(Map<String, dynamic>)? onBookmark;
  final Function(Map<String, dynamic>)? onShare;
  final Function(Map<String, dynamic>)? onEdit;

  const SearchResultsListWidget({
    super.key,
    required this.categorizedResults,
    required this.searchQuery,
    required this.onResultTap,
    this.onBookmark,
    this.onShare,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (categorizedResults.isEmpty) {
      return _buildEmptyState(context, colorScheme);
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 10.h),
      itemCount: _getTotalItemCount(),
      itemBuilder: (context, index) {
        return _buildItemAtIndex(context, index);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              size: 64,
            ),
            SizedBox(height: 3.h),
            Text(
              'No results found',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              searchQuery.isNotEmpty
                  ? 'Try adjusting your search terms or filters'
                  : 'Start typing to search across your workspaces',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            _buildPopularSearches(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularSearches(BuildContext context, ColorScheme colorScheme) {
    final List<String> popularSearches = [
      'Recent projects',
      'Overdue tasks',
      'Team meetings',
      'Design files',
      'Budget planning',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Searches',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: popularSearches
              .map((search) => GestureDetector(
                    onTap: () {
                      // Handle popular search tap
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color:
                            colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        search,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildItemAtIndex(BuildContext context, int index) {
    int currentIndex = 0;

    for (String category in categorizedResults.keys) {
      final List<Map<String, dynamic>> items = categorizedResults[category]!;

      if (currentIndex == index) {
        return _buildCategoryHeader(context, category, items.length);
      }
      currentIndex++;

      if (index < currentIndex + items.length) {
        final itemIndex = index - currentIndex;
        return SearchResultItemWidget(
          result: items[itemIndex],
          searchQuery: searchQuery,
          onTap: () => onResultTap(items[itemIndex]),
          onBookmark:
              onBookmark != null ? () => onBookmark!(items[itemIndex]) : null,
          onShare: onShare != null ? () => onShare!(items[itemIndex]) : null,
          onEdit: onEdit != null ? () => onEdit!(items[itemIndex]) : null,
        );
      }
      currentIndex += items.length;
    }

    return const SizedBox.shrink();
  }

  Widget _buildCategoryHeader(
      BuildContext context, String category, int count) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 1.h),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: _getCategoryIcon(category),
            color: colorScheme.primary,
            size: 20,
          ),
          SizedBox(width: 2.w),
          Text(
            _getCategoryTitle(category),
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(width: 2.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'workspaces':
        return 'folder';
      case 'projects':
        return 'list_alt';
      case 'nodes':
        return 'account_tree';
      case 'reminders':
        return 'notifications';
      default:
        return 'search';
    }
  }

  String _getCategoryTitle(String category) {
    switch (category) {
      case 'workspaces':
        return 'Workspaces';
      case 'projects':
        return 'Projects';
      case 'nodes':
        return 'Nodes';
      case 'reminders':
        return 'Reminders';
      default:
        return 'Results';
    }
  }

  int _getTotalItemCount() {
    int count = 0;
    for (String category in categorizedResults.keys) {
      count += 1; // Category header
      count += categorizedResults[category]!.length; // Items
    }
    return count;
  }
}