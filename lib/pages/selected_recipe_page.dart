import 'package:flutter/material.dart';
import 'package:recishare_flutter/recipe.dart';
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe.imagePath != null)
              Image.file(
                File(recipe.imagePath!),
                fit: BoxFit.cover,
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
              recipe.description,
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
            ...?recipe.instructions?.map((instruction) =>
                Text('- $instruction', style: const TextStyle(fontSize: 20))),
            const SizedBox(height: 16),
            Row(children: [
              const Icon(Icons.timer),
              Text(
                ' Prep Time: ${recipe.prepTime} minutes | '
                'Cook Time: ${recipe.cookTime} minutes',
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
