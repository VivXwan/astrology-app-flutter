import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/chart_provider.dart';
import '../../../models/kundali_details.dart';

class KundaliTableWidget extends StatelessWidget {
  const KundaliTableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChartProvider>(
      builder: (context, provider, child) {
        final chart = provider.getMainChart();
        if (chart == null) {
          return const SizedBox.shrink();
        }

        // Access the typed properties instead of dynamic maps
        final kundaliDetails = chart.kundali;
        
        // Access birth data from the raw data (since it's not yet modeled)
        final birthData = chart.rawData['birth_data'] as Map<String, dynamic>;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoTable(birthData),
              const SizedBox(height: 16),
              _buildPlanetaryPositionsTable(kundaliDetails),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBasicInfoTable(Map<String, dynamic> birthData) {
    final tzOffset = birthData['tz_offset'] as double;
    final tzMultiplier = tzOffset > 0 ? 1 : -1;
    final tzSign = tzOffset > 0 ? '+' : '-';
    final tzDir = tzMultiplier == 1 ? 'East of GMT' : 'West of GMT';
    final timezoneHour = (tzOffset.abs() / 1).floor();
    final timezoneMinute = (tzOffset.abs() % 1 * 60).floor();
    final timezone = '$timezoneHour:${timezoneMinute.toString().padLeft(2, '0')}';
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Birth Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(2),
              },
              children: [
                _buildTableRow('Birth Date', '${birthData['day']}-${birthData['month']}-${birthData['year']}'),
                _buildTableRow('Birth Time', '${birthData['hour'].toString().padLeft(2, '0')}:${birthData['minute'].toString().padLeft(2, '0')}'),
                _buildTableRow('Birth Place', 'Latitude: ${birthData['latitude']}, Longitude: ${birthData['longitude']}'),
                _buildTableRow('Timezone', '$tzSign$timezone ($tzDir)')
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanetaryPositionsTable(KundaliDetails kundaliDetails) {
    // Now we're using the typed PlanetDetails objects
    final planets = kundaliDetails.planets;

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Planetary Positions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              DataTable(
                columns: const [
                  DataColumn(label: Text('Planet')),
                  DataColumn(label: Text('Sign')),
                  DataColumn(label: Text('Degree')),
                  DataColumn(label: Text('House')),
                  DataColumn(label: Text('Nakshatra')),
                  DataColumn(label: Text('Pada')),
                  DataColumn(label: Text('Retrograde')),
                ],
                rows: planets.entries.map((entry) {
                  final planet = entry.key;
                  final details = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(Text(planet)),
                      DataCell(Text(details.sign)),
                      DataCell(Text(details.degreesInSignDms)),
                      DataCell(Text('${details.house}')),
                      DataCell(Text(details.nakshatra)),
                      DataCell(Text('${details.pada}')),
                      DataCell(Text(details.isRetrograde ? 'Yes' : 'No')),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(value),
        ),
      ],
    );
  }
} 