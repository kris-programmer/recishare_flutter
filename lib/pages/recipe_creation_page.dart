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
  final TextEditingController _prepTimeController = TextEditingController();
  final TextEditingController _cookTimeController = TextEditingController();

  final List<TextEditingController> _ingredientControllers = [];
  final List<TextEditingController> _instructionStepControllers = [];

  bool _isProcessingIngredientsPaste = false;
  bool _isProcessingStepsPaste = false; // Separate flag for steps

  @override
  // Free up memory after user is done creating a recipe
  void dispose() {
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    for (var controller in _instructionStepControllers) {
      controller.dispose();
    }
    _titleController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    super.dispose();
  }

  Future getImageGallery() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected.')),
        );
      }
    });
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _addInstructionField() {
    setState(() {
      _instructionStepControllers.add(TextEditingController());
    });
  }

  void _removeIngredientField(int index) {
    setState(() {
      _ingredientControllers.removeAt(index).dispose();
    });
  }

  void _removeInstructionField(int index) {
    setState(() {
      _instructionStepControllers.removeAt(index).dispose();
    });
  }

  void saveRecipe() {
    final recipe = Recipe(
      name: _titleController.text,
      description: _descriptionController.text,
      ingredients: _ingredientControllers.map((c) => c.text).toList(),
      instructions: _instructionStepControllers.map((c) => c.text).toList(),
      prepTime: int.tryParse(_prepTimeController.text),
      cookTime: int.tryParse(_cookTimeController.text),
      imagePath: _image?.path,
      favourite: false,
    );
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            minLines: 3,
            maxLines: null,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 16),

          // INGREDIENTS
          const Text('Ingredients'),
          ..._ingredientControllers.asMap().entries.map((entry) {
            int index = entry.key;
            TextEditingController controller = entry.value;
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration:
                        InputDecoration(labelText: 'Ingredient ${index + 1}'),
                    minLines: 1,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textAlignVertical: TextAlignVertical.top,
                    onChanged: (value) {
                      if (_isProcessingIngredientsPaste) {
                        return; // Prevent repeated updates
                      }
                      if (value.contains('\n')) {
                        setState(() {
                          _isProcessingIngredientsPaste = true; // Set the flag

                          // Split the pasted text into lines
                          final lines = value
                              .split('\n')
                              .map((line) => line.trim())
                              .where((line) => line.isNotEmpty)
                              .toList();

                          // Update the current field with the first line
                          controller.text = lines.first;

                          // Add the remaining lines as new fields
                          for (var line in lines.skip(1)) {
                            _ingredientControllers
                                .add(TextEditingController(text: line));
                          }

                          _isProcessingIngredientsPaste =
                              false; // Reset the flag
                        });
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeIngredientField(index),
                ),
              ],
            );
          }),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Ingredient'),
            onPressed: _addIngredientField,
          ),
          const SizedBox(height: 16),

          // INSTRUCTIONS
          const Text('Steps'),
          ..._instructionStepControllers.asMap().entries.map((entry) {
            int index = entry.key;
            TextEditingController controller = entry.value;
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(labelText: 'Step ${index + 1}'),
                    minLines: 2,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textAlignVertical: TextAlignVertical.top,
                    onChanged: (value) {
                      if (_isProcessingStepsPaste) {
                        return; // Prevent repeated updates
                      }
                      if (value.contains('\n')) {
                        setState(() {
                          _isProcessingStepsPaste = true; // Set the flag

                          // Split the pasted text into lines
                          final lines = value
                              .split('\n')
                              .map((line) => line.trim())
                              .where((line) => line.isNotEmpty)
                              .toList();

                          // Update the current field with the first line
                          controller.text = lines.first;

                          // Add the remaining lines as new fields
                          for (var line in lines.skip(1)) {
                            _instructionStepControllers
                                .add(TextEditingController(text: line));
                          }

                          _isProcessingStepsPaste = false; // Reset the flag
                        });
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeInstructionField(index),
                ),
              ],
            );
          }),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Step'),
            onPressed: _addInstructionField,
          ),
          const SizedBox(height: 16),
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
