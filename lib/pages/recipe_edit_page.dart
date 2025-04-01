import "dart:io";
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../recipe.dart';
import '../recipe_service.dart';
import '../widgets/dynamic_text_field_list.dart';
import '../widgets/image_picker_widget.dart';

class RecipeEditPage extends StatefulWidget {
  final Recipe recipe;
  final Function(Recipe) onSave;

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

  Future<void> getImageGallery() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected.')),
        );
      }
    }
  }

  void saveRecipe() async {
    final updatedRecipe = Recipe(
      name: _titleController.text.isNotEmpty
          ? _titleController.text
          : 'Untitled Recipe',
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : 'No description provided.',
      ingredients: _ingredientControllers
          .map((c) => c.text.isNotEmpty ? c.text : 'Unnamed ingredient')
          .toList(),
      instructions: _stepControllers
          .map((c) => c.text.isNotEmpty ? c.text : 'Unnamed step')
          .toList(),
      prepTime: int.tryParse(_prepTimeController.text) ?? 0,
      cookTime: int.tryParse(_cookTimeController.text) ?? 0,
      imagePath: _image?.path,
      favourite: widget.recipe.favourite,
      id: widget.recipe.id,
    );

    final recipeService = RecipeService();
    await recipeService.updateRecipe(updatedRecipe);

    if (mounted) {
      widget.onSave(updatedRecipe);
      Navigator.pop(context, updatedRecipe);
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

          // INSTRUCTIONS
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
