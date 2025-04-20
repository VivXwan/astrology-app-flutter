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
        if (provider.chart == null) {
          return const SizedBox.shrink();
        }

        final kundali = provider.chart!.data['kundali'] as Map<String, dynamic>;
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoTable(kundali),
              const SizedBox(height: 16),
              _buildPlanetaryPositionsTable(kundali),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBasicInfoTable(Map<String, dynamic> kundali) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
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
                _buildTableRow('Ayanamsa', '${kundali['ayanamsa'].toStringAsFixed(2)}°'),
                _buildTableRow('Ayanamsa Type', kundali['ayanamsa_type']),
                _buildTableRow('Ascendant Sign', kundali['ascendant']['sign']),
                _buildTableRow('Ascendant Longitude', kundali['ascendant']['longitude_dms']),
                _buildTableRow('Midheaven', kundali['midheaven_dms']),
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