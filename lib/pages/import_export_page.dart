import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert'; // Needed for UTF-8 conversion
import 'package:recishare_flutter/recipe.dart';
import 'package:recishare_flutter/recipe_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ImportExportPage extends StatefulWidget {
  final Function() onRefresh;

  const ImportExportPage({super.key, required this.onRefresh});

  @override
  ImportExportPageState createState() => ImportExportPageState();
}

class ImportExportPageState extends State<ImportExportPage> {
  final RecipeService _recipeService =
      RecipeService(); // Service to handle recipe operations

  // Function to handle importing recipes from a JSON file
  Future<void> _importRecipes() async {
    // Clear the cache before importing a file to avoid stale data
    await FilePicker.platform.clearTemporaryFiles();

    // Open a file picker to select a JSON file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'], // Restrict to JSON files
    );

    if (result != null) {
      String filePath = result.files.single.path!; // Get the selected file path
      try {
        // Read the file content as a UTF-8 encoded string
        String fileContent = await File(filePath).readAsString(encoding: utf8);

        // Parse the JSON content into a list of Recipe objects
        List<Recipe> recipes = Recipe.fromJsonList(fileContent);
        await _recipeService
            .importRecipes(recipes); // Save recipes to the database

        if (mounted) {
          // Show success message and refresh the recipe list
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recipes imported successfully!')),
          );

          widget.onRefresh(); // Trigger the refresh callback
          Navigator.pop(context, true); // Close the current page
        }
      } catch (e) {
        // Handle errors such as invalid JSON format or file reading issues
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Failed to import recipes. Invalid file format or unsupported characters.')),
          );
        }
      }
    }
  }

  // Function to handle exporting recipes to a JSON file
  Future<void> _exportRecipes() async {
    // Check for permission to manage external storage
    final permissionStatus = await Permission.manageExternalStorage.status;
    if (permissionStatus.isDenied) {
      // Request permission if it is denied
      await Permission.manageExternalStorage.request();

      // If permission is still denied, open app settings
      if (permissionStatus.isDenied) {
        await openAppSettings();
      }
    } else if (permissionStatus.isPermanentlyDenied) {
      // Handle permanently denied permission
      await Permission.manageExternalStorage.request();
    } else {
      // Fetch all recipes from the database
      List<Recipe> recipes = await _recipeService.getAllRecipes();
      // Convert the recipes to a JSON string
      String jsonContent = Recipe.toJsonList(recipes);

      // Open a directory picker to select the export location
      String? directoryPath = await FilePicker.platform.getDirectoryPath();

      if (directoryPath != null) {
        String outputPath =
            '$directoryPath/recipes.json'; // Define the output file path

        try {
          // Write the JSON content to the selected file
          File file = File(outputPath);
          await file.writeAsString(jsonContent, encoding: utf8);

          if (mounted) {
            // Show success message with the file path
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Recipes exported successfully! File saved at $outputPath')),
            );
          }
        } catch (e) {
          // Handle file writing errors
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to export recipes.')),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import/Export Recipes'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center the buttons vertically
          children: <Widget>[
            // Button to trigger the import functionality
            ElevatedButton(
              onPressed: _importRecipes,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                backgroundColor: Colors.green[800], // Dark green color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Import Recipes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Make sure to refresh the recipes after importing!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            // Button to trigger the export functionality
            ElevatedButton(
              onPressed: _exportRecipes,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                backgroundColor: Colors.blue[800], // Dark blue color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Export Recipes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
