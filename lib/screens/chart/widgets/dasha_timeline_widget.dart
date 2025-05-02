import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/dasha_model.dart';
import '../../../providers/dasha_provider.dart';
import 'package:intl/intl.dart';

// Enum to represent the Dasha level
enum DashaLevel { maha, antar, pratyantar }

class DashaTimelineWidget extends StatelessWidget {
  const DashaTimelineWidget({Key? key}) : super(key: key);

  // Helper to build the content of a Dasha tile
  Widget _buildDashaTileContent(BuildContext context, DashaPeriod dasha, DashaLevel level) {
    final dateFormat = DateFormat('dd-MM-yyyy');
    // Pass the level to get the appropriate color
    final planetColor = _getPlanetColor(dasha.planet, level);

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
            style: TextStyle(fontSize: 12, color: Colors.black54.withOpacity(0.8)), // Slightly less prominent date
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          formattedDuration,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black.withOpacity(0.9)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0), // Add padding below title
              child: Text(
                'Vimshottari Dasha',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  // Pass MahaDasha level
                  title: _buildDashaTileContent(context, mahaDasha, DashaLevel.maha),
                  children: (mahaDasha.antardashas ?? []).map((antarDasha) {
                    bool hasPratyantars = (antarDasha.pratyantarDashas ?? []).isNotEmpty;
                    // Nested ExpansionTile for Antar Dashas
                    return ExpansionTile(
                       key: PageStorageKey('antar_${antarDasha.planet}_${antarDasha.startDate}'),
                       tilePadding: const EdgeInsets.only(left: 32.0, right: 16.0, top: 4.0, bottom: 4.0), // Indent Antar
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

  // Modified color helper to accept DashaLevel
  Color _getPlanetColor(String planet, DashaLevel level) {
    // Base color can be defined elsewhere if needed, e.g., from Constants
    Color baseColor;
    switch (planet.toLowerCase()) {
      case 'sun': baseColor = Colors.orange[800]!; break;
      case 'moon': baseColor = Colors.grey[400]!; break;
      case 'mars': baseColor = Colors.red[700]!; break;
      case 'mercury': baseColor = Colors.green[600]!; break;
      case 'jupiter': baseColor = Colors.yellow[700]!; break;
      case 'venus': baseColor = Colors.pink[300]!; break;
      case 'saturn': baseColor = Colors.blueGrey[700]!; break;
      case 'rahu': baseColor = Colors.indigo[700]!; break;
      case 'ketu': baseColor = Colors.purple[700]!; break;
      default: baseColor = Colors.black;
    }

    // Adjust color based on Dasha level
    switch (level) {
      case DashaLevel.maha:
        // Use a slightly darker/more saturated version or the base color itself
        // return baseColor; // Or HSLColor.fromColor(baseColor).withLightness(0.4).toColor();
        return Colors.black;
      case DashaLevel.antar:
        // Use a slightly lighter version
        // return HSLColor.fromColor(baseColor).withLightness(0.6).toColor();
        return const Color(0xFF7E4B39);
      case DashaLevel.pratyantar:
        // Use the lightest version
        // return HSLColor.fromColor(baseColor).withLightness(0.75).toColor();
        return const Color(0xFFB46C00);
    }
  }
}