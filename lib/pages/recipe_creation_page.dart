import "dart:io";
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../recipe.dart';

class RecipeCreationPage extends StatefulWidget {
  const RecipeCreationPage({super.key});

  @override
  State<RecipeCreationPage> createState() => _RecipeCreationPageState();
}

class _RecipeCreationPageState extends State<RecipeCreationPage> {
  File? _image;
  final picker = ImagePicker();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _prepTimeController = TextEditingController();
  final TextEditingController _cookTimeController = TextEditingController();

  Future getImageGallery() async {
    // Create the image pick functionality
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print("No image picked");
      }
    });
  }

  void saveRecipe() {
    final recipe = Recipe(
        _titleController.text,
        _descriptionController.text,
        _ingredientsController.text.split(','),
        _instructionsController.text.split(','),
        int.tryParse(_prepTimeController.text),
        int.tryParse(_cookTimeController.text),
        _image?.path);
    // Navigate back to the recipes page and pass the new recipe
    Navigator.pop(context, recipe);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a recipe"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: saveRecipe,
          ),
        ],
      ),
      body: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          Center(
            child: InkWell(
              onTap: () {
                getImageGallery();
              },
              child: Container(
                height: 200,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(5),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.grey)),
                child: Stack(
                  children: [
                    _image != null
                        ? Image.file(_image!.absolute,
                            fit: BoxFit.cover, width: double.infinity)
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    size: 30),
                                SizedBox(height: 8),
                                Text('Add photo')
                              ],
                            ),
                          ),
                    if (_image != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _image = null;
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
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
            decoration: const InputDecoration(labelText: 'Prep Time (minutes)'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _cookTimeController,
            decoration: const InputDecoration(labelText: 'Cook Time (minutes)'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}
