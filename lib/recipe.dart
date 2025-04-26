import 'dart:convert';

class Recipe {
  final int? id;
  final String name;
  final String? description;
  final List<String>? ingredients;
  final List<String>? instructions;
  final int? prepTime;
  final int? cookTime;
  String? imageData;
  final DateTime dateCreated;
  bool favourite;

  Recipe({
    this.id,
    required this.name,
    this.description,
    this.ingredients,
    this.instructions,
    this.prepTime,
    this.cookTime,
    this.imageData,
    required this.dateCreated,
    this.favourite = false,
  });

  // Convert a Recipe object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': jsonEncode(ingredients), // Store as JSON array
      'instructions': jsonEncode(instructions), // Store as JSON array
      'prepTime': prepTime,
      'cookTime': cookTime,
      'imageData': imageData,
      'dateCreated': dateCreated.toIso8601String(), // Convert to ISO string
      'favourite': favourite ? 1 : 0,
    };
  }

  // Convert a Map to a Recipe object
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
      imageData: map['imageData'],
      dateCreated: map['dateCreated'] != null
          ? DateTime.parse(map['dateCreated'])
          : DateTime.now(), // Use current date if NULL
      favourite: map['favourite'] == 1,
    );
  }

  // Convert a JSON string to a list of Recipe objects
  static List<Recipe> fromJsonList(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Recipe.fromMap(json)).toList();
  }

  // Convert a list of Recipe objects to a JSON string
  static String toJsonList(List<Recipe> recipes) {
    final List<Map<String, dynamic>> jsonList =
        recipes.map((recipe) => recipe.toMap()).toList();
    return jsonEncode(jsonList);
  }
}
