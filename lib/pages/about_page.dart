import 'package:flutter/material.dart';
import '../pages/privacy_policy_page.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ReciShare',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'ReciShare is an app designed to help you share and discover amazing recipes with your friends and family.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Developed by:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Kristian Bojkov',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Version: 2.0.0',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Acknowledgments:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Thanks to the Flutter community and open-source contributors.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyPage()),
                  );
                },
                child: const Text('Privacy Policy'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
