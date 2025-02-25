class Recipe {
  String name;
  String category;
  bool favourite = false;

  Recipe(this.name, this.category);

  void favouriteRecipe() {
    favourite = !favourite;
    if (favourite) {
      // Add it to a favourites menu
    }
  }
}
