import 'package:flutter/material.dart';
import 'package:recishare_flutter/pages/import_export_page.dart';

class SettingsPage extends StatelessWidget {
  final Function() onRefresh;

  const SettingsPage({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import / Export recipes'),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ImportExportPage(onRefresh: onRefresh)),
              );
              if (result == true) {
                onRefresh();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              // Navigate to about page
            },
          ),
        ],
      ),
    );
  }
}
