// filepath: /home/storm/Documents/ProgramProjects/ReciShare/recishare_flutter/lib/recipe_service.dart
import 'database_helper.dart';
import 'recipe.dart';

class RecipeService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<Recipe>> getAllRecipes() async {
    return await _databaseHelper.getAllRecipes();
  }

  Future<void> importRecipes(List<Recipe> recipes) async {
    for (var recipe in recipes) {
      await _databaseHelper.insertRecipe(recipe);
    }
  }

  Future<void> deleteRecipe(int id) async {
    await _databaseHelper.deleteRecipe(id);
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await _databaseHelper.updateRecipe(recipe);
  }
}
