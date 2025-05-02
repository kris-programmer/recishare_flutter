import 'dart:convert';

class Recipe {
  // Unique identifier for the recipe, can be null for new recipes
  final int? id;

  // Name of the recipe
  final String name;

  // Optional description of the recipe
  final String? description;

  // List of ingredients required for the recipe, stored as strings
  final List<String>? ingredients;

  // List of instructions for preparing the recipe, stored as strings
  final List<String>? instructions;

  // Preparation time in minutes, optional
  final int? prepTime;

  // Cooking time in minutes, optional
  final int? cookTime;

  // Base64-encoded image data for the recipe, optional
  String? imageData;

  // Date and time when the recipe was created
  final DateTime dateCreated;

  // Boolean flag indicating whether the recipe is marked as a favorite
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

  // Convert a Recipe object to a Map for storage or serialization
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
      'favourite': favourite ? 1 : 0, // Store boolean as integer
    };
  }

  // Create a Recipe object from a Map, typically retrieved from storage
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      ingredients: map['ingredients'] != null
          ? List<String>.from(
              jsonDecode(map['ingredients'])) // Decode JSON array
          : [],
      instructions: map['instructions'] != null
          ? List<String>.from(
              jsonDecode(map['instructions'])) // Decode JSON array
          : [],
      prepTime: map['prepTime'],
      cookTime: map['cookTime'],
      imageData: map['imageData'],
      dateCreated: map['dateCreated'] != null
          ? DateTime.parse(map['dateCreated']) // Parse ISO string to DateTime
          : DateTime.now(), // Use current date if NULL
      favourite: map['favourite'] == 1, // Convert integer to boolean
    );
  }

  // Convert a JSON string to a list of Recipe objects
  static List<Recipe> fromJsonList(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString); // Decode JSON string
    return jsonList
        .map((json) => Recipe.fromMap(json))
        .toList(); // Map to Recipe objects
  }

  // Convert a list of Recipe objects to a JSON string
  static String toJsonList(List<Recipe> recipes) {
    final List<Map<String, dynamic>> jsonList = recipes
        .map((recipe) => recipe.toMap())
        .toList(); // Convert each Recipe to Map
    return jsonEncode(jsonList); // Encode list of Maps to JSON string
  }
}
