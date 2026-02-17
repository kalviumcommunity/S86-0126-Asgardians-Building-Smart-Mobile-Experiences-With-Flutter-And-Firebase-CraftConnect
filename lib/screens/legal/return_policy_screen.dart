import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/app_constants.dart';

class ReturnPolicyScreen extends StatelessWidget {
  const ReturnPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Return & Refund Policy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _buildHeader(context),
          const SizedBox(height: AppSpacing.xl),
          _buildSection(
            context,
            'Return Eligibility',
            '''You can return most items within 7 days of delivery if:

✓ Item is unused and in original condition
✓ Original packaging and tags are intact
✓ Item is not on the non-returnable list
✓ Return initiated through the platform

Note: Custom, personalized, or made-to-order items may have different return policies set by individual sellers.''',
          ),
          _buildSection(
            context,
            'Non-Returnable Items',
            '''The following items cannot be returned:

• Personalized or custom-made products
• Perishable goods (food, flowers)
• Intimate apparel and swimwear
• Health and personal care items (once opened)
• Downloadable digital products
• Items marked "Final Sale" or "Non-Returnable"
• Gift cards

Always check the product page for specific return information.''',
          ),
          _buildSection(
            context,
            'Return Process',
            '''Step 1: Initiate Return
• Go to Orders in your Account
• Select the order and item to return
• Choose return reason
• Upload photos if damaged/defective

Step 2: Approval
• Seller reviews your request within 48 hours
• You'll receive email notification of approval/rejection

Step 3: Ship Back
• Pack item securely in original packaging
• Use provided return shipping label (if applicable)
• Drop off at designated courier location
• Keep tracking number for reference

Step 4: Inspection
• Seller inspects returned item
• Approval typically within 2-3 business days

Step 5: Refund
• Refund processed after inspection approval
• Amount credited within 5-7 business days''',
          ),
          _buildSection(
            context,
            'Return Shipping',
            '''Who Pays for Return Shipping?

Defective/Damaged/Wrong Item:
• CraftConnect covers return shipping
• Pre-paid return label provided

Buyer's Choice (changed mind, didn't like):
• Buyer pays return shipping
• Deducted from refund amount

Free Returns:
• Some sellers offer free returns on select items
• Look for "Free Returns" badge on product pages''',
          ),
          _buildSection(
            context,
            'Refund Methods',
            '''Refunds are issued to your original payment method:

Credit/Debit Card:
• Processed within 5-7 business days
• May take additional time to reflect in your statement

UPI/Net Banking:
• Typically 3-5 business days

CraftConnect Wallet:
• Instant credit (can be used for future purchases)

Cash on Delivery:
• Refunded to your bank account or CraftConnect Wallet
• Bank details required''',
          ),
          _buildSection(
            context,
            'Partial Refunds',
            '''In some cases, partial refunds may be granted:

• Item returned after 7-day window (at seller's discretion)
• Item shows signs of use or missing accessories
• Item not in original packaging
• Restocking fee applies (varies by seller)

Partial refund amount determined by seller based on item condition.''',
          ),
          _buildSection(
            context,
            'Damaged or Defective Items',
            '''If you receive damaged or defective items:

1. Report within 48 hours of delivery
2. Take clear photos showing damage/defect
3. Contact seller through platform messaging
4. Initiate return request with photos

Priority Processing:
• Damage/defect returns processed within 24 hours
• Free return shipping provided
• Full refund or replacement offered

Report damage before initiating return for faster resolution.''',
          ),
          _buildSection(
            context,
            'Wrong Item Delivered',
            '''If you receive the wrong item:

1. Don't use or remove tags from the item
2. Report immediately through Orders page
3. Upload photos of received item
4. Return at no cost to you

We'll either:
• Send correct item with expedited shipping
• Provide full refund including original shipping''',
          ),
          _buildSection(
            context,
            'Exchange Policy',
            '''Currently, we don't offer direct exchanges. To exchange an item:

1. Return the original item for refund
2. Place a new order for desired item

This ensures:
• Faster processing
• Better inventory accuracy
• Flexibility to choose different products''',
          ),
          _buildSection(
            context,
            'Refund Timeline',
            '''Expected refund timeline after return approval:

Wallet Credit: Instant
UPI/Net Banking: 3-5 business days
Debit Card: 5-7 business days
Credit Card: 7-10 business days
International Cards: 10-15 business days

If refund is delayed beyond expected timeline, contact support@craftconnect.com with:
• Order number
• Return tracking number
• Bank/card details (last 4 digits)''',
          ),
          _buildSection(
            context,
            'Cancellations',
            '''Before Shipment:
• Can be cancelled free of charge
• Full refund within 24-48 hours

After Shipment:
• Cannot be cancelled, must follow return process
• Contact seller for return approval

Seller Cancellations:
• If seller cancels, you receive full refund automatically
• Refund within 48 hours''',
          ),
          _buildSection(
            context,
            'Special Circumstances',
            '''Lost in Transit:
• File claim after expected delivery date + 5 days
• Full refund or replacement offered
• Investigation may take 7-10 days

Quality Issues:
• Open dispute within 7 days
• Provide evidence (photos, videos)
• CraftConnect mediates between buyer/seller
• Resolution within 10 business days

Bulk Orders:
• Different return policies may apply
• Check with seller before placing order
• Clearly stated on product page''',
          ),
          _buildSection(
            context,
            'Contact Us',
            '''For return and refund inquiries:

Email: returns@craftconnect.com
Phone: +91 1800-XXX-XXXX (Mon-Sat, 9 AM - 6 PM IST)
Support Ticket: Through Orders page > Need Help

Response time:
• Email: Within 24 hours
• Phone: Immediate during business hours
• Support Ticket: Within 12 hours''',
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
            Icons.autorenew,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Hassle-Free Returns',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '7-day return window on most items with simple process',
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
