import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../recipe.dart';
import 'recipe_creation_page.dart';
import '../recipe_list.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  List<Recipe> recipes = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recipesString = prefs.getString('recipes');
    if (recipesString != null) {
      final List<dynamic> recipesJson = jsonDecode(recipesString);
      setState(() {
        recipes = recipesJson.map((json) => Recipe.fromJson(json)).toList();
      });
    }
  }

  Future<void> _saveRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final String recipesString =
        jsonEncode(recipes.map((recipe) => recipe.toJson()).toList());
    await prefs.setString('recipes', recipesString);
  }

  void _deleteRecipe(Recipe recipe) {
    setState(() {
      recipes.remove(recipe);
    });
    _saveRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Recipes"),
        actions: [
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
                _saveRecipes();
              }
            },
          ),
        ],
      ),
      body: RecipeList(
        recipes,
        onDelete: _deleteRecipe,
      ),
    );
  }
}
