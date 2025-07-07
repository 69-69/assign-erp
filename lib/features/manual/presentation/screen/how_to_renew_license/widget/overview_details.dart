import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/network/data_sources/models/subscription_licenses_enum.dart';
import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/text_to_speech.dart';
import 'package:assign_erp/features/manual/data/models/subscription_model.dart';
import 'package:flutter/material.dart';

final Map<SubscriptionLicenses, SubscriptionDetail> subscriptionDetails = {
  SubscriptionLicenses.pos: SubscriptionDetail.fromMap('pos', {
    'description': [
      'POS Subscription: Ideal for businesses needing full point-of-sale functionality.',
    ],
    'features': {
      '• Orders': 'Product scanning, searching, and sales transactions.',
      '• Reports': 'Sales performance analytics and reporting tools.',
      '• Payment': 'Payment processing options integrated into POS.',
      '• Receipt': 'Automatic generation of receipts for transactions.',
      '• Finance': 'Manage and track financial data related to POS.',
    },
  }),
  SubscriptionLicenses.warehouse: SubscriptionDetail.fromMap('warehouse', {
    'description': [
      'Warehouse Subscription: Designed for managing warehouse operations and logistics.',
    ],
    'features': {
      'Stocks': '• Real-time tracking of stock levels.',
      'Supplies': '• Managing and tracking supply and inventory levels.',
      'Deliveries': '• Manage and track deliveries and logistics.',
    },
  }),
  SubscriptionLicenses.full: SubscriptionDetail.fromMap('full', {
    'description': [
      'Full Subscription: Provides complete access to all ERP system features.',
    ],
    'features': {
      'Suite': '• Full access to POS, Warehouse, Inventory, CRM, Reports, etc.',
      'Manage': '• Comprehensive control over orders, stocks, and deliveries.',
      'Advance': '• Advanced reporting and performance tracking tools.',
    },
  }),
  SubscriptionLicenses.agent: SubscriptionDetail.fromMap('agent', {
    'description': [
      'Agent Subscription: Meant for agents or franchises managing subscriber accounts.',
    ],
    'features': {
      'Workspace Account Setup':
          'Create and manage workspace accounts for subscribers.',
      'Basic':
          '• Limited access to full ERP features, mainly for setup and basic management.',
      'Agent Access':
          '• Allows agents to create subscriber accounts and manage permissions.',
    },
  }),
  SubscriptionLicenses.inventory: SubscriptionDetail.fromMap('inventory', {
    'description': [
      'Inventory Subscription: For businesses managing stock, orders, and inventory levels.',
    ],
    'features': {
      '• Orders': 'Manage and track orders (pending, shipped, completed).',
      '• Purchases': 'Handle purchase orders (POs) and approved POs.',
      '• Miscellaneous Orders':
          'Manage miscellaneous orders and their approvals.',
      '• RFQ': 'Create and approve requests for quotations (RFQ).',
      '• Deliveries': 'Track and manage deliveries.',
      '• Sales': 'Track payments (installments, cheques, credits).',
      '• Reports': 'Detailed reports for inventory, purchases, sales, etc.',
    },
  }),
  SubscriptionLicenses.setup: SubscriptionDetail.fromMap('setup', {
    'description': [
      'Setup Subscription: Primarily for developers and system administrators to set up workspace accounts.',
    ],
    'features': {
      'Account': '• Setup workspace accounts for agents and franchises.',
      'Access Control': '• Configure initial account settings and permissions.',
      'Restrictions':
          '• Limited access for setup and onboarding purposes only.',
    },
  }),
  SubscriptionLicenses.crm: SubscriptionDetail.fromMap('crm', {
    'description': [
      'CRM Subscription: For managing customer relationships and account information.',
    ],
    'features': {
      '• Account Management': 'Manage customer profiles and details.',
      '• Activities': 'Track and manage customer interactions and activities.',
      '• Statement of Account':
          'Generate and view customer account statements.',
    },
  }),
  SubscriptionLicenses.dev: SubscriptionDetail.fromMap('dev', {
    'description': [
      'Developer Subscription: Designed for system maintenance and software development.',
    ],
    'features': {
      '• Software Maintenance': 'Tools for system updates and bug fixes.',
      '• Troubleshooting': 'Address technical issues and system bugs.',
      '• Development Tools':
          'Full access to system development tools for backend maintenance.',
    },
  }),
};

class OverviewDetails extends StatelessWidget {
  final String subscriptionName;

  const OverviewDetails({super.key, required this.subscriptionName});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      subTitle: '$subscriptionName License Subscription ⏺',
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Features of $subscriptionName Subscription',
                style: context.ofTheme.textTheme.titleLarge?.copyWith(
                  color: kDarkTextColor,
                  fontWeight: FontWeight.w500,
                ),
                // textScaler: TextScaler.linear(context.textScaleFactor),
              ),
              SizedBox(height: 10),
              buildDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDetails() {
    final subscription =
        subscriptionDetails[getLicenseByString(subscriptionName.toLowerCase())];

    if (subscription != null) {
      final description = subscription.description;
      final features = subscription.features.map(
        (key, value) => MapEntry(key, value.description),
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Render description
          ...description.map((text) => Text(text)),
          SizedBox(height: 10),
          TextToSpeech(
            title: 'Include',
            subTitle: 'Details of features',
            guides: features, // Passing features directly as a list of strings
          ),
        ],
      );
    } else {
      return Text('No details available');
    }
  }
}
