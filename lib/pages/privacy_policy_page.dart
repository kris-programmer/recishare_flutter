import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SelectableText(
                'Privacy Policy for ReciShare',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const SelectableText(
                'Effective Date: [Insert Date]\nLast Updated: [Insert Date]',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('1. Introduction'),
              const SelectableText(
                'Welcome to ReciShare! Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your information when you use our app.\n\n'
                'By using ReciShare, you agree to the terms outlined in this Privacy Policy. If you do not agree, please do not use the app.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('2. Information We Collect'),
              _buildBulletPoint(
                  'Personal Information: Information you provide, such as your name, email address, or other contact details when contacting us for support or feedback.'),
              _buildBulletPoint(
                  'Usage Data: Information about how you use the app, such as the recipes you create, edit, or share.'),
              _buildBulletPoint(
                  'Device Information: Information about the device you use, including operating system, device type, and app version.'),
              _buildBulletPoint(
                  'Permissions: Access to your device\'s storage, camera, or other features (e.g., for importing/exporting recipes or adding images to recipes).'),
              const SizedBox(height: 16),
              _buildSectionTitle('3. How We Use Your Information'),
              _buildBulletPoint(
                  'Provide and improve the app\'s functionality.'),
              _buildBulletPoint(
                  'Allow you to create, edit, and share recipes.'),
              _buildBulletPoint(
                  'Enable importing and exporting of recipe data.'),
              _buildBulletPoint(
                  'Respond to your inquiries or support requests.'),
              _buildBulletPoint(
                  'Analyze app usage to improve performance and features.'),
              _buildBulletPoint('Comply with legal obligations.'),
              const SizedBox(height: 16),
              _buildSectionTitle('4. Sharing Your Information'),
              const SelectableText(
                'We do not sell or share your personal information with third parties, except in the following cases:',
                style: TextStyle(fontSize: 16),
              ),
              _buildBulletPoint(
                  'Service Providers: Trusted third-party services that help us operate the app (e.g., cloud storage or analytics).'),
              _buildBulletPoint(
                  'Legal Requirements: When required by law or to protect our legal rights.'),
              const SizedBox(height: 16),
              _buildSectionTitle('5. Data Security'),
              const SelectableText(
                'We take reasonable measures to protect your data from unauthorized access, loss, or misuse. However, no method of transmission over the internet or electronic storage is 100% secure.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('6. Your Rights'),
              _buildBulletPoint(
                  'Access, update, or delete your personal information.'),
              _buildBulletPoint('Withdraw consent for data collection.'),
              _buildBulletPoint(
                  'File a complaint with a data protection authority.'),
              const SelectableText(
                'To exercise these rights, contact us at kris.formal@gmail.com.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('7. Permissions'),
              _buildBulletPoint(
                  'Storage Access: To save and load recipes or export/import recipe data.'),
              _buildBulletPoint(
                  'Camera Access: To allow users to add images to their recipes.'),
              const SelectableText(
                'You can manage these permissions in your device settings.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('8. Third-Party Links'),
              const SelectableText(
                'Our app may contain links to third-party websites or services. We are not responsible for the privacy practices of these third parties.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('9. Changes to This Privacy Policy'),
              const SelectableText(
                'We may update this Privacy Policy from time to time. Any changes will be posted in the app, and the "Last Updated" date will be revised.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('10. Contact Us'),
              const SelectableText(
                'If you have any questions or concerns about this Privacy Policy, please contact us at:\n\n'
                'Email: kris.formal@gmail.com',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return SelectableText(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SelectableText(
            '• ',
            style: TextStyle(fontSize: 16),
          ),
          Expanded(
            child: SelectableText(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
