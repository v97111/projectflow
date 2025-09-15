import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CreateWorkspaceBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onCreateWorkspace;

  const CreateWorkspaceBottomSheet({
    super.key,
    required this.onCreateWorkspace,
  });

  @override
  State<CreateWorkspaceBottomSheet> createState() =>
      _CreateWorkspaceBottomSheetState();
}

class _CreateWorkspaceBottomSheetState
    extends State<CreateWorkspaceBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Color _selectedColor = const Color(0xFF2563EB);
  String _selectedIcon = 'folder';
  bool _isCreating = false;

  final List<Color> _colorOptions = [
    const Color(0xFF2563EB), // Blue
    const Color(0xFF059669), // Green
    const Color(0xFFD97706), // Orange
    const Color(0xFFDC2626), // Red
    const Color(0xFF7C3AED), // Purple
    const Color(0xFF0891B2), // Cyan
    const Color(0xFFDB2777), // Pink
    const Color(0xFF65A30D), // Lime
    const Color(0xFF9333EA), // Violet
    const Color(0xFF0D9488), // Teal
    const Color(0xFFE11D48), // Rose
    const Color(0xFF7C2D12), // Brown
  ];

  final List<String> _iconOptions = [
    'folder',
    'work',
    'business',
    'school',
    'home',
    'favorite',
    'star',
    'lightbulb',
    'palette',
    'code',
    'design_services',
    'campaign',
    'analytics',
    'trending_up',
    'rocket_launch',
    'psychology',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 10.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: colorScheme.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                Text(
                  'Create Workspace',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: _isCreating || _nameController.text.trim().isEmpty
                      ? null
                      : _createWorkspace,
                  child: _isCreating
                      ? SizedBox(
                          width: 5.w,
                          height: 5.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        )
                      : Text(
                          'Create',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: _nameController.text.trim().isEmpty
                                ? colorScheme.onSurface.withValues(alpha: 0.4)
                                : colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),

          Divider(color: colorScheme.outline.withValues(alpha: 0.2)),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Preview
                  Center(
                    child: Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _selectedColor.withValues(alpha: 0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: _selectedIcon,
                          color: Colors.white,
                          size: 10.w,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Name field
                  Text(
                    'Workspace Name',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter workspace name',
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: CustomIconWidget(
                          iconName: 'edit',
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          size: 5.w,
                        ),
                      ),
                    ),
                    onChanged: (value) => setState(() {}),
                    textCapitalization: TextCapitalization.words,
                  ),

                  SizedBox(height: 3.h),

                  // Description field
                  Text(
                    'Description (Optional)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: 'Enter workspace description',
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: CustomIconWidget(
                          iconName: 'description',
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          size: 5.w,
                        ),
                      ),
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),

                  SizedBox(height: 3.h),

                  // Color picker
                  Text(
                    'Choose Color',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 3.w,
                    runSpacing: 2.h,
                    children: _colorOptions.map((color) {
                      final isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _selectedColor = color);
                        },
                        child: Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: colorScheme.onSurface, width: 3)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.3),
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
                                    color: Colors.white,
                                    size: 6.w,
                                  ),
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 3.h),

                  // Icon picker
                  Text(
                    'Choose Icon',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 3.w,
                    runSpacing: 2.h,
                    children: _iconOptions.map((icon) {
                      final isSelected = _selectedIcon == icon;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _selectedIcon = icon);
                        },
                        child: Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primaryContainer
                                : colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outline.withValues(alpha: 0.2),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: icon,
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                              size: 6.w,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _createWorkspace() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isCreating = true);

    try {
      final workspace = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'color': _selectedColor.value,
        'icon': _selectedIcon,
        'projectCount': 0,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Simulate creation delay
      await Future.delayed(const Duration(milliseconds: 500));

      widget.onCreateWorkspace(workspace);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('Failed to create workspace. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }
}
