import 'package:recishare_flutter/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RecipeService {
  List<Recipe> _recipes = [];

  Future<void> importRecipes(List<Recipe> recipes) async {
    // Filter out duplicates
    final newRecipes = recipes
        .where((newRecipe) => !_recipes
            .any((existingRecipe) => existingRecipe.name == newRecipe.name))
        .toList();
    _recipes.addAll(newRecipes);
    await _saveRecipesToStorage(); // Ensure this line saves the imported recipes
  }

  Future<List<Recipe>> getAllRecipes() async {
    await _loadRecipesFromStorage();
    return _recipes;
  }

  Future<void> _saveRecipesToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String recipesString = Recipe.toJsonList(_recipes);
    await prefs.setString('recipes', recipesString);
  }

  Future<void> _loadRecipesFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recipesString = prefs.getString('recipes');
    if (recipesString != null) {
      final List<dynamic> recipesJson = jsonDecode(recipesString);
      _recipes = recipesJson.map((json) => Recipe.fromJson(json)).toList();
    }
  }
}
