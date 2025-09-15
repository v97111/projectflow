import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/create_workspace_bottom_sheet.dart';
import './widgets/empty_workspace_state.dart';
import './widgets/workspace_card_widget.dart';
import './widgets/workspace_search_delegate.dart';

class WorkspaceList extends StatefulWidget {
  const WorkspaceList({super.key});

  @override
  State<WorkspaceList> createState() => _WorkspaceListState();
}

class _WorkspaceListState extends State<WorkspaceList>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _workspaces = [];
  List<String> _selectedWorkspaceIds = [];
  bool _isMultiSelectMode = false;
  bool _isLoading = true;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  // Mock data for workspaces
  final List<Map<String, dynamic>> _mockWorkspaces = [
    {
      'id': '1',
      'name': 'Personal Projects',
      'description': 'My personal development and creative projects',
      'color': 0xFF2563EB,
      'icon': 'person',
      'projectCount': 5,
      'createdAt': '2024-01-15T10:30:00Z',
      'updatedAt': '2024-09-14T15:45:00Z',
    },
    {
      'id': '2',
      'name': 'Work & Business',
      'description': 'Professional projects and client work',
      'color': 0xFF059669,
      'icon': 'work',
      'projectCount': 12,
      'createdAt': '2024-02-20T09:15:00Z',
      'updatedAt': '2024-09-15T08:20:00Z',
    },
    {
      'id': '3',
      'name': 'Design Portfolio',
      'description': 'Creative design projects and experiments',
      'color': 0xFF7C3AED,
      'icon': 'palette',
      'projectCount': 8,
      'createdAt': '2024-03-10T14:22:00Z',
      'updatedAt': '2024-09-13T11:30:00Z',
    },
    {
      'id': '4',
      'name': 'Learning & Education',
      'description': 'Courses, tutorials, and skill development',
      'color': 0xFFD97706,
      'icon': 'school',
      'projectCount': 3,
      'createdAt': '2024-04-05T16:45:00Z',
      'updatedAt': '2024-09-12T09:15:00Z',
    },
    {
      'id': '5',
      'name': 'Side Hustles',
      'description': 'Entrepreneurial ventures and side projects',
      'color': 0xFFDC2626,
      'icon': 'rocket_launch',
      'projectCount': 7,
      'createdAt': '2024-05-18T12:00:00Z',
      'updatedAt': '2024-09-14T17:30:00Z',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));
    _loadWorkspaces();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkspaces() async {
    setState(() => _isLoading = true);

    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _workspaces = List.from(_mockWorkspaces);
      _isLoading = false;
    });
  }

  Future<void> _refreshWorkspaces() async {
    HapticFeedback.lightImpact();
    await _loadWorkspaces();
  }

  void _showCreateWorkspaceBottomSheet() {
    HapticFeedback.lightImpact();
    _fabAnimationController.forward().then((_) {
      _fabAnimationController.reverse();
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateWorkspaceBottomSheet(
        onCreateWorkspace: _createWorkspace,
      ),
    );
  }

  void _createWorkspace(Map<String, dynamic> workspace) {
    setState(() {
      _workspaces.insert(0, workspace);
    });

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Workspace "${workspace['name']}" created successfully'),
        backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.light),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToWorkspace(Map<String, dynamic> workspace) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/project-list', arguments: workspace);
  }

  void _editWorkspace(Map<String, dynamic> workspace) {
    HapticFeedback.lightImpact();
    // Show edit workspace bottom sheet (similar to create)
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateWorkspaceBottomSheet(
        onCreateWorkspace: (updatedWorkspace) {
          setState(() {
            final index =
                _workspaces.indexWhere((w) => w['id'] == workspace['id']);
            if (index != -1) {
              _workspaces[index] = {
                ...updatedWorkspace,
                'id': workspace['id'],
                'createdAt': workspace['createdAt'],
                'updatedAt': DateTime.now().toIso8601String(),
              };
            }
          });
        },
      ),
    );
  }

  void _duplicateWorkspace(Map<String, dynamic> workspace) {
    HapticFeedback.lightImpact();
    final duplicatedWorkspace = {
      ...workspace,
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': '${workspace['name']} Copy',
      'projectCount': 0,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    setState(() {
      _workspaces.insert(
          _workspaces.indexOf(workspace) + 1, duplicatedWorkspace);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Workspace duplicated as "${duplicatedWorkspace['name']}"'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _archiveWorkspace(Map<String, dynamic> workspace) {
    HapticFeedback.lightImpact();
    setState(() {
      _workspaces.remove(workspace);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Workspace "${workspace['name']}" archived'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _workspaces.add(workspace);
            });
          },
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteWorkspace(Map<String, dynamic> workspace) {
    HapticFeedback.mediumImpact();
    setState(() {
      _workspaces.remove(workspace);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Workspace "${workspace['name']}" deleted'),
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _workspaces.add(workspace);
            });
          },
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleWorkspaceSelection(String workspaceId) {
    setState(() {
      if (_selectedWorkspaceIds.contains(workspaceId)) {
        _selectedWorkspaceIds.remove(workspaceId);
      } else {
        _selectedWorkspaceIds.add(workspaceId);
      }

      if (_selectedWorkspaceIds.isEmpty) {
        _isMultiSelectMode = false;
      }
    });
  }

  void _enterMultiSelectMode(String workspaceId) {
    setState(() {
      _isMultiSelectMode = true;
      _selectedWorkspaceIds = [workspaceId];
    });
  }

  void _exitMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = false;
      _selectedWorkspaceIds.clear();
    });
  }

  void _selectAllWorkspaces() {
    setState(() {
      _selectedWorkspaceIds =
          _workspaces.map((w) => w['id'] as String).toList();
    });
  }

  void _deleteSelectedWorkspaces() {
    HapticFeedback.mediumImpact();
    final selectedWorkspaces = _workspaces
        .where((w) => _selectedWorkspaceIds.contains(w['id']))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workspaces'),
        content: Text(
          'Are you sure you want to delete ${_selectedWorkspaceIds.length} workspace${_selectedWorkspaceIds.length == 1 ? '' : 's'}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _workspaces.removeWhere(
                    (w) => _selectedWorkspaceIds.contains(w['id']));
                _exitMultiSelectMode();
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${selectedWorkspaces.length} workspace${selectedWorkspaces.length == 1 ? '' : 's'} deleted'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
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

  void _showSearch() {
    HapticFeedback.lightImpact();
    showSearch(
      context: context,
      delegate: WorkspaceSearchDelegate(
        workspaces: _workspaces,
        onWorkspaceSelected: _navigateToWorkspace,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _isMultiSelectMode
          ? _buildMultiSelectAppBar()
          : _buildStandardAppBar(),
      body: _isLoading ? _buildLoadingState() : _buildBody(),
      floatingActionButton:
          _isMultiSelectMode ? null : _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildStandardAppBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Text(
        'Workspaces',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: colorScheme.surface,
      elevation: 0,
      actions: [
        IconButton(
          icon: CustomIconWidget(
            iconName: 'search',
            color: colorScheme.onSurface,
            size: 6.w,
          ),
          onPressed: _showSearch,
          tooltip: 'Search workspaces',
        ),
        PopupMenuButton<String>(
          icon: CustomIconWidget(
            iconName: 'more_vert',
            color: colorScheme.onSurface,
            size: 6.w,
          ),
          onSelected: (value) {
            HapticFeedback.lightImpact();
            switch (value) {
              case 'sort_name':
                _sortWorkspacesByName();
                break;
              case 'sort_date':
                _sortWorkspacesByDate();
                break;
              case 'sort_projects':
                _sortWorkspacesByProjectCount();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'sort_name',
              child: Row(
                children: [
                  Icon(Icons.sort_by_alpha, size: 20),
                  SizedBox(width: 12),
                  Text('Sort by Name'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'sort_date',
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 20),
                  SizedBox(width: 12),
                  Text('Sort by Date'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'sort_projects',
              child: Row(
                children: [
                  Icon(Icons.folder, size: 20),
                  SizedBox(width: 12),
                  Text('Sort by Projects'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  PreferredSizeWidget _buildMultiSelectAppBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Text(
        '${_selectedWorkspaceIds.length} selected',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: colorScheme.primaryContainer,
      leading: IconButton(
        icon: CustomIconWidget(
          iconName: 'close',
          color: colorScheme.onPrimaryContainer,
          size: 6.w,
        ),
        onPressed: _exitMultiSelectMode,
      ),
      actions: [
        IconButton(
          icon: CustomIconWidget(
            iconName: 'select_all',
            color: colorScheme.onPrimaryContainer,
            size: 6.w,
          ),
          onPressed: _selectAllWorkspaces,
          tooltip: 'Select all',
        ),
        IconButton(
          icon: CustomIconWidget(
            iconName: 'delete',
            color: colorScheme.error,
            size: 6.w,
          ),
          onPressed: _deleteSelectedWorkspaces,
          tooltip: 'Delete selected',
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: colorScheme.primary,
            strokeWidth: 3,
          ),
          SizedBox(height: 2.h),
          Text(
            'Loading workspaces...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_workspaces.isEmpty) {
      return EmptyWorkspaceState(
        onCreateWorkspace: _showCreateWorkspaceBottomSheet,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshWorkspaces,
      color: Theme.of(context).colorScheme.primary,
      child: ListView.builder(
        padding: EdgeInsets.only(
          top: 2.h,
          bottom: 10.h, // Space for FAB
        ),
        itemCount: _workspaces.length,
        itemBuilder: (context, index) {
          final workspace = _workspaces[index];
          final isSelected = _selectedWorkspaceIds.contains(workspace['id']);

          return WorkspaceCardWidget(
            workspace: workspace,
            isSelected: isSelected,
            onTap: () {
              if (_isMultiSelectMode) {
                _toggleWorkspaceSelection(workspace['id']);
              } else {
                _navigateToWorkspace(workspace);
              }
            },
            onLongPress: () {
              if (!_isMultiSelectMode) {
                _enterMultiSelectMode(workspace['id']);
              }
            },
            onEdit: () => _editWorkspace(workspace),
            onDuplicate: () => _duplicateWorkspace(workspace),
            onArchive: () => _archiveWorkspace(workspace),
            onDelete: () => _deleteWorkspace(workspace),
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _fabScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabScaleAnimation.value,
          child: FloatingActionButton.extended(
            onPressed: _showCreateWorkspaceBottomSheet,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: 4,
            icon: CustomIconWidget(
              iconName: 'add',
              color: colorScheme.onPrimary,
              size: 6.w,
            ),
            label: Text(
              'New Workspace',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  void _sortWorkspacesByName() {
    setState(() {
      _workspaces.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
    });
  }

  void _sortWorkspacesByDate() {
    setState(() {
      _workspaces.sort((a, b) {
        final dateA = DateTime.tryParse(a['updatedAt'] ?? '') ?? DateTime.now();
        final dateB = DateTime.tryParse(b['updatedAt'] ?? '') ?? DateTime.now();
        return dateB.compareTo(dateA); // Most recent first
      });
    });
  }

  void _sortWorkspacesByProjectCount() {
    setState(() {
      _workspaces.sort(
          (a, b) => (b['projectCount'] ?? 0).compareTo(a['projectCount'] ?? 0));
    });
  }
}
