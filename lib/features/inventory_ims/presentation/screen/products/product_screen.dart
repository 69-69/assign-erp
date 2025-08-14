import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/layout/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/nav/custom_tab.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/inventory_ims/data/models/product_model.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/inventory_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/product/product_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/products/add/add_product.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/products/list_stocks/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  // String _barcodeValue = '';

  // bool isScanCompleted = false;
  ProductBloc _initializeProductBloc(BuildContext context) {
    final productBloc = ProductBloc(firestore: FirebaseFirestore.instance);
    productBloc.add(GetInventories<Product>());
    return productBloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductBloc>(
      create: _initializeProductBloc,
      child: CustomScaffold(
        title: stocksScreenTitle.toUpperCaseAll,
        body: _buildBody(),
        floatingActionButton: context.buildFloatingBtn(
          'Create Stock',
          onPressed: () => context.openAddProduct(),
        ),
      ),
    );
  }

  _buildBody() {
    return const CustomTab(
      length: 4,
      tabs: [
        {'label': 'Products', 'icon': Icons.line_style},
        {'label': 'Expired', 'icon': Icons.date_range},
        {'label': 'Stock Level', 'icon': Icons.dashboard_customize_outlined},
        {'label': 'Out-Stock', 'icon': Icons.space_dashboard_outlined},
      ],
      children: [
        ListProducts(),
        ListExpired(),
        ListStockLevel(),
        Center(
          child: Text(
            'Replace Out-Stock with "(Sales): Update Historical sales data for forecasting"',
          ),
        ),
      ],
    );
  }

  /*BarcodeScanner _buildBarcodeScanner() {
    return BarcodeScanner(
      childWidget: (void Function()? scanFunction, List<Barcode> barcodes) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (mounted && barcodes.isNotEmpty) {
            setState(() => _barcodeValue = barcodes.first.displayValue);
          }
        });
        return FloatingActionButton(
          onPressed: scanFunction,
          tooltip: 'Scan Product',
          child: const Icon(Icons.qr_code_scanner),
        );
      },
    );
  }*/
}
