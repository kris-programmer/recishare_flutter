import 'package:flutter/material.dart';
import 'package:recishare_flutter/recipe.dart';
import 'package:recishare_flutter/pages/recipe_selected_page.dart';
import 'package:recishare_flutter/pages/recipe_edit_page.dart';
import 'package:recishare_flutter/recipe_service.dart';
import 'dart:io';

class RecipeList extends StatelessWidget {
  final List<Recipe> listItems;
  final Function(Recipe) onDelete;
  final Function() onRefresh;
  final RecipeService _recipeService = RecipeService();

  RecipeList(this.listItems,
      {super.key, required this.onDelete, required this.onRefresh});

  void _toggleFavourite(Recipe recipe) async {
    recipe.favourite = !recipe.favourite;
    await _recipeService.updateRecipe(recipe);
    onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: listItems.length,
      itemBuilder: (context, index) {
        var recipe = listItems[index];
        return Card(
          child: Row(
            children: <Widget>[
              Expanded(
                child: ListTile(
                  title: Text(recipe.name),
                  subtitle:
                      Text(recipe.description ?? 'No description available'),
                  leading: recipe.imagePath != null
                      ? Image.file(
                          File(recipe.imagePath!),
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                        )
                      : const Icon(Icons.image_not_supported),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (recipe.favourite)
                        const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        ),
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
                                    listItems[index] =
                                        updatedRecipe; // Update the recipe in the list
                                    onRefresh(); // Refresh the list
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
                            child: Text(
                                recipe.favourite ? "Unfavourite" : "Favourite"),
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SelectedRecipePage(recipe: recipe),
                      ),
                    ).then((_) => onRefresh());
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
