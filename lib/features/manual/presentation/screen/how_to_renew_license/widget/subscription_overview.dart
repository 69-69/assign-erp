import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/network/data_sources/models/workspace_model.dart';
import 'package:assign_erp/core/util/column_row_builder.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/manual/data/models/subscription_model.dart';
import 'package:assign_erp/features/manual/presentation/screen/how_to_renew_license/widget/overview_details.dart';
import 'package:flutter/material.dart';

final List<Map<String, String>> subs = [
  {'title': 'POS', 'description': 'Orders, Sales, Payment, Finance'},
  {'title': 'Warehouse', 'description': 'Stocks, Supplies, Deliveries'},
  {'title': 'Full', 'description': 'Complete ERP access'},
  {'title': 'Agent', 'description': 'Account creation and management'},
  {'title': 'Inventory', 'description': 'Order, Stock, Purchases, Sales'},
  {'title': 'Setup', 'description': 'Workspace account setup'},
  {'title': 'CRM', 'description': 'Customer Relationship Management'},
  {'title': 'Dev', 'description': 'System maintenance and development'},
];

final String _overview =
    'This document provides a comprehensive overview of the different subscription licenses available in the ERP software, developed in Flutter. '
    'Each subscription tier is designed to cater to specific business needs, ensuring that your enterprise is equipped with the appropriate tools for efficient operations. '
    'The manual also outlines onboarding processes and additional features included in all licenses.';

class SubscriptionOverview extends StatelessWidget {
  final Workspace? myAgent;
  const SubscriptionOverview({super.key, this.myAgent});

  @override
  Widget build(BuildContext context) {
    final subscriptions = subs.map((sub) => Feature.fromMap(sub)).toList();
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _overview,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          ),
          SizedBox(height: 20),
          Text(
            'Subscription Licenses Overview',
            style: context.ofTheme.textTheme.titleMedium?.copyWith(
              color: kDarkTextColor,
            ),
            textScaler: TextScaler.linear(context.textScaleFactor),
          ),
          SizedBox(height: 10),
          // Subscription List
          Expanded(
            child: context.columnBuilder(
              itemCount: subscriptions.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 7.0,
                  child: ListTile(
                    title: Text(
                      '${subscriptions[index].title} License',
                      style: context.ofTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(subscriptions[index].description),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OverviewDetails(
                            subscriptionName: subscriptions[index].title,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          if (myAgent != null) ...[
            GenericCard(
              headTitle: 'License Agent Contact',
              title: myAgent!.clientName,
              subTitle: 'Your License Agent',
              extra: [
                {'title': 'Mobile', 'value': myAgent!.mobileNumber},
                {'title': 'Email', 'value': myAgent!.email},
              ],
            ),
          ],
        ],
      ),
    );
  }
}
