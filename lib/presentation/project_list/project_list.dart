import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/create_project_bottom_sheet.dart';
import './widgets/multi_select_bottom_bar.dart';
import './widgets/project_grid_widget.dart';
import './widgets/sort_bottom_sheet.dart';
import './widgets/workspace_header_widget.dart';

class ProjectList extends StatefulWidget {
  const ProjectList({super.key});

  @override
  State<ProjectList> createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectList>
    with TickerProviderStateMixin {
  late AnimationController _refreshController;
  late Animation<double> _refreshAnimation;

  bool _isRefreshing = false;
  bool _isMultiSelectMode = false;
  Set<String> _selectedProjects = {};
  SortOption _currentSort = SortOption.recent;
  String _searchQuery = '';

  // Mock workspace data
  final Map<String, dynamic> _currentWorkspace = {
    'id': 'workspace_1',
    'name': 'Design Projects',
    'description': 'All design-related projects and creative work',
    'color': 0xFF2563EB,
    'icon': 'palette',
    'createdAt': DateTime.now().subtract(const Duration(days: 30)),
  };

  // Mock projects data
  List<Map<String, dynamic>> _allProjects = [
    {
      'id': 'project_1',
      'workspaceId': 'workspace_1',
      'name': 'Mobile App Redesign',
      'description':
          'Complete redesign of the mobile application with modern UI/UX principles and improved user experience.',
      'color': 0xFF2563EB,
      'nodeCount': 24,
      'progress': 0.75,
      'status': 'active',
      'createdAt': DateTime.now().subtract(const Duration(days: 5)),
      'lastUpdated': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'id': 'project_2',
      'workspaceId': 'workspace_1',
      'name': 'Brand Identity System',
      'description':
          'Comprehensive brand identity including logo, color palette, typography, and brand guidelines.',
      'color': 0xFF059669,
      'nodeCount': 18,
      'progress': 1.0,
      'status': 'completed',
      'createdAt': DateTime.now().subtract(const Duration(days: 15)),
      'lastUpdated': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': 'project_3',
      'workspaceId': 'workspace_1',
      'name': 'Website Landing Page',
      'description':
          'Modern landing page design with conversion optimization and responsive layout.',
      'color': 0xFFDC2626,
      'nodeCount': 12,
      'progress': 0.45,
      'status': 'active',
      'createdAt': DateTime.now().subtract(const Duration(days: 8)),
      'lastUpdated': DateTime.now().subtract(const Duration(hours: 6)),
    },
    {
      'id': 'project_4',
      'workspaceId': 'workspace_1',
      'name': 'Social Media Campaign',
      'description':
          'Visual assets and content strategy for Q4 social media marketing campaign.',
      'color': 0xFF7C3AED,
      'nodeCount': 31,
      'progress': 0.20,
      'status': 'active',
      'createdAt': DateTime.now().subtract(const Duration(days: 3)),
      'lastUpdated': DateTime.now().subtract(const Duration(minutes: 30)),
    },
    {
      'id': 'project_5',
      'workspaceId': 'workspace_1',
      'name': 'Product Photography',
      'description':
          'Professional product photography setup and post-processing workflow.',
      'color': 0xFFD97706,
      'nodeCount': 8,
      'progress': 0.90,
      'status': 'active',
      'createdAt': DateTime.now().subtract(const Duration(days: 12)),
      'lastUpdated': DateTime.now().subtract(const Duration(hours: 4)),
    },
  ];

  List<Map<String, dynamic>> get _filteredProjects {
    List<Map<String, dynamic>> filtered = List.from(_allProjects);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((project) {
        final name = (project['name'] ?? '').toString().toLowerCase();
        final description =
            (project['description'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || description.contains(query);
      }).toList();
    }

    // Apply sorting
    switch (_currentSort) {
      case SortOption.recent:
        filtered.sort((a, b) {
          final aDate = a['lastUpdated'] as DateTime;
          final bDate = b['lastUpdated'] as DateTime;
          return bDate.compareTo(aDate);
        });
        break;
      case SortOption.alphabetical:
        filtered.sort((a, b) {
          final aName = (a['name'] ?? '').toString().toLowerCase();
          final bName = (b['name'] ?? '').toString().toLowerCase();
          return aName.compareTo(bName);
        });
        break;
      case SortOption.progress:
        filtered.sort((a, b) {
          final aProgress = (a['progress'] ?? 0.0) as double;
          final bProgress = (b['progress'] ?? 0.0) as double;
          return bProgress.compareTo(aProgress);
        });
        break;
      case SortOption.nodeCount:
        filtered.sort((a, b) {
          final aCount = (a['nodeCount'] ?? 0) as int;
          final bCount = (b['nodeCount'] ?? 0) as int;
          return bCount.compareTo(aCount);
        });
        break;
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _refreshAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _refreshController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          // Workspace header
          WorkspaceHeaderWidget(
            workspace: _currentWorkspace,
            projectCount: _filteredProjects.length,
            onBackPressed: _handleBackPressed,
            onSortPressed: _showSortBottomSheet,
            onSearchPressed: _navigateToSearch,
          ),

          // Multi-select mode header
          if (_isMultiSelectMode)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Select projects to perform batch actions',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Projects grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: colorScheme.primary,
              child: ProjectGridWidget(
                projects: _filteredProjects,
                selectedProjects: _selectedProjects,
                isMultiSelectMode: _isMultiSelectMode,
                onProjectTap: _handleProjectTap,
                onProjectEdit: _handleProjectEdit,
                onProjectDuplicate: _handleProjectDuplicate,
                onProjectShare: _handleProjectShare,
                onProjectArchive: _handleProjectArchive,
                onProjectDelete: _handleProjectDelete,
                onProjectLongPress: _handleProjectLongPress,
              ),
            ),
          ),
        ],
      ),

      // Multi-select bottom bar
      bottomNavigationBar: _isMultiSelectMode
          ? MultiSelectBottomBar(
              selectedCount: _selectedProjects.length,
              onSelectAll: _handleSelectAll,
              onDeselectAll: _handleDeselectAll,
              onDuplicate: _handleBatchDuplicate,
              onArchive: _handleBatchArchive,
              onDelete: _handleBatchDelete,
              onCancel: _exitMultiSelectMode,
            )
          : null,

      // Floating action button
      floatingActionButton: _isMultiSelectMode
          ? null
          : FloatingActionButton.extended(
              onPressed: _showCreateProjectBottomSheet,
              icon: CustomIconWidget(
                iconName: 'add',
                color: colorScheme.onPrimary,
                size: 24,
              ),
              label: Text(
                'New Project',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
    );
  }

  void _handleBackPressed() {
    if (_isMultiSelectMode) {
      _exitMultiSelectMode();
    } else {
      Navigator.pushReplacementNamed(context, '/workspace-list');
    }
  }

  void _navigateToSearch() {
    Navigator.pushNamed(context, '/search-results');
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SortBottomSheet(
        currentSort: _currentSort,
        onSortChanged: (sortOption) {
          setState(() {
            _currentSort = sortOption;
          });
        },
      ),
    );
  }

  void _showCreateProjectBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateProjectBottomSheet(
        workspaceId: _currentWorkspace['id'],
        onProjectCreated: _handleProjectCreated,
      ),
    );
  }

  void _handleProjectCreated(Map<String, dynamic> newProject) {
    setState(() {
      _allProjects.insert(0, newProject);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Project "${newProject['name']}" created successfully'),
        backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.light),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleProjectTap(Map<String, dynamic> project) {
    if (_isMultiSelectMode) {
      _toggleProjectSelection(project['id'].toString());
    } else {
      // Navigate to graph view with shared element transition
      Navigator.pushNamed(context, '/graph-view', arguments: {
        'projectId': project['id'],
        'projectName': project['name'],
        'projectColor': project['color'],
      });
    }
  }

  void _handleProjectLongPress(Map<String, dynamic> project) {
    if (!_isMultiSelectMode) {
      HapticFeedback.mediumImpact();
      setState(() {
        _isMultiSelectMode = true;
        _selectedProjects.add(project['id'].toString());
      });
    }
  }

  void _toggleProjectSelection(String projectId) {
    setState(() {
      if (_selectedProjects.contains(projectId)) {
        _selectedProjects.remove(projectId);
        if (_selectedProjects.isEmpty) {
          _isMultiSelectMode = false;
        }
      } else {
        _selectedProjects.add(projectId);
      }
    });
  }

  void _exitMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = false;
      _selectedProjects.clear();
    });
  }

  void _handleSelectAll() {
    setState(() {
      if (_selectedProjects.length == _filteredProjects.length) {
        _selectedProjects.clear();
        _isMultiSelectMode = false;
      } else {
        _selectedProjects =
            _filteredProjects.map((p) => p['id'].toString()).toSet();
      }
    });
  }

  void _handleDeselectAll() {
    setState(() {
      _selectedProjects.clear();
      _isMultiSelectMode = false;
    });
  }

  void _handleProjectEdit(Map<String, dynamic> project) {
    // Show edit project dialog or navigate to edit screen
    _showEditProjectDialog(project);
  }

  void _handleProjectDuplicate(Map<String, dynamic> project) {
    final duplicatedProject = Map<String, dynamic>.from(project);
    duplicatedProject['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    duplicatedProject['name'] = '${project['name']} (Copy)';
    duplicatedProject['createdAt'] = DateTime.now();
    duplicatedProject['lastUpdated'] = DateTime.now();

    setState(() {
      _allProjects.insert(0, duplicatedProject);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Project duplicated successfully'),
        backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.light),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleProjectShare(Map<String, dynamic> project) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing "${project['name']}"...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleProjectArchive(Map<String, dynamic> project) {
    _showArchiveConfirmationDialog([project]);
  }

  void _handleProjectDelete(Map<String, dynamic> project) {
    _showDeleteConfirmationDialog([project]);
  }

  void _handleBatchDuplicate() {
    final selectedProjectsList = _allProjects
        .where((p) => _selectedProjects.contains(p['id'].toString()))
        .toList();

    for (final project in selectedProjectsList) {
      final duplicatedProject = Map<String, dynamic>.from(project);
      duplicatedProject['id'] =
          DateTime.now().millisecondsSinceEpoch.toString();
      duplicatedProject['name'] = '${project['name']} (Copy)';
      duplicatedProject['createdAt'] = DateTime.now();
      duplicatedProject['lastUpdated'] = DateTime.now();

      _allProjects.insert(0, duplicatedProject);
    }

    setState(() {});
    _exitMultiSelectMode();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selectedProjectsList.length} projects duplicated'),
        backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.light),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleBatchArchive() {
    final selectedProjectsList = _allProjects
        .where((p) => _selectedProjects.contains(p['id'].toString()))
        .toList();

    _showArchiveConfirmationDialog(selectedProjectsList);
  }

  void _handleBatchDelete() {
    final selectedProjectsList = _allProjects
        .where((p) => _selectedProjects.contains(p['id'].toString()))
        .toList();

    _showDeleteConfirmationDialog(selectedProjectsList);
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    _refreshController.forward();

    // Simulate refresh delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Update last updated times for active projects
    for (final project in _allProjects) {
      if (project['status'] == 'active') {
        project['lastUpdated'] = DateTime.now().subtract(
          Duration(minutes: (project['id'].hashCode % 60).abs()),
        );
      }
    }

    setState(() {
      _isRefreshing = false;
    });

    _refreshController.reverse();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Projects updated'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showEditProjectDialog(Map<String, dynamic> project) {
    // This would show an edit dialog similar to create project
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit project functionality coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showArchiveConfirmationDialog(List<Map<String, dynamic>> projects) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          projects.length == 1
              ? 'Archive Project'
              : 'Archive ${projects.length} Projects',
        ),
        content: Text(
          projects.length == 1
              ? 'Are you sure you want to archive "${projects.first['name']}"? You can restore it later from the archive.'
              : 'Are you sure you want to archive ${projects.length} projects? You can restore them later from the archive.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _archiveProjects(projects);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.getWarningColor(
                  theme.brightness == Brightness.light),
              foregroundColor: Colors.white,
            ),
            child: Text('Archive'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(List<Map<String, dynamic>> projects) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          projects.length == 1
              ? 'Delete Project'
              : 'Delete ${projects.length} Projects',
        ),
        content: Text(
          projects.length == 1
              ? 'Are you sure you want to permanently delete "${projects.first['name']}"? This action cannot be undone.'
              : 'Are you sure you want to permanently delete ${projects.length} projects? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProjects(projects);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _archiveProjects(List<Map<String, dynamic>> projects) {
    for (final project in projects) {
      project['status'] = 'archived';
      project['archivedAt'] = DateTime.now();
    }

    setState(() {});
    _exitMultiSelectMode();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          projects.length == 1
              ? 'Project archived'
              : '${projects.length} projects archived',
        ),
        backgroundColor: AppTheme.getWarningColor(
            Theme.of(context).brightness == Brightness.light),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            for (final project in projects) {
              project['status'] = 'active';
              project.remove('archivedAt');
            }
            setState(() {});
          },
        ),
      ),
    );
  }

  void _deleteProjects(List<Map<String, dynamic>> projects) {
    final projectIds = projects.map((p) => p['id'].toString()).toSet();

    setState(() {
      _allProjects.removeWhere((p) => projectIds.contains(p['id'].toString()));
    });

    _exitMultiSelectMode();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          projects.length == 1
              ? 'Project deleted'
              : '${projects.length} projects deleted',
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
