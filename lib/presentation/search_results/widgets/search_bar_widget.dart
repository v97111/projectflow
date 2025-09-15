import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SearchBarWidget extends StatefulWidget {
  final String initialQuery;
  final Function(String) onSearchChanged;
  final VoidCallback? onVoiceSearch;
  final VoidCallback? onBarcodeSearch;
  final VoidCallback? onFilterTap;

  const SearchBarWidget({
    super.key,
    required this.initialQuery,
    required this.onSearchChanged,
    this.onVoiceSearch,
    this.onBarcodeSearch,
    this.onFilterTap,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _searchController;
  bool _isVoiceSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: widget.onSearchChanged,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Search workspaces, projects, nodes...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearchChanged('');
                        },
                        icon: CustomIconWidget(
                          iconName: 'clear',
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          size: 20,
                        ),
                      ),
                    if (widget.onVoiceSearch != null)
                      IconButton(
                        onPressed: _isVoiceSearching
                            ? null
                            : () {
                                HapticFeedback.lightImpact();
                                setState(() => _isVoiceSearching = true);
                                widget.onVoiceSearch?.call();
                                Future.delayed(const Duration(seconds: 2), () {
                                  if (mounted)
                                    setState(() => _isVoiceSearching = false);
                                });
                              },
                        icon: _isVoiceSearching
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.primary,
                                ),
                              )
                            : CustomIconWidget(
                                iconName: 'mic',
                                color: colorScheme.primary,
                                size: 20,
                              ),
                      ),
                    if (widget.onBarcodeSearch != null)
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          widget.onBarcodeSearch?.call();
                        },
                        icon: CustomIconWidget(
                          iconName: 'qr_code_scanner',
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    if (widget.onFilterTap != null)
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          widget.onFilterTap?.call();
                        },
                        icon: CustomIconWidget(
                          iconName: 'filter_list',
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                  ],
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.h,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}