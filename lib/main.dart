import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_provider.dart';
import 'pages/my_home_page.dart';
import 'pages/tutorial_page.dart';

const String appTitle = 'ReciShare';
const String firstLaunchKey = 'isFirstLaunch';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool(firstLaunchKey) ?? true;

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeProvider,
      child: MyApp(isFirstLaunch: isFirstLaunch),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isFirstLaunch;

  const MyApp({super.key, required this.isFirstLaunch});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: appTitle,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: themeProvider.themeMode,
      home: isFirstLaunch ? const TutorialPage() : const MyHomePage(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      brightness: brightness,
      primaryColor: Colors.green[800],
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
    );
  }
}
