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
  File? _image;
  final picker = ImagePicker();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _prepTimeController = TextEditingController();
  final TextEditingController _cookTimeController = TextEditingController();

  final List<TextEditingController> _ingredientControllers = [];
  final List<TextEditingController> _instructionStepControllers = [];

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

  void saveRecipe() async {
    String? base64Image;

    // Encode the selected image to Base64 if an image is selected
    if (_image != null) {
      base64Image = await encodeImageToBase64(_image!.path);
    }

    final recipe = Recipe(
      name: _titleController.text.isNotEmpty
          ? _titleController.text
          : 'Untitled Recipe',
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : 'No description provided.',
      ingredients: _ingredientControllers.isNotEmpty
          ? _ingredientControllers
              .map((c) => c.text.isNotEmpty ? c.text : 'Unnamed ingredient')
              .toList()
          : ['No ingredients added.'],
      instructions: _instructionStepControllers.isNotEmpty
          ? _instructionStepControllers
              .map((c) => c.text.isNotEmpty ? c.text : 'Unnamed step')
              .toList()
          : ['No instructions added.'],
      prepTime: int.tryParse(_prepTimeController.text) ?? 0,
      cookTime: int.tryParse(_cookTimeController.text) ?? 0,
      imageData: base64Image, // Pass the Base64-encoded image
      dateCreated: DateTime.now(),
      favourite: false,
    );

    // Ensure the widget is still mounted before using the context
    if (mounted) {
      Navigator.pop(context, recipe);
    }
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
          DynamicTextFieldList(
            controllers: _ingredientControllers,
            label: 'Ingredient',
            onAdd: _addIngredientField,
            onRemove: _removeIngredientField,
            minLines: 1, // Start with 2 rows for each ingredient text box
          ),

          // INSTRUCTIONS
          DynamicTextFieldList(
            controllers: _instructionStepControllers,
            label: 'Step',
            onAdd: _addInstructionField,
            onRemove: _removeInstructionField,
            minLines: 3, // Start with 3 rows for each step text box
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
