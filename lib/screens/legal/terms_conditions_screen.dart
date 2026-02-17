import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/app_constants.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _buildHeader(context),
          const SizedBox(height: AppSpacing.xl),
          _buildSection(
            context,
            '1. Acceptance of Terms',
            '''By accessing and using CraftConnect ("the Platform"), you accept and agree to be bound by these Terms and Conditions. If you do not agree, please do not use our services.

These terms apply to all users, including buyers and artisans/sellers.''',
          ),
          _buildSection(
            context,
            '2. User Accounts',
            '''Account Creation:
• You must be at least 18 years old to create an account
• You must provide accurate and complete information
• You are responsible for maintaining account security
• One person or business may maintain only one account

Account Termination:
• We reserve the right to suspend or terminate accounts that violate these terms
• You may close your account at any time
• Upon termination, you lose access to all account features''',
          ),
          _buildSection(
            context,
            '3. For Buyers',
            '''Purchase Process:
• All prices are in Indian Rupees (₹) unless stated otherwise
• Product availability is subject to change
• We do not guarantee product quality but facilitate communication with sellers

Payment:
• Payment must be made at the time of order
• We use secure third-party payment processors
• Refunds are subject to our Return Policy

Order Cancellation:
• You may cancel orders before shipment
• Cancellation after shipment is subject to seller approval
• Cancellation fees may apply''',
          ),
          _buildSection(
            context,
            '4. For Sellers/Artisans',
            '''Seller Responsibilities:
• Provide accurate product descriptions and images
• Fulfill orders within specified timeframes
• Maintain product quality standards
• Respond to customer inquiries promptly
• Comply with all applicable laws

Prohibited Products:
• Counterfeit or stolen items
• Illegal or restricted items
• Dangerous or hazardous materials
• Items infringing intellectual property rights

Commission & Fees:
• CraftConnect charges a platform fee on each sale
• Payment processing fees apply
• Fees are deducted from seller payments
• Fee structure is available in the Seller Dashboard''',
          ),
          _buildSection(
            context,
            '5. Intellectual Property',
            '''Platform Content:
• CraftConnect owns all platform IP (logo, design, code)
• You may not copy, modify, or distribute platform content

User Content:
• You retain ownership of content you upload
• You grant us license to use your content for platform operations
• You must have rights to all content you upload

Product Listings:
• Sellers must own or have permission for product images and descriptions
• Buyers may not use product images without seller permission''',
          ),
          _buildSection(
            context,
            '6. Prohibited Conduct',
            '''You may not:
• Violate any laws or regulations
• Infringe on others' rights
• Transmit harmful code or malware
• Engage in fraudulent activities
• Harass, abuse, or harm others
• Manipulate reviews or ratings
• Scrape or data mine the platform
• Circumvent platform fees
• Create multiple accounts
• Impersonate others''',
          ),
          _buildSection(
            context,
            '7. Dispute Resolution',
            '''Between Buyers and Sellers:
• First attempt resolution through platform messaging
• Contact CraftConnect support for mediation
• We may assist but are not responsible for resolving disputes

Platform Disputes:
• Governed by Indian law
• Disputes subject to Bangalore jurisdiction
• Arbitration before litigation when applicable''',
          ),
          _buildSection(
            context,
            '8. Liability Limitations',
            '''CraftConnect provides a marketplace platform. We:
• Do not guarantee product quality or seller reliability
• Are not liable for transaction disputes
• Limit liability to the amount paid for services
• Do not guarantee uninterrupted service
• Are not responsible for third-party actions

Use the platform at your own risk.''',
          ),
          _buildSection(
            context,
            '9. Privacy',
            '''Your privacy is important. Our Privacy Policy explains:
• What information we collect
• How we use and protect it
• Your privacy rights

By using CraftConnect, you consent to our Privacy Policy.''',
          ),
          _buildSection(
            context,
            '10. Shipping & Delivery',
            '''Sellers are responsible for:
• Accurate shipping cost calculation
• Timely shipment of orders
• Proper packaging
• Providing tracking information

Buyers should:
• Provide accurate shipping addresses
• Be available to receive deliveries
• Report delivery issues within 48 hours''',
          ),
          _buildSection(
            context,
            '11. Returns & Refunds',
            '''See our Return & Refund Policy for detailed information.

General guidelines:
• 7-day return window for eligible items
• Items must be unused and in original condition
• Custom/personalized items may not be returnable
• Refunds processed within 5-7 business days''',
          ),
          _buildSection(
            context,
            '12. Modifications',
            '''We may modify these terms at any time. Changes effective immediately upon posting. Continued use constitutes acceptance of modified terms.

We will notify you of significant changes via email or platform notification.''',
          ),
          _buildSection(
            context,
            '13. Contact Information',
            '''For questions about these Terms and Conditions:

Email: legal@craftconnect.com
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
            Icons.description,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Terms & Conditions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Please read these terms carefully before using CraftConnect',
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
