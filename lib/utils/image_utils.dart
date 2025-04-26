import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

// Encode image to Base64
Future<String> encodeImageToBase64(String imagePath) async {
  final bytes = await File(imagePath).readAsBytes();
  return base64Encode(bytes);
}

// Decode Base64 to Image
Widget decodeBase64ToImage(String? base64String) {
  if (base64String == null || base64String.isEmpty) {
    return const Icon(Icons.image,
        size: 50, color: Colors.grey); // Placeholder icon
  }
  Uint8List imageBytes = base64Decode(base64String);
  return Image.memory(imageBytes, fit: BoxFit.cover); // Display decoded image
}

ImageProvider decodeBase64ToImageProvider(String base64String) {
  try {
    Uint8List bytes = base64Decode(base64String);
    return MemoryImage(bytes);
  } catch (e) {
    // Return a built-in placeholder image in case of an error
    return const AssetImage(''); // Use an empty AssetImage as a placeholder
  }
}
