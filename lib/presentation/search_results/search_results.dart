import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/recent_searches_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/search_results_list_widget.dart';
import './widgets/search_suggestions_widget.dart';
import 'widgets/filter_bottom_sheet_widget.dart';
import 'widgets/recent_searches_widget.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/search_results_list_widget.dart';
import 'widgets/search_suggestions_widget.dart';

class SearchResults extends StatefulWidget {
  const SearchResults({super.key});

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  String _searchQuery = '';
  Timer? _debounceTimer;
  bool _isSearching = false;
  bool _showSuggestions = false;

  // Audio recording
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  // Barcode scanning
  MobileScannerController? _scannerController;

  // Search data
  List<String> _recentSearches = [
    'project timeline',
    'team meeting notes',
    'budget planning',
    'design mockups',
    'client feedback',
  ];

  List<Map<String, dynamic>> _searchSuggestions = [];
  Map<String, List<Map<String, dynamic>>> _searchResults = {};

  // Filters
  Map<String, dynamic> _currentFilters = {
    'contentTypes': <String>[],
    'dateRange': null,
    'workspaces': <String>[],
    'sortBy': 'relevance',
  };

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _audioRecorder.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  void _initializeData() {
    // Initialize with mock data
    _searchSuggestions = [
      {'text': 'Personal Projects', 'type': 'workspace'},
      {'text': 'Mobile App Development', 'type': 'project'},
      {'text': 'User Interface Design', 'type': 'node'},
      {'text': 'Team Meeting Tomorrow', 'type': 'reminder'},
      {'text': 'Budget Review', 'type': 'project'},
    ];
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _showSuggestions = query.isNotEmpty && query.length < 3;
    });

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (query.isNotEmpty && query.length >= 3) {
        _performSearch(query);
      } else {
        setState(() {
          _searchResults.clear();
          _isSearching = false;
        });
      }
    });
  }

  void _performSearch(String query) {
    setState(() => _isSearching = true);

    // Add to recent searches if not already present
    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.take(10).toList();
      }
    }

    // Simulate search with mock data
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _searchResults = _generateMockSearchResults(query);
          _isSearching = false;
          _showSuggestions = false;
        });
      }
    });
  }

  Map<String, List<Map<String, dynamic>>> _generateMockSearchResults(
      String query) {
    final Map<String, List<Map<String, dynamic>>> results = {};

    // Mock workspaces
    results['workspaces'] = [
      {
        'id': 'ws1',
        'type': 'workspace',
        'title': 'Personal Projects',
        'description':
            'Collection of personal development projects and learning goals',
        'color': 0xFF2563EB,
        'breadcrumb': null,
        'lastModified': '2025-09-14T10:30:00Z',
      },
      {
        'id': 'ws2',
        'type': 'workspace',
        'title': 'Work Tasks',
        'description': 'Professional work assignments and team collaborations',
        'color': 0xFF059669,
        'breadcrumb': null,
        'lastModified': '2025-09-13T15:45:00Z',
      },
    ];

    // Mock projects
    results['projects'] = [
      {
        'id': 'p1',
        'type': 'project',
        'title': 'Mobile App Development',
        'description':
            'Flutter-based project management application with graph visualization',
        'color': 0xFF7C3AED,
        'breadcrumb': 'Personal Projects',
        'lastModified': '2025-09-15T08:20:00Z',
      },
      {
        'id': 'p2',
        'type': 'project',
        'title': 'Website Redesign Project',
        'description':
            'Complete overhaul of company website with modern design principles',
        'color': 0xFFD97706,
        'breadcrumb': 'Work Tasks',
        'lastModified': '2025-09-12T14:15:00Z',
      },
      {
        'id': 'p3',
        'type': 'project',
        'title': 'Budget Planning System',
        'description':
            'Financial planning and budget tracking system for quarterly reviews',
        'color': 0xFFDC2626,
        'breadcrumb': 'Work Tasks',
        'lastModified': '2025-09-11T11:30:00Z',
      },
    ];

    // Mock nodes
    results['nodes'] = [
      {
        'id': 'n1',
        'type': 'node',
        'title': 'User Interface Design',
        'description':
            'Design system and component library for mobile application',
        'color': 0xFF059669,
        'breadcrumb': 'Personal Projects > Mobile App Development',
        'lastModified': '2025-09-15T09:10:00Z',
      },
      {
        'id': 'n2',
        'type': 'node',
        'title': 'Database Schema Planning',
        'description': 'Entity relationship design and data flow architecture',
        'color': 0xFF2563EB,
        'breadcrumb': 'Personal Projects > Mobile App Development',
        'lastModified': '2025-09-14T16:45:00Z',
      },
      {
        'id': 'n3',
        'type': 'node',
        'title': 'Client Feedback Integration',
        'description':
            'Incorporating client suggestions into website design mockups',
        'color': 0xFFD97706,
        'breadcrumb': 'Work Tasks > Website Redesign Project',
        'lastModified': '2025-09-13T13:20:00Z',
      },
    ];

    // Mock reminders
    results['reminders'] = [
      {
        'id': 'r1',
        'type': 'reminder',
        'title': 'Team Meeting - Project Review',
        'description':
            'Weekly team sync to discuss project progress and blockers',
        'color': null,
        'breadcrumb': 'Work Tasks > Website Redesign Project',
        'lastModified': '2025-09-15T07:00:00Z',
      },
      {
        'id': 'r2',
        'type': 'reminder',
        'title': 'Submit Budget Proposal',
        'description':
            'Final review and submission of quarterly budget planning document',
        'color': null,
        'breadcrumb': 'Work Tasks > Budget Planning System',
        'lastModified': '2025-09-14T12:30:00Z',
      },
    ];

    // Filter results based on current filters
    return _applyFilters(results);
  }

  Map<String, List<Map<String, dynamic>>> _applyFilters(
    Map<String, List<Map<String, dynamic>>> results,
  ) {
    final Map<String, List<Map<String, dynamic>>> filteredResults = {};

    final List<String> selectedTypes =
        (_currentFilters['contentTypes'] as List<String>?) ?? [];

    for (String category in results.keys) {
      if (selectedTypes.isEmpty || selectedTypes.contains(category)) {
        filteredResults[category] = results[category]!;
      }
    }

    return filteredResults;
  }

  Future<void> _handleVoiceSearch() async {
    if (kIsWeb) {
      // Web doesn't support voice recording, show message
      _showSnackBar('Voice search is not available on web');
      return;
    }

    try {
      if (await _audioRecorder.hasPermission()) {
        if (!_isRecording) {
          await _audioRecorder.start(const RecordConfig(path: ''));
          setState(() => _isRecording = true);

          // Stop recording after 5 seconds
          Timer(const Duration(seconds: 5), () async {
            if (_isRecording) {
              final String? path = await _audioRecorder.stop();
              setState(() => _isRecording = false);

              if (path != null) {
                // Simulate voice recognition result
                _onSearchChanged('voice search result');
                _showSnackBar('Voice search completed');
              }
            }
          });
        } else {
          final String? path = await _audioRecorder.stop();
          setState(() => _isRecording = false);

          if (path != null) {
            _onSearchChanged('voice search result');
            _showSnackBar('Voice search completed');
          }
        }
      } else {
        _showSnackBar('Microphone permission required');
      }
    } catch (e) {
      setState(() => _isRecording = false);
      _showSnackBar('Voice search failed');
    }
  }

  Future<void> _handleBarcodeSearch() async {
    try {
      if (kIsWeb) {
        _showSnackBar('Barcode scanning is not available on web');
        return;
      }

      final bool hasPermission = await Permission.camera.request().isGranted;
      if (!hasPermission) {
        _showSnackBar('Camera permission required');
        return;
      }

      _scannerController = MobileScannerController();

      final String? result = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => _BarcodeScannerScreen(
            controller: _scannerController!,
          ),
        ),
      );

      if (result != null) {
        _onSearchChanged(result);
        _showSnackBar('Barcode scanned successfully');
      }
    } catch (e) {
      _showSnackBar('Barcode scanning failed');
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        currentFilters: _currentFilters,
        onFiltersChanged: (filters) {
          setState(() {
            _currentFilters = filters;
          });
          if (_searchQuery.isNotEmpty) {
            _performSearch(_searchQuery);
          }
        },
      ),
    );
  }

  void _onResultTap(Map<String, dynamic> result) {
    HapticFeedback.lightImpact();

    final String type = result['type'] as String;
    final String id = result['id'] as String;

    // Navigate based on result type
    switch (type) {
      case 'workspace':
        Navigator.pushNamed(context, '/workspace-list');
        break;
      case 'project':
        Navigator.pushNamed(context, '/project-list');
        break;
      case 'node':
        Navigator.pushNamed(context, '/graph-view');
        break;
      case 'reminder':
        Navigator.pushNamed(context, '/calendar-view');
        break;
    }
  }

  void _onBookmark(Map<String, dynamic> result) {
    HapticFeedback.lightImpact();
    _showSnackBar('Bookmarked: ${result['title']}');
  }

  void _onShare(Map<String, dynamic> result) {
    HapticFeedback.lightImpact();
    _showSnackBar('Shared: ${result['title']}');
  }

  void _onEdit(Map<String, dynamic> result) {
    HapticFeedback.lightImpact();
    _showSnackBar('Edit: ${result['title']}');
  }

  void _onRecentSearchTap(String search) {
    _onSearchChanged(search);
  }

  void _onRecentSearchRemove(String search) {
    setState(() {
      _recentSearches.remove(search);
    });
  }

  void _onSuggestionTap(String suggestion) {
    _onSearchChanged(suggestion);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: colorScheme.onSurface,
            size: 24,
          ),
        ),
        title: Text(
          'Search',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: theme.brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
        ),
      ),
      body: Column(
        children: [
          SearchBarWidget(
            initialQuery: _searchQuery,
            onSearchChanged: _onSearchChanged,
            onVoiceSearch: _handleVoiceSearch,
            onBarcodeSearch: _handleBarcodeSearch,
            onFilterTap: _showFilterBottomSheet,
          ),
          if (_showSuggestions)
            SearchSuggestionsWidget(
              suggestions: _searchSuggestions
                  .where((s) => (s['text'] as String)
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                  .toList(),
              onSuggestionTap: _onSuggestionTap,
              isVisible: _showSuggestions,
            ),
          if (_searchQuery.isEmpty && !_showSuggestions)
            RecentSearchesWidget(
              recentSearches: _recentSearches,
              onSearchTap: _onRecentSearchTap,
              onSearchRemove: _onRecentSearchRemove,
            ),
          if (_isSearching)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Searching...',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (!_isSearching && _searchQuery.isNotEmpty && !_showSuggestions)
            Expanded(
              child: SearchResultsListWidget(
                categorizedResults: _searchResults,
                searchQuery: _searchQuery,
                onResultTap: _onResultTap,
                onBookmark: _onBookmark,
                onShare: _onShare,
                onEdit: _onEdit,
              ),
            ),
        ],
      ),
    );
  }
}

class _BarcodeScannerScreen extends StatelessWidget {
  final MobileScannerController controller;

  const _BarcodeScannerScreen({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'close',
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          'Scan Barcode',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: (BarcodeCapture capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final String? code = barcodes.first.rawValue;
            if (code != null) {
              Navigator.pop(context, code);
            }
          }
        },
      ),
    );
  }
}