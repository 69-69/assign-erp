import 'package:assign_erp/core/widgets/nav/custom_tab.dart';
import 'package:assign_erp/features/setup/presentation/screen/company/index.dart';
import 'package:flutter/material.dart';

class CompanyScreen extends StatelessWidget {
  const CompanyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  CustomTab _buildBody() {
    return const CustomTab(
      length: 3,
      isColoredTab: false,
      indicatorWeight: 1.0,
      tabs: [
        {'label': 'company', 'icon': Icons.home_work},
        {'label': 'add stores', 'icon': Icons.store},
        {'label': 'PDFs / Print Setup', 'icon': Icons.print},
      ],
      children: [ListCompanyInfo(), ListCompanyStores(), PrintoutSetup()],
    );
  }
}
