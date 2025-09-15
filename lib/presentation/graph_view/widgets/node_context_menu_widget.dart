import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Context menu widget for node actions
class NodeContextMenuWidget extends StatefulWidget {
  final GraphNode node;
  final Offset position;
  final Function() onEdit;
  final Function() onDelete;
  final Function() onChangeColor;
  final Function() onAddConnection;
  final Function() onDuplicate;
  final Function() onClose;

  const NodeContextMenuWidget({
    super.key,
    required this.node,
    required this.position,
    required this.onEdit,
    required this.onDelete,
    required this.onChangeColor,
    required this.onAddConnection,
    required this.onDuplicate,
    required this.onClose,
  });

  @override
  State<NodeContextMenuWidget> createState() => _NodeContextMenuWidgetState();
}

class _NodeContextMenuWidgetState extends State<NodeContextMenuWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned(
              left: widget.position.dx,
              top: widget.position.dy,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildContextMenu(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the context menu
  Widget _buildContextMenu() {
    final theme = AppTheme.lightTheme;
    final colorScheme = theme.colorScheme;

    return Container(
      width: 50.w,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.2),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with node info
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Color(widget.node.color).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: Color(widget.node.color),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    widget.node.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          _buildMenuItem(
            icon: 'edit',
            label: 'Edit Node',
            onTap: () {
              widget.onClose();
              widget.onEdit();
            },
          ),
          _buildMenuItem(
            icon: 'palette',
            label: 'Change Color',
            onTap: () {
              widget.onClose();
              widget.onChangeColor();
            },
          ),
          _buildMenuItem(
            icon: 'link',
            label: 'Add Connection',
            onTap: () {
              widget.onClose();
              widget.onAddConnection();
            },
          ),
          _buildMenuItem(
            icon: 'content_copy',
            label: 'Duplicate',
            onTap: () {
              widget.onClose();
              widget.onDuplicate();
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: 'delete',
            label: 'Delete Node',
            onTap: () {
              widget.onClose();
              widget.onDelete();
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  /// Builds individual menu item
  Widget _buildMenuItem({
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = AppTheme.lightTheme;
    final colorScheme = theme.colorScheme;

    final itemColor = isDestructive ? colorScheme.error : colorScheme.onSurface;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: itemColor,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: itemColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds divider between menu sections
  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
    );
  }
}

/// Graph node data model (if not already defined)
class GraphNode {
  final String id;
  final String title;
  final String description;
  final Offset position;
  final int color;
  final DateTime createdAt;
  final DateTime? updatedAt;

  GraphNode({
    required this.id,
    required this.title,
    required this.description,
    required this.position,
    required this.color,
    required this.createdAt,
    this.updatedAt,
  });

  GraphNode copyWith({
    String? id,
    String? title,
    String? description,
    Offset? position,
    int? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GraphNode(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      position: position ?? this.position,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
