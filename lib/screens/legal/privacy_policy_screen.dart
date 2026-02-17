import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/app_constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _buildHeader(context),
          const SizedBox(height: AppSpacing.xl),
          _buildSection(
            context,
            'Information We Collect',
            '''We collect information that you provide directly to us, including:

• Personal Information: Name, email address, phone number, shipping address
• Payment Information: Credit card details, UPI IDs (processed securely)
• Account Information: Username, password, profile picture
• Transaction History: Order details, purchase history
• Communication Data: Messages with artisans, customer support conversations

We also automatically collect:
• Device Information: IP address, browser type, operating system
• Usage Data: Pages visited, time spent, click patterns
• Location Data: Approximate location for shipping and local recommendations''',
          ),
          _buildSection(
            context,
            'How We Use Your Information',
            '''We use your information to:

• Process and fulfill your orders
• Communicate with you about your purchases
• Provide customer support
• Personalize your shopping experience
• Send promotional offers and updates (with your consent)
• Improve our services and platform
• Detect and prevent fraud
• Comply with legal obligations''',
          ),
          _buildSection(
            context,
            'Information Sharing',
            '''We share your information only in the following circumstances:

• With Artisans: To fulfill your orders and enable communication
• Payment Processors: To process payments securely
• Shipping Partners: To deliver your orders
• Service Providers: Who help us operate our platform
• Legal Requirements: When required by law or to protect our rights
• Business Transfers: In case of merger, acquisition, or sale

We never sell your personal information to third parties for marketing purposes.''',
          ),
          _buildSection(
            context,
            'Data Security',
            '''We implement industry-standard security measures to protect your data:

• SSL/TLS encryption for data transmission
• Encrypted storage of sensitive information
• Regular security audits and updates
• Access controls and authentication
• Secure payment processing through certified payment gateways

However, no method of transmission over the internet is 100% secure. We cannot guarantee absolute security.''',
          ),
          _buildSection(
            context,
            'Your Rights',
            '''You have the right to:

• Access your personal data
• Correct inaccurate information
• Request deletion of your data (subject to legal requirements)
• Object to processing of your data
• Data portability
• Withdraw consent for marketing communications

To exercise these rights, contact us at privacy@craftconnect.com''',
          ),
          _buildSection(
            context,
            'Cookies and Tracking',
            '''We use cookies and similar technologies to:

• Remember your preferences
• Analyze site usage
• Personalize content and ads
• Improve platform performance

You can control cookies through your browser settings. Note that disabling cookies may limit platform functionality.''',
          ),
          _buildSection(
            context,
            'Children\'s Privacy',
            '''CraftConnect is not intended for children under 13. We do not knowingly collect personal information from children. If you believe we have collected information from a child, please contact us immediately.''',
          ),
          _buildSection(
            context,
            'International Users',
            '''If you access CraftConnect from outside India, your information may be transferred to and processed in India. By using our services, you consent to this transfer.''',
          ),
          _buildSection(
            context,
            'Changes to This Policy',
            '''We may update this Privacy Policy periodically. We will notify you of significant changes via email or platform notification. Continued use of CraftConnect after changes constitutes acceptance of the updated policy.''',
          ),
          _buildSection(
            context,
            'Contact Us',
            '''If you have questions or concerns about this Privacy Policy, contact us:

Email: privacy@craftconnect.com
Phone: +91 1800-XXX-XXXX
Address: CraftConnect Pvt Ltd
         123 Artisan Street
         Bangalore, Karnataka 560001
         India''',
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              'Last Updated: February 16, 2026',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(
            Icons.privacy_tip,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Your Privacy Matters',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'We are committed to protecting your personal information and your right to privacy.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
              ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
