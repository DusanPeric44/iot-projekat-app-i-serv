import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(HealthApp());

class HealthApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HealthScreen());
  }
}

class HealthScreen extends StatefulWidget {
  @override
  _HealthScreenState createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final channel = IOWebSocketChannel.connect("ws://10.15.225.187:8080");

  List<FlSpot> ecg = [];
  int index = 0;
  double temp = 0;

  @override
  void initState() {
    super.initState();

    channel.stream.listen((msg) {
      final data = jsonDecode(msg);

      final ecgVal = (data["ecg"] ?? 0).toDouble();
      final tempVal = (data["temp"] ?? 0).toDouble();

      setState(() {
        temp = tempVal;

        // scale ECG nicely for chart
        double scaled = ecgVal / 4095 * 100;

        ecg.add(FlSpot(index.toDouble(), scaled));
        index++;

        // keep last 200 samples
        if (ecg.length > 200) {
          ecg.removeAt(0);
        }
      });
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Telemedicine Health Monitor")),

      body: Column(
        children: [
          SizedBox(height: 20),

          Text(
            "Temperature: ${temp.toStringAsFixed(2)} °C",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 20),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),

              child: LineChart(
                LineChartData(
                  minX: ecg.isEmpty ? 0 : ecg.first.x,
                  maxX: ecg.isEmpty ? 200 : ecg.last.x,

                  minY: 0,
                  maxY: 100,

                  gridData: FlGridData(show: true),

                  titlesData: FlTitlesData(show: false),

                  borderData: FlBorderData(show: true),

                  lineBarsData: [
                    LineChartBarData(
                      spots: ecg,
                      isCurved: false,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
