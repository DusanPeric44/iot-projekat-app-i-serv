import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/auth_provider.dart';
import '../../features/auth/login_screen.dart';
import '../../features/scans/results_screen.dart';
import '../../main.dart';

class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(child: Text('Menu')),
          ListTile(
            leading: const Icon(Icons.monitor_heart),
            title: const Text('Live Monitor'),
            onTap: () {
              if (ModalRoute.of(context)?.settings.name ==
                  HealthScreen.routeName) {
                Navigator.of(context).pop();
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => HealthScreen(),
                  settings: RouteSettings(name: HealthScreen.routeName),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('My Results'),
            onTap: () {
              if (ModalRoute.of(context)?.settings.name ==
                  ResultsScreen.routeName) {
                Navigator.of(context).pop();
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ResultsScreen(),
                  settings: RouteSettings(name: ResultsScreen.routeName),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
