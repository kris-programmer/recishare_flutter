import 'database_helper.dart';
import 'recipe.dart';

/// Service class to handle high-level operations related to recipes.
/// Acts as an intermediary between the UI/business logic and the database.
class RecipeService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  /// Fetches all recipes from the database.
  /// Returns a list of [Recipe] objects.
  Future<List<Recipe>> getAllRecipes() async {
    return await _databaseHelper.getAllRecipes();
  }

  /// Imports a list of recipes into the database.
  /// If a recipe already exists, it will be replaced.
  Future<void> importRecipes(List<Recipe> recipes) async {
    for (var recipe in recipes) {
      await _databaseHelper.insertRecipe(recipe);
    }
  }

  /// Deletes a recipe from the database by its ID.
  Future<void> deleteRecipe(int id) async {
    await _databaseHelper.deleteRecipe(id);
  }

  /// Updates an existing recipe in the database.
  Future<void> updateRecipe(Recipe recipe) async {
    await _databaseHelper.updateRecipe(recipe);
  }
}
