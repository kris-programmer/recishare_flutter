import 'package:flutter/material.dart';
import 'package:recishare_flutter/recipe.dart';

class SelectedRecipePage extends StatelessWidget {
  final Recipe recipe;
  SelectedRecipePage({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        child: Text("Selected recipe"),
      ),
    );
  }
}
