import 'package:flutter/material.dart';
import 'package:assign_erp/features/inventory_ims/data/models/orders/misc_order_model.dart';

/// LIST Miscellaneous ORDERS
class ListMiscellaneousOrders extends StatefulWidget {
  const ListMiscellaneousOrders({super.key});

  @override
  State<ListMiscellaneousOrders> createState() => _ListMiscellaneousOrdersState();
}

class _ListMiscellaneousOrdersState extends State<ListMiscellaneousOrders> {
  // List to group orders for printout
  final List<MiscOrder> _ordersForInvoice = [];

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('List Miscellaneous orders $_ordersForInvoice'));
  }
}

