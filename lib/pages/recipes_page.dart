import 'package:flutter/material.dart';
import '../recipe.dart';
import 'recipe_creation_page.dart';
import '../recipe_list.dart';
import '../recipe_service.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final RecipeService _recipeService = RecipeService();
  List<Recipe> recipes = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    recipes = await _recipeService.getAllRecipes();
    setState(() {});
  }

  Future<void> _saveRecipes() async {
    await _recipeService.importRecipes(recipes);
  }

  void _deleteRecipe(Recipe recipe) {
    setState(() {
      recipes.removeWhere((r) => r == recipe);
    });
    _saveRecipes(); // Save the updated list of recipes after deletion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Recipes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecipes, // refresh recipes
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final newRecipe = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RecipeCreationPage()),
              );
              if (newRecipe != null) {
                setState(() {
                  recipes.add(newRecipe);
                });
                _saveRecipes();
              }
            },
          ),
        ],
      ),
      body: RecipeList(
        recipes,
        onDelete: _deleteRecipe,
        onRefresh: _loadRecipes,
      ),
    );
  }
}
