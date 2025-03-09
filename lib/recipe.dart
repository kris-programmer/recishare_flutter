class Recipe {
  String name;
  String description;
  List<String>? ingredients;
  List<String>? instructions;
  int? prepTime;
  int? cookTime;
  String? imagePath;
  bool favourite = false;

  Recipe(this.name, this.description, this.ingredients, this.instructions,
      this.prepTime, this.cookTime, this.imagePath);

  void favouriteRecipe() {
    favourite = !favourite;
    if (favourite) {
      // Add it to a favourites menu
    }
  }

  // Convert a Recipe object into a Map object
  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'ingredients': ingredients,
        'instructions': instructions,
        'prepTime': prepTime,
        'cookTime': cookTime,
        'imagePath': imagePath,
        'favourite': favourite,
      };

  // Convert a Map object into a Recipe object
  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        json['name'],
        json['description'],
        List<String>.from(json['ingredients']),
        List<String>.from(json['instructions']),
        json['prepTime'],
        json['cookTime'],
        json['imagePath'],
      );
}
