import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom app bar widget implementing Contemporary Spatial Minimalism
/// with gesture-first navigation and contextual actions for mobile project management
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// App bar variant types
  enum AppBarVariant {
    standard,      // Standard app bar with title and actions
    search,        // App bar with integrated search functionality
    contextual,    // Contextual app bar for selection states
    minimal,       // Minimal app bar with reduced visual weight
  }

  /// Creates a custom app bar
  const CustomAppBar({
    super.key,
    required this.title,
    this.variant = AppBarVariant.standard,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onSearchChanged,
    this.searchHint = 'Search...',
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = false,
    this.bottom,
    this.flexibleSpace,
    this.toolbarHeight,
  });

  /// The title to display in the app bar
  final String title;
  
  /// The variant of the app bar
  final AppBarVariant variant;
  
  /// Actions to display in the app bar
  final List<Widget>? actions;
  
  /// Leading widget (overrides back button if provided)
  final Widget? leading;
  
  /// Whether to show the back button
  final bool showBackButton;
  
  /// Callback for search text changes (required for search variant)
  final ValueChanged<String>? onSearchChanged;
  
  /// Hint text for search input
  final String searchHint;
  
  /// Background color override
  final Color? backgroundColor;
  
  /// Foreground color override
  final Color? foregroundColor;
  
  /// Elevation override
  final double? elevation;
  
  /// Whether to center the title
  final bool centerTitle;
  
  /// Bottom widget for the app bar
  final PreferredSizeWidget? bottom;
  
  /// Flexible space widget
  final Widget? flexibleSpace;
  
  /// Custom toolbar height
  final double? toolbarHeight;

  @override
  Size get preferredSize {
    final double height = toolbarHeight ?? kToolbarHeight;
    final double bottomHeight = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight(height + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    return AppBar(
      title: _buildTitle(context),
      leading: _buildLeading(context),
      actions: _buildActions(context),
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
      elevation: _getElevation(),
      shadowColor: theme.appBarTheme.shadowColor,
      surfaceTintColor: Colors.transparent,
      centerTitle: centerTitle,
      titleSpacing: variant == AppBarVariant.search ? 0 : null,
      bottom: bottom,
      flexibleSpace: flexibleSpace,
      toolbarHeight: toolbarHeight,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );
  }

  /// Builds the title widget based on variant
  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);
    
    switch (variant) {
      case AppBarVariant.search:
        return _buildSearchField(context);
      case AppBarVariant.contextual:
        return _buildContextualTitle(context);
      case AppBarVariant.minimal:
        return _buildMinimalTitle(context);
      case AppBarVariant.standard:
      default:
        return Text(
          title,
          style: theme.appBarTheme.titleTextStyle,
          overflow: TextOverflow.ellipsis,
        );
    }
  }

  /// Builds search field for search variant
  Widget _buildSearchField(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withAlpha(51),
          width: 1,
        ),
      ),
      child: TextField(
        onChanged: onSearchChanged,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: theme.appBarTheme.foregroundColor,
        ),
        decoration: InputDecoration(
          hintText: searchHint,
          hintStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: theme.appBarTheme.foregroundColor?.withAlpha(153),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.appBarTheme.foregroundColor?.withAlpha(153),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
        onTap: () {
          HapticFeedback.lightImpact();
        },
      ),
    );
  }

  /// Builds contextual title for selection states
  Widget _buildContextualTitle(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.appBarTheme.titleTextStyle?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Builds minimal title with reduced visual weight
  Widget _buildMinimalTitle(BuildContext context) {
    final theme = Theme.of(context);
    
    return Text(
      title,
      style: theme.appBarTheme.titleTextStyle?.copyWith(
        fontWeight: FontWeight.w400,
        fontSize: 16,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds leading widget
  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;
    
    if (!showBackButton) return null;
    
    final bool canPop = ModalRoute.of(context)?.canPop ?? false;
    if (!canPop) return null;

    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
      },
      tooltip: 'Back',
    );
  }

  /// Builds action widgets
  List<Widget>? _buildActions(BuildContext context) {
    if (actions != null) return actions;
    
    switch (variant) {
      case AppBarVariant.standard:
        return _buildStandardActions(context);
      case AppBarVariant.search:
        return _buildSearchActions(context);
      case AppBarVariant.contextual:
        return _buildContextualActions(context);
      case AppBarVariant.minimal:
        return null;
      default:
        return null;
    }
  }

  /// Builds standard actions
  List<Widget> _buildStandardActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pushNamed(context, '/search-results');
        },
        tooltip: 'Search',
      ),
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (value) {
          HapticFeedback.lightImpact();
          _handleMenuAction(context, value);
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'settings',
            child: Row(
              children: [
                Icon(Icons.settings, size: 20),
                SizedBox(width: 12),
                Text('Settings'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'help',
            child: Row(
              children: [
                Icon(Icons.help_outline, size: 20),
                SizedBox(width: 12),
                Text('Help'),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  /// Builds search actions
  List<Widget> _buildSearchActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.filter_list),
        onPressed: () {
          HapticFeedback.lightImpact();
          _showFilterBottomSheet(context);
        },
        tooltip: 'Filter',
      ),
    ];
  }

  /// Builds contextual actions for selection states
  List<Widget> _buildContextualActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.select_all),
        onPressed: () {
          HapticFeedback.lightImpact();
          // Handle select all
        },
        tooltip: 'Select All',
      ),
      IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () {
          HapticFeedback.lightImpact();
          _showDeleteConfirmation(context);
        },
        tooltip: 'Delete',
      ),
    ];
  }

  /// Gets elevation based on variant
  double _getElevation() {
    if (elevation != null) return elevation!;
    
    switch (variant) {
      case AppBarVariant.minimal:
        return 0;
      case AppBarVariant.search:
        return 2;
      case AppBarVariant.contextual:
        return 4;
      case AppBarVariant.standard:
      default:
        return 0;
    }
  }

  /// Handles menu actions
  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'settings':
        // Navigate to settings
        break;
      case 'help':
        // Show help
        break;
    }
  }

  /// Shows filter bottom sheet
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
                'Filter Options',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            // Add filter options here
          ],
        ),
      ),
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