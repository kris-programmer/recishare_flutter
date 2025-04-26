import 'dart:math';
import 'package:flutter/material.dart';
import 'package:recishare_flutter/recipe_service.dart';
import 'package:recishare_flutter/recipe.dart';
import 'package:recishare_flutter/utils/image_utils.dart';
import 'package:recishare_flutter/pages/recipe_selected_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Recipe> recipes = [];
  List<Recipe> featuredRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final recipeService =
        RecipeService(); // Create an instance of RecipeService
    final allRecipes =
        await recipeService.getAllRecipes(); // Call the instance method
    setState(() {
      recipes = allRecipes;

      // Randomly select up to 3 distinct recipes
      if (recipes.isNotEmpty) {
        final random = Random();
        final Set<int> selectedIndices = {}; // Track selected indices
        featuredRecipes = [];

        while (featuredRecipes.length < min(3, recipes.length)) {
          final index = random.nextInt(recipes.length);
          if (!selectedIndices.contains(index)) {
            selectedIndices.add(index);
            featuredRecipes.add(recipes[index]);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Centered Welcome Banner
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'Welcome to ReciShare!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.color, // Dynamic color
              ),
              textAlign: TextAlign.center, // Center-align the text
            ),
          ),
        ),
        const Spacer(), // Pushes the recipe cards to the bottom

        // Featured Recipes Section
        if (featuredRecipes.isEmpty)
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  'No recipes created yet. Start adding some!',
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ))
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add "Quick Recipes:" text
                const Padding(
                  padding: EdgeInsets.only(
                      bottom: 8.0), // Add spacing below the text
                  child: Text(
                    'Quick Recipes:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Display the recipe cards
                ...featuredRecipes.map((recipe) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildRecipeCard(recipe),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectedRecipePage(recipe: recipe),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
            vertical: 1.0), // Reduced vertical margin
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
          side: const BorderSide(
            color: Colors.grey, // Border color
            width: 1.0, // Border width
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display recipe image
              Container(
                width: 100,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  image: recipe.imageData != null &&
                          recipe.imageData!.isNotEmpty
                      ? DecorationImage(
                          image: decodeBase64ToImageProvider(recipe.imageData!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: recipe.imageData == null || recipe.imageData!.isEmpty
                    ? const Icon(Icons.image, size: 50, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              // Display recipe name and description
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recipe.description ?? 'No description available',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
