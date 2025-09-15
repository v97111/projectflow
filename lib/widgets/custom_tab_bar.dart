import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../presentation/dashboard/dashboard.dart';

/// Custom tab bar widget implementing Contemporary Spatial Minimalism
/// with gesture-first navigation and progressive disclosure for mobile project management
class CustomTabBar extends StatefulWidget implements PreferredSizeWidget {
  /// Tab bar variant types
  enum TabBarVariant {
    standard,     // Standard tab bar with text labels
    icon,         // Icon-only tab bar for compact spaces
    mixed,        // Mixed icon and text tabs
    scrollable,   // Scrollable tabs for many options
    segmented,    // Segmented control style
  }

  /// Creates a custom tab bar
  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.controller,
    this.variant = TabBarVariant.standard,
    this.onTap,
    this.isScrollable = false,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.backgroundColor,
    this.elevation,
    this.enableHapticFeedback = true,
    this.showDivider = true,
  });

  /// List of tabs to display
  final List<CustomTab> tabs;
  
  /// Tab controller
  final TabController controller;
  
  /// Variant of the tab bar
  final TabBarVariant variant;
  
  /// Callback when tab is tapped
  final ValueChanged<int>? onTap;
  
  /// Whether tabs are scrollable
  final bool isScrollable;
  
  /// Indicator color override
  final Color? indicatorColor;
  
  /// Label color override
  final Color? labelColor;
  
  /// Unselected label color override
  final Color? unselectedLabelColor;
  
  /// Background color override
  final Color? backgroundColor;
  
  /// Elevation override
  final double? elevation;
  
  /// Whether to enable haptic feedback
  final bool enableHapticFeedback;
  
  /// Whether to show bottom divider
  final bool showDivider;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.variant) {
      case TabBarVariant.segmented:
        return _buildSegmentedTabBar(context);
      case TabBarVariant.scrollable:
        return _buildScrollableTabBar(context);
      case TabBarVariant.icon:
        return _buildIconTabBar(context);
      case TabBarVariant.mixed:
        return _buildMixedTabBar(context);
      case TabBarVariant.standard:
      default:
        return _buildStandardTabBar(context);
    }
  }

  /// Builds standard tab bar
  Widget _buildStandardTabBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.colorScheme.surface,
        border: widget.showDivider
            ? Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withAlpha(51),
                  width: 1,
                ),
              )
            : null,
      ),
      child: TabBar(
        controller: widget.controller,
        tabs: widget.tabs.map((tab) => _buildStandardTab(context, tab)).toList(),
        onTap: (index) {
          if (widget.enableHapticFeedback) {
            HapticFeedback.lightImpact();
          }
          _animationController.forward().then((_) {
            _animationController.reverse();
          });
          widget.onTap?.call(index);
        },
        isScrollable: widget.isScrollable,
        indicatorColor: widget.indicatorColor ?? colorScheme.primary,
        labelColor: widget.labelColor ?? colorScheme.primary,
        unselectedLabelColor: widget.unselectedLabelColor ?? 
            colorScheme.onSurface.withAlpha(153),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 2,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  /// Builds icon-only tab bar
  Widget _buildIconTabBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.colorScheme.surface,
        border: widget.showDivider
            ? Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withAlpha(51),
                  width: 1,
                ),
              )
            : null,
      ),
      child: TabBar(
        controller: widget.controller,
        tabs: widget.tabs.map((tab) => _buildIconTab(context, tab)).toList(),
        onTap: (index) {
          if (widget.enableHapticFeedback) {
            HapticFeedback.lightImpact();
          }
          _animationController.forward().then((_) {
            _animationController.reverse();
          });
          widget.onTap?.call(index);
        },
        isScrollable: widget.isScrollable,
        indicatorColor: widget.indicatorColor ?? colorScheme.primary,
        labelColor: widget.labelColor ?? colorScheme.primary,
        unselectedLabelColor: widget.unselectedLabelColor ?? 
            colorScheme.onSurface.withAlpha(153),
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 2,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  /// Builds mixed icon and text tab bar
  Widget _buildMixedTabBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.colorScheme.surface,
        border: widget.showDivider
            ? Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withAlpha(51),
                  width: 1,
                ),
              )
            : null,
      ),
      child: TabBar(
        controller: widget.controller,
        tabs: widget.tabs.map((tab) => _buildMixedTab(context, tab)).toList(),
        onTap: (index) {
          if (widget.enableHapticFeedback) {
            HapticFeedback.lightImpact();
          }
          _animationController.forward().then((_) {
            _animationController.reverse();
          });
          widget.onTap?.call(index);
        },
        isScrollable: widget.isScrollable,
        indicatorColor: widget.indicatorColor ?? colorScheme.primary,
        labelColor: widget.labelColor ?? colorScheme.primary,
        unselectedLabelColor: widget.unselectedLabelColor ?? 
            colorScheme.onSurface.withAlpha(153),
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 2,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  /// Builds scrollable tab bar
  Widget _buildScrollableTabBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.colorScheme.surface,
        border: widget.showDivider
            ? Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withAlpha(51),
                  width: 1,
                ),
              )
            : null,
      ),
      child: TabBar(
        controller: widget.controller,
        tabs: widget.tabs.map((tab) => _buildScrollableTab(context, tab)).toList(),
        onTap: (index) {
          if (widget.enableHapticFeedback) {
            HapticFeedback.lightImpact();
          }
          _animationController.forward().then((_) {
            _animationController.reverse();
          });
          widget.onTap?.call(index);
        },
        isScrollable: true,
        indicatorColor: widget.indicatorColor ?? colorScheme.primary,
        labelColor: widget.labelColor ?? colorScheme.primary,
        unselectedLabelColor: widget.unselectedLabelColor ?? 
            colorScheme.onSurface.withAlpha(153),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 2,
        tabAlignment: TabAlignment.start,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  /// Builds segmented control style tab bar
  Widget _buildSegmentedTabBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: widget.tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = widget.controller.index == index;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (widget.enableHapticFeedback) {
                  HapticFeedback.lightImpact();
                }
                widget.controller.animateTo(index);
                widget.onTap?.call(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colorScheme.shadow.withAlpha(26),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    tab.text ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected 
                          ? colorScheme.onSurface 
                          : colorScheme.onSurface.withAlpha(153),
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Builds standard tab
  Widget _buildStandardTab(BuildContext context, CustomTab tab) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Tab(
            text: tab.text,
            height: 48,
          ),
        );
      },
    );
  }

  /// Builds icon tab
  Widget _buildIconTab(BuildContext context, CustomTab tab) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Tab(
            icon: Icon(tab.icon, size: 24),
            height: 48,
          ),
        );
      },
    );
  }

  /// Builds mixed tab with icon and text
  Widget _buildMixedTab(BuildContext context, CustomTab tab) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Tab(
            icon: Icon(tab.icon, size: 20),
            text: tab.text,
            height: 48,
          ),
        );
      },
    );
  }

  /// Builds scrollable tab with badge support
  Widget _buildScrollableTab(BuildContext context, CustomTab tab) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (tab.icon != null) ...[
                    Icon(tab.icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(tab.text ?? ''),
                  if (tab.badge != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tab.badge!,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onError,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Custom tab data class
class CustomTab {
  const CustomTab({
    this.text,
    this.icon,
    this.badge,
    this.route,
  });

  /// Tab text label
  final String? text;
  
  /// Tab icon
  final IconData? icon;
  
  /// Badge text (for notifications, counts, etc.)
  final String? badge;
  
  /// Route to navigate when tab is selected
  final String? route;
}

/// Predefined tab configurations for common use cases
class TabConfigurations {
  /// Dashboard tabs for project overview
  static List<CustomTab> dashboardTabs = [
    const CustomTab(
      text: 'Overview',
      icon: Icons.dashboard_outlined,
      route: '/dashboard',
    ),
    const CustomTab(
      text: 'Recent',
      icon: Icons.history,
    ),
    const CustomTab(
      text: 'Favorites',
      icon: Icons.star_outline,
    ),
  ];

  /// Project management tabs
  static List<CustomTab> projectTabs = [
    const CustomTab(
      text: 'Tasks',
      icon: Icons.task_outlined,
    ),
    const CustomTab(
      text: 'Timeline',
      icon: Icons.timeline,
    ),
    const CustomTab(
      text: 'Team',
      icon: Icons.people_outline,
    ),
    const CustomTab(
      text: 'Files',
      icon: Icons.folder_outlined,
    ),
  ];

  /// Graph view tabs
  static List<CustomTab> graphTabs = [
    const CustomTab(
      text: 'Network',
      icon: Icons.account_tree_outlined,
      route: '/graph-view',
    ),
    const CustomTab(
      text: 'Hierarchy',
      icon: Icons.device_hub,
    ),
    const CustomTab(
      text: 'Dependencies',
      icon: Icons.link,
    ),
  ];

  /// Calendar view tabs
  static List<CustomTab> calendarTabs = [
    const CustomTab(
      text: 'Month',
      icon: Icons.calendar_view_month,
      route: '/calendar-view',
    ),
    const CustomTab(
      text: 'Week',
      icon: Icons.calendar_view_week,
    ),
    const CustomTab(
      text: 'Day',
      icon: Icons.calendar_today,
    ),
    const CustomTab(
      text: 'Agenda',
      icon: Icons.list_alt,
    ),
  ];

  /// Workspace tabs
  static List<CustomTab> workspaceTabs = [
    const CustomTab(
      text: 'Projects',
      icon: Icons.folder_outlined,
      route: '/workspace-list',
    ),
    const CustomTab(
      text: 'Members',
      icon: Icons.people_outline,
    ),
    const CustomTab(
      text: 'Settings',
      icon: Icons.settings_outlined,
    ),
  ];
}