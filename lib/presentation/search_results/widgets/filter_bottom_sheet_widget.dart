import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this import
import '../../../core/app_export.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const FilterBottomSheetWidget({
    super.key,
    required this.currentFilters,
    required this.onFiltersChanged,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          _buildHandle(colorScheme),
          _buildHeader(context, colorScheme),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContentTypeFilter(colorScheme),
                  SizedBox(height: 3.h),
                  _buildDateRangeFilter(colorScheme),
                  SizedBox(height: 3.h),
                  _buildWorkspaceFilter(colorScheme),
                  SizedBox(height: 3.h),
                  _buildSortOptions(colorScheme),
                ],
              ),
            ),
          ),
          _buildActionButtons(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHandle(ColorScheme colorScheme) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.outline.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filter Results',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _filters = {
                  'contentTypes': <String>[],
                  'dateRange': null,
                  'workspaces': <String>[],
                  'sortBy': 'relevance',
                };
              });
            },
            child: Text(
              'Clear All',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTypeFilter(ColorScheme colorScheme) {
    final List<String> contentTypes = [
      'workspaces',
      'projects',
      'nodes',
      'reminders'
    ];
    final List<String> selectedTypes =
        (_filters['contentTypes'] as List<String>?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Content Type',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: contentTypes.map((type) {
            final bool isSelected = selectedTypes.contains(type);
            return FilterChip(
              label: Text(_getContentTypeLabel(type)),
              selected: isSelected,
              onSelected: (selected) {
                HapticFeedback.lightImpact();
                setState(() {
                  if (selected) {
                    selectedTypes.add(type);
                  } else {
                    selectedTypes.remove(type);
                  }
                  _filters['contentTypes'] = selectedTypes;
                });
              },
              backgroundColor: colorScheme.surfaceContainerHighest,
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.onPrimaryContainer,
              labelStyle: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter(ColorScheme colorScheme) {
    final List<String> dateRanges = [
      'today',
      'week',
      'month',
      'year',
      'custom'
    ];
    final String? selectedRange = _filters['dateRange'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: dateRanges.map((range) {
            final bool isSelected = selectedRange == range;
            return FilterChip(
              label: Text(_getDateRangeLabel(range)),
              selected: isSelected,
              onSelected: (selected) {
                HapticFeedback.lightImpact();
                setState(() {
                  _filters['dateRange'] = selected ? range : null;
                });
              },
              backgroundColor: colorScheme.surfaceContainerHighest,
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.onPrimaryContainer,
              labelStyle: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWorkspaceFilter(ColorScheme colorScheme) {
    final List<Map<String, dynamic>> workspaces = [
      {'id': '1', 'name': 'Personal Projects', 'color': 0xFF2563EB},
      {'id': '2', 'name': 'Work Tasks', 'color': 0xFF059669},
      {'id': '3', 'name': 'Design Portfolio', 'color': 0xFF7C3AED},
      {'id': '4', 'name': 'Learning Goals', 'color': 0xFFD97706},
    ];
    final List<String> selectedWorkspaces =
        (_filters['workspaces'] as List<String>?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workspace Scope',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        Column(
          children: workspaces.map((workspace) {
            final bool isSelected =
                selectedWorkspaces.contains(workspace['id']);
            return CheckboxListTile(
              value: isSelected,
              onChanged: (selected) {
                HapticFeedback.lightImpact();
                setState(() {
                  if (selected == true) {
                    selectedWorkspaces.add(workspace['id'] as String);
                  } else {
                    selectedWorkspaces.remove(workspace['id']);
                  }
                  _filters['workspaces'] = selectedWorkspaces;
                });
              },
              title: Row(
                children: [
                  Container(
                    width: 4.w,
                    height: 4.w,
                    decoration: BoxDecoration(
                      color: Color(workspace['color'] as int),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    workspace['name'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSortOptions(ColorScheme colorScheme) {
    final List<String> sortOptions = ['relevance', 'date', 'name', 'type'];
    final String selectedSort = (_filters['sortBy'] as String?) ?? 'relevance';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        Column(
          children: sortOptions.map((option) {
            final bool isSelected = selectedSort == option;
            return RadioListTile<String>(
              value: option,
              groupValue: selectedSort,
              onChanged: (value) {
                HapticFeedback.lightImpact();
                setState(() {
                  _filters['sortBy'] = value;
                });
              },
              title: Text(
                _getSortOptionLabel(option),
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                widget.onFiltersChanged(_filters);
                Navigator.pop(context);
              },
              child: Text(
                'Apply Filters',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getContentTypeLabel(String type) {
    switch (type) {
      case 'workspaces':
        return 'Workspaces';
      case 'projects':
        return 'Projects';
      case 'nodes':
        return 'Nodes';
      case 'reminders':
        return 'Reminders';
      default:
        return type;
    }
  }

  String _getDateRangeLabel(String range) {
    switch (range) {
      case 'today':
        return 'Today';
      case 'week':
        return 'This Week';
      case 'month':
        return 'This Month';
      case 'year':
        return 'This Year';
      case 'custom':
        return 'Custom Range';
      default:
        return range;
    }
  }

  String _getSortOptionLabel(String option) {
    switch (option) {
      case 'relevance':
        return 'Relevance';
      case 'date':
        return 'Date Modified';
      case 'name':
        return 'Name';
      case 'type':
        return 'Type';
      default:
        return option;
    }
  }
}