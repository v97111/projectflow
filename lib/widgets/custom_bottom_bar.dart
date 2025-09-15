import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bottom bar variant types
enum BottomBarVariant {
  standard,     // Standard bottom navigation with 5 tabs
  compact,      // Compact version with 4 tabs
  floating,     // Floating action button integrated
  contextual,   // Contextual actions overlay
}

/// Custom bottom navigation bar implementing gesture-first navigation
/// with haptic feedback and contextual bottom sheets for mobile project management
class CustomBottomBar extends StatefulWidget {
  /// Creates a custom bottom navigation bar
  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.variant = BottomBarVariant.standard,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation,
    this.showLabels = true,
    this.enableHapticFeedback = true,
  });

  /// Current selected index
  final int currentIndex;
  
  /// Callback when tab is tapped
  final ValueChanged<int> onTap;
  
  /// Variant of the bottom bar
  final BottomBarVariant variant;
  
  /// Background color override
  final Color? backgroundColor;
  
  /// Selected item color override
  final Color? selectedItemColor;
  
  /// Unselected item color override
  final Color? unselectedItemColor;
  
  /// Elevation override
  final double? elevation;
  
  /// Whether to show labels
  final bool showLabels;
  
  /// Whether to enable haptic feedback
  final bool enableHapticFeedback;

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar>
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
      end: 0.95,
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
      case BottomBarVariant.floating:
        return _buildFloatingBottomBar(context);
      case BottomBarVariant.contextual:
        return _buildContextualBottomBar(context);
      case BottomBarVariant.compact:
        return _buildCompactBottomBar(context);
      case BottomBarVariant.standard:
      default:
        return _buildStandardBottomBar(context);
    }
  }

  /// Builds standard bottom navigation bar
  Widget _buildStandardBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(20),
            offset: const Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildNavigationItems(context),
          ),
        ),
      ),
    );
  }

  /// Builds compact bottom navigation bar
  Widget _buildCompactBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(20),
            offset: const Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildCompactNavigationItems(context),
          ),
        ),
      ),
    );
  }

  /// Builds floating bottom navigation bar with FAB
  Widget _buildFloatingBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.bottomNavigationBarTheme.backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(31),
            offset: const Offset(0, 4),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildFloatingNavigationItems(context),
          ),
        ),
      ),
    );
  }

  /// Builds contextual bottom bar for actions
  Widget _buildContextualBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(31),
            offset: const Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _buildContextualActions(context),
          ),
        ),
      ),
    );
  }

  /// Builds navigation items for standard variant
  List<Widget> _buildNavigationItems(BuildContext context) {
    final items = [
      _NavigationItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: 'Dashboard',
        route: '/dashboard',
        index: 0,
      ),
      _NavigationItem(
        icon: Icons.folder_outlined,
        activeIcon: Icons.folder,
        label: 'Workspaces',
        route: '/workspace-list',
        index: 1,
      ),
      _NavigationItem(
        icon: Icons.list_alt_outlined,
        activeIcon: Icons.list_alt,
        label: 'Projects',
        route: '/project-list',
        index: 2,
      ),
      _NavigationItem(
        icon: Icons.account_tree_outlined,
        activeIcon: Icons.account_tree,
        label: 'Graph',
        route: '/graph-view',
        index: 3,
      ),
      _NavigationItem(
        icon: Icons.calendar_today_outlined,
        activeIcon: Icons.calendar_today,
        label: 'Calendar',
        route: '/calendar-view',
        index: 4,
      ),
    ];

    return items.map((item) => _buildNavigationItem(context, item)).toList();
  }

  /// Builds navigation items for compact variant
  List<Widget> _buildCompactNavigationItems(BuildContext context) {
    final items = [
      _NavigationItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: 'Dashboard',
        route: '/dashboard',
        index: 0,
      ),
      _NavigationItem(
        icon: Icons.folder_outlined,
        activeIcon: Icons.folder,
        label: 'Workspaces',
        route: '/workspace-list',
        index: 1,
      ),
      _NavigationItem(
        icon: Icons.account_tree_outlined,
        activeIcon: Icons.account_tree,
        label: 'Graph',
        route: '/graph-view',
        index: 2,
      ),
      _NavigationItem(
        icon: Icons.calendar_today_outlined,
        activeIcon: Icons.calendar_today,
        label: 'Calendar',
        route: '/calendar-view',
        index: 3,
      ),
    ];

    return items.map((item) => _buildNavigationItem(context, item)).toList();
  }

  /// Builds navigation items for floating variant with FAB
  List<Widget> _buildFloatingNavigationItems(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final items = [
      _NavigationItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: 'Dashboard',
        route: '/dashboard',
        index: 0,
      ),
      _NavigationItem(
        icon: Icons.folder_outlined,
        activeIcon: Icons.folder,
        label: 'Workspaces',
        route: '/workspace-list',
        index: 1,
      ),
    ];

    final navigationItems = items.map((item) => 
      _buildNavigationItem(context, item)).toList();

    // Add floating action button in the center
    navigationItems.add(
      GestureDetector(
        onTap: () {
          if (widget.enableHapticFeedback) {
            HapticFeedback.lightImpact();
          }
          _showCreateBottomSheet(context);
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withAlpha(77),
                offset: const Offset(0, 4),
                blurRadius: 12,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Icon(
            Icons.add,
            color: colorScheme.onPrimary,
            size: 24,
          ),
        ),
      ),
    );

    final moreItems = [
      _NavigationItem(
        icon: Icons.account_tree_outlined,
        activeIcon: Icons.account_tree,
        label: 'Graph',
        route: '/graph-view',
        index: 2,
      ),
      _NavigationItem(
        icon: Icons.calendar_today_outlined,
        activeIcon: Icons.calendar_today,
        label: 'Calendar',
        route: '/calendar-view',
        index: 3,
      ),
    ];

    navigationItems.addAll(
      moreItems.map((item) => _buildNavigationItem(context, item)).toList()
    );

    return navigationItems;
  }

  /// Builds contextual actions
  List<Widget> _buildContextualActions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return [
      _buildContextualAction(
        context,
        icon: Icons.edit_outlined,
        label: 'Edit',
        onTap: () {
          if (widget.enableHapticFeedback) {
            HapticFeedback.lightImpact();
          }
          // Handle edit action
        },
      ),
      _buildContextualAction(
        context,
        icon: Icons.share_outlined,
        label: 'Share',
        onTap: () {
          if (widget.enableHapticFeedback) {
            HapticFeedback.lightImpact();
          }
          // Handle share action
        },
      ),
      _buildContextualAction(
        context,
        icon: Icons.delete_outline,
        label: 'Delete',
        color: colorScheme.error,
        onTap: () {
          if (widget.enableHapticFeedback) {
            HapticFeedback.lightImpact();
          }
          _showDeleteConfirmation(context);
        },
      ),
    ];
  }

  /// Builds individual navigation item
  Widget _buildNavigationItem(BuildContext context, _NavigationItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = widget.currentIndex == item.index;
    
    final selectedColor = widget.selectedItemColor ?? 
        theme.bottomNavigationBarTheme.selectedItemColor ?? 
        colorScheme.primary;
    final unselectedColor = widget.unselectedItemColor ?? 
        theme.bottomNavigationBarTheme.unselectedItemColor ?? 
        colorScheme.onSurface.withAlpha(153);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (widget.enableHapticFeedback) {
            HapticFeedback.lightImpact();
          }
          _animationController.forward().then((_) {
            _animationController.reverse();
          });
          
          if (item.index != widget.currentIndex) {
            widget.onTap(item.index);
            Navigator.pushNamed(context, item.route);
          }
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isSelected ? _scaleAnimation.value : 1.0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? selectedColor.withAlpha(26)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isSelected ? item.activeIcon : item.icon,
                        color: isSelected ? selectedColor : unselectedColor,
                        size: 24,
                      ),
                    ),
                    if (widget.showLabels) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                          color: isSelected ? selectedColor : unselectedColor,
                          letterSpacing: 0.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds contextual action button
  Widget _buildContextualAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final actionColor = color ?? colorScheme.onPrimaryContainer;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: actionColor.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: actionColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: actionColor,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows create bottom sheet with contextual actions
  void _showCreateBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withAlpha(102),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Create New',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCreateOption(
                    context,
                    icon: Icons.folder_outlined,
                    title: 'New Workspace',
                    subtitle: 'Create a new workspace for your projects',
                    onTap: () {
                      Navigator.pop(context);
                      // Handle create workspace
                    },
                  ),
                  _buildCreateOption(
                    context,
                    icon: Icons.list_alt_outlined,
                    title: 'New Project',
                    subtitle: 'Start a new project in current workspace',
                    onTap: () {
                      Navigator.pop(context);
                      // Handle create project
                    },
                  ),
                  _buildCreateOption(
                    context,
                    icon: Icons.task_outlined,
                    title: 'New Task',
                    subtitle: 'Add a task to existing project',
                    onTap: () {
                      Navigator.pop(context);
                      // Handle create task
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds create option item
  Widget _buildCreateOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: colorScheme.onPrimaryContainer,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall,
      ),
      onTap: () {
        if (widget.enableHapticFeedback) {
          HapticFeedback.lightImpact();
        }
        onTap();
      },
    );
  }

  /// Shows delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Items'),
        content: const Text('Are you sure you want to delete the selected items?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle delete
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Navigation item data class
class _NavigationItem {
  const _NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.index,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final int index;
}