import 'package:flutter/material.dart';
import 'package:recishare_flutter/recipe.dart';
import 'package:recishare_flutter/pages/recipe_selected_page.dart';
import 'package:recishare_flutter/pages/recipe_edit_page.dart';
import 'package:recishare_flutter/recipe_service.dart';
import 'package:recishare_flutter/utils/image_utils.dart';

class RecipeList extends StatelessWidget {
  // List of recipes to display
  final List<Recipe> listItems;

  // Indicates if the list is in selection mode
  final bool isSelectionMode;

  // Set of selected recipes in selection mode
  final Set<Recipe> selectedRecipes;

  // Callback for deleting a recipe
  final Function(Recipe) onDelete;

  // Callback to refresh the list
  final Function() onRefresh;

  // Callback for handling selection changes
  final Function(Recipe, bool) onSelectionChange;

  // Callback to start selection mode
  final Function() onStartSelectionMode;

  // Service for managing recipe data
  final RecipeService _recipeService = RecipeService();

  // Current sorting criteria
  final String sortCriteria;

  // Callback for changing the sorting criteria
  final Function(String) onSortChange;

  RecipeList(
    this.listItems, {
    super.key,
    required this.isSelectionMode,
    required this.selectedRecipes,
    required this.onDelete,
    required this.onRefresh,
    required this.onSelectionChange,
    required this.onStartSelectionMode,
    required this.sortCriteria,
    required this.onSortChange,
  });

  // Toggles the favourite status of a recipe and updates it in the service
  void _toggleFavourite(Recipe recipe) async {
    recipe.favourite = !recipe.favourite;
    await _recipeService.updateRecipe(recipe);
    onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Dropdown for sorting recipes
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sort by:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: sortCriteria,
                items: [
                  // Current sorting criteria
                  DropdownMenuItem(
                    value: sortCriteria,
                    child: Row(
                      children: [
                        Text(sortCriteria),
                      ],
                    ),
                  ),
                  // Other sorting options
                  ...['Name', 'Date', 'Favourite']
                      .where((criteria) => criteria != sortCriteria)
                      .map((criteria) => DropdownMenuItem(
                            value: criteria,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(criteria),
                                if (criteria == 'Name') const Text('🅰️'),
                                if (criteria == 'Date') const Text('📅'),
                                if (criteria == 'Favourite') const Text('❤️'),
                              ],
                            ),
                          ))
                ],
                onChanged: (value) {
                  if (value != null) {
                    onSortChange(value);
                  }
                },
              ),
            ],
          ),
        ),
        // List of recipes
        Expanded(
          child: ListView.builder(
            itemCount: listItems.length,
            itemBuilder: (context, index) {
              var recipe = listItems[index];
              final isSelected = selectedRecipes.contains(recipe);

              return GestureDetector(
                // Handle long press to start selection mode
                onLongPress: () {
                  if (!isSelectionMode) {
                    onStartSelectionMode();
                    onSelectionChange(recipe, true);
                  }
                },
                // Handle tap to select or view recipe details
                onTap: () {
                  if (isSelectionMode) {
                    onSelectionChange(recipe, !isSelected);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SelectedRecipePage(recipe: recipe),
                      ),
                    ).then((_) => onRefresh());
                  }
                },
                child: Card(
                  child: Row(
                    children: <Widget>[
                      // Checkbox for selection mode
                      if (isSelectionMode)
                        Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            onSelectionChange(recipe, value ?? false);
                          },
                        ),
                      Expanded(
                        child: ListTile(
                          // Display recipe name and description
                          title: Text(recipe.name),
                          subtitle: Text(
                            recipe.description?.split('.').first ??
                                'No description available',
                          ),
                          // Display recipe image or placeholder icon
                          leading: recipe.imageData != null &&
                                  recipe.imageData!.isNotEmpty
                              ? decodeBase64ToImage(recipe.imageData)
                              : const Icon(Icons.image_not_supported),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              // Display Favourite icon if the recipe is marked as favourite
                              if (recipe.favourite)
                                const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                              // Popup menu for actions (favourite, edit, delete)
                              if (!isSelectionMode)
                                PopupMenuButton<String>(
                                  onSelected: (String value) {
                                    if (value == 'Favourite') {
                                      _toggleFavourite(recipe);
                                    } else if (value == 'Edit') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RecipeEditPage(
                                            recipe: recipe,
                                            onSave: (updatedRecipe) {
                                              listItems[index] = updatedRecipe;
                                              onRefresh();
                                            },
                                          ),
                                        ),
                                      );
                                    } else if (value == 'Delete') {
                                      onDelete(recipe);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    // Favourite/unfavourite option
                                    PopupMenuItem(
                                      value: 'Favourite',
                                      child: Text(recipe.favourite
                                          ? "Unfavourite"
                                          : "Favourite"),
                                    ),
                                    // Edit option
                                    const PopupMenuItem(
                                      value: 'Edit',
                                      child: Text("Edit"),
                                    ),
                                    // Delete option
                                    const PopupMenuItem(
                                      value: 'Delete',
                                      child: Text("Delete"),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
