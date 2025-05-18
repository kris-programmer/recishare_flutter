import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import added
import '../theme_provider.dart';
import 'settings_pages/import_export_page.dart';
import 'settings_pages/font_settings_page.dart';
import 'about_page.dart';
import 'settings_pages/language_settings_page.dart';
import 'settings_pages/listview_settings_page.dart';
import 'tutorial_page.dart';

// The SettingsPage widget provides a settings screen for the app.
class SettingsPage extends StatelessWidget {
  // Callback function to refresh the app's state when necessary.
  final Function() onRefresh;

  // Constructor for SettingsPage, requiring the onRefresh callback.
  const SettingsPage({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    // Access the ThemeProvider to manage theme-related settings.
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        // Title of the settings page.
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // ListTile for navigating to the Import/Export page.
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import / Export recipes'),
            onTap: () async {
              // Navigate to the ImportExportPage and wait for a result.
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ImportExportPage(onRefresh: onRefresh)),
              );
              // If the result is true, trigger the onRefresh callback,
              // updating the recipes inside the app.
              if (result == true) {
                onRefresh();
              }
            },
          ),

          // SwitchListTile for toggling between light and dark mode.
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: themeProvider.themeMode ==
                ThemeMode.dark, // Current theme mode.
            onChanged: (value) {
              // Toggle the theme mode when the switch is changed.
              themeProvider.toggleTheme();
            },
            secondary: const Icon(Icons.dark_mode),
          ),

          // ListTile for navigating to the Font settings page
          ListTile(
            leading: const Icon(Icons.font_download),
            title: const Text('Font Size'),
            onTap: () {
              // Navigate to the FontSettingsPage.
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const FontSettingsPage()),
              );
            },
          ),

          // ListTile for navigating to the Language settings page.
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            onTap: () {
              // Navigate to the LanguageSettingsPage.
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const LanguageSettingsPage()),
              );
            },
          ),

          // ListTile for navigating to the View settings page.
          ListTile(
            leading: const Icon(Icons.view_compact),
            title: const Text('View Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewSettingsPage(
                    currentViewMode: 'List', // Default value
                    onViewModeChange: (mode) {
                      // Call the onRefresh callback to update the view mode in RecipesPage
                      onRefresh();
                    },
                  ),
                ),
              );
            },
          ),

          // ListTile for redoing the tutorial
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Redo Tutorial'),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isFirstLaunch', true); // Reset the flag

              // Navigate to the TutorialPage
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TutorialPage()),
              );
            },
          ),

          // ListTile for navigating to the About page.
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              // Navigate to the AboutPage.
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
