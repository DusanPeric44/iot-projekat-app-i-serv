import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(HealthApp());

class HealthApp extends StatefulWidget {
  @override
  _HealthAppState createState() => _HealthAppState();
}

class _HealthAppState extends State<HealthApp> {
  final channel = IOWebSocketChannel.connect("ws://192.168.4.1:81");

  List<FlSpot> ecg = [];
  int index = 0;
  double temp = 0;

  @override
  void initState() {
    super.initState();

    channel.stream.listen((msg) {
      // "ECG:1234;TEMP:36.55"
      final parts = msg.split(";");

      final ecgVal = double.parse(parts[0].split(":")[1]);
      final tempVal = double.parse(parts[1].split(":")[1]);

      setState(() {
        temp = tempVal;

        ecg.add(FlSpot(index.toDouble(), ecgVal));
        index++;
        if (ecg.length > 200) ecg.removeAt(0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Health Monitor")),
        body: Column(
          children: [
            SizedBox(height: 20),
            Text(
              "Temperature: ${temp.toStringAsFixed(2)} °C",
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 20),
            Expanded(
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: ecg,
                      isCurved: false,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
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
