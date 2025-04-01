import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'pages/my_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter is initialized
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme(); // Load theme preferences before app starts

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'ReciShare',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.green[800],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32), // Dark green
          foregroundColor: Colors.white, // Text/icon color
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.green[800],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32), // Dark green
          foregroundColor: Colors.white, // Text/icon color
        ),
      ),
      themeMode: themeProvider.themeMode,
      home: const MyHomePage(),
    );
  }
}
