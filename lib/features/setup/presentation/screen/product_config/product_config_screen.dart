import 'package:assign_erp/core/widgets/custom_tab.dart';
import 'package:assign_erp/features/setup/presentation/screen/product_config/index.dart';
import 'package:flutter/material.dart';

class ProductConfigScreen extends StatelessWidget {
  const ProductConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  CustomTab _buildBody() {
    return const CustomTab(
      length: 2,
      isColoredTab: false,
      indicatorWeight: 1.0,
      tabs: [
        {'label': 'Product Suppliers', 'icon': Icons.select_all},
        {'label': 'Product Category', 'icon': Icons.category_outlined},
      ],
      children: [ListSuppliers(), ListCategories()],
    );
  }
}
