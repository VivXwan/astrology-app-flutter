import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/chart_provider.dart';

class KundaliTableWidget extends StatelessWidget {
  const KundaliTableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChartProvider>(
      builder: (context, provider, child) {
        if (provider.chart == null) {
          return const SizedBox.shrink();
        }

        final kundali = provider.chart!.data['kundali'] as Map<String, dynamic>;
        final birth_data = provider.chart!.data['birth_data'] as Map<String, dynamic>;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoTable(birth_data),
              const SizedBox(height: 16),
              _buildPlanetaryPositionsTable(kundali),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBasicInfoTable(Map<String, dynamic> birth_data) {
    final tz_multiplier = birth_data['tz_offset'] > 0 ? 1 : -1;
    final tz_sign = birth_data['tz_offset'] > 0 ? '+' : '-';
    final tz_dir = tz_multiplier == 1 ? 'East of GMT' : 'West of GMT';
    final timezone_hour = (birth_data['tz_offset'] / 1).floor();
    final timezone_minute = (birth_data['tz_offset'] % 1 * 60).floor();
    final timezone = '$timezone_hour:$timezone_minute';
    
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
                _buildTableRow('Birth Date', '${birth_data['day']}-${birth_data['month']}-${birth_data['year']}'),
                _buildTableRow('Birth Time', '${birth_data['hour'].toString().padLeft(2, '0')}:${birth_data['minute'].toString().padLeft(2, '0')}'),
                _buildTableRow('Birth Place', 'Latitude: ${birth_data['latitude']}, Longitude: ${birth_data['longitude']}'),
                _buildTableRow('Timezone', '$tz_sign$timezone ($tz_dir)')
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanetaryPositionsTable(Map<String, dynamic> kundali) {
    final planets = kundali['planets'] as Map<String, dynamic>;

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
                ],
                rows: planets.entries.map((entry) {
                  final planet = entry.key;
                  final details = entry.value as Map<String, dynamic>;
                  return DataRow(
                    cells: [
                      DataCell(Text(planet)),
                      DataCell(Text(details['sign'] as String)),
                      DataCell(Text(details['degrees_in_sign_dms'] as String)),
                      DataCell(Text('${details['house']}')),
                      DataCell(Text(details['nakshatra'] as String)),
                      DataCell(Text('${details['pada']}')),
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