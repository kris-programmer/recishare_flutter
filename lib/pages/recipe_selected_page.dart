import 'package:flutter/material.dart';
import 'package:recishare_flutter/recipe.dart';
import 'package:recishare_flutter/pages/recipe_edit_page.dart';
import 'dart:convert';

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
          onPressed: () =>
              Navigator.pop(context), // Navigate back to the previous page
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to the RecipeEditPage and handle the updated recipe
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeEditPage(
                    recipe: recipe,
                    onSave: (updatedRecipe) {
                      Navigator.pop(
                          context, updatedRecipe); // Return the updated recipe
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the recipe image or a placeholder icon if no image is available
            if (recipe.imageData != null && recipe.imageData!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.memory(
                  base64Decode(recipe.imageData!), // Decode Base64 image
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              )
            else
              const Icon(Icons.image_not_supported, size: 100),
            const SizedBox(height: 24),
            // Display the recipe name
            Text(
              recipe.name,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(thickness: 1.5),
            const SizedBox(height: 16),
            // Display the recipe description
            Text(
              recipe.description ?? 'No description available',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(
              height: 24,
            ),
            // Display the last edited date
            Text(
              'Last edited: ${recipe.dateCreated.toLocal().toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
            ),
            const SizedBox(height: 24),
            // Display the ingredients list
            Text(
              'Ingredients',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: recipe.ingredients?.map((ingredient) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            '- $ingredient',
                            style: const TextStyle(fontSize: 18),
                          ),
                        );
                      }).toList() ??
                      [
                        const Text('No ingredients available',
                            style: TextStyle(fontSize: 18)),
                      ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Display the instructions list
            Text(
              'Instructions',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: recipe.instructions?.asMap().entries.map((entry) {
                        int index = entry.key + 1;
                        String instruction = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            '$index. $instruction',
                            style: const TextStyle(fontSize: 18),
                          ),
                        );
                      }).toList() ??
                      [
                        const Text('No instructions available',
                            style: TextStyle(fontSize: 18)),
                      ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 24),
            // Display prep time and cook time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Prep Time:',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.prepTime ?? 0} min',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.restaurant, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Cook Time:',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.cookTime ?? 0} min',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
