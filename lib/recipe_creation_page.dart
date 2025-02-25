import "dart:io";
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RecipeCreationPage extends StatefulWidget {
  const RecipeCreationPage({super.key});

  @override
  State<RecipeCreationPage> createState() => _RecipeCreationPageState();
}

class _RecipeCreationPageState extends State<RecipeCreationPage> {
  File? _image;
  final picker = ImagePicker();

  Future getImageGallery() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        //widget.imgUrl = null;
      } else {
        print("No image picked");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a recipe"),
      ),
      body: Column(
        children: [
          Center(
              child: InkWell(
            onTap: () {
              getImageGallery();
            },
            child: Container(
                height: 200,
                width: 300,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.grey)),
                child: _image != null
                    ? Image.file(_image!.absolute, fit: BoxFit.cover)
                    : const Center(
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 30,
                        ),
                      )),
          ))
        ],
      ),
    );
  }
}
