import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Floating action button widget for quick node creation
class FloatingAddButtonWidget extends StatefulWidget {
  final bool isVisible;
  final Function() onAddNode;
  final Function() onAddConnection;
  final Function() onQuickActions;

  const FloatingAddButtonWidget({
    super.key,
    required this.isVisible,
    required this.onAddNode,
    required this.onAddConnection,
    required this.onQuickActions,
  });

  @override
  State<FloatingAddButtonWidget> createState() =>
      _FloatingAddButtonWidgetState();
}

class _FloatingAddButtonWidgetState extends State<FloatingAddButtonWidget>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _expandAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _expandAnimation;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _expandAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Curves.easeOutBack,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.125, // 45 degrees (1/8 turn)
    ).animate(CurvedAnimation(
      parent: _expandAnimationController,
      curve: Curves.easeInOut,
    ));

    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandAnimationController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void didUpdateWidget(FloatingAddButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _mainAnimationController.forward();
      } else {
        _mainAnimationController.reverse();
        _collapseMenu();
      }
    }
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _expandAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _mainAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              // Expanded menu items
              if (_isExpanded) ..._buildExpandedMenuItems(),

              // Main FAB
              _buildMainFAB(),
            ],
          ),
        );
      },
    );
  }

  /// Builds the main floating action button
  Widget _buildMainFAB() {
    final theme = AppTheme.lightTheme;
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return FloatingActionButton(
          onPressed: _handleMainFABTap,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 6,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: CustomIconWidget(
              iconName: _isExpanded ? 'close' : 'add',
              color: colorScheme.onPrimary,
              size: 24,
            ),
          ),
        );
      },
    );
  }

  /// Builds expanded menu items
  List<Widget> _buildExpandedMenuItems() {
    return [
      // Add Node option
      AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -20.w * _expandAnimation.value),
            child: Transform.scale(
              scale: _expandAnimation.value,
              child: _buildMenuOption(
                icon: 'add_circle_outline',
                label: 'Add Node',
                color: AppTheme.getSuccessColor(true),
                onTap: () {
                  _collapseMenu();
                  widget.onAddNode();
                },
              ),
            ),
          );
        },
      ),

      // Add Connection option
      AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -35.w * _expandAnimation.value),
            child: Transform.scale(
              scale: _expandAnimation.value,
              child: _buildMenuOption(
                icon: 'link',
                label: 'Connect',
                color: AppTheme.getAccentColor(true),
                onTap: () {
                  _collapseMenu();
                  widget.onAddConnection();
                },
              ),
            ),
          );
        },
      ),

      // Quick Actions option
      AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -50.w * _expandAnimation.value),
            child: Transform.scale(
              scale: _expandAnimation.value,
              child: _buildMenuOption(
                icon: 'auto_awesome',
                label: 'Quick Actions',
                color: AppTheme.getWarningColor(true),
                onTap: () {
                  _collapseMenu();
                  widget.onQuickActions();
                },
              ),
            ),
          );
        },
      ),
    ];
  }

  /// Builds individual menu option
  Widget _buildMenuOption({
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightTheme.colorScheme.shadow
                    .withValues(alpha: 0.1),
                offset: const Offset(0, 2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Text(
            label,
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        SizedBox(width: 2.w),

        // Button
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: icon,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Handles main FAB tap
  void _handleMainFABTap() {
    HapticFeedback.lightImpact();

    if (_isExpanded) {
      _collapseMenu();
    } else {
      _expandMenu();
    }
  }

  /// Expands the menu
  void _expandMenu() {
    setState(() {
      _isExpanded = true;
    });
    _expandAnimationController.forward();
  }

  /// Collapses the menu
  void _collapseMenu() {
    _expandAnimationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isExpanded = false;
        });
      }
    });
  }
}
