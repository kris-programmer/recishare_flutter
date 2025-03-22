import 'package:flutter/material.dart';
import 'package:recishare_flutter/recipe.dart';
import 'package:recishare_flutter/pages/recipe_selected_page.dart';
import 'dart:io';

class RecipeList extends StatelessWidget {
  final List<Recipe> listItems;
  final Function(Recipe) onDelete;
  final Function() onRefresh;

  const RecipeList(this.listItems,
      {super.key, required this.onDelete, required this.onRefresh});

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
                  trailing: PopupMenuButton<String>(
                    onSelected: (String value) {
                      if (value == 'Favourite') {
                        // Handle favourite functionality
                      } else if (value == 'Edit') {
                        // Handle edit functionality
                      } else if (value == 'Delete') {
                        onDelete(recipe);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'Favourite',
                        child: Text("Favourite"),
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

//IconButton(
 //                 onPressed: () => this.fav(recipe.favouriteRecipe),
   //               icon: Icon(Icons.favorite),
     //             color: recipe.favourite ? Colors.red : Colors.black)
