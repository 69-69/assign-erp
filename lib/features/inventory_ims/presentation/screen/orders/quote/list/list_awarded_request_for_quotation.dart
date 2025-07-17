import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/widgets/adaptive_layout.dart';
import 'package:assign_erp/core/widgets/async_progress_dialog.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/dynamic_table.dart';
import 'package:assign_erp/core/widgets/prompt_user_for_action.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/inventory_ims/data/models/orders/request_price_quotation_model.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/inventory_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/orders/request_price_quotation_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/orders/quote/add/add_request_for_quotation.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/orders/quote/update/update_request_for_quotation.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/widget/print_request_for_quote.dart';
import 'package:assign_erp/features/setup/data/data_sources/remote/get_suppliers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// LIST Request For Price Quotations
class ListAwardedRequestForQuotation extends StatefulWidget {
  const ListAwardedRequestForQuotation({super.key});

  @override
  State<ListAwardedRequestForQuotation> createState() =>
      _ListAwardedRequestForQuotationState();
}

class _ListAwardedRequestForQuotationState
    extends State<ListAwardedRequestForQuotation> {
  // List to group quotations for printout
  final List<RequestForQuotation> _printouts = [];

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  BlocBuilder<RequestForQuotationBloc, InventoryState<RequestForQuotation>>
  _buildBody() {
    return BlocBuilder<
      RequestForQuotationBloc,
      InventoryState<RequestForQuotation>
    >(
      builder: (context, state) {
        return switch (state) {
          LoadingInventories<RequestForQuotation>() => context.loader,
          InventoriesLoaded<RequestForQuotation>(data: var results) =>
            results.isEmpty
                ? context.buildAddButton(
                    'Request For Quotation',
                    onPressed: () => context.openAddRequestForQuotation(),
                  )
                : _buildCard(context, results),
          InventoryError<RequestForQuotation>(error: final error) =>
            context.buildError(error),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  Widget _buildCard(BuildContext context, List<RequestForQuotation> quotes) {
    // Filter for Awarded Quotations
    final todayQuotations = RequestForQuotation.filterAwardedRFQ(quotes);

    return DynamicDataTable(
      skip: true,
      toggleHideID: true,
      anyWidget: _buildAnyWidget(quotes),
      headers: RequestForQuotation.dataTableHeader,
      rows: todayQuotations.map((o) => o.itemAsList()).toList(),
      onChecked: (bool? isChecked, row) => _onChecked(quotes, row, isChecked),
      onAllChecked:
          (
            bool isChecked,
            List<bool> isAllChecked,
            List<List<String>> checkedRows,
          ) {
            // if all are unChecked, empty _printouts List
            if (!isAllChecked.first) {
              setState(() => _printouts.clear());
            }
            if (checkedRows.isNotEmpty) {
              for (int i = 0; i < checkedRows.length; i++) {
                _onChecked(quotes, checkedRows[i], isChecked);
              }
            }
          },
      optButtonLabel: 'Print',
      onOptButtonTap: (row) async => await _onPrintPOTap(quotes, row),
      onEditTap: (row) async => await _onEditTap(quotes, row),
      onDeleteTap: (row) async => await _onDeleteTap(quotes, row),
    );
  }

  _buildAnyWidget(List<RequestForQuotation> quotes) {
    return AdaptiveLayout(
      isFormBuilder: false,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        context.buildTotalItems(
          'Refresh Awarded Quotation',
          label: 'Awarded',
          count: quotes.length,
          // Dispatch an event to refresh data
          onPressed: () {
            // Refresh Request For Quotation Data
            context.read<RequestForQuotationBloc>().add(
              RefreshInventories<RequestForQuotation>(),
            );
          },
        ),
        // final quoteBloc = context.read<RequestPriceQuotationBloc>();
        // final quoteBloc = BlocProvider.of<RequestPriceQuotationBloc>(context, listen: false);
        const SizedBox(height: 20),
        _IssueMultiQuotesPrintout(
          quotes: _printouts,
          onDone: (s) => setState(() => _printouts.clear()),
        ),
      ],
    );
  }

  /// Check if selected Quotes are related by RFQNumber [_haveSameRFQNumber]
  /// @Return: return Pattern, i.e ({bool a, String b})
  ({bool status, String misMatchID}) _haveSameRFQNumber(
    List<RequestForQuotation> selectedQuotes,
  ) {
    if (selectedQuotes.isEmpty) {
      return (status: true, misMatchID: ''); // Handle empty list
    }

    String misMatchRFQNumber = '';
    final firstRFQNumber = selectedQuotes.first.rfqNumber;

    var status = selectedQuotes.every((quote) {
      misMatchRFQNumber = quote.rfqNumber;

      return quote.rfqNumber == firstRFQNumber;
    });

    return (status: status, misMatchID: misMatchRFQNumber);
  }

  // Handle onChecked Quotations
  void _onChecked(
    List<RequestForQuotation> quotes,
    List<String> row,
    bool? isChecked,
  ) async {
    setState(() {
      final quote = quotes.firstWhere((q) => q.id == row.first);

      if (isChecked != null && isChecked) {
        // A temporary list, tempQuotesForPrintout, is created which includes
        // the current quotation in _printouts and the new quotation to be checked.
        List<RequestForQuotation> tempQuotesForPrintout = List.from(_printouts)
          ..add(quote);

        ({bool status, String misMatchID}) r = _haveSameRFQNumber(
          tempQuotesForPrintout,
        );

        if (r.status) {
          _printouts.add(quote);
        } else {
          context.orderNumberMisMatchWarningDialog(r.misMatchID);
        }
      } else {
        _printouts.remove(quote);
      }
    });
  }

  _onPrintPOTap(List<RequestForQuotation> quotes, List<String> row) async {
    // Show progress dialog while loading data
    await context.progressBarDialog(
      request: _printout(quotes, row),
      onSuccess: (_) =>
          context.showAlertOverlay('Printout successfully created'),
      onError: (error) => context.showAlertOverlay(
        'RFQ printout failed',
        bgColor: kDangerColor,
      ),
    );
  }

  Future<dynamic> _printout(List<RequestForQuotation> rfq, List<String> row) =>
      Future.delayed(wAnimateDuration, () async {
        // Simulate loading supplier and company info
        final quotes = RequestForQuotation.findRequestForQuotationById(
          rfq,
          row.first,
        ).toList();
        final sup = await GetSuppliers.bySupplierId(quotes.first.supplierId);

        if (quotes.isNotEmpty && sup.isNotEmpty) {
          // Perform action after loading
          PrintRequestForQuotation(quotes: quotes, supplier: sup).onPrintRFQ();
        }
      });

  Future<void> _onEditTap(
    List<RequestForQuotation> quotes,
    List<String> row,
  ) async {
    final quote = RequestForQuotation.findRequestForQuotationById(
      quotes,
      row.first,
    ).first;
    await context.openUpdateRequestForQuotation(quote: quote);
  }

  Future<void> _onDeleteTap(
    List<RequestForQuotation> quotes,
    List<String> row,
  ) async {
    {
      final rfq = RequestForQuotation.findRequestForQuotationById(
        quotes,
        row.first,
      ).first;

      final isConfirmed = await context.confirmUserActionDialog();
      if (mounted && isConfirmed) {
        /// Remove Quotation from Quote-DB
        context.read<RequestForQuotationBloc>().add(
          DeleteInventory<String>(documentId: rfq.id),
        );
      }
    }
  }
}

/// Print grouped or multiple Purchase Quotes [_IssueMultiQuotesPrintout]
class _IssueMultiQuotesPrintout extends StatelessWidget {
  final List<RequestForQuotation> quotes;
  final Function(bool) onDone;

  const _IssueMultiQuotesPrintout({required this.quotes, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return quotes.isEmpty
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
        final sup = await GetSuppliers.bySupplierId(quotes.first.supplierId);

        // Perform action after loading
        PrintRequestForQuotation(quotes: quotes, supplier: sup).onPrintRFQ();
      },
      icon: const Icon(Icons.print, color: kWarningColor),
      label: const Text('Print', style: TextStyle(color: kWarningColor)),
    );
  }

  Future<bool> _confirmDeleteDialog(BuildContext context) async {
    return context.confirmAction(
      const Text('Are you sure you want to delete the selected Quote?'),
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
          final ids = quotes.map((q) => q.id).toList();

          // Remove quotes from quotes-DB
          RequestForQuotationBloc(
            firestore: FirebaseFirestore.instance,
          ).add(DeleteInventory<List<String>>(documentId: ids));

          // Check if totalDeleted isEqual to total quotes,
          // is so, then deletion completed
          onDone(true);

          /* int totalDeleted = 0;
            totalDeleted++;
            for (var quote in quotes) {}
            if (totalDeleted == quote.length) {
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
              text:
                  'Multiple or Grouped Quotations Must Have Identical RFQ Numbers',
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
