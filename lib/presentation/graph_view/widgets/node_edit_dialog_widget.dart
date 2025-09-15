import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Dialog widget for editing node properties
class NodeEditDialogWidget extends StatefulWidget {
  final GraphNode? node;
  final Function(String title, String description, int color) onSave;
  final Function() onCancel;

  const NodeEditDialogWidget({
    super.key,
    this.node,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<NodeEditDialogWidget> createState() => _NodeEditDialogWidgetState();
}

class _NodeEditDialogWidgetState extends State<NodeEditDialogWidget>
    with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  int _selectedColor = 0xFF2563EB; // Default blue
  final List<int> _availableColors = [
    0xFF2563EB, // Blue
    0xFF059669, // Green
    0xFFD97706, // Orange
    0xFFDC2626, // Red
    0xFF7C3AED, // Purple
    0xFF0891B2, // Cyan
    0xFFBE185D, // Pink
    0xFF374151, // Gray
    0xFF92400E, // Brown
    0xFF1F2937, // Dark Gray
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.node?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.node?.description ?? '');
    _selectedColor = widget.node?.color ?? _availableColors.first;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildDialogContent(),
          );
        },
      ),
    );
  }

  /// Builds the dialog content
  Widget _buildDialogContent() {
    final theme = AppTheme.lightTheme;
    final colorScheme = theme.colorScheme;

    return Container(
      width: 85.w,
      constraints: BoxConstraints(maxHeight: 80.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.2),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Color(_selectedColor).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: Color(_selectedColor),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: CustomIconWidget(
                    iconName: 'edit',
                    color: _getContrastColor(Color(_selectedColor)),
                    size: 20,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    widget.node != null ? 'Edit Node' : 'Create Node',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onCancel();
                  },
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title field
                  Text(
                    'Node Title',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextField(
                    controller: _titleController,
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Enter node title',
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: CustomIconWidget(
                          iconName: 'title',
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          size: 20,
                        ),
                      ),
                    ),
                    maxLength: 50,
                    textCapitalization: TextCapitalization.words,
                  ),

                  SizedBox(height: 2.h),

                  // Description field
                  Text(
                    'Description',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextField(
                    controller: _descriptionController,
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Enter node description (optional)',
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: CustomIconWidget(
                          iconName: 'description',
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          size: 20,
                        ),
                      ),
                    ),
                    maxLines: 3,
                    maxLength: 200,
                    textCapitalization: TextCapitalization.sentences,
                  ),

                  SizedBox(height: 2.h),

                  // Color selection
                  Text(
                    'Node Color',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  _buildColorPicker(),
                ],
              ),
            ),
          ),

          // Actions
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
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
                      widget.onCancel();
                    },
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canSave() ? _handleSave : null,
                    child: Text(widget.node != null ? 'Update' : 'Create'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds color picker grid
  Widget _buildColorPicker() {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 2.w,
        runSpacing: 2.w,
        children:
            _availableColors.map((color) => _buildColorOption(color)).toList(),
      ),
    );
  }

  /// Builds individual color option
  Widget _buildColorOption(int color) {
    final isSelected = _selectedColor == color;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: Color(color),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(color).withValues(alpha: 0.3),
              offset: const Offset(0, 2),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: isSelected
            ? Center(
                child: CustomIconWidget(
                  iconName: 'check',
                  color: _getContrastColor(Color(color)),
                  size: 16,
                ),
              )
            : null,
      ),
    );
  }

  /// Checks if form can be saved
  bool _canSave() {
    return _titleController.text.trim().isNotEmpty;
  }

  /// Handles save action
  void _handleSave() {
    if (_canSave()) {
      HapticFeedback.lightImpact();
      widget.onSave(
        _titleController.text.trim(),
        _descriptionController.text.trim(),
        _selectedColor,
      );
    }
  }

  /// Gets contrast color for text on colored background
  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
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
