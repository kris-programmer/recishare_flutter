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
  String sortCriteria = 'Name';
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  bool isSearching = false; // Flag to toggle search mode

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    recipes = await _recipeService.getAllRecipes();
    _sortRecipes();
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

  List<Recipe> get filteredRecipes {
    if (searchQuery.isEmpty) {
      return recipes;
    }
    return recipes
        .where((recipe) =>
            recipe.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  // Saves the new recipe and reloads the list
  Future<void> _saveRecipe(Recipe recipe) async {
    await _recipeService.importRecipes([recipe]);
    await _loadRecipes(); // Reload recipes after saving
  }

  // Deletes a single recipe
  void _deleteRecipe(Recipe recipe) async {
    setState(() {
      recipes.removeWhere((r) => r == recipe); // Remove recipe from the list
    });
    await _recipeService.deleteRecipe(recipe.id!); // Delete recipe from the app
  }

  // Deletes all selected recipes after user confirmation
  void _deleteSelectedRecipes() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete ${selectedRecipes.length} recipes?'), // Confirmation message
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false), // Cancel deletion
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(true), // Confirm deletion
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      for (var recipe in selectedRecipes) {
        await _recipeService
            .deleteRecipe(recipe.id!); // Delete each selected recipe
      }
      setState(() {
        recipes.removeWhere((r) => selectedRecipes
            .contains(r)); // Remove deleted recipes from the list
        selectedRecipes.clear(); // Clear the selection
        isSelectionMode = false; // Exit selection mode
      });
    }
  }

  // Toggles the favourite status of selected recipes
  void _toggleFavouriteSelectedRecipes() async {
    for (var recipe in selectedRecipes) {
      recipe.favourite = !recipe.favourite; // Toggle favourite status
      await _recipeService
          .updateRecipe(recipe); // Update recipe fav status in the database
    }
    setState(() {
      selectedRecipes.clear();
      isSelectionMode = false;
    });
  }

  // Toggles selection mode on or off
  void _toggleSelectionMode() {
    setState(() {
      isSelectionMode = !isSelectionMode; // Toggle the flag
      if (!isSelectionMode) {
        selectedRecipes.clear(); // Clear selection if exiting selection mode
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSelectionMode
            ? Text('${selectedRecipes.length} Selected')
            : const Text('My Recipes'), // Main title
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
                if (isSearching)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0), // Add padding to the left
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search recipes...',
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(isSearching ? Icons.close : Icons.search),
                  onPressed: () {
                    setState(() {
                      if (isSearching) {
                        isSearching = false; // Exit search mode
                        searchQuery = ''; // Clear search query
                        _searchController.clear();
                      } else {
                        isSearching = true; // Enable search mode
                      }
                    });
                  },
                ),
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
        filteredRecipes,
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
        sortCriteria: sortCriteria,
        onSortChange: (newCriteria) {
          setState(() {
            sortCriteria = newCriteria;
          });
          _sortRecipes();
        },
      ),
    );
  }
}
