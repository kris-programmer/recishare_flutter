import 'package:flutter/material.dart';
import 'package:recishare_flutter/recipe_service.dart';
import 'package:recishare_flutter/recipe.dart';
import 'package:recishare_flutter/utils/image_utils.dart';
import 'package:recishare_flutter/pages/recipe_selected_page.dart';

// Default padding for consistent spacing across the UI
const EdgeInsets defaultPadding = EdgeInsets.symmetric(horizontal: 16.0);

// Messages for empty or error states
const String noRecipesMessage =
    'No recipes found. Start creating some recipes in the "Recipes" tab!';
const String loadErrorMessage =
    'Failed to load recipes. Please try again later.';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // List of all recipes and featured recipes
  List<Recipe> recipes = [];
  List<Recipe> featuredRecipes = [];

  // Loading and error state variables
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Load the most recently created recipes when the page initializes
    _loadLastCreatedRecipes();
  }

  // Fetches the most recently created recipes from the service
  Future<void> _loadLastCreatedRecipes() async {
    try {
      final recipeService = RecipeService();
      final allRecipes = await recipeService.getAllRecipes();

      setState(() {
        if (allRecipes.isNotEmpty) {
          // Sort recipes by creation date (most recent first)
          allRecipes.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
          recipes = allRecipes;

          // Take the top 3 recipes as featured recipes
          featuredRecipes = allRecipes.take(3).toList();
          errorMessage = ''; // Clear any previous error messages
        } else {
          // Handle the case where no recipes are found
          recipes = [];
          featuredRecipes = [];
          errorMessage = noRecipesMessage;
        }
        isLoading = false; // Stop the loading indicator
      });
    } catch (e) {
      // Handle errors during recipe loading
      setState(() {
        isLoading = false;
        errorMessage = loadErrorMessage;
      });
    }
  }

  // Refreshes the list of recipes (used in pull-to-refresh)
  Future<void> _refreshRecipes() async {
    setState(() => isLoading = true); // Show loading indicator
    await _loadLastCreatedRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ReciShare')),
      body: RefreshIndicator(
        onRefresh: _refreshRecipes, // Pull-to-refresh functionality
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message at the top of the page
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Welcome to ReciShare!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (isLoading)
                // Show a loading spinner while data is being fetched
                const Center(child: CircularProgressIndicator())
              else if (errorMessage.isNotEmpty)
                // Show an error message if something went wrong
                Padding(
                  padding: defaultPadding,
                  child: Center(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(
                          fontSize: 16, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                // Display the list of featured recipes
                Padding(
                  padding: defaultPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'Recently created recipes:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Map each featured recipe to a card widget
                      ...featuredRecipes.map((recipe) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: _buildRecipeCard(recipe),
                          )),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Builds a card widget for a single recipe
  Widget _buildRecipeCard(Recipe recipe) {
    return GestureDetector(
      onTap: () async {
        // Navigate to the selected recipe's details page
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectedRecipePage(recipe: recipe),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the recipe's image or a placeholder icon
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
              // Display the recipe's name and description
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recipe name (bold and truncated if too long)
                      Text(
                        recipe.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Recipe description (italicized if available)
                      Text(
                        recipe.description ?? 'No description available',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      // Date created text at the bottom
                      Text(
                        'Created on: ${recipe.dateCreated.toLocal().toString().split(' ')[0]}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
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
