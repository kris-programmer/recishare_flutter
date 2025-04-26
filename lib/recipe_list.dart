import 'package:flutter/material.dart';
import 'package:recishare_flutter/recipe.dart';
import 'package:recishare_flutter/pages/recipe_selected_page.dart';
import 'package:recishare_flutter/pages/recipe_edit_page.dart';
import 'package:recishare_flutter/recipe_service.dart';
import 'package:recishare_flutter/utils/image_utils.dart';

class RecipeList extends StatelessWidget {
  final List<Recipe> listItems;
  final bool isSelectionMode;
  final Set<Recipe> selectedRecipes;
  final Function(Recipe) onDelete;
  final Function() onRefresh;
  final Function(Recipe, bool) onSelectionChange;
  final Function() onStartSelectionMode;
  final RecipeService _recipeService = RecipeService();
  final String sortCriteria;
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

  void _toggleFavourite(Recipe recipe) async {
    recipe.favourite = !recipe.favourite;
    await _recipeService.updateRecipe(recipe);
    onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                  DropdownMenuItem(
                    value: sortCriteria,
                    child: Row(
                      children: [
                        Text(sortCriteria),
                      ],
                    ),
                  ),
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
        Expanded(
          child: ListView.builder(
            itemCount: listItems.length,
            itemBuilder: (context, index) {
              var recipe = listItems[index];
              final isSelected = selectedRecipes.contains(recipe);

              return GestureDetector(
                onLongPress: () {
                  if (!isSelectionMode) {
                    onStartSelectionMode();
                    onSelectionChange(recipe, true);
                  }
                },
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
                      if (isSelectionMode)
                        Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            onSelectionChange(recipe, value ?? false);
                          },
                        ),
                      Expanded(
                        child: ListTile(
                          title: Text(recipe.name),
                          subtitle: Text(
                            recipe.description?.split('.').first ??
                                'No description available',
                          ),
                          leading: recipe.imageData != null &&
                                  recipe.imageData!.isNotEmpty
                              ? decodeBase64ToImage(recipe.imageData)
                              : const Icon(Icons.image_not_supported),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              if (recipe.favourite)
                                const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
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
                                    PopupMenuItem(
                                      value: 'Favourite',
                                      child: Text(recipe.favourite
                                          ? "Unfavourite"
                                          : "Favourite"),
                                    ),
                                    const PopupMenuItem(
                                      value: 'Edit',
                                      child: Text("Edit"),
                                    ),
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
