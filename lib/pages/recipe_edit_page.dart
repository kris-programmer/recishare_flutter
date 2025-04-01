import "dart:io";
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../recipe.dart';
import '../recipe_service.dart';

class RecipeEditPage extends StatefulWidget {
  final Recipe recipe;
  final Function(Recipe) onSave; // Add this parameter

  const RecipeEditPage({super.key, required this.recipe, required this.onSave});

  @override
  State<RecipeEditPage> createState() => _RecipeEditPageState();
}

class _RecipeEditPageState extends State<RecipeEditPage> {
  File? _image;
  final picker = ImagePicker();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _prepTimeController;
  late final TextEditingController _cookTimeController;

  List<TextEditingController> _ingredientControllers = [];
  List<TextEditingController> _stepControllers = [];

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing recipe data
    _titleController = TextEditingController(text: widget.recipe.name);
    _descriptionController =
        TextEditingController(text: widget.recipe.description);
    _prepTimeController =
        TextEditingController(text: widget.recipe.prepTime?.toString() ?? '');
    _cookTimeController =
        TextEditingController(text: widget.recipe.cookTime?.toString() ?? '');

    // Map ingredients to _ingredientControllers
    _ingredientControllers = (widget.recipe.ingredients ?? [])
        .map((ingredient) => TextEditingController(text: ingredient))
        .toList();

    // Map instructions to _stepControllers
    _stepControllers = (widget.recipe.instructions ?? [])
        .map((step) => TextEditingController(text: step))
        .toList();

    // Load the image if it exists
    if (widget.recipe.imagePath != null) {
      _image = File(widget.recipe.imagePath!);
    }
  }

  @override
  void dispose() {
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    for (var controller in _stepControllers) {
      controller.dispose();
    }
    _titleController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    super.dispose();
  }

  bool _isPickingImage = false; // Temp flag

  Future getImageGallery() async {
    if (_isPickingImage) return; // Prevent multiple calls
    _isPickingImage = true;

    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        if (mounted) {
          setState(() {
            _image = File(pickedFile.path);
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No image selected.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick an image.')),
        );
      }
    } finally {
      _isPickingImage = false; // Reset the flag
    }
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _addStepField() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  void _removeIngredientField(int index) {
    setState(() {
      _ingredientControllers.removeAt(index).dispose();
    });
  }

  void _removeStepField(int index) {
    setState(() {
      _stepControllers.removeAt(index).dispose();
    });
  }

  void saveRecipe() async {
    final updatedRecipe = Recipe(
      name: _titleController.text,
      description: _descriptionController.text,
      ingredients: _ingredientControllers.map((c) => c.text).toList(),
      instructions: _stepControllers.map((c) => c.text).toList(),
      prepTime: int.tryParse(_prepTimeController.text),
      cookTime: int.tryParse(_cookTimeController.text),
      imagePath: _image?.path,
      favourite: widget.recipe.favourite,
      id: widget.recipe.id, // Ensure the ID is preserved
    );

    // Save the updated recipe to the database
    final recipeService = RecipeService();
    await recipeService.updateRecipe(updatedRecipe);

    if (mounted) {
      widget.onSave(updatedRecipe); // Call the onSave callback
      Navigator.pop(context, updatedRecipe); // Safely pop the navigation stack
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Recipe"),
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
                    minLines: 1, // Initial height of the text box
                    maxLines: null, // Allows the text box to grow vertically
                    keyboardType:
                        TextInputType.multiline, // Enables multi-line input
                    textAlignVertical:
                        TextAlignVertical.top, // Aligns text to the top
                    onChanged: (value) {
                      // Detect if the user pasted multiple lines
                      if (value.contains('\n')) {
                        setState(() {
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
          ..._stepControllers.asMap().entries.map((entry) {
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
                      if (value.contains('\n')) {
                        setState(() {
                          final lines = value
                              .split('\n')
                              .map((line) => line.trim())
                              .where((line) => line.isNotEmpty)
                              .toList();

                          controller.text = lines.first;

                          for (var line in lines.skip(1)) {
                            _stepControllers
                                .add(TextEditingController(text: line));
                          }
                        });
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeStepField(index),
                ),
              ],
            );
          }),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Step'),
            onPressed: _addStepField,
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
