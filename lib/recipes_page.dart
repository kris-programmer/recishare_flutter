import 'package:flutter/material.dart';
import 'package:recishare_flutter/recipe.dart';
import 'package:recishare_flutter/recipe_list.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  List<Recipe> recipes = [];

  void newRecipe() {
    var recipe = Recipe("chicken", "Lunch");
    setState(() {
      recipes.add(recipe);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Expanded(child: RecipeList(recipes)),
        floatingActionButton: FloatingActionButton(
            onPressed: () => newRecipe(),
            backgroundColor: Colors.green,
            child: const Icon(Icons.add)));
  }
}
