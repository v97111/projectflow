import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

/// Interactive graph canvas widget for node-based project visualization
class GraphCanvasWidget extends StatefulWidget {
  final List<GraphNode> nodes;
  final List<GraphConnection> connections;
  final Function(Offset) onAddNode;
  final Function(GraphNode) onNodeTap;
  final Function(GraphNode) onNodeDoubleTap;
  final Function(GraphNode) onNodeLongPress;
  final Function(GraphNode, Offset) onNodeDrag;
  final Function(GraphNode, GraphNode) onCreateConnection;
  final Function() onFitToScreen;
  final bool isAutoLayoutEnabled;

  const GraphCanvasWidget({
    super.key,
    required this.nodes,
    required this.connections,
    required this.onAddNode,
    required this.onNodeTap,
    required this.onNodeDoubleTap,
    required this.onNodeLongPress,
    required this.onNodeDrag,
    required this.onCreateConnection,
    required this.onFitToScreen,
    this.isAutoLayoutEnabled = false,
  });

  @override
  State<GraphCanvasWidget> createState() => _GraphCanvasWidgetState();
}

class _GraphCanvasWidgetState extends State<GraphCanvasWidget>
    with TickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();

  late AnimationController _scaleAnimationController;
  late Animation<double> _scaleAnimation;

  GraphNode? _selectedNode;
  GraphNode? _draggedNode;
  Offset? _dragStartPosition;
  bool _isDragging = false;
  bool _isCreatingConnection = false;
  GraphNode? _connectionStartNode;
  Offset? _connectionEndPosition;

  // Zoom constraints
  static const double _minScale = 0.25;
  static const double _maxScale = 4.0;

  @override
  void initState() {
    super.initState();
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _scaleAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ClipRect(
        child: GestureDetector(
          onTapUp: _handleCanvasTap,
          onDoubleTap: _handleCanvasDoubleTap,
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: _minScale,
            maxScale: _maxScale,
            boundaryMargin: EdgeInsets.all(20.w),
            constrained: false,
            child: Container(
              width: 200.w,
              height: 200.h,
              child: CustomPaint(
                painter: GraphCanvasPainter(
                  nodes: widget.nodes,
                  connections: widget.connections,
                  selectedNode: _selectedNode,
                  connectionPreview: _isCreatingConnection
                      ? ConnectionPreview(
                          startNode: _connectionStartNode!,
                          endPosition: _connectionEndPosition!,
                        )
                      : null,
                ),
                child: Stack(
                  children: [
                    // Node widgets
                    ...widget.nodes.map((node) => _buildNodeWidget(node)),

                    // Connection creation overlay
                    if (_isCreatingConnection) _buildConnectionOverlay(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds individual node widget
  Widget _buildNodeWidget(GraphNode node) {
    final isSelected = _selectedNode?.id == node.id;
    final isDragged = _draggedNode?.id == node.id;

    return Positioned(
      left: node.position.dx - 30.w,
      top: node.position.dy - 15.w,
      child: GestureDetector(
        onTap: () => _handleNodeTap(node),
        onDoubleTap: () => _handleNodeDoubleTap(node),
        onLongPress: () => _handleNodeLongPress(node),
        onPanStart: (details) => _handleNodeDragStart(node, details),
        onPanUpdate: (details) => _handleNodeDragUpdate(node, details),
        onPanEnd: (details) => _handleNodeDragEnd(node, details),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isSelected ? _scaleAnimation.value : 1.0,
              child: Container(
                width: 60.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: Color(node.color),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                        : Colors.transparent,
                    width: isSelected ? 2 : 0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.lightTheme.colorScheme.shadow
                          .withValues(alpha: isDragged ? 0.2 : 0.1),
                      offset: Offset(0, isDragged ? 4 : 2),
                      blurRadius: isDragged ? 8 : 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    node.title,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: _getContrastColor(Color(node.color)),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds connection creation overlay
  Widget _buildConnectionOverlay() {
    return Positioned.fill(
      child: CustomPaint(
        painter: ConnectionOverlayPainter(
          startNode: _connectionStartNode!,
          endPosition: _connectionEndPosition!,
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
      ),
    );
  }

  /// Handles canvas tap
  void _handleCanvasTap(TapUpDetails details) {
    setState(() {
      _selectedNode = null;
    });

    // Add node at tap position if in add mode
    final localPosition = details.localPosition;
    widget.onAddNode(localPosition);
  }

  /// Handles canvas double tap for fit to screen
  void _handleCanvasDoubleTap() {
    HapticFeedback.lightImpact();
    widget.onFitToScreen();
  }

  /// Handles node tap
  void _handleNodeTap(GraphNode node) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedNode = node;
    });
    _scaleAnimationController.forward().then((_) {
      _scaleAnimationController.reverse();
    });
    widget.onNodeTap(node);
  }

  /// Handles node double tap
  void _handleNodeDoubleTap(GraphNode node) {
    HapticFeedback.mediumImpact();
    widget.onNodeDoubleTap(node);
  }

  /// Handles node long press
  void _handleNodeLongPress(GraphNode node) {
    HapticFeedback.heavyImpact();
    widget.onNodeLongPress(node);
  }

  /// Handles node drag start
  void _handleNodeDragStart(GraphNode node, DragStartDetails details) {
    setState(() {
      _draggedNode = node;
      _dragStartPosition = details.localPosition;
      _isDragging = true;
    });
  }

  /// Handles node drag update
  void _handleNodeDragUpdate(GraphNode node, DragUpdateDetails details) {
    if (_isDragging && _draggedNode?.id == node.id) {
      final newPosition = node.position + details.delta;
      widget.onNodeDrag(node, newPosition);
    }
  }

  /// Handles node drag end
  void _handleNodeDragEnd(GraphNode node, DragEndDetails details) {
    setState(() {
      _draggedNode = null;
      _dragStartPosition = null;
      _isDragging = false;
    });
  }

  /// Gets contrast color for text on colored background
  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Fits graph to screen
  void _fitToScreen() {
    if (widget.nodes.isEmpty) return;

    // Calculate bounds of all nodes
    double minX = widget.nodes.first.position.dx;
    double maxX = widget.nodes.first.position.dx;
    double minY = widget.nodes.first.position.dy;
    double maxY = widget.nodes.first.position.dy;

    for (final node in widget.nodes) {
      minX = minX < node.position.dx ? minX : node.position.dx;
      maxX = maxX > node.position.dx ? maxX : node.position.dx;
      minY = minY < node.position.dy ? minY : node.position.dy;
      maxY = maxY > node.position.dy ? maxY : node.position.dy;
    }

    // Add padding
    const padding = 100.0;
    minX -= padding;
    maxX += padding;
    minY -= padding;
    maxY += padding;

    // Calculate scale and translation
    final graphWidth = maxX - minX;
    final graphHeight = maxY - minY;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final scaleX = screenWidth / graphWidth;
    final scaleY = screenHeight / graphHeight;
    final scale =
        (scaleX < scaleY ? scaleX : scaleY).clamp(_minScale, _maxScale);

    final centerX = (minX + maxX) / 2;
    final centerY = (minY + maxY) / 2;
    final targetX = screenWidth / 2 - centerX * scale;
    final targetY = screenHeight / 2 - centerY * scale;

    _transformationController.value = Matrix4.identity()
      ..translate(targetX, targetY)
      ..scale(scale);
  }
}

/// Graph canvas painter for drawing connections
class GraphCanvasPainter extends CustomPainter {
  final List<GraphNode> nodes;
  final List<GraphConnection> connections;
  final GraphNode? selectedNode;
  final ConnectionPreview? connectionPreview;

  GraphCanvasPainter({
    required this.nodes,
    required this.connections,
    this.selectedNode,
    this.connectionPreview,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw connections
    for (final connection in connections) {
      final startNode = nodes.firstWhere((n) => n.id == connection.fromNodeId);
      final endNode = nodes.firstWhere((n) => n.id == connection.toNodeId);

      paint.color = AppTheme.lightTheme.colorScheme.outline;
      _drawConnection(canvas, startNode.position, endNode.position, paint);
    }

    // Draw connection preview
    if (connectionPreview != null) {
      paint.color = AppTheme.lightTheme.colorScheme.primary;
      paint.strokeWidth = 3;
      _drawConnection(
        canvas,
        connectionPreview!.startNode.position,
        connectionPreview!.endPosition,
        paint,
      );
    }
  }

  void _drawConnection(Canvas canvas, Offset start, Offset end, Paint paint) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    // Draw curved connection
    final controlPoint1 =
        Offset(start.dx + (end.dx - start.dx) * 0.5, start.dy);
    final controlPoint2 = Offset(start.dx + (end.dx - start.dx) * 0.5, end.dy);

    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      end.dx,
      end.dy,
    );

    canvas.drawPath(path, paint);

    // Draw arrow head
    _drawArrowHead(canvas, controlPoint2, end, paint);
  }

  void _drawArrowHead(Canvas canvas, Offset start, Offset end, Paint paint) {
    const arrowLength = 10.0;
    const arrowAngle = 0.5;

    final direction = (end - start).direction;
    final arrowPoint1 = Offset(
      end.dx - arrowLength * cos(direction - arrowAngle),
      end.dy - arrowLength * sin(direction - arrowAngle),
    );
    final arrowPoint2 = Offset(
      end.dx - arrowLength * cos(direction + arrowAngle),
      end.dy - arrowLength * sin(direction + arrowAngle),
    );

    final arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
      ..moveTo(end.dx, end.dy)
      ..lineTo(arrowPoint2.dx, arrowPoint2.dy);

    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Connection overlay painter for connection creation
class ConnectionOverlayPainter extends CustomPainter {
  final GraphNode startNode;
  final Offset endPosition;
  final Color color;

  ConnectionOverlayPainter({
    required this.startNode,
    required this.endPosition,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(startNode.position.dx, startNode.position.dy);
    path.lineTo(endPosition.dx, endPosition.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Graph node data model
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

/// Graph connection data model
class GraphConnection {
  final String id;
  final String fromNodeId;
  final String toNodeId;
  final String? label;
  final DateTime createdAt;

  GraphConnection({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    this.label,
    required this.createdAt,
  });
}

/// Connection preview data model
class ConnectionPreview {
  final GraphNode startNode;
  final Offset endPosition;

  ConnectionPreview({
    required this.startNode,
    required this.endPosition,
  });
}
