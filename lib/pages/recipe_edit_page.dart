import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recishare_flutter/recipe.dart';
import 'package:recishare_flutter/recipe_service.dart';
import 'dart:io';

class RecipeEditPage extends StatefulWidget {
  final Recipe recipe;
  final Function(Recipe) onSave;

  const RecipeEditPage({super.key, required this.recipe, required this.onSave});

  @override
  _RecipeEditPageState createState() => _RecipeEditPageState();
}

class _RecipeEditPageState extends State<RecipeEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _ingredientsController;
  late TextEditingController _instructionsController;
  late TextEditingController _prepTimeController;
  late TextEditingController _cookTimeController;
  final RecipeService _recipeService = RecipeService();
  File? _image;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.recipe.name);
    _descriptionController =
        TextEditingController(text: widget.recipe.description);
    _ingredientsController =
        TextEditingController(text: widget.recipe.ingredients?.join(', '));
    _instructionsController =
        TextEditingController(text: widget.recipe.instructions?.join(', '));
    _prepTimeController =
        TextEditingController(text: widget.recipe.prepTime?.toString());
    _cookTimeController =
        TextEditingController(text: widget.recipe.cookTime?.toString());
    _image =
        widget.recipe.imagePath != null ? File(widget.recipe.imagePath!) : null;
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _image = null;
    });
  }

  void _saveRecipe() async {
    final updatedRecipe = Recipe(
      id: widget.recipe.id,
      name: _titleController.text,
      description: _descriptionController.text,
      ingredients: _ingredientsController.text.split(', '),
      instructions: _instructionsController.text.split(', '),
      prepTime: int.tryParse(_prepTimeController.text),
      cookTime: int.tryParse(_cookTimeController.text),
      imagePath: _image?.path,
      favourite: widget.recipe.favourite,
    );
    await _recipeService.updateRecipe(updatedRecipe);
    widget.onSave(updatedRecipe);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Recipe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveRecipe,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16.0),
            _image != null
                ? Column(
                    children: [
                      Image.file(_image!, height: 200, fit: BoxFit.cover),
                      TextButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('Remove Image'),
                        onPressed: _removeImage,
                      ),
                    ],
                  )
                : const Text('No image selected'),
            TextButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Select Image'),
              onPressed: _pickImage,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _ingredientsController,
              decoration: const InputDecoration(
                  labelText: 'Ingredients (comma separated)'),
            ),
            TextField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                  labelText: 'Instructions (comma separated)'),
            ),
            TextField(
              controller: _prepTimeController,
              decoration:
                  const InputDecoration(labelText: 'Prep Time (minutes)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _cookTimeController,
              decoration:
                  const InputDecoration(labelText: 'Cook Time (minutes)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }
}
