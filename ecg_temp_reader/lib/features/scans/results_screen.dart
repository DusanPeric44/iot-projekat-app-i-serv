import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import 'scan_provider.dart';
import 'scan_details_screen.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthProvider>();
    final provider = context.read<ScanProvider>();
    if (auth.currentUser != null) {
      provider.load(auth.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScanProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('My Results')),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemBuilder: (ctx, i) {
                final s = provider.scans[i];
                return Dismissible(
                  key: ValueKey(s.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    provider.delete(s.id);
                  },
                  child: ListTile(
                    title: Text('${s.createdAt.toLocal()}'),
                    subtitle: Text(
                      'Temperature: ${s.temperature.toStringAsFixed(2)} °C',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ScanDetailsScreen(session: s),
                        ),
                      );
                    },
                  ),
                );
              },
              separatorBuilder: (_, i2) => const Divider(height: 1),
              itemCount: provider.scans.length,
            ),
    );
  }
}
