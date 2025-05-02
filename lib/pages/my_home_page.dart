import 'package:flutter/material.dart';
import 'package:recishare_flutter/pages/home_page.dart';
import 'package:recishare_flutter/pages/recipes_page.dart';
import 'package:recishare_flutter/pages/settings_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int myIndex = 1; // Page index in app, used for the bottom nav bar
  late List<Widget> pageList; // Declare pageList as late to avoid errors

  @override
  void initState() {
    super.initState();
    pageList = [
      SettingsPage(onRefresh: _refreshRecipes), // Initialize pageList
      const HomePage(),
      const RecipesPage()
    ]; // Bottom Nav bar
  }

  void _refreshRecipes() {
    setState(() {
      // Logic to refresh recipes when exiting settings page
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Stack(
          children: [
            // Outline effect
            Text(
              'ReciShare',
              style: TextStyle(
                fontSize: 30,
                fontStyle: FontStyle.italic,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 3
                  ..color = Colors.black, // Outline color
              ),
            ),
            // Main text
            const Text(
              'ReciShare',
              style: TextStyle(
                fontSize: 30,
                fontStyle: FontStyle.italic,
                color: Colors.white, // Main text color
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: myIndex,
        children: pageList,
      ), // Select a page to display
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) {
          setState(() {
            myIndex = index;
          });
        },
        selectedIndex: myIndex,
        indicatorColor: Colors.green,
        // Pages available on the bottom navigation bar
        destinations: const [
          NavigationDestination(icon: Icon(Icons.settings), label: "Settings"),
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(
              icon: Icon(Icons.soup_kitchen), label: "Recipes")
        ],
      ),
    );
  }
}
