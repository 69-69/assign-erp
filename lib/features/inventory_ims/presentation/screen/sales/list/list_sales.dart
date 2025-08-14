import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/dialog/async_progress_dialog.dart';
import 'package:assign_erp/core/widgets/dialog/prompt_user_for_action.dart';
import 'package:assign_erp/core/widgets/layout/adaptive_layout.dart';
import 'package:assign_erp/core/widgets/layout/dynamic_table.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/inventory_ims/data/models/sale_model.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/inventory_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/sales/sale_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/sales/add/add_sale.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/sales/update/update_sale.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/widget/print_sales_report.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// All SALES
class ListSales extends StatefulWidget {
  const ListSales({super.key});

  @override
  State<ListSales> createState() => _ListSalesState();
}

class _ListSalesState extends State<ListSales> {
  // List to group orders for printout
  final List<Sale> _groupReportsForPrintout = [];

  // final SaleBloc saleBloc = BlocProvider.of<SaleBloc>(context);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SaleBloc(firestore: FirebaseFirestore.instance)
            ..add(GetInventories<Sale>()),
      child: _buildBody(),
    );
  }

  BlocBuilder<SaleBloc, InventoryState<Sale>> _buildBody() {
    return BlocBuilder<SaleBloc, InventoryState<Sale>>(
      builder: (context, state) {
        return switch (state) {
          LoadingInventory<Sale>() => context.loader,
          InventoriesLoaded<Sale>(data: var results) =>
            results.isEmpty
                ? context.buildAddButton(
                    'Add Sales',
                    onPressed: () => context.openAddSales(),
                  )
                : _buildCard(results),
          InventoryError<Sale>(error: final error) => context.buildError(error),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  Widget _buildCard(List<Sale> sales) {
    List<Sale> todaySales = Sale.filterSalesByDate(sales);
    List<Sale> pastSales = Sale.filterSalesByDate(sales, isSameDay: false);

    return DynamicDataTable(
      skip: true,
      showIDToggle: true,
      headers: Sale.dataTableHeader,
      anyWidget: _buildAnyWidget(sales),
      rows: todaySales.map((s) => s.itemAsList()).toList(),
      childrenRow: pastSales.map((s) => s.itemAsList()).toList(),
      onChecked: (bool? isChecked, row) => _onChecked(sales, row, isChecked),
      onAllChecked:
          (
            bool isChecked,
            List<bool> isAllChecked,
            List<List<String>> checkedRows,
          ) {
            // if all unChecked, empty _groupReportsForPrintout List
            if (!isAllChecked.first) {
              setState(() => _groupReportsForPrintout.clear());
            }
            if (checkedRows.isNotEmpty) {
              for (int i = 0; i < checkedRows.length; i++) {
                _onChecked(sales, checkedRows[i], isChecked);
              }
            }
          },
      optButtonLabel: 'Report',
      onOptButtonTap: (row) async => await _onReportTap(sales, row),
      onEditTap: (row) => _onEditTap(sales, row),
      onDeleteTap: (row) => _onDeleteTap(sales, row),
    );
  }

  _buildAnyWidget(List<Sale> sales) {
    return AdaptiveLayout(
      isFormBuilder: false,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        context.buildTotalItems(
          'Refresh Sales',
          label: 'Sales',
          count: sales.length,
          onPressed: () {
            // Refresh Sales Data
            context.read<SaleBloc>().add(RefreshInventories<Sale>());
          },
        ),
        // final orderBloc = context.read<OrdersBloc>();
        // final orderBloc = BlocProvider.of<OrdersBloc>(context, listen: false);
        const SizedBox(height: 20),
        _IssueMultiReportPrintout(
          sales: _groupReportsForPrintout,
          onDone: (s) => setState(() => _groupReportsForPrintout.clear()),
        ),
      ],
    );
  }

  // Handle onChecked orders
  void _onChecked(List<Sale> sales, List<String> row, bool? isChecked) async {
    setState(() {
      final sale = sales.firstWhere((order) => order.id == row.first);

      if (isChecked != null && isChecked) {
        List<Sale> tempSalesReport = List.from(_groupReportsForPrintout)
          ..add(sale);

        ({bool isIncomplete, String incompleteInvoiceNo}) r =
            _hasIncompleteSalesData(tempSalesReport);

        if (r.isIncomplete) {
          context.incompleteSalesDataWarningDialog(r.incompleteInvoiceNo);
        } else {
          _groupReportsForPrintout.add(sale);
        }
      } else {
        _groupReportsForPrintout.remove(sale);
      }
    });
  }

  /// Checks if there is any incomplete sales data within the given list of sales. [_hasIncompleteSalesData]
  ///
  /// This function evaluates a list of [Sale] objects to determine if any of them
  /// have incomplete data. It returns a tuple indicating whether there is incomplete
  /// data and, if so, the invoice number associated with the incomplete sale.
  ({bool isIncomplete, String incompleteInvoiceNo}) _hasIncompleteSalesData(
    List<Sale> selectedSales,
  ) {
    if (selectedSales.isEmpty) {
      return (isIncomplete: true, incompleteInvoiceNo: ''); // Handle empty list
    }

    String invoiceNumber = '';

    // Check if any sale has incomplete data
    var hasIncompleteData = selectedSales.any((sale) {
      invoiceNumber = sale.invoiceNumber;

      return !sale.isDataComplete();
    });

    return (
      isIncomplete: hasIncompleteData,
      incompleteInvoiceNo: invoiceNumber,
    );
  }

  _onReportTap(List<Sale> orders, List<String> row) async {
    // Show progress dialog while loading data
    await context.progressBarDialog(
      request: _printout(orders, row),
      onSuccess: (_) => context.showAlertOverlay('Report successfully created'),
      onError: (error) => context.showAlertOverlay(
        'Report printout failed: $error',
        bgColor: kDangerColor,
      ),
    );
  }

  Future<dynamic> _printout(List<Sale> sales, List<String> row) =>
      Future.delayed(kRProgressDelay, () async {
        // Simulate loading supplier and company info
        final getSales = Sale.findSaleById(sales, saleId: row.first).toList();

        if (mounted && getSales.isNotEmpty) {
          PrintSalesReport(
            sales: getSales,
            createdBy: context.employee!.createdBy,
            storeNumber: context.employee!.storeNumber,
          ).onPrint(title: 'Sales Reports');
        }
      });

  Future<void> _onEditTap(List<Sale> sales, List<String> row) async {
    {
      final sale = Sale.findSaleById(sales, saleId: row.first).first;

      return context.openUpdateSale(sale: sale);
    }
  }

  Future<void> _onDeleteTap(List<Sale> sales, List<String> row) async {
    {
      final sale = Sale.findSaleById(sales, saleId: row.first).first;

      final isConfirmed = await context.confirmUserActionDialog();
      if (mounted && isConfirmed) {
        /// Remove sale from Sales-list
        context.read<SaleBloc>().add(
          DeleteInventory<String>(documentId: sale.id),
        );
      }
    }
  }

  // Function to map Sale object to its respective row data
  /*List mapSalesToRows(List<Sale> salesList) {
     return salesList.map((Sale s) async {
      final product = await GetProducts.byProductId(s.productId);
      final f = GetProducts.byProductId(s.productId).asStream().map<double>((s)=>s.costPrice);

      // Calculate profit for each sale item
      final profit = s.calculateProfit(product.costPrice);
      // Create a list representing the sale item with profit appended
      List<dynamic> r = s.itemAsList();
      r.add(profit.toString());

      r= rowData;
    }).toList();
  }*/
}

/// Print grouped or multiple Sales Report [_IssueMultiInvoicePrintout]
class _IssueMultiReportPrintout extends StatelessWidget {
  final List<Sale> sales;
  final Function(bool) onDone;

  const _IssueMultiReportPrintout({required this.sales, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return sales.isEmpty
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
          _buildPrintButton(context),
          _buildNote(),
          _buildDeleteButton(context),
        ],
      ),
    );
  }

  ElevatedButton _buildPrintButton(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: kWarningColor),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      onPressed: () async {
        PrintSalesReport(
          sales: sales,
          createdBy: context.employee!.createdBy,
          storeNumber: context.employee!.storeNumber,
        ).onPrint(title: 'Sales Reports');
      },
      icon: const Icon(Icons.print, color: kWarningColor),
      label: const Text('Report', style: TextStyle(color: kWarningColor)),
    );
  }

  Future<bool> _confirmDeleteDialog(BuildContext context) async {
    return context.confirmAction<bool>(
      const Text('Are you sure you want to delete the selected sales?'),
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
          final ids = sales.map((s) => s.id).toList();

          // Remove sales from Sales-DB
          SaleBloc(
            firestore: FirebaseFirestore.instance,
          ).add(DeleteInventory<List<String>>(documentId: ids));

          // Check if totalDeleted isEqual to total orders,
          // is so, then deletion completed
          onDone(true);

          /* int totalDeleted = 0;
            totalDeleted++;
            for (var sale in sales) {}
            if (totalDeleted == sales.length) {
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
              text: 'Sales Reports will be organized by date on the printout.',
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
