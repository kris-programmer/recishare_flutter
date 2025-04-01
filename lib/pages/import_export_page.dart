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
  final RecipeService _recipeService = RecipeService();

  Future<void> _importRecipes() async {
    // Clear the cache before importing a file
    await FilePicker.platform.clearTemporaryFiles();

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      try {
        // Read the file as a string using UTF-8 encoding
        String fileContent = await File(filePath).readAsString(encoding: utf8);

        // Attempt to parse the JSON content
        List<Recipe> recipes = Recipe.fromJsonList(fileContent);
        await _recipeService.importRecipes(recipes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recipes imported successfully!')),
          );

          widget.onRefresh(); // Refresh the recipe list
          Navigator.pop(context, true);
        }
      } catch (e) {
        // Handle JSON decoding or file reading errors
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

  Future<void> _exportRecipes() async {
    // Ask for file exporting permission
    final permissionStatus = await Permission.manageExternalStorage.status;
    if (permissionStatus.isDenied) {
      await Permission.manageExternalStorage.request();

      if (permissionStatus.isDenied) {
        await openAppSettings();
      }
    } else if (permissionStatus.isPermanentlyDenied) {
      await Permission.manageExternalStorage.request();
    } else {
      List<Recipe> recipes = await _recipeService.getAllRecipes();
      String jsonContent =
          Recipe.toJsonList(recipes); // Convert the recipes to a JSON list

      String? directoryPath = await FilePicker.platform.getDirectoryPath();

      if (directoryPath != null) {
        String outputPath = '$directoryPath/recipes.json';

        try {
          File file = File(outputPath);
          await file.writeAsString(jsonContent, encoding: utf8);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Recipes exported successfully! File saved at $outputPath')),
            );
          }
        } catch (e) {
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _importRecipes,
              child: const Text('Import Recipes'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _exportRecipes,
              child: const Text('Export Recipes'),
            ),
          ],
        ),
      ),
    );
  }
}
