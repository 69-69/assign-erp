import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/widgets/adaptive_layout.dart';
import 'package:assign_erp/core/widgets/async_progress_dialog.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/dynamic_table.dart';
import 'package:assign_erp/core/widgets/prompt_user_for_action.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/inventory_ims/data/models/orders/purchase_order_model.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/inventory_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/orders/purchase_order_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/orders/po/add/add_purchase_order.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/orders/po/update/update_purchase_order.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/widget/print_po.dart';
import 'package:assign_erp/features/setup/data/data_sources/remote/get_suppliers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// LIST APPROVED PURCHASE ORDERS
class ListApprovedPO extends StatefulWidget {
  const ListApprovedPO({super.key});

  @override
  State<ListApprovedPO> createState() => _ListApprovedPOState();
}

class _ListApprovedPOState extends State<ListApprovedPO> {
  // List to group PO for printout
  final List<PurchaseOrder> _groupOrdersForPrintout = [];

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  BlocBuilder<PurchaseOrderBloc, InventoryState<PurchaseOrder>> _buildBody() {
    return BlocBuilder<PurchaseOrderBloc, InventoryState<PurchaseOrder>>(
      builder: (context, state) {
        return switch (state) {
          LoadingInventories<PurchaseOrder>() => context.loader,
          InventoriesLoaded<PurchaseOrder>(data: var results) =>
            results.isEmpty
                ? context.buildAddButton(
                    'Create Purchase Order (PO)',
                    onPressed: () => context.openAddPurchaseOrders(),
                  )
                : _buildCard(context, results),
          InventoryError<PurchaseOrder>(error: final error) =>
            context.buildError(error),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  Widget _buildCard(BuildContext context, List<PurchaseOrder> orders) {
    // Filter for approved purchase orders
    List<PurchaseOrder> todayOrders = PurchaseOrder.filterApprovedPOs(orders);

    return DynamicDataTable(
      skip: true,
      toggleHideID: true,
      anyWidget: _buildAnyWidget(orders),
      headers: PurchaseOrder.dataTableHeader,
      rows: todayOrders.map((o) => o.itemAsList()).toList(),
      onChecked: (bool? isChecked, row) => _onChecked(orders, row, isChecked),
      onAllChecked:
          (
            bool isChecked,
            List<bool> isAllChecked,
            List<List<String>> checkedRows,
          ) {
            // if all are unChecked, empty _ordersForInvoice List
            if (!isAllChecked.first) {
              setState(() => _groupOrdersForPrintout.clear());
            }
          },
      optButtonLabel: 'Print',
      onOptButtonTap: (row) async => await _onPrintPOTap(orders, row),
      onEditTap: (row) async => await _onEditTap(orders, row),
      onDeleteTap: (row) async => await _onDeleteTap(orders, row),
    );
  }

  _buildAnyWidget(List<PurchaseOrder> orders) {
    return AdaptiveLayout(
      isFormBuilder: false,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        context.buildTotalItems(
          'Refresh Purchase Orders',
          label: 'Approvals',
          count: orders.length,
          // Dispatch an event to refresh data
          onPressed: () {
            // Refresh Purchase Orders Data
            context.read<PurchaseOrderBloc>().add(
              RefreshInventories<PurchaseOrder>(),
            );
          },
        ),
        // final orderBloc = context.read<OrdersBloc>();
        // final orderBloc = BlocProvider.of<OrdersBloc>(context, listen: false);
        const SizedBox(height: 20),
        _IssueMultiPOPrintout(
          orders: _groupOrdersForPrintout,
          onDone: (s) => setState(() => _groupOrdersForPrintout.clear()),
        ),
      ],
    );
  }

  /// Check if selected PO are related by PurchaseOrderNumber [_haveSamePONumber]
  /// @Return: return Pattern, i.e ({bool a, String b})
  ({bool status, String misMatchID}) _haveSamePONumber(
    List<PurchaseOrder> selectedOrders,
  ) {
    if (selectedOrders.isEmpty) {
      return (status: true, misMatchID: ''); // Handle empty list
    }

    String misMatchOrderNumber = '';
    final firstOrderNumber = selectedOrders.first.poNumber;

    var status = selectedOrders.every((order) {
      misMatchOrderNumber = order.poNumber;

      return order.poNumber == firstOrderNumber;
    });

    return (status: status, misMatchID: misMatchOrderNumber);
  }

  // Handle onChecked orders
  void _onChecked(
    List<PurchaseOrder> orders,
    List<String> row,
    bool? isChecked,
  ) async {
    setState(() {
      final order = orders.firstWhere((order) => order.id == row.first);

      if (isChecked != null && isChecked) {
        // A temporary list, tempOrdersForInvoice, is created which includes
        // the current orders in _ordersForInvoice and the new order to be checked.
        List<PurchaseOrder> tempOrdersForInvoice = List.from(
          _groupOrdersForPrintout,
        )..add(order);

        ({bool status, String misMatchID}) r = _haveSamePONumber(
          tempOrdersForInvoice,
        );

        if (r.status) {
          _groupOrdersForPrintout.add(order);
        } else {
          context.orderNumberMisMatchWarningDialog(r.misMatchID);
        }
      } else {
        _groupOrdersForPrintout.remove(order);
      }
    });
  }

  _onPrintPOTap(List<PurchaseOrder> orders, List<String> row) async {
    // Show progress dialog while loading data
    await context.progressBarDialog(
      request: _printout(orders, row),
      onSuccess: (_) =>
          context.showAlertOverlay('Printout successfully created'),
      onError: (error) =>
          context.showAlertOverlay('PO printout failed', bgColor: kDangerColor),
    );
  }

  Future<dynamic> _printout(List<PurchaseOrder> po, List<String> row) =>
      Future.delayed(kRProgressDelay, () async {
        // Simulate loading supplier and company info
        final orders = PurchaseOrder.findPurchaseOrderById(
          po,
          row.first,
        ).toList();
        final sup = await GetSuppliers.bySupplierId(orders.first.supplierId);
        if (orders.isNotEmpty && sup.isNotEmpty) {
          PrintPurchaseOrder(orders: orders, supplier: sup).onPrintPO();
        }
      });

  Future<void> _onEditTap(List<PurchaseOrder> orders, List<String> row) async {
    final po = PurchaseOrder.findPurchaseOrderById(orders, row.first).first;
    await context.openUpdatePurchaseOrder(po: po);
  }

  Future<void> _onDeleteTap(
    List<PurchaseOrder> orders,
    List<String> row,
  ) async {
    {
      final po = PurchaseOrder.findPurchaseOrderById(orders, row.first).first;

      final isConfirmed = await context.confirmUserActionDialog();
      if (mounted && isConfirmed) {
        /// Remove order from Orders-DB
        context.read<PurchaseOrderBloc>().add(
          DeleteInventory<String>(documentId: po.id),
        );
      }
    }
  }
}

/// Print grouped or multiple Purchase Orders [_IssueMultiPOPrintout]
class _IssueMultiPOPrintout extends StatelessWidget {
  final List<PurchaseOrder> orders;
  final Function(bool) onDone;

  const _IssueMultiPOPrintout({required this.orders, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return orders.isEmpty
        ? const SizedBox.shrink()
        : Center(child: _buildBody(context));
  }

  _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Wrap(
        spacing: 20,
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [
          _buildPrintButton(),
          _buildNote(),
          _buildDeleteButton(context),
        ],
      ),
    );
  }

  ElevatedButton _buildPrintButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: kWarningColor),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      onPressed: () async {
        final sup = await GetSuppliers.bySupplierId(orders.first.supplierId);

        // Perform action after loading
        PrintPurchaseOrder(orders: orders, supplier: sup).onPrintPO();
      },
      icon: const Icon(Icons.print, color: kWarningColor),
      label: const Text('Print PO', style: TextStyle(color: kWarningColor)),
    );
  }

  Future<bool> _confirmDeleteDialog(BuildContext context) async {
    return context.confirmAction(
      const Text('Are you sure you want to delete the selected orders?'),
      title: "Confirm Delete",
      onAccept: "Delete",
      onReject: "Cancel",
    );
  }

  ElevatedButton _buildDeleteButton(BuildContext context) {
    return ElevatedButton.icon(
      style: OutlinedButton.styleFrom(
        backgroundColor: context.colorScheme.error,
      ),
      icon: const Icon(Icons.delete, color: kLightColor),
      onPressed: () async {
        final isConfirmed = await _confirmDeleteDialog(context);
        if (context.mounted && isConfirmed) {
          final ids = orders.map((o) => o.id).toList();

          // Remove order from Orders-DB
          PurchaseOrderBloc(
            firestore: FirebaseFirestore.instance,
          ).add(DeleteInventory<List<String>>(documentId: ids));

          // Check if totalDeleted isEqual to total orders,
          // is so, then deletion completed
          onDone(true);

          /* int totalDeleted = 0;
            totalDeleted++;
            for (var order in orders) {}
            if (totalDeleted == orders.length) {
              onDone(true);
            }*/
        }
      },
      label: const Text('Delete', style: TextStyle(color: kLightColor)),
    );
  }

  Padding _buildNote() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: RichText(
        text: const TextSpan(
          text: 'NOTE: ',
          style: TextStyle(color: kDangerColor, fontWeight: FontWeight.bold),
          children: [
            TextSpan(
              text: 'Multiple or Grouped Orders Must Have Identical PO Numbers',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
