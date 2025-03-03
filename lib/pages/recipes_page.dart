import 'package:flutter/material.dart';
import 'package:recishare_flutter/pages/recipe_creation_page.dart';
import 'package:recishare_flutter/recipe.dart';
import 'package:recishare_flutter/recipe_list.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  List<Recipe> recipes = [];

  // void newRecipe() {
  //   var recipe = Recipe("chicken", "Lunch", null, null, null, null, null);
  //   setState(() {
  //     recipes.add(recipe);
  //   });
  // } For testing

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("My Recipes")),
        body: Expanded(child: RecipeList(recipes)),
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final newRecipe = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RecipeCreationPage()));
              if (newRecipe != null) {
                setState(() {
                  recipes.add(newRecipe);
                });
              }
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.add)));
  }
}
