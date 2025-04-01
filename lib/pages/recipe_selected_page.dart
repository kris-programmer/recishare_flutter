import 'package:flutter/material.dart';
import 'package:recishare_flutter/recipe.dart';
import 'package:recishare_flutter/pages/recipe_edit_page.dart';
import 'dart:io';

class SelectedRecipePage extends StatelessWidget {
  final Recipe recipe;
  const SelectedRecipePage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeEditPage(
                    recipe: recipe,
                    onSave: (updatedRecipe) {
                      // Handle the updated recipe if needed
                      Navigator.pop(context, updatedRecipe);
                    },
                  ),
                ),
              ).then((updatedRecipe) {
                if (updatedRecipe != null) {
                  // Update the UI with the new recipe details if needed
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe.imagePath != null)
              Image.file(
                File(recipe.imagePath!),
                fit: BoxFit.fill,
                width: double.infinity,
                height: 200,
              )
            else
              const Icon(Icons.image_not_supported),
            const SizedBox(height: 16),
            Text(
              recipe.name,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              recipe.description ?? 'No description available',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Ingredients',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            ...?recipe.ingredients?.map((ingredient) =>
                Text('- $ingredient', style: const TextStyle(fontSize: 20))),
            const SizedBox(height: 16),
            Text(
              'Instructions',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            ...recipe.instructions?.asMap().entries.map((entry) {
                  int index = entry.key + 1; // Step number (1-based index)
                  String instruction = entry.value;
                  return Text(
                    '$index. $instruction',
                    style: const TextStyle(fontSize: 20),
                  );
                }).toList() ??
                [
                  const Text('No instructions available',
                      style: TextStyle(fontSize: 20))
                ],
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            Row(children: [
              const Icon(Icons.timer),
              Text(
                ' Prep Time: ${recipe.prepTime ?? 0} minutes | '
                'Cook Time: ${recipe.cookTime ?? 0} minutes',
                style: Theme.of(context).textTheme.labelLarge,
              )
            ]),
            const SizedBox(height: 8)
          ],
        ),
      ),
    );
  }
}
