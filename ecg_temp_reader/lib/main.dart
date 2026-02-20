import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';

import 'data/repositories/auth_repository.dart';
import 'data/repositories/scan_repository.dart';
import 'data/models/scan_session.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/scans/scan_provider.dart';
import 'ui/widgets/app_drawer.dart';

void main() {
  runApp(AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthRepository())),
        ChangeNotifierProvider(create: (_) => ScanProvider(ScanRepository())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const SessionGate(),
      ),
    );
  }
}

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final auth = context.read<AuthProvider>();
      auth.loadSession().then((_) {
        if (!mounted) return;
        setState(() {
          _ready = true;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final auth = context.watch<AuthProvider>();
    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }
    return HealthScreen();
  }
}

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});
  @override
  HealthScreenState createState() => HealthScreenState();
}

class HealthScreenState extends State<HealthScreen> {
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
        double scaled = ecgVal / 4095 * 100;
        ecg.add(FlSpot(index.toDouble(), scaled));
        index++;
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

  Future<void> _saveScan() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser == null) return;
    final samples = ecg.map((e) => e.y).toList();
    final session = ScanSession(
      id: 0,
      userId: auth.currentUser!.id,
      createdAt: DateTime.now(),
      temperature: temp,
      ecgSamples: samples,
    );
    final scanProvider = context.read<ScanProvider>();
    await scanProvider.save(session);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Telemedicine Health Monitor")),
      drawer: const AppMenuDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveScan,
        child: const Icon(Icons.save),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            "Temperature: ${temp.toStringAsFixed(2)} °C",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
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
