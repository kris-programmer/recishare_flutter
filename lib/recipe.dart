import 'dart:convert';

class Recipe {
  final int? id;
  final String name;
  final String? description;
  final List<String>? ingredients;
  final List<String>? instructions;
  final int? prepTime;
  final int? cookTime;
  final String? imagePath;
  bool favourite;

  Recipe({
    this.id,
    required this.name,
    this.description,
    this.ingredients,
    this.instructions,
    this.prepTime,
    this.cookTime,
    this.imagePath,
    this.favourite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': jsonEncode(ingredients), // Store as JSON array
      'instructions': jsonEncode(instructions), // Store as JSON array
      'prepTime': prepTime,
      'cookTime': cookTime,
      'imagePath': imagePath,
      'favourite': favourite ? 1 : 0,
    };
  }

  // Convert a Map object into a Recipe object
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      ingredients: map['ingredients'] != null
          ? List<String>.from(jsonDecode(map['ingredients']))
          : [],
      instructions: map['instructions'] != null
          ? List<String>.from(jsonDecode(map['instructions']))
          : [],
      prepTime: map['prepTime'],
      cookTime: map['cookTime'],
      imagePath: map['imagePath'],
      favourite: map['favourite'] == 1,
    );
  }

  static String toJsonList(List<Recipe> recipes) {
    List<Map<String, dynamic>> jsonList =
        recipes.map((recipe) => recipe.toMap()).toList();
    return jsonEncode(jsonList);
  }

  // Convert a JSON string to a list of Recipe objects
  static List<Recipe> fromJsonList(String jsonString) {
    List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Recipe.fromMap(json)).toList();
  }
}
