import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/nav/custom_tab.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/inventory_ims/data/models/orders/order_model.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/inventory_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/orders/order_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/finance/add/add_finance.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/finance/list/list_finance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrderBloc>(
      create: (context) =>
          OrderBloc(firestore: FirebaseFirestore.instance)
            ..add(GetInventories<Orders>()),
      child: CustomScaffold(
        title: salesOrderScreenTitle.toUpperCaseAll,
        body: _buildBody(),
        floatingActionButton: context.buildFloatingBtn(
          'Place an Order',
          onPressed: () => context.openAddFinance(),
        ),
      ),
    );
  }

  CustomTab _buildBody() {
    return const CustomTab(
      length: 4,
      tabs: [
        {'label': 'Orders', 'icon': Icons.shopping_cart},
        {'label': 'Pending', 'icon': Icons.pending},
        {
          'label': 'Shipped or Dispatched',
          'icon': Icons.local_shipping_outlined,
        },
        {'label': 'Completed', 'icon': Icons.done_all},
      ],
      children: [
        ListFinance(),
        Center(child: Text('Pending')),
        Center(child: Text('Shipped or Dispatched')),
        Center(child: Text('Completed')),
      ],
    );
  }
}
