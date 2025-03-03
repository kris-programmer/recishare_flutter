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
}
