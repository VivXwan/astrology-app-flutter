import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chart_provider.dart';
import '../providers/dasha_provider.dart';
import '../models/chart.dart';
import 'chart/widgets/chart_widget.dart';
import 'chart/widgets/kundali_table_widget.dart';
import 'chart/widgets/dasha_timeline_widget.dart';
import 'dart:math';

// New Widget for Tab Content
class ChartTabContent extends StatefulWidget {
  const ChartTabContent({required Key key}) : super(key: key);

  @override
  _ChartTabContentState createState() => _ChartTabContentState();
}

class _ChartTabContentState extends State<ChartTabContent> with AutomaticKeepAliveClientMixin {
  // Local state for this tab's view configuration
  List<String> _selectedChartTypes = ['D-1'];
  // *** ADD State for styles ***
  List<String> _selectedChartStyles = ['North Indian']; 
  final List<String> _availableChartStyles = ['North Indian', 'South Indian'];

  // Style constants
  static const double _dropdownHeight = 35.0;
  static const double _minDropdownWidth = 90.0; // Slightly wider minimum

  @override
  bool get wantKeepAlive => true; // Keep state when switching tabs

  void _setChartType(int index, String type) {
     // Access available types from provider (could be passed down or read here)
    final availableTypes = context.read<ChartProvider>().availableChartTypes;
    if (index >= 0 && index < _selectedChartTypes.length && availableTypes.contains(type)) {
       if (_selectedChartTypes[index] != type) {
          setState(() {
             _selectedChartTypes[index] = type;
          });
       }
    }
  }

  // *** ADD Method to set style ***
  void _setChartStyle(int index, String style) {
     if (index >= 0 && index < _selectedChartStyles.length && _availableChartStyles.contains(style)) {
       if (_selectedChartStyles[index] != style) {
          setState(() {
             _selectedChartStyles[index] = style;
          });
       }
    }
  }

 // *** ADD Helper for Type Dropdown ***
  Widget _buildTypeDropdown(int index, String selectedType, double availableWidth) {
    final chartProvider = context.read<ChartProvider>();
    return SizedBox(
      height: _dropdownHeight,
      width: availableWidth, // Take the width provided by the caller
      child: DropdownButton<String>(
        value: selectedType,
        isExpanded: true,
        underline: Container(height: 1, color: Colors.grey),
        style: const TextStyle(fontSize: 13, color: Colors.black),
        items: chartProvider.availableChartTypes.map((String type) {
          String displayText = switch (type) {
            'D-1' => 'Rashi (D-1)',
            'D-2' => 'Hora (D-2)',
            'D-3' => 'Drekkana (D-3)',
            'D-7' => 'Saptamsa (D-7)',
            'D-9' => 'Navamsa (D-9)',
            'D-12' => 'Dwadasamsa (D-12)',
            'D-30' => 'Trimshamsa (D-30)',
            _ => type
          };
          return DropdownMenuItem<String>(
            value: type,
            child: Text(displayText, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            _setChartType(index, newValue);
          }
        },
      ),
    );
  }

  // *** ADD Helper for Style Dropdown ***
  Widget _buildStyleDropdown(int index, String selectedStyle, double availableWidth) {
      return SizedBox(
        height: _dropdownHeight,
        width: availableWidth, // Take the width provided by the caller
        child: DropdownButton<String>(
          value: selectedStyle,
          isExpanded: true,
          underline: Container(height: 1, color: Colors.grey),
          style: const TextStyle(fontSize: 13, color: Colors.black),
          items: _availableChartStyles.map((String style) {
            return DropdownMenuItem<String>(
              value: style,
              child: Text(style, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (String? newValue) {
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

  // Helper to build adaptive selectors (used in TALL layout primarily now)
  // Retained for potential use if cell width calculation needs it later, but might simplify
  Widget _buildAdaptiveSelectorsRow(int index, String selectedType, String selectedStyle, double availableWidth) {
    const double horizontalPadding = 4.0; 
    final double requiredRowWidth = (_minDropdownWidth * 2) + horizontalPadding;
    final bool canFitRow = availableWidth >= requiredRowWidth;

    if (canFitRow) {
      // Use Row if width is sufficient
      return SizedBox(
        height: _dropdownHeight + 8, 
        child: Row(
          children: [
            Expanded(
              child: _buildTypeDropdown(index, selectedType, double.infinity), 
            ),
            const SizedBox(width: horizontalPadding),
            Expanded(
               child: _buildStyleDropdown(index, selectedStyle, double.infinity), 
            ),
          ],
        ),
      );
    } else {
      // Use Column if width is insufficient
      return Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
           _buildTypeDropdown(index, selectedType, availableWidth),
           const SizedBox(height: 4), 
           _buildStyleDropdown(index, selectedStyle, availableWidth),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final chartProvider = context.watch<ChartProvider>();

    // Check necessary conditions from provider before building UI
     if (chartProvider.error != null) {
       return Center(child: Text('Error: ${chartProvider.error}'));
     }
     if (chartProvider.isLoading && chartProvider.chart == null) {
       return const Center(child: CircularProgressIndicator());
     }
     if (chartProvider.chart == null) {
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
          if (numberOfChartsToDisplay != _selectedChartTypes.length || numberOfChartsToDisplay != _selectedChartStyles.length ) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    final currentLen = _selectedChartTypes.length;
                    if (numberOfChartsToDisplay > currentLen) {
                      final chartProvider = context.read<ChartProvider>();
                      List<String> availableTypes = chartProvider.availableChartTypes;
                      for (int i = currentLen; i < numberOfChartsToDisplay; i++) {
                        int typeIndex = (i % availableTypes.length);
                        _selectedChartTypes.add(availableTypes[typeIndex]);
                        _selectedChartStyles.add('North Indian'); 
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
          
          // *** CHANGE: Align the SizedBox containing the GridView instead of Center ***
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
                  String selectedType = _selectedChartTypes[index];
                  String selectedStyle = _selectedChartStyles[index];
                  Chart? chartData = chartProvider.getChartDataForType(selectedType);
                  
                  // Build Selectors - Use the adaptive helper
                  Widget selectorsWidget = _buildAdaptiveSelectorsRow(index, selectedType, selectedStyle, requiredCellWidth - cellPadding * 2);
    
                  // Build Chart Widget 
                  Widget chartWidget = Expanded(
                      child: chartData != null
                          ? ChartWidget(
                              key: ValueKey('$selectedType-$selectedStyle-$index'), 
                              chart: chartData,
                              selectedStyle: selectedStyle,
                             )
                          : const Center(child: Text('N/A')),
                     );
    
                  // Assemble final layout within Card - ALWAYS a Column
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias, 
                    child: Padding(
                      padding: EdgeInsets.all(cellPadding),
                      child: Column( 
                          children: [
                            selectorsWidget, 
                            chartWidget, // Expanded chart takes remaining space
                          ],
                        ),
                    ),
                  );
                },
              ),
            ),
          );
        }
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
         if (provider.error != null && provider.chart == null) {
           return Scaffold(
             appBar: AppBar(title: const Text('Error')),
             body: Center(child: Text('Error generating chart: ${provider.error}')),
           );
         }
         if (provider.isLoading && provider.chart == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Vedic Astrology')),
              body: const Center(child: CircularProgressIndicator()),
            );
         }

        // --- Determine Layout based on Screen Size (Keep this the same) ---
        final Size screenSize = MediaQuery.of(context).size;
        final bool isDesktopLayout = screenSize.width > screenSize.height; 

        // --- Assemble Body Content --- 
        Widget bodyContent;
        if (isDesktopLayout) {
          // Desktop: Row layout - *** ADJUST FLEX ***
          bodyContent = Row(
            children: [
              Expanded( // Left side for tabs
                flex: 2, // Increased flex for charts 
                child: _buildTabSection(), 
              ),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded( // Right side for info
                flex: 3, // Decreased flex for info
                child: _buildInfoSection(),
              ),
            ],
          );
        } else {
          // Phone: Column layout (original structure) - *** ADJUST FLEX ***
          bodyContent = Column(
             children: [
               Expanded(
                 flex: 3, // Increased flex for tabs
                 child: _buildTabSection(),
               ),
               Expanded(
                 flex: 3, // Kept info flex the same or decrease slightly if needed
                 child: _buildInfoSection(),
               ),
             ]
          );
        }

        // --- Build Scaffold (Keep AppBar/Bottom structure the same) ---
        return Scaffold(
          appBar: AppBar(
            title: const Text('Chart Analysis'),
             actions: const [], 
            bottom: PreferredSize( 
              preferredSize: Size.fromHeight(kToolbarHeight * 0.8), 
              child: Container(
                height: kToolbarHeight * 0.8, 
                child: Row(
                  children: [
                    Expanded(
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true, 
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
                                    child: const Icon(Icons.close, size: 14),
                                  )
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: 'Add New Tab',
                      onPressed: _addTab,
                      splashRadius: 18, 
                      padding: const EdgeInsets.symmetric(horizontal: 12.0), 
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: bodyContent, 
        );
      },
    );
  }
}