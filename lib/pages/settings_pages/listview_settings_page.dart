import 'package:flutter/material.dart';

class ViewSettingsPage extends StatefulWidget {
  final String currentViewMode;
  final Function(String) onViewModeChange;

  const ViewSettingsPage({
    super.key,
    required this.currentViewMode,
    required this.onViewModeChange,
  });

  @override
  State<ViewSettingsPage> createState() => _ViewSettingsPageState();
}

class _ViewSettingsPageState extends State<ViewSettingsPage> {
  late String selectedViewMode;

  @override
  void initState() {
    super.initState();
    selectedViewMode = widget.currentViewMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          RadioListTile<String>(
            title: const Text('List View'),
            value: 'List',
            groupValue: selectedViewMode,
            onChanged: (value) {
              setState(() {
                selectedViewMode = value!;
              });
              widget.onViewModeChange(value!);
              Navigator.pop(context, value); // Return the selected mode
            },
          ),
          RadioListTile<String>(
            title: const Text('Grid View'),
            value: 'Grid',
            groupValue: selectedViewMode,
            onChanged: (value) {
              setState(() {
                selectedViewMode = value!;
              });
              widget.onViewModeChange(value!);
              Navigator.pop(context, value); // Return the selected mode
            },
          ),
        ],
      ),
    );
  }
}
