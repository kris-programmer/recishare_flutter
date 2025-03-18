import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:recishare_flutter/recipe.dart';
import 'package:recishare_flutter/recipe_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ImportExportPage extends StatefulWidget {
  final Function() onRefresh;

  const ImportExportPage({super.key, required this.onRefresh});

  @override
  _ImportExportPageState createState() => _ImportExportPageState();
}

class _ImportExportPageState extends State<ImportExportPage> {
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
      String fileContent = await File(filePath).readAsString();

      List<Recipe> recipes = Recipe.fromJsonList(fileContent);
      await _recipeService.getAllRecipes();
      await _recipeService.importRecipes(recipes);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipes imported successfully!')),
      );

      widget.onRefresh(); // Refresh the recipe list
      Navigator.pop(context, true);
    }
  }

  Future<void> _exportRecipes() async {
    final permissionStatus = await Permission.manageExternalStorage.status;
    if (permissionStatus.isDenied) {
      // Ask for the permission for the first time
      await Permission.manageExternalStorage.request();

      // Sometimes the popup won't show after user presses deny
      // so do the check once again but now go straight to appSettings
      if (permissionStatus.isDenied) {
        await openAppSettings();
      }
    } else if (permissionStatus.isPermanentlyDenied) {
      // Here open app settings for user to manually enable permission in case
      // permission was permanently denied
      await Permission.manageExternalStorage.request();
    } else {
      // Do stuff that require permission here
      List<Recipe> recipes = await _recipeService.getAllRecipes();
      String jsonContent = Recipe.toJsonList(recipes);

      // Use FilePicker to get the directory path from the user
      String? directoryPath = await FilePicker.platform.getDirectoryPath();

      if (directoryPath != null) {
        String outputPath = '$directoryPath/recipes.json';
        Uint8List bytes =
            Uint8List.fromList(jsonContent.codeUnits); // Convert to Uint8List
        File file = File(outputPath);
        await file.writeAsBytes(bytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Recipes exported successfully! File saved at $outputPath')),
        );
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
