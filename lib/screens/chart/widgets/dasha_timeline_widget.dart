import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/dasha_model.dart';
import '../../../providers/dasha_provider.dart';
import 'package:intl/intl.dart';

class DashaTimelineWidget extends StatelessWidget {
  const DashaTimelineWidget({Key? key}) : super(key: key);

  // Helper to build the content of a Dasha tile
  Widget _buildDashaTileContent(BuildContext context, DashaPeriod dasha) {
    final dateFormat = DateFormat('dd-MM-yyyy');
    final planetColor = _getPlanetColor(dasha.planet);

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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          dasha.planet,
          style: TextStyle(
            color: planetColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            '${dateFormat.format(dasha.startDate)} - ${dateFormat.format(dasha.endDate)}',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          formattedDuration,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
                  title: _buildDashaTileContent(context, mahaDasha),
                  children: (mahaDasha.antardashas ?? []).map((antarDasha) {
                    bool hasPratyantars = (antarDasha.pratyantarDashas ?? []).isNotEmpty;
                    // Nested ExpansionTile for Antar Dashas
                    return ExpansionTile(
                       key: PageStorageKey('antar_${antarDasha.planet}_${antarDasha.startDate}'),
                       tilePadding: const EdgeInsets.only(left: 32.0, right: 16.0, top: 4.0, bottom: 4.0), // Indent Antar
                       title: _buildDashaTileContent(context, antarDasha),
                       // Only allow expansion if there are pratyantars
                       initiallyExpanded: false, 
                       maintainState: true,
                       children: hasPratyantars
                          ? (antarDasha.pratyantarDashas!).map((pratyantarDasha) {
                              // Use ListTile for Pratyantar Dashas
                              return ListTile(
                                key: PageStorageKey('prat_${pratyantarDasha.planet}_${pratyantarDasha.startDate}'),
                                contentPadding: const EdgeInsets.only(left: 48.0, right: 16.0), // Further indent Pratyantar
                                visualDensity: VisualDensity.compact, // Make it denser
                                title: _buildDashaTileContent(context, pratyantarDasha),
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

  // Keep color helper
  Color _getPlanetColor(String planet) {
    switch (planet.toLowerCase()) {
      case 'sun': return Colors.orange;
      case 'moon': return Colors.blue;
      case 'mars': return Colors.red;
      case 'mercury': return Colors.green;
      case 'jupiter': return Colors.purple;
      case 'venus': return Colors.pink;
      case 'saturn': return Colors.grey;
      case 'rahu': return Colors.brown;
      case 'ketu': return Colors.black;
      default: return Colors.grey;
    }
  }
}