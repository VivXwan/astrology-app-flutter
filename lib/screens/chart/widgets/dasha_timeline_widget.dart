import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/dasha_model.dart';
import '../../../providers/dasha_provider.dart';
import '../../../config/theme_extensions.dart';
import 'package:intl/intl.dart';

// Enum to represent the Dasha level
enum DashaLevel { maha, antar, pratyantar }

class DashaTimelineWidget extends StatelessWidget {
  const DashaTimelineWidget({Key? key}) : super(key: key);

  // Helper to build the content of a Dasha tile
  Widget _buildDashaTileContent(BuildContext context, DashaPeriod dasha, DashaLevel level) {
    final dateFormat = DateFormat('dd-MM-yyyy');
    // Get theme
    final dashaTheme = Theme.of(context).extension<DashaTheme>() ?? DashaTheme.light;
    // Pass the level to get the appropriate color
    final planetColor = _getPlanetColor(context, dasha.planet, level);

    // Calculate duration
    final Duration duration = dasha.endDate.difference(dasha.startDate);
    final int years = duration.inDays ~/ 365;
    final int months = (duration.inDays % 365) ~/ 30;
    final int days = (duration.inDays % 365) % 30;
    String formattedDuration = '';
    if (years > 0) formattedDuration += '${years}Y ';
    if (months > 0 || (years > 0 && days > 0)) formattedDuration += '${months}M ';
    if (days > 0 || formattedDuration.isEmpty) formattedDuration += '${days}D';
    formattedDuration = formattedDuration.trim();

    // Adjust font weight based on level for visual hierarchy
    FontWeight fontWeight;
    double fontSize = 14; // Default font size
    switch (level) {
      case DashaLevel.maha:
        fontWeight = FontWeight.bold;
        fontSize = 15; // Slightly larger for Maha
        break;
      case DashaLevel.antar:
        fontWeight = FontWeight.w600; // Semi-bold for Antar
        break;
      case DashaLevel.pratyantar:
        fontWeight = FontWeight.w600; // Semi-bold for Pratyantar
        fontSize = 13; // Slightly smaller for Pratyantar
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          dasha.planet,
          style: TextStyle(
            color: planetColor,
            fontWeight: fontWeight,
            fontSize: fontSize,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            '${dateFormat.format(dasha.startDate)} - ${dateFormat.format(dasha.endDate)}',
            style: TextStyle(
              fontSize: 12, 
              color: dashaTheme.textColor.withOpacity(0.8)
            ), // Use theme color with opacity
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          formattedDuration,
          style: TextStyle(
            fontSize: 12, 
            fontWeight: FontWeight.w500, 
            color: dashaTheme.textColor.withOpacity(0.9)
          ), // Use theme color with opacity
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get theme
    final dashaTheme = Theme.of(context).extension<DashaTheme>() ?? DashaTheme.light;
    
    return Consumer<DashaProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.error != null) {
          return Center(child: Text(provider.error!, style: const TextStyle(color: Colors.red)));
        }
        final dashaData = provider.dashaData;
        if (dashaData == null || dashaData.mahaDashas.isEmpty) {
          return const Center(child: Text('No Dasha data available'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Use min size
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0), // Add padding below title
              child: Text(
                'Vimshottari Dasha',
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  color: dashaTheme.textColor,
                ),
              ),
            ),
            // Use ListView for scrollability if many Maha Dashas
            ListView.builder(
              shrinkWrap: true, // Essential inside a Column
              physics: const NeverScrollableScrollPhysics(), // Handled by outer scroll
              itemCount: dashaData.mahaDashas.length,
              itemBuilder: (context, mahaIndex) {
                final mahaDasha = dashaData.mahaDashas[mahaIndex];
                return ExpansionTile(
                  key: PageStorageKey('maha_${mahaDasha.planet}_${mahaDasha.startDate}'),
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  collapsedIconColor: dashaTheme.mahaDashaBorderColor,
                  iconColor: dashaTheme.mahaDashaBorderColor,
                  // Pass MahaDasha level
                  title: _buildDashaTileContent(context, mahaDasha, DashaLevel.maha),
                  children: (mahaDasha.antardashas ?? []).map((antarDasha) {
                    bool hasPratyantars = (antarDasha.pratyantarDashas ?? []).isNotEmpty;
                    // Nested ExpansionTile for Antar Dashas
                    return ExpansionTile(
                       key: PageStorageKey('antar_${antarDasha.planet}_${antarDasha.startDate}'),
                       tilePadding: const EdgeInsets.only(left: 32.0, right: 16.0, top: 4.0, bottom: 4.0), // Indent Antar
                       collapsedIconColor: dashaTheme.antarDashaBorderColor,
                       iconColor: dashaTheme.antarDashaBorderColor,
                       // Pass AntarDasha level
                       title: _buildDashaTileContent(context, antarDasha, DashaLevel.antar),
                       // Only allow expansion if there are pratyantars
                       initiallyExpanded: false,
                       maintainState: false, // Build Pratyantars only when Antar is expanded
                       children: hasPratyantars
                          ? (antarDasha.pratyantarDashas!).map((pratyantarDasha) {
                              // Use ListTile for Pratyantar Dashas
                              return ListTile(
                                key: PageStorageKey('prat_${pratyantarDasha.planet}_${pratyantarDasha.startDate}'),
                                contentPadding: const EdgeInsets.only(left: 48.0, right: 16.0), // Further indent Pratyantar
                                visualDensity: VisualDensity.compact, // Make it denser
                                // Pass PratyantarDasha level
                                title: _buildDashaTileContent(context, pratyantarDasha, DashaLevel.pratyantar),
                              );
                            }).toList()
                          : [], // No children if no pratyantars
                    );
                  }).toList(),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Modified color helper to accept DashaLevel and use theme
  Color _getPlanetColor(BuildContext context, String planet, DashaLevel level) {
    // Get theme
    final dashaTheme = Theme.of(context).extension<DashaTheme>() ?? DashaTheme.light;
    final chartTheme = Theme.of(context).extension<ChartTheme>() ?? ChartTheme.light;
    
    // Try to get color from chart theme's planet colors first
    Color planetBaseColor = chartTheme.planetColors[planet.toLowerCase()] ?? 
                           chartTheme.planetColors[planet] ?? 
                           dashaTheme.textColor;
    
    // Adjust color based on Dasha level
    switch (level) {
      case DashaLevel.maha:
        return dashaTheme.mahaDashaBorderColor;
      case DashaLevel.antar:
        return dashaTheme.antarDashaBorderColor;
      case DashaLevel.pratyantar:
        return dashaTheme.pratDashaBorderColor;
    }
  }
}