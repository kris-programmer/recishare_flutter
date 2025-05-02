import "dart:io";
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../recipe.dart';
import '../recipe_service.dart';
import '../widgets/dynamic_text_field_list.dart';
import 'package:recishare_flutter/utils/image_utils.dart';
import 'dart:convert';

class RecipeEditPage extends StatefulWidget {
  final Recipe recipe; // The recipe being edited
  final Function(Recipe) onSave; // Callback to save the updated recipe

  const RecipeEditPage({super.key, required this.recipe, required this.onSave});

  @override
  State<RecipeEditPage> createState() => _RecipeEditPageState();
}

class _RecipeEditPageState extends State<RecipeEditPage> {
  File? _image; // Holds the selected image file
  final picker = ImagePicker(); // Image picker instance

  // Controllers for text fields
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _prepTimeController;
  late final TextEditingController _cookTimeController;

  // Lists of controllers for dynamic fields
  final List<TextEditingController> _ingredientControllers = [];
  final List<TextEditingController> _stepControllers = [];

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

    // Map ingredients and instructions to controllers
    _ingredientControllers.addAll(
      (widget.recipe.ingredients ?? [])
          .map((ingredient) => TextEditingController(text: ingredient)),
    );
    _stepControllers.addAll(
      (widget.recipe.instructions ?? [])
          .map((step) => TextEditingController(text: step)),
    );

    // Do not initialize _image for Base64 data
    // _image will only be set when a new image is picked
  }

  @override
  void dispose() {
    // Dispose all controllers to free resources
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

  // Opens the gallery to pick an image
  Future<void> getImageGallery() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Compress image quality to 80%
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Set the selected image
        widget.recipe.imageData = null; // Clear the existing Base64 data
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected.')),
        );
      }
    }
  }

  // Saves the updated recipe
  void saveRecipe() async {
    String? base64Image;

    // Encode the selected image to Base64 if an image is selected
    if (_image != null) {
      base64Image = await encodeImageToBase64(_image!.path);
    } else if (widget.recipe.imageData != null &&
        widget.recipe.imageData!.isNotEmpty) {
      base64Image =
          widget.recipe.imageData; // Preserve the existing Base64 data
    }

    // Create an updated recipe object
    final updatedRecipe = Recipe(
      id: widget.recipe.id,
      name: _titleController.text.isNotEmpty
          ? _titleController.text
          : 'Untitled Recipe', // Default title if empty
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : 'No description provided.', // Default description if empty
      ingredients: _ingredientControllers
          .map((c) => c.text.isNotEmpty ? c.text : 'Unnamed ingredient')
          .toList(), // Default ingredient name if empty
      instructions: _stepControllers
          .map((c) => c.text.isNotEmpty ? c.text : 'Unnamed step')
          .toList(), // Default step name if empty
      prepTime: int.tryParse(_prepTimeController.text) ?? 0, // Default to 0
      cookTime: int.tryParse(_cookTimeController.text) ?? 0, // Default to 0
      imageData: base64Image, // Pass the Base64-encoded image
      dateCreated:
          widget.recipe.dateCreated, // Preserve the original creation date
      favourite: widget.recipe.favourite, // Preserve favourite status
    );

    // Update the recipe using the service
    final recipeService = RecipeService();
    await recipeService.updateRecipe(updatedRecipe);

    if (mounted) {
      widget.onSave(
          updatedRecipe); // Trigger the callback with the updated recipe
      Navigator.pop(context); // Navigate back to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Confirm with the user before discarding changes
        final shouldDiscard = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Discard Changes?'),
              content: const Text(
                  'Are you sure you want to discard your changes? Any unsaved progress will be lost.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // Stay
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true), // Discard
                  child: const Text('Discard'),
                ),
              ],
            );
          },
        );
        return shouldDiscard ?? false; // Prevent navigation if canceled
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Edit Recipe"),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed:
                  saveRecipe, // Save the recipe when the check icon is pressed
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Title input field
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),

            // Image picker and preview
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap:
                        getImageGallery, // Allow the user to pick a new image
                    child: _image != null
                        ? Image.file(
                            _image!,
                            width: double
                                .infinity, // Take up full horizontal space
                            height: 200, // Adjust height as needed
                            fit: BoxFit.contain, // Maintain aspect ratio
                          )
                        : (widget.recipe.imageData != null &&
                                widget.recipe.imageData!.isNotEmpty)
                            ? Image.memory(
                                base64Decode(widget.recipe.imageData!),
                                width: double
                                    .infinity, // Take up full horizontal space
                                height: 200, // Adjust height as needed
                                fit: BoxFit.contain, // Maintain aspect ratio
                              )
                            : const Icon(Icons.image,
                                size: 100,
                                color: Colors.grey), // Placeholder icon
                  ),
                  const SizedBox(height: 8),
                  // Add a button to remove the image
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _image = null; // Clear the selected image
                        widget.recipe.imageData =
                            null; // Clear the Base64 image data
                      });
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      'Remove Image',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description input field
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

            // Dynamic list for ingredients
            DynamicTextFieldList(
              controllers: _ingredientControllers,
              label: 'Ingredient',
              onAdd: () {
                setState(() {
                  _ingredientControllers.add(TextEditingController());
                });
              },
              onRemove: (index) {
                setState(() {
                  _ingredientControllers.removeAt(index).dispose();
                });
              },
              minLines: 1,
            ),

            const SizedBox(height: 16),

            // Dynamic list for instructions
            DynamicTextFieldList(
              controllers: _stepControllers,
              label: 'Step',
              onAdd: () {
                setState(() {
                  _stepControllers.add(TextEditingController());
                });
              },
              onRemove: (index) {
                setState(() {
                  _stepControllers.removeAt(index).dispose();
                });
              },
              minLines: 3,
            ),

            const SizedBox(height: 16),

            // Prep time input field
            TextField(
              controller: _prepTimeController,
              decoration:
                  const InputDecoration(labelText: 'Prep Time (minutes)'),
              keyboardType: TextInputType.number,
            ),

            // Cook time input field
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
