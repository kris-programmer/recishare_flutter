import 'package:flutter/material.dart';
import 'package:recishare_flutter/recipe.dart';
import 'package:recishare_flutter/pages/selected_recipe_page.dart';

class RecipeList extends StatefulWidget {
  final List<Recipe> listItems;

  const RecipeList(this.listItems, {super.key});

  @override
  State<RecipeList> createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  void fav(Function callBack) {
    setState(() {
      callBack();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.listItems.length,
        itemBuilder: (context, index) {
          var recipe = widget.listItems[index];
          return Card(
            child: Row(children: <Widget>[
              Expanded(
                  child: ListTile(
                title: Text(recipe.name),
                subtitle: Text(recipe.description),
                leading: const Expanded(
                    child: Image(
                  image: NetworkImage(
                      "https://cdn-icons-png.flaticon.com/512/4552/4552949.png"),
                  fit: BoxFit.cover,
                )),
                trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                          PopupMenuItem(
                            value: recipe.name,
                            child:
                                const Text("Favourite"), // Favourite the recipe
                          ),
                          PopupMenuItem(
                            value: recipe.name,
                            child: const Text(
                                "Edit"), // Open the edit page of the recipe
                          ),
                          PopupMenuItem(
                            child: const Text("Delete"),
                            onTap: () => setState(() {
                              widget.listItems.remove(recipe); // Delete recipe
                            }),
                          )
                        ]),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SelectedRecipePage(
                            recipe:
                                recipe))), // Open the view page of the recipe
              )),
            ]),
          );
        });
  }
}

//IconButton(
 //                 onPressed: () => this.fav(recipe.favouriteRecipe),
   //               icon: Icon(Icons.favorite),
     //             color: recipe.favourite ? Colors.red : Colors.black)
