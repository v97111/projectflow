import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SearchResultItemWidget extends StatelessWidget {
  final Map<String, dynamic> result;
  final String searchQuery;
  final VoidCallback onTap;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;
  final VoidCallback? onEdit;

  const SearchResultItemWidget({
    super.key,
    required this.result,
    required this.searchQuery,
    required this.onTap,
    this.onBookmark,
    this.onShare,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Slidable(
      key: ValueKey(result['id']),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          if (onBookmark != null)
            SlidableAction(
              onPressed: (_) {
                HapticFeedback.lightImpact();
                onBookmark?.call();
              },
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
              icon: Icons.bookmark_outline,
              label: 'Bookmark',
            ),
          if (onShare != null)
            SlidableAction(
              onPressed: (_) {
                HapticFeedback.lightImpact();
                onShare?.call();
              },
              backgroundColor: colorScheme.secondaryContainer,
              foregroundColor: colorScheme.onSecondaryContainer,
              icon: Icons.share_outlined,
              label: 'Share',
            ),
          if (onEdit != null)
            SlidableAction(
              onPressed: (_) {
                HapticFeedback.lightImpact();
                onEdit?.call();
              },
              backgroundColor: colorScheme.tertiaryContainer,
              foregroundColor: colorScheme.onTertiaryContainer,
              icon: Icons.edit_outlined,
              label: 'Edit',
            ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(4.w),
          leading: _buildLeadingIcon(colorScheme),
          title: _buildTitle(colorScheme),
          subtitle: _buildSubtitle(colorScheme),
          trailing: _buildTrailing(colorScheme),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(ColorScheme colorScheme) {
    final String type = result['type'] as String;
    final Color? itemColor =
        result['color'] != null ? Color(result['color'] as int) : null;

    return Container(
      width: 12.w,
      height: 12.w,
      decoration: BoxDecoration(
        color:
            (itemColor ?? colorScheme.primaryContainer).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: _getIconNameForType(type),
          color: itemColor ?? colorScheme.onPrimaryContainer,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildTitle(ColorScheme colorScheme) {
    final String title = result['title'] as String;

    return RichText(
      text: _highlightSearchQuery(
        title,
        searchQuery,
        GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitle(ColorScheme colorScheme) {
    final String type = result['type'] as String;
    final String? description = result['description'] as String?;
    final String? breadcrumb = result['breadcrumb'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 0.5.h),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getTypeLabel(type),
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),
            if (breadcrumb != null) ...[
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  breadcrumb,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        if (description != null) ...[
          SizedBox(height: 0.5.h),
          RichText(
            text: _highlightSearchQuery(
              description,
              searchQuery,
              GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: colorScheme.primary,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildTrailing(ColorScheme colorScheme) {
    final DateTime? lastModified = result['lastModified'] != null
        ? DateTime.parse(result['lastModified'] as String)
        : null;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CustomIconWidget(
          iconName: 'chevron_right',
          color: colorScheme.onSurface.withValues(alpha: 0.4),
          size: 20,
        ),
        if (lastModified != null) ...[
          SizedBox(height: 0.5.h),
          Text(
            _formatDate(lastModified),
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ],
    );
  }

  String _getIconNameForType(String type) {
    switch (type) {
      case 'workspace':
        return 'folder';
      case 'project':
        return 'list_alt';
      case 'node':
        return 'account_tree';
      case 'reminder':
        return 'notifications';
      default:
        return 'search';
    }
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
        return 'Item';
    }
  }

  TextSpan _highlightSearchQuery(
    String text,
    String query,
    TextStyle normalStyle,
    TextStyle highlightStyle,
  ) {
    if (query.isEmpty) {
      return TextSpan(text: text, style: normalStyle);
    }

    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final String lowerQuery = query.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index != -1) {
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: normalStyle,
        ));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: highlightStyle,
      ));

      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: normalStyle,
      ));
    }

    return TextSpan(children: spans);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}