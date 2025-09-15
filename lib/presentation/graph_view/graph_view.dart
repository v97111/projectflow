import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/floating_add_button_widget.dart';
import './widgets/graph_canvas_widget.dart' as canvas;
import './widgets/graph_toolbar_widget.dart';
import './widgets/node_context_menu_widget.dart';
import './widgets/node_edit_dialog_widget.dart';

/// Graph View screen for interactive visual project planning
class GraphView extends StatefulWidget {
  const GraphView({super.key});

  @override
  State<GraphView> createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> with TickerProviderStateMixin {
  late AnimationController _toolbarAnimationController;
  late AnimationController _headerAnimationController;

  // Graph data
  List<canvas.GraphNode> _nodes = [];
  List<canvas.GraphConnection> _connections = [];

  // UI state
  bool _isToolbarVisible = true;
  bool _isAutoLayoutEnabled = false;
  double _currentZoom = 1.0;
  canvas.GraphNode? _selectedNode;
  bool _showContextMenu = false;
  Offset _contextMenuPosition = Offset.zero;

  // Mock project data
  final Map<String, dynamic> _currentProject = {
    "id": "proj_001",
    "name": "Mobile App Redesign",
    "description":
        "Complete redesign of the mobile application with new user interface and improved user experience",
    "color": 0xFF2563EB,
    "status": "active",
    "createdAt": DateTime.now().subtract(const Duration(days: 15)),
    "updatedAt": DateTime.now().subtract(const Duration(hours: 2)),
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadMockData();
    _startAutoHideTimer();
  }

  @override
  void dispose() {
    _toolbarAnimationController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  /// Initializes animation controllers
  void _initializeAnimations() {
    _toolbarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _toolbarAnimationController.forward();
    _headerAnimationController.forward();
  }

  /// Loads mock graph data
  void _loadMockData() {
    _nodes = [
      canvas.GraphNode(
        id: "node_001",
        title: "User Research",
        description:
            "Conduct user interviews and surveys to understand current pain points",
        position: Offset(50.w, 30.h),
        color: 0xFF059669,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      canvas.GraphNode(
        id: "node_002",
        title: "Wireframing",
        description: "Create low-fidelity wireframes for key user flows",
        position: Offset(50.w, 50.h),
        color: 0xFF2563EB,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      canvas.GraphNode(
        id: "node_003",
        title: "UI Design",
        description: "Design high-fidelity mockups and interactive prototypes",
        position: Offset(50.w, 70.h),
        color: 0xFF7C3AED,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      canvas.GraphNode(
        id: "node_004",
        title: "Usability Testing",
        description: "Test prototypes with target users and gather feedback",
        position: Offset(80.w, 50.h),
        color: 0xFFD97706,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      canvas.GraphNode(
        id: "node_005",
        title: "Development",
        description: "Implement the final design with responsive layouts",
        position: Offset(50.w, 90.h),
        color: 0xFFDC2626,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    _connections = [
      canvas.GraphConnection(
        id: "conn_001",
        fromNodeId: "node_001",
        toNodeId: "node_002",
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      canvas.GraphConnection(
        id: "conn_002",
        fromNodeId: "node_002",
        toNodeId: "node_003",
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      canvas.GraphConnection(
        id: "conn_003",
        fromNodeId: "node_003",
        toNodeId: "node_004",
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      canvas.GraphConnection(
        id: "conn_004",
        fromNodeId: "node_004",
        toNodeId: "node_005",
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  /// Starts auto-hide timer for toolbar
  void _startAutoHideTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isToolbarVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      body: Stack(
        children: [
          // Main graph canvas
          GestureDetector(
            onTap: _handleCanvasTap,
            child: canvas.GraphCanvasWidget(
              nodes: _nodes,
              connections: _connections,
              onAddNode: _handleAddNode,
              onNodeTap: _handleNodeTap,
              onNodeDoubleTap: _handleNodeDoubleTap,
              onNodeLongPress: _handleNodeLongPress,
              onNodeDrag: _handleNodeDrag,
              onCreateConnection: _handleCreateConnection,
              onFitToScreen: _handleFitToScreen,
              isAutoLayoutEnabled: _isAutoLayoutEnabled,
            ),
          ),

          // Translucent header
          _buildHeader(),

          // Context menu overlay
          if (_showContextMenu && _selectedNode != null)
            NodeContextMenuWidget(
              node: _selectedNode!,
              position: _contextMenuPosition,
              onEdit: _handleEditNode,
              onDelete: _handleDeleteNode,
              onChangeColor: _handleChangeNodeColor,
              onAddConnection: _handleAddConnectionFromNode,
              onDuplicate: _handleDuplicateNode,
              onClose: _hideContextMenu,
            ),

          // Bottom toolbar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GraphToolbarWidget(
              isVisible: _isToolbarVisible,
              onAddNode: _handleAddNodeAtCenter,
              onAutoLayout: _handleAutoLayout,
              onZoomIn: _handleZoomIn,
              onZoomOut: _handleZoomOut,
              onFitToScreen: _handleFitToScreen,
              onViewOptions: _handleViewOptions,
              isAutoLayoutEnabled: _isAutoLayoutEnabled,
              currentZoom: _currentZoom,
            ),
          ),

          // Floating action button
          Positioned(
            bottom: 20.h,
            right: 4.w,
            child: FloatingAddButtonWidget(
              isVisible: !_isToolbarVisible,
              onAddNode: _handleAddNodeAtCenter,
              onAddConnection: _handleAddConnectionMode,
              onQuickActions: _handleQuickActions,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds translucent header
  Widget _buildHeader() {
    final theme = AppTheme.lightTheme;
    final colorScheme = theme.colorScheme;

    return Container(
      height: 25.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surface.withValues(alpha: 0.95),
            colorScheme.surface.withValues(alpha: 0.8),
            colorScheme.surface.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'arrow_back',
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                  ),
                ),
              ),

              SizedBox(width: 3.w),

              // Project info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentProject["name"] as String,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${_nodes.length} nodes • ${_connections.length} connections',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Action menu
              GestureDetector(
                onTap: _handleHeaderMenu,
                child: Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'more_vert',
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handles canvas tap
  void _handleCanvasTap() {
    setState(() {
      _isToolbarVisible = !_isToolbarVisible;
      _selectedNode = null;
      _showContextMenu = false;
    });

    if (_isToolbarVisible) {
      _startAutoHideTimer();
    }
  }

  /// Handles adding node at position
  void _handleAddNode(Offset position) {
    _showNodeEditDialog(position: position);
  }

  /// Handles adding node at center
  void _handleAddNodeAtCenter() {
    final centerPosition = Offset(50.w, 50.h);
    _showNodeEditDialog(position: centerPosition);
  }

  /// Handles node tap
  void _handleNodeTap(canvas.GraphNode node) {
    setState(() {
      _selectedNode = node;
      _showContextMenu = false;
    });
  }

  /// Handles node double tap
  void _handleNodeDoubleTap(canvas.GraphNode node) {
    _showNodeEditDialog(node: node);
  }

  /// Handles node long press
  void _handleNodeLongPress(canvas.GraphNode node) {
    setState(() {
      _selectedNode = node;
      _contextMenuPosition = node.position;
      _showContextMenu = true;
    });
  }

  /// Handles node drag
  void _handleNodeDrag(canvas.GraphNode node, Offset newPosition) {
    setState(() {
      final index = _nodes.indexWhere((n) => n.id == node.id);
      if (index != -1) {
        _nodes[index] = node.copyWith(
          position: newPosition,
          updatedAt: DateTime.now(),
        );
      }
    });
  }

  /// Handles creating connection
  void _handleCreateConnection(canvas.GraphNode fromNode, canvas.GraphNode toNode) {
    final newConnection = canvas.GraphConnection(
      id: "conn_${DateTime.now().millisecondsSinceEpoch}",
      fromNodeId: fromNode.id,
      toNodeId: toNode.id,
      createdAt: DateTime.now(),
    );

    setState(() {
      _connections.add(newConnection);
    });

    HapticFeedback.lightImpact();
  }

  /// Handles fit to screen
  void _handleFitToScreen() {
    HapticFeedback.lightImpact();
    // Implementation handled by GraphCanvasWidget
  }

  /// Handles auto layout
  void _handleAutoLayout() {
    setState(() {
      _isAutoLayoutEnabled = !_isAutoLayoutEnabled;
    });

    if (_isAutoLayoutEnabled) {
      _applyAutoLayout();
    }

    HapticFeedback.lightImpact();
  }

  /// Handles zoom in
  void _handleZoomIn() {
    setState(() {
      _currentZoom = (_currentZoom * 1.2).clamp(0.25, 4.0);
    });
    HapticFeedback.lightImpact();
  }

  /// Handles zoom out
  void _handleZoomOut() {
    setState(() {
      _currentZoom = (_currentZoom / 1.2).clamp(0.25, 4.0);
    });
    HapticFeedback.lightImpact();
  }

  /// Handles view options
  void _handleViewOptions() {
    _showViewOptionsBottomSheet();
  }

  /// Handles header menu
  void _handleHeaderMenu() {
    _showHeaderMenuBottomSheet();
  }

  /// Handles edit node
  void _handleEditNode() {
    if (_selectedNode != null) {
      _showNodeEditDialog(node: _selectedNode);
    }
  }

  /// Handles delete node
  void _handleDeleteNode() {
    if (_selectedNode != null) {
      _showDeleteConfirmation();
    }
  }

  /// Handles change node color
  void _handleChangeNodeColor() {
    if (_selectedNode != null) {
      _showColorPicker();
    }
  }

  /// Handles add connection from node
  void _handleAddConnectionFromNode() {
    // Enter connection creation mode
    HapticFeedback.lightImpact();
  }

  /// Handles duplicate node
  void _handleDuplicateNode() {
    if (_selectedNode != null) {
      final duplicatedNode = canvas.GraphNode(
        id: "node_${DateTime.now().millisecondsSinceEpoch}",
        title: "${_selectedNode!.title} (Copy)",
        description: _selectedNode!.description,
        position: _selectedNode!.position + const Offset(50, 50),
        color: _selectedNode!.color,
        createdAt: DateTime.now(),
      );

      setState(() {
        _nodes.add(duplicatedNode);
      });

      HapticFeedback.lightImpact();
    }
  }

  /// Handles add connection mode
  void _handleAddConnectionMode() {
    HapticFeedback.lightImpact();
    // Implementation for connection creation mode
  }

  /// Handles quick actions
  void _handleQuickActions() {
    _showQuickActionsBottomSheet();
  }

  /// Hides context menu
  void _hideContextMenu() {
    setState(() {
      _showContextMenu = false;
    });
  }

  /// Shows node edit dialog
  void _showNodeEditDialog({canvas.GraphNode? node, Offset? position}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NodeEditDialogWidget(
        node: node,
        onSave: (title, description, color) {
          _saveNode(node, title, description, color, position);
          Navigator.pop(context);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  /// Saves node data
  void _saveNode(canvas.GraphNode? existingNode, String title, String description,
      int color, Offset? position) {
    if (existingNode != null) {
      // Update existing node
      setState(() {
        final index = _nodes.indexWhere((n) => n.id == existingNode.id);
        if (index != -1) {
          _nodes[index] = existingNode.copyWith(
            title: title,
            description: description,
            color: color,
            updatedAt: DateTime.now(),
          );
        }
      });
    } else {
      // Create new node
      final newNode = canvas.GraphNode(
        id: "node_${DateTime.now().millisecondsSinceEpoch}",
        title: title,
        description: description,
        position: position ?? Offset(50.w, 50.h),
        color: color,
        createdAt: DateTime.now(),
      );

      setState(() {
        _nodes.add(newNode);
      });
    }

    HapticFeedback.lightImpact();
  }

  /// Shows delete confirmation dialog
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Node'),
        content:
            Text('Are you sure you want to delete "${_selectedNode?.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteNode();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Deletes selected node
  void _deleteNode() {
    if (_selectedNode != null) {
      setState(() {
        _nodes.removeWhere((n) => n.id == _selectedNode!.id);
        _connections.removeWhere((c) =>
            c.fromNodeId == _selectedNode!.id ||
            c.toNodeId == _selectedNode!.id);
        _selectedNode = null;
        _showContextMenu = false;
      });

      HapticFeedback.lightImpact();
    }
  }

  /// Shows color picker bottom sheet
  void _showColorPicker() {
    // Implementation for color picker
    HapticFeedback.lightImpact();
  }

  /// Shows view options bottom sheet
  void _showViewOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              width: 10.w,
              height: 1.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Text(
                'View Options',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
            ),
            // Add view options here
          ],
        ),
      ),
    );
  }

  /// Shows header menu bottom sheet
  void _showHeaderMenuBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              width: 10.w,
              height: 1.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Text(
                'Project Options',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
            ),
            // Add project options here
          ],
        ),
      ),
    );
  }

  /// Shows quick actions bottom sheet
  void _showQuickActionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 35.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              width: 10.w,
              height: 1.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Text(
                'Quick Actions',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
            ),
            // Add quick actions here
          ],
        ),
      ),
    );
  }

  /// Applies auto layout to nodes
  void _applyAutoLayout() {
    // Simple auto-layout implementation
    if (_nodes.isEmpty) return;

    const double nodeSpacing = 100.0;
    const double levelHeight = 120.0;

    // Group nodes by their connections (simple hierarchical layout)
    final Map<String, int> nodeLevels = {};
    final Set<String> processedNodes = {};

    // Find root nodes (nodes with no incoming connections)
    final Set<String> rootNodes = _nodes.map<String>((n) => n.id).toSet();
    for (final connection in _connections) {
      rootNodes.remove(connection.toNodeId);
    }

    // Assign levels starting from root nodes
    int currentLevel = 0;
    Set<String> currentLevelNodes = rootNodes;

    while (currentLevelNodes.isNotEmpty) {
      for (final nodeId in currentLevelNodes) {
        nodeLevels[nodeId] = currentLevel;
        processedNodes.add(nodeId);
      }

      // Find next level nodes
      final Set<String> nextLevelNodes = {};
      for (final connection in _connections) {
        if (processedNodes.contains(connection.fromNodeId) &&
            !processedNodes.contains(connection.toNodeId)) {
          nextLevelNodes.add(connection.toNodeId);
        }
      }

      currentLevelNodes = nextLevelNodes;
      currentLevel++;
    }

    // Position nodes based on their levels
    final Map<int, List<String>> levelGroups = {};
    for (final entry in nodeLevels.entries) {
      levelGroups.putIfAbsent(entry.value, () => []).add(entry.key);
    }

    setState(() {
      for (final entry in levelGroups.entries) {
        final level = entry.key;
        final nodesInLevel = entry.value;

        for (int i = 0; i < nodesInLevel.length; i++) {
          final nodeId = nodesInLevel[i];
          final nodeIndex = _nodes.indexWhere((n) => n.id == nodeId);

          if (nodeIndex != -1) {
            final x = (i + 1) * nodeSpacing +
                (50.w - (nodesInLevel.length * nodeSpacing / 2));
            final y = level * levelHeight + 20.h;

            _nodes[nodeIndex] = _nodes[nodeIndex].copyWith(
              position: Offset(x, y),
              updatedAt: DateTime.now(),
            );
          }
        }
      }
    });
  }
}