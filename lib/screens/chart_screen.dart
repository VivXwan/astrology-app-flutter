import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chart_provider.dart';
import '../providers/dasha_provider.dart';
import '../models/chart.dart';
import 'chart/widgets/chart_widget.dart';
import 'chart/widgets/kundali_table_widget.dart';
import 'chart/widgets/dasha_timeline_widget.dart';
import '../widgets/theme_switch.dart';
import '../widgets/app_settings.dart';
import '../config/theme_extensions.dart';
import 'chart_painters/base_chart_painter.dart';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;

// New Widget for Tab Content
class ChartTabContent extends StatefulWidget {
  const ChartTabContent({required Key key}) : super(key: key);

  @override
  _ChartTabContentState createState() => _ChartTabContentState();
}

class _ChartTabContentState extends State<ChartTabContent> with AutomaticKeepAliveClientMixin {
  // Local state for this tab's view configuration
  List<ChartType> _selectedChartTypes = [ChartType.d1];
  // Chart styles
  List<ChartStyle> _selectedChartStyles = [ChartStyle.northIndian]; 
  // Map to track hover state for each cell
  final Map<int, bool> _hoverStates = {};

  // Style constants
  static const double _dropdownHeight = 35.0;
  static const double _minDropdownWidth = 90.0; // Slightly wider minimum

  @override
  bool get wantKeepAlive => true; // Keep state when switching tabs

  void _setChartType(int index, ChartType type) {
    // Access available types from provider
    final availableTypes = context.read<ChartProvider>().availableChartTypes;
    if (index >= 0 && index < _selectedChartTypes.length && availableTypes.contains(type)) {
      if (_selectedChartTypes[index] != type) {
        setState(() {
          _selectedChartTypes[index] = type;
        });
      }
    }
  }

  void _setChartStyle(int index, ChartStyle style) {
    final availableStyles = context.read<ChartProvider>().availableChartStyles;
    if (index >= 0 && index < _selectedChartStyles.length && availableStyles.contains(style)) {
      if (_selectedChartStyles[index] != style) {
        setState(() {
          _selectedChartStyles[index] = style;
        });
      }
    }
  }

  // Helper to update hover state
  void _setHoverState(int index, bool isHovered) {
    if (_hoverStates[index] != isHovered) {
      setState(() {
        _hoverStates[index] = isHovered;
      });
    }
  }

  // Helper to toggle hover state on tap
  void _toggleHoverState(int index) {
    final currentState = _hoverStates[index] ?? false;
    setState(() {
      _hoverStates[index] = !currentState;
    });
  }

  // Helper to check if device is touch-only (no hover support)
  bool get _isTouchOnlyDevice {
    // For mobile devices, we can use MediaQuery, but for simplicity 
    // we'll use a Web detection approach since hover mainly matters on desktop/web
    return !kIsWeb && (Theme.of(context).platform == TargetPlatform.iOS || 
                        Theme.of(context).platform == TargetPlatform.android);
  }

  // Helper for Type Dropdown
  Widget _buildTypeDropdown(int index, ChartType selectedType, double availableWidth, ChartTheme chartTheme) {
    final chartProvider = context.read<ChartProvider>();
    return SizedBox(
      height: _dropdownHeight,
      width: availableWidth, // Take the width provided by the caller
      child: DropdownButton<ChartType>(
        value: selectedType,
        isExpanded: true,
        underline: Container(height: 1, color: chartTheme.chartBorderColor),
        style: TextStyle(fontSize: 13, color: chartTheme.textColor),
        items: chartProvider.availableChartTypes.map((ChartType type) {
          return DropdownMenuItem<ChartType>(
            value: type,
            child: Text(type.toString(), overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (ChartType? newValue) {
          if (newValue != null) {
            _setChartType(index, newValue);
          }
        },
      ),
    );
  }

  // Helper for Style Dropdown
  Widget _buildStyleDropdown(int index, ChartStyle selectedStyle, double availableWidth, ChartTheme chartTheme,) {
    final chartProvider = context.read<ChartProvider>();
    return SizedBox(
      height: _dropdownHeight,
      width: availableWidth, // Take the width provided by the caller
      child: DropdownButton<ChartStyle>(
        value: selectedStyle,
        isExpanded: true,
        underline: Container(height: 1, color: chartTheme.chartBorderColor),
        style: TextStyle(fontSize: 13, color: chartTheme.textColor),
        items: chartProvider.availableChartStyles.map((ChartStyle style) {
          return DropdownMenuItem<ChartStyle>(
            value: style,
            child: Text(style.toString(), overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (ChartStyle? newValue) {
          if (newValue != null) {
            _setChartStyle(index, newValue);
          }
        },
      ),
    );
  }

  // Helper to calculate effective selector height based on available width
  double _calculateSelectorHeight(double availableWidth) {
    const double horizontalPadding = 4.0;
    final double requiredRowWidth = (_minDropdownWidth * 2) + horizontalPadding;
    final bool canFitRow = availableWidth >= requiredRowWidth;
    if (canFitRow) {
      return _dropdownHeight + 8; // Row layout height + padding
    } else {
      return (_dropdownHeight * 2) + 4 + 8; // Column layout height + spacing + padding
    }
  }

  // Helper to build adaptive selectors
  Widget _buildAdaptiveSelectorsRow(int index, ChartType selectedType, ChartStyle selectedStyle, double availableWidth, ChartTheme chartTheme) {
    const double horizontalPadding = 4.0; 
    final double requiredRowWidth = (_minDropdownWidth * 2) + horizontalPadding;
    final bool canFitRow = availableWidth >= requiredRowWidth;

    // Get hover state with fallback
    final bool isHovered = _hoverStates[index] ?? false;
    final bool shouldShowSelectors = isHovered;

    // Wrap with AnimatedOpacity for smooth fade effect
    return AnimatedOpacity(
      opacity: shouldShowSelectors ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: canFitRow 
          ? SizedBox(
              height: _dropdownHeight + 8, 
              child: Row(
                children: [
                  Expanded(
                    child: _buildTypeDropdown(index, selectedType, double.infinity, chartTheme), 
                  ),
                  const SizedBox(width: horizontalPadding),
                  Expanded(
                     child: _buildStyleDropdown(index, selectedStyle, double.infinity, chartTheme), 
                  ),
                ],
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                 _buildTypeDropdown(index, selectedType, availableWidth, chartTheme),
                 const SizedBox(height: 4), 
                 _buildStyleDropdown(index, selectedStyle, availableWidth, chartTheme),
              ],
            ),
    );
  }

  // Helper to build chart type label
  Widget _buildChartTypeLabel(ChartType chartType, double width, ChartTheme chartTheme, bool isVisible) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        height: _dropdownHeight,
        width: width,
        child: Center(
          child: Text(
            chartType.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: chartTheme.textColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final chartProvider = context.watch<ChartProvider>();
    // Get the chart theme from the current theme
    final chartTheme = Theme.of(context).extension<ChartTheme>() ?? ChartTheme.light;

    // Check necessary conditions from provider before building UI
    if (chartProvider.error != null) {
      return Center(child: Text('Error: ${chartProvider.error}'));
    }
    if (chartProvider.isLoading && chartProvider.getMainChart() == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (chartProvider.getMainChart() == null) {
      return const Center(child: Text('Generate a chart first.'));
    }

    return Padding(
      padding: const EdgeInsets.all(0), // Remove padding here, apply within Card if needed
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double availableWidth = constraints.maxWidth;
          final double availableHeight = constraints.maxHeight;
          const double spacing = 8.0;
          const double cellPadding = 4.0; // Internal padding within card

          // --- Determine Grid Configuration (e.g., Max 2x2) ---
          // We need a target chart size to calculate required space
          // Let's aim for a chart size, but it will be adjusted based on constraints
          const double targetChartEdge = 250.0; // Target minimum size
          
          int crossAxisCount = 1;
          if (availableWidth >= (targetChartEdge * 2 + spacing + cellPadding * 4)) { // Can fit two wide?
            crossAxisCount = 2;
          }
          
          // Estimate cell width to determine selector height needed
          double approxCellWidth = (availableWidth - (crossAxisCount - 1) * spacing) / crossAxisCount;
          double H_sel_eff = _calculateSelectorHeight(approxCellWidth - cellPadding * 2); // Subtract padding

          int mainAxisCount = 1;
          if (availableHeight >= ((targetChartEdge + H_sel_eff + cellPadding * 2) * 2 + spacing)) { // Can fit two high?
            mainAxisCount = 2;
          }
          
          final int numberOfChartsToDisplay = crossAxisCount * mainAxisCount;

          // --- State Update Scheduling (Handles both type and style lists) ---
          if (numberOfChartsToDisplay != _selectedChartTypes.length || numberOfChartsToDisplay != _selectedChartStyles.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  final currentLen = _selectedChartTypes.length;
                  if (numberOfChartsToDisplay > currentLen) {
                    final chartProvider = context.read<ChartProvider>();
                    List<ChartType> availableTypes = chartProvider.availableChartTypes;
                    for (int i = currentLen; i < numberOfChartsToDisplay; i++) {
                      int typeIndex = (i % availableTypes.length);
                      _selectedChartTypes.add(availableTypes[typeIndex]);
                      _selectedChartStyles.add(ChartStyle.northIndian); 
                    }
                  } else {
                    _selectedChartTypes = _selectedChartTypes.sublist(0, numberOfChartsToDisplay);
                    _selectedChartStyles = _selectedChartStyles.sublist(0, numberOfChartsToDisplay);
                  }
                });
              }
            });
          }
          // --- End State Update --- 
          
          // --- Calculate Actual Sizes based on Constraints --- 
          // Find largest possible square chart edge that fits
          double maxChartEdgeW = (availableWidth - (crossAxisCount - 1) * spacing - crossAxisCount * cellPadding * 2) / crossAxisCount;
          // For height, subtract selector height and padding
          double maxChartEdgeH = (availableHeight - (mainAxisCount - 1) * spacing - mainAxisCount * (H_sel_eff + cellPadding * 2)) / mainAxisCount;
          double finalChartEdge = max(50.0, min(maxChartEdgeW, maxChartEdgeH)); // Ensure positive, take min

          // Recalculate required cell dimensions based on finalChartEdge
          double requiredCellWidth = finalChartEdge + cellPadding * 2;
          // Recalculate H_sel_eff based on actual requiredCellWidth
          H_sel_eff = _calculateSelectorHeight(requiredCellWidth - cellPadding * 2);
          double requiredCellHeight = finalChartEdge + H_sel_eff + cellPadding * 2;
          
          // Calculate total grid size
          double totalGridWidth = crossAxisCount * requiredCellWidth + (crossAxisCount - 1) * spacing;
          double totalGridHeight = mainAxisCount * requiredCellHeight + (mainAxisCount - 1) * spacing;
          
          // Calculate cell aspect ratio
          double cellAspectRatio = (requiredCellHeight > 0) ? requiredCellWidth / requiredCellHeight : 1.0;

          // --- Build GridView --- 
          if (_selectedChartTypes.length != numberOfChartsToDisplay || _selectedChartStyles.length != numberOfChartsToDisplay) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return Center(
            child: SizedBox(
              width: totalGridWidth,
              height: totalGridHeight,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(), 
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: cellAspectRatio, 
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                ),
                itemCount: numberOfChartsToDisplay, 
                itemBuilder: (context, index) {
                  // Retrieve state for this index
                  ChartType selectedType = _selectedChartTypes[index];
                  ChartStyle selectedStyle = _selectedChartStyles[index];
                  
                  // Get appropriate chart data based on type
                  dynamic chartData = chartProvider.getChartDataForDisplay(selectedType);
                  
                  // Calculate available cell space
                  double selectorSpace = H_sel_eff;
                  double chartSpace = requiredCellHeight - selectorSpace - cellPadding * 2;

                  // Check if selectors are visible
                  final bool isHovered = _hoverStates[index] ?? false;

                  return GestureDetector(
                    onTap: () => _toggleHoverState(index),
                    child: MouseRegion(
                      onEnter: (_) => _setHoverState(index, true),
                      onExit: (_) => _setHoverState(index, false),
                      child: Card(
                        margin: EdgeInsets.zero, // No margin, handled by grid
                        child: Padding(
                          padding: EdgeInsets.all(cellPadding),
                          child: Column(
                            children: [
                              // Stack with chart type label and selectors
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Chart type label - visible when selectors are not
                                  _buildChartTypeLabel(
                                    selectedType,
                                    requiredCellWidth - cellPadding * 2,
                                    chartTheme,
                                    !isHovered,
                                  ),
                                  
                                  // Type Selector - visible on hover/tap
                                  _buildAdaptiveSelectorsRow(
                                    index, 
                                    selectedType, 
                                    selectedStyle, 
                                    requiredCellWidth - cellPadding * 2,
                                    chartTheme,
                                  ),
                                ],
                              ),
                              
                              // Chart Display
                              Expanded(
                                child: chartData != null
                                  ? ChartWidget(
                                      chartData: chartData,
                                      chartStyle: selectedStyle,
                                    )
                                  : const Center(
                                      child: Text('No data available for this chart type'),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}


// --- Modify ChartScreen --- 

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

// Add TickerProviderStateMixin
class _ChartScreenState extends State<ChartScreen> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  
  TabController? _tabController; // Make nullable
  // State for dynamic tabs
  List<ValueKey<int>> _tabKeys = [const ValueKey(0)]; // Start with one tab key
  int _tabCounter = 1; // Counter for generating unique keys

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _updateTabController(); // Initial setup
  }

  // Helper to create/update TabController
  void _updateTabController({bool animateToLast = false}) {
     // Dispose the old controller IF it exists and state is mounted
     if (mounted) {
        _tabController?.dispose();
     }
    _tabController = TabController(length: _tabKeys.length, vsync: this);

    if (animateToLast && _tabKeys.isNotEmpty) {
      // Use a post-frame callback to ensure the controller is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
         if (mounted && _tabController != null) {
            _tabController!.animateTo(_tabKeys.length - 1);
         }
      });
    }
     // Optional listener if needed later
     // _tabController?.addListener(() { ... });
  }

  void _addTab() {
    // Limit number of tabs for performance/UI reasons
    if (_tabKeys.length >= 8) { 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maximum tabs reached"), duration: Duration(seconds: 2)),
      );
      return;
    }
    setState(() {
      final newKey = ValueKey(_tabCounter++); // Generate unique key
      _tabKeys.add(newKey);
      _updateTabController(animateToLast: true); // Recreate controller and animate
    });
  }

  // --- Add Method to Remove Tab ---
  void _removeTab(int index) {
    // Prevent removing the last tab
    if (_tabKeys.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot remove the last tab"), duration: Duration(seconds: 2)),
      );
      return;
    }
    setState(() {
      // Determine the index the controller should move to after removal
      int newIndex = _tabController?.index ?? 0;
      if (newIndex >= index) {
        // If removing the current tab or one before it, adjust index
        // Clamp to 0 just in case
        newIndex = max(0, newIndex - 1);
      }
      
      _tabKeys.removeAt(index);
      _updateTabController(); // Recreate controller

      // Animate to the adjusted index after the controller is updated
      WidgetsBinding.instance.addPostFrameCallback((_) {
         if (mounted && _tabController != null && newIndex < _tabController!.length) {
           _tabController!.animateTo(newIndex);
         }
      });
    });
  }
  // --- End Remove Tab Method ---

  @override
  void dispose() {
    _tabController?.dispose(); // Dispose if exists
    super.dispose();
  }

  // --- Helper method to build the Tab Section ---
  Widget _buildTabSection() {
    // Note: TabBarView needs constraints. It gets them from Expanded in the layouts below.
    return TabBarView(
      controller: _tabController,
      children: _tabKeys.map((key) => ChartTabContent(key: key)).toList(),
    );
  }

  // --- Helper method to build the Info Section ---
  Widget _buildInfoSection() {
    // This section needs to be scrollable independently
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16), // Add padding at the bottom
      child: Column(
         children: [
           const Divider(height: 1, thickness: 1),
           const KundaliTableWidget(),
           const Divider(height: 1, thickness: 1),
           const Padding(
             padding: EdgeInsets.symmetric(vertical: 8.0),
             child: DashaTimelineWidget(),
           ),
         ],
      ),
    );
  }

  // --- Helper method to build a horizontal tab bar ---
  Widget _buildHorizontalTabBar() {
    // Get theme colors
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;
    
    return Container(
      height: kToolbarHeight * 0.8,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.dividerColor, width: 0.5))
      ),
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: textColor,
              unselectedLabelColor: textColor.withOpacity(0.7),
              labelPadding: const EdgeInsets.symmetric(horizontal: 12.0),
              indicatorPadding: const EdgeInsets.only(bottom: 2.0),
              tabs: List.generate(_tabKeys.length, (index) {
                return Tab(
                  height: kToolbarHeight * 0.8 - 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Tab ${index + 1}'),
                      const SizedBox(width: 4),
                      if (_tabKeys.length > 1)
                        InkWell(
                          onTap: () => _removeTab(index),
                          customBorder: const CircleBorder(),
                          child: Icon(Icons.close, size: 14, color: textColor),
                        )
                    ],
                  ),
                );
              }),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add, color: textColor),
            tooltip: 'Add New Tab',
            onPressed: _addTab,
            splashRadius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
          ),
        ],
      ),
    );
  }

  // --- Helper method to build a vertical tab bar ---
  Widget _buildVerticalTabBar() {
    // Get theme colors
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;
    
    return Container(
      width: 60, // Reduced width for vertical tab bar
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: theme.dividerColor, width: 0.5))
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _tabKeys.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                bool isSelected = _tabController?.index == index;
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        if (_tabController != null) {
                          _tabController!.animateTo(index);
                        }
                      },
                      child: Container(
                        height: 56,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: theme.dividerColor,
                              width: 0.5,
                            ),
                            left: BorderSide(
                              color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : null,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Tab number
                            Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isSelected ? theme.colorScheme.primary : textColor,
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            
                            // Close button (if more than one tab)
                            if (_tabKeys.length > 1)
                              Positioned(
                                top: 2,
                                right: 2,
                                child: InkWell(
                                  onTap: () => _removeTab(index),
                                  customBorder: const CircleBorder(),
                                  child: Icon(
                                    Icons.close,
                                    size: 12,
                                    color: textColor.withOpacity(0.7),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Add tab button
          InkWell(
            onTap: _addTab,
            child: Container(
              height: 46,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: theme.dividerColor, width: 0.5),
                ),
              ),
              child: Icon(
                Icons.add,
                color: textColor,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    // Check for null controller first
    if (_tabController == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vedic Astrology')),
        body: const Center(child: Text('Initializing...')), 
      );
    }

    // Build the main content based on provider state
    return Consumer<ChartProvider>(
      builder: (context, provider, child) {
        // Handle overall error/loading BEFORE Scaffold assembly
        if (provider.error != null && provider.getMainChart() == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('Error generating chart: ${provider.error}')),
          );
        }
        if (provider.isLoading && provider.getMainChart() == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Vedic Astrology')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // --- Determine Layout based on Screen Size ---
        final Size screenSize = MediaQuery.of(context).size;
        final bool isDesktopLayout = screenSize.width > screenSize.height; 

        // --- Assemble Body Content --- 
        Widget bodyContent;
        if (isDesktopLayout) {
          // Desktop: Row layout with vertical tabs on left
          bodyContent = Row(
            children: [
              _buildVerticalTabBar(),
              Expanded(
                flex: 2,
                child: _buildTabSection(), 
              ),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded(
                flex: 3,
                child: _buildInfoSection(),
              ),
            ],
          );
        } else {
          // Phone: Column layout with horizontal tabs at bottom
          bodyContent = Column(
            children: [
              Expanded(
                flex: 3,
                child: _buildTabSection(),
              ),
              Expanded(
                flex: 3,
                child: _buildInfoSection(),
              ),
              _buildHorizontalTabBar(),
            ]
          );
        }

        // --- Build Scaffold ---
        return Scaffold(
          appBar: AppBar(
            title: const Text('Chart Analysis'),
            actions: [
              // Using the reusable settings button
              AppSettings.settingsButton(context),
            ],
          ),
          body: bodyContent, 
        );
      },
    );
  }
}