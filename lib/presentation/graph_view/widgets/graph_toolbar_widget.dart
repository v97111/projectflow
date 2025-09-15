import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Bottom toolbar widget for graph view actions
class GraphToolbarWidget extends StatefulWidget {
  final bool isVisible;
  final Function() onAddNode;
  final Function() onAutoLayout;
  final Function() onZoomIn;
  final Function() onZoomOut;
  final Function() onFitToScreen;
  final Function() onViewOptions;
  final bool isAutoLayoutEnabled;
  final double currentZoom;

  const GraphToolbarWidget({
    super.key,
    required this.isVisible,
    required this.onAddNode,
    required this.onAutoLayout,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onFitToScreen,
    required this.onViewOptions,
    this.isAutoLayoutEnabled = false,
    this.currentZoom = 1.0,
  });

  @override
  State<GraphToolbarWidget> createState() => _GraphToolbarWidgetState();
}

class _GraphToolbarWidgetState extends State<GraphToolbarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(GraphToolbarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: EdgeInsets.all(4.w),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.shadow
                        .withValues(alpha: 0.15),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ],
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildToolbarButton(
                    icon: 'add_circle_outline',
                    label: 'Add Node',
                    onTap: widget.onAddNode,
                    isPrimary: true,
                  ),
                  _buildDivider(),
                  _buildToolbarButton(
                    icon: widget.isAutoLayoutEnabled
                        ? 'auto_awesome'
                        : 'auto_fix_normal',
                    label: 'Auto Layout',
                    onTap: widget.onAutoLayout,
                    isActive: widget.isAutoLayoutEnabled,
                  ),
                  _buildDivider(),
                  _buildZoomControls(),
                  _buildDivider(),
                  _buildToolbarButton(
                    icon: 'fit_screen',
                    label: 'Fit Screen',
                    onTap: widget.onFitToScreen,
                  ),
                  _buildDivider(),
                  _buildToolbarButton(
                    icon: 'tune',
                    label: 'Options',
                    onTap: widget.onViewOptions,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds individual toolbar button
  Widget _buildToolbarButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
    bool isActive = false,
  }) {
    final theme = AppTheme.lightTheme;
    final colorScheme = theme.colorScheme;

    Color buttonColor;
    Color iconColor;
    Color textColor;

    if (isPrimary) {
      buttonColor = colorScheme.primary;
      iconColor = colorScheme.onPrimary;
      textColor = colorScheme.onPrimary;
    } else if (isActive) {
      buttonColor = colorScheme.primaryContainer;
      iconColor = colorScheme.onPrimaryContainer;
      textColor = colorScheme.onPrimaryContainer;
    } else {
      buttonColor = Colors.transparent;
      iconColor = colorScheme.onSurface;
      textColor = colorScheme.onSurface;
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: iconColor,
              size: 24,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: textColor,
                fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds zoom controls
  Widget _buildZoomControls() {
    final theme = AppTheme.lightTheme;
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onZoomOut();
            },
            child: Container(
              padding: EdgeInsets.all(1.w),
              child: CustomIconWidget(
                iconName: 'zoom_out',
                color: colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(widget.currentZoom * 100).round()}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onZoomIn();
            },
            child: Container(
              padding: EdgeInsets.all(1.w),
              child: CustomIconWidget(
                iconName: 'zoom_in',
                color: colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds divider between toolbar sections
  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 6.h,
      color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
    );
  }
}
