import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import 'package:craftconnect/config/app_constants.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@craftconnect.app',
      query: 'subject=Help & Support Request',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+911234567890');

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Contact Options
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: AppDecorations.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contact Us',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  leading: const Icon(Icons.email_outlined,
                      color: AppTheme.primaryColor),
                  title: const Text('Email'),
                  subtitle: const Text('support@craftconnect.app'),
                  onTap: _launchEmail,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.phone_outlined,
                      color: AppTheme.primaryColor),
                  title: const Text('Phone'),
                  subtitle: const Text('+91 1234567890'),
                  onTap: _launchPhone,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // FAQ Section
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: AppDecorations.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Frequently Asked Questions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildFAQItem(
                  'How do I track my order?',
                  'Go to Orders tab and tap on any order to see tracking details.',
                ),
                _buildFAQItem(
                  'How can I cancel my order?',
                  'Contact the artisan directly through the order details page or reach out to our support team.',
                ),
                _buildFAQItem(
                  'What payment methods are accepted?',
                  'We currently accept UPI payments and cash on delivery.',
                ),
                _buildFAQItem(
                  'How do I become an artisan?',
                  'Sign up with an artisan account and create your shop to start selling your products.',
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // App Info
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: AppDecorations.cardDecoration,
            child: const Column(
              children: [
                Icon(
                  Icons.store,
                  size: 64,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'CraftConnect',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(color: AppTheme.textSecondaryColor),
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'Supporting local artisans and handcrafted products',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            answer,
            style: const TextStyle(color: AppTheme.textSecondaryColor),
          ),
        ),
      ],
    );
  }
}