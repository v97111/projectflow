import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SearchSuggestionsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> suggestions;
  final Function(String) onSuggestionTap;
  final bool isVisible;

  const SearchSuggestionsWidget({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible || suggestions.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.12),
            offset: const Offset(0, 4),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: suggestions
            .take(5)
            .map((suggestion) => _buildSuggestionItem(
                  context,
                  suggestion,
                  colorScheme,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildSuggestionItem(
    BuildContext context,
    Map<String, dynamic> suggestion,
    ColorScheme colorScheme,
  ) {
    final String text = suggestion['text'] as String;
    final String type = suggestion['type'] as String;
    final IconData icon = _getIconForType(type);

    return ListTile(
      leading: CustomIconWidget(
        iconName: _getIconName(icon),
        color: colorScheme.onSurface.withValues(alpha: 0.6),
        size: 20,
      ),
      title: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _getTypeLabel(type),
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      trailing: CustomIconWidget(
        iconName: 'north_west',
        color: colorScheme.onSurface.withValues(alpha: 0.4),
        size: 16,
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        onSuggestionTap(text);
      },
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'workspace':
        return Icons.folder_outlined;
      case 'project':
        return Icons.list_alt_outlined;
      case 'node':
        return Icons.account_tree_outlined;
      case 'reminder':
        return Icons.notifications_outlined;
      default:
        return Icons.search;
    }
  }

  String _getIconName(IconData icon) {
    if (icon == Icons.folder_outlined) return 'folder_outlined';
    if (icon == Icons.list_alt_outlined) return 'list_alt_outlined';
    if (icon == Icons.account_tree_outlined) return 'account_tree_outlined';
    if (icon == Icons.notifications_outlined) return 'notifications_outlined';
    return 'search';
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'workspace':
        return 'Workspace';
      case 'project':
        return 'Project';
      case 'node':
        return 'Node';
      case 'reminder':
        return 'Reminder';
      default:
        return 'Search';
    }
  }
}