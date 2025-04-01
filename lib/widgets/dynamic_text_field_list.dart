import 'package:flutter/material.dart';

class DynamicTextFieldList extends StatelessWidget {
  final List<TextEditingController> controllers;
  final String label;
  final VoidCallback onAdd;
  final void Function(int) onRemove;
  final int minLines;

  const DynamicTextFieldList({
    required this.controllers,
    required this.label,
    required this.onAdd,
    required this.onRemove,
    this.minLines = 1,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        ...controllers.asMap().entries.map((entry) {
          int index = entry.key;
          TextEditingController controller = entry.value;
          return Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(labelText: '$label ${index + 1}'),
                  minLines: minLines,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  onChanged: (value) {
                    if (value.contains('\n')) {
                      // Split pasted text into separate lines
                      final lines = value
                          .split('\n')
                          .map((line) => line.trim())
                          .where((line) => line.isNotEmpty)
                          .toList();

                      // Update the current field with the first line
                      controller.text = lines.first;

                      // Add the remaining lines as new fields
                      if (lines.length > 1) {
                        final newControllers = lines
                            .skip(1)
                            .map((line) => TextEditingController(text: line))
                            .toList();
                        controllers.insertAll(index + 1, newControllers);

                        // Trigger a rebuild by calling addPostFrameCallback
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          // Notify the parent widget to rebuild
                          (context as Element).markNeedsBuild();
                        });
                      }
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => onRemove(index),
              ),
            ],
          );
        }),
        TextButton.icon(
          icon: const Icon(Icons.add),
          label: Text('Add $label'),
          onPressed: onAdd,
        ),
      ],
    );
  }
}
