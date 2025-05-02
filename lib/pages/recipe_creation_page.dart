import "dart:io";
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../recipe.dart';
import '../widgets/dynamic_text_field_list.dart';
import '../widgets/image_picker_widget.dart';
import 'package:recishare_flutter/utils/image_utils.dart';

class RecipeCreationPage extends StatefulWidget {
  const RecipeCreationPage({super.key});

  @override
  State<RecipeCreationPage> createState() => _RecipeCreationPageState();
}

class _RecipeCreationPageState extends State<RecipeCreationPage> {
  // Holds the selected image file
  File? _image;

  // Image picker instance for selecting images
  final picker = ImagePicker();

  // Controllers for the various text fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _prepTimeController = TextEditingController();
  final TextEditingController _cookTimeController = TextEditingController();

  // Lists to manage dynamic text fields for ingredients and instructions
  final List<TextEditingController> _ingredientControllers = [];
  final List<TextEditingController> _instructionStepControllers = [];

  @override
  void dispose() {
    // Dispose all controllers to free up memory
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

  // Opens the gallery to pick an image and updates the state
  Future getImageGallery() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        // Show a message if no image is selected
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected.')),
        );
      }
    });
  }

  // Adds a new ingredient text field
  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  // Adds a new instruction step text field
  void _addInstructionField() {
    setState(() {
      _instructionStepControllers.add(TextEditingController());
    });
  }

  // Removes an ingredient text field at the specified index
  void _removeIngredientField(int index) {
    setState(() {
      _ingredientControllers.removeAt(index).dispose();
    });
  }

  // Removes an instruction step text field at the specified index
  void _removeInstructionField(int index) {
    setState(() {
      _instructionStepControllers.removeAt(index).dispose();
    });
  }

  // Saves the recipe and navigates back with the created recipe object
  void saveRecipe() async {
    String? base64Image;

    // Encode the selected image to Base64 if an image is selected
    if (_image != null) {
      base64Image = await encodeImageToBase64(_image!.path);
    }

    // Create a Recipe object with the provided data
    final recipe = Recipe(
      name: _titleController.text.isNotEmpty
          ? _titleController.text
          : 'Untitled Recipe', // Default title if none is provided
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : 'No description provided.', // Default description
      ingredients: _ingredientControllers.isNotEmpty
          ? _ingredientControllers
              .map((c) => c.text.isNotEmpty ? c.text : 'Unnamed ingredient')
              .toList()
          : ['No ingredients added.'], // Default ingredient list
      instructions: _instructionStepControllers.isNotEmpty
          ? _instructionStepControllers
              .map((c) => c.text.isNotEmpty ? c.text : 'Unnamed step')
              .toList()
          : ['No instructions added.'], // Default instruction list
      prepTime: int.tryParse(_prepTimeController.text) ?? 0, // Default to 0
      cookTime: int.tryParse(_cookTimeController.text) ?? 0, // Default to 0
      imageData: base64Image, // Pass the Base64-encoded image
      dateCreated: DateTime.now(), // Timestamp for recipe creation
      favourite: false, // Default to not favorited
    );

    // Ensure the widget is still mounted before using the context
    if (mounted) {
      Navigator.pop(
          context, recipe); // Return the recipe to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a recipe"),
        actions: [
          // Save button
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: saveRecipe,
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

          // Image picker widget
          Center(
            child: ImagePickerWidget(
              initialImage: _image,
              onImagePicked: (pickedImage) {
                setState(() {
                  _image = pickedImage;
                });
              },
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
            onAdd: _addIngredientField,
            onRemove: _removeIngredientField,
            minLines: 1, // Start with 1 row for each ingredient text box
          ),

          // Dynamic list for instructions
          DynamicTextFieldList(
            controllers: _instructionStepControllers,
            label: 'Step',
            onAdd: _addInstructionField,
            onRemove: _removeInstructionField,
            minLines: 3, // Start with 3 rows for each step text box
          ),

          const SizedBox(height: 16),

          // Prep time input field
          TextField(
            controller: _prepTimeController,
            decoration: const InputDecoration(labelText: 'Prep Time (minutes)'),
            keyboardType: TextInputType.number,
          ),

          // Cook time input field
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
