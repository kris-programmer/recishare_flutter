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
  bool isSelectionMode = false;
  final Set<Recipe> selectedRecipes = {};

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    recipes = await _recipeService.getAllRecipes();
    setState(() {});
  }

  Future<void> _saveRecipe(Recipe recipe) async {
    await _recipeService.importRecipes([recipe]);
  }

  void _deleteRecipe(Recipe recipe) async {
    setState(() {
      recipes.removeWhere((r) => r == recipe);
    });
    await _recipeService.deleteRecipe(recipe.id!);
  }

  void _deleteSelectedRecipes() async {
    for (var recipe in selectedRecipes) {
      await _recipeService.deleteRecipe(recipe.id!);
    }
    setState(() {
      recipes.removeWhere((r) => selectedRecipes.contains(r));
      selectedRecipes.clear();
      isSelectionMode = false;
    });
  }

  void _toggleFavouriteSelectedRecipes() async {
    for (var recipe in selectedRecipes) {
      recipe.favourite = !recipe.favourite;
      await _recipeService.updateRecipe(recipe);
    }
    setState(() {
      selectedRecipes.clear();
      isSelectionMode = false;
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;
      if (!isSelectionMode) {
        selectedRecipes.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isSelectionMode
            ? '${selectedRecipes.length} Selected'
            : "My Recipes"),
        actions: isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.favorite),
                  onPressed: _toggleFavouriteSelectedRecipes,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteSelectedRecipes,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _toggleSelectionMode,
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadRecipes,
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
                      _saveRecipe(newRecipe);
                    }
                  },
                ),
              ],
      ),
      body: RecipeList(
        recipes,
        isSelectionMode: isSelectionMode,
        selectedRecipes: selectedRecipes,
        onDelete: _deleteRecipe,
        onRefresh: _loadRecipes,
        onSelectionChange: (recipe, isSelected) {
          setState(() {
            if (isSelected) {
              selectedRecipes.add(recipe);
            } else {
              selectedRecipes.remove(recipe);
            }

            // Exit selection mode if no recipes are selected
            if (selectedRecipes.isEmpty) {
              isSelectionMode = false;
            }
          });
        },
        onStartSelectionMode: () {
          setState(() {
            isSelectionMode = true;
          });
        },
      ),
    );
  }
}
