import 'package:flutter/material.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  LanguageSettingsPageState createState() => LanguageSettingsPageState();
}

class LanguageSettingsPageState extends State<LanguageSettingsPage> {
  String _selectedLanguage = 'English'; // Default language

  final List<String> _languages = ['English', 'Български', 'French', 'German'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Settings'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          final language = _languages[index];
          return RadioListTile<String>(
            title: Text(language),
            value: language,
            groupValue: _selectedLanguage,
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
                // Add logic to update the app's language here.
              });
            },
          );
        },
      ),
    );
  }
}
