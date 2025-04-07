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
  String sortCriteria = 'Name'; // Default sorting criteria

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    recipes = await _recipeService.getAllRecipes();
    //_sortRecipes();
    setState(() {});
  }

  void _sortRecipes() {
    setState(() {
      if (sortCriteria == 'Name') {
        recipes.sort((a, b) => a.name.compareTo(b.name));
      } else if (sortCriteria == 'Date') {
        recipes.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
      } else if (sortCriteria == 'Favourite') {
        recipes.sort(
            (a, b) => (b.favourite ? 1 : 0).compareTo(a.favourite ? 1 : 0));
      }
    });
  }

  Future<void> _saveRecipe(Recipe recipe) async {
    await _recipeService.importRecipes([recipe]);
    await _loadRecipes();
  }

  void _deleteRecipe(Recipe recipe) async {
    setState(() {
      recipes.removeWhere((r) => r == recipe);
    });
    await _recipeService.deleteRecipe(recipe.id!);
  }

  void _deleteSelectedRecipes() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete ${selectedRecipes.length} recipes?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      for (var recipe in selectedRecipes) {
        await _recipeService.deleteRecipe(recipe.id!);
      }
      setState(() {
        recipes.removeWhere((r) => selectedRecipes.contains(r));
        selectedRecipes.clear();
        isSelectionMode = false;
      });
    }
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
      body: RecipeList(recipes,
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
          sortCriteria: sortCriteria, // Pass the sorting criteria
          onSortChange: (newCriteria) {
            setState(() {
              sortCriteria = newCriteria;
            });
            _sortRecipes(); // Trigger the sorting
          }),
    );
  }
}
