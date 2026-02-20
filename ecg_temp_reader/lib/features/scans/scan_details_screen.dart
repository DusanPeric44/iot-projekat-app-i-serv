import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../data/models/scan_session.dart';

class ScanDetailsScreen extends StatelessWidget {
  final ScanSession session;
  const ScanDetailsScreen({super.key, required this.session});

  static String? get routeName => '/scan-details';

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (var i = 0; i < session.ecgSamples.length; i++) {
      spots.add(FlSpot(i.toDouble(), session.ecgSamples[i]));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${session.createdAt.toLocal()}'),
            const SizedBox(height: 8),
            Text('Temperature: ${session.temperature.toStringAsFixed(2)} °C'),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: session.ecgSamples.isEmpty
                      ? 0
                      : (session.ecgSamples.length - 1).toDouble(),
                  minY: 0,
                  maxY: 100,
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
