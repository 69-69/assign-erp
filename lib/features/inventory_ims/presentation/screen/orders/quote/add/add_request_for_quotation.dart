import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/util/generate_new_uid.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/async_progress_dialog.dart';
import 'package:assign_erp/core/widgets/custom_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/core/widgets/custom_scroll_bar.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/prompt_user_for_action.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/core/widgets/top_header_bottom_sheet.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/inventory_ims/data/models/orders/request_price_quotation_model.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/inventory_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/orders/request_price_quotation_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/orders/quote/widget/form_inputs.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/widget/print_request_for_quote.dart';
import 'package:assign_erp/features/setup/data/data_sources/remote/get_suppliers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension AddOrderRequestForQuoteForm on BuildContext {
  Future<void> openAddRequestForQuotation({Widget? header}) => openBottomSheet(
    isExpand: false,
    child: _AddRequestForQuotation(header: header),
  );
}

class _AddRequestForQuotation extends StatelessWidget {
  final Widget? header;

  const _AddRequestForQuotation({this.header});

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      padding: EdgeInsets.only(bottom: context.bottomInsetPadding),
      initialChildSize: 0.90,
      maxChildSize: 0.90,
      header: _buildHeader(context),
      child: _buildBody(context),
    );
  }

  TopHeaderRow _buildHeader(BuildContext context) {
    return TopHeaderRow(
      title: Text(
        'Request For Quotation'.toUppercaseFirstLetterEach,
        semanticsLabel: 'Request For Quotation',
        style: context.ofTheme.textTheme.titleLarge?.copyWith(
          color: kGrayColor,
        ),
      ),
      btnText: 'Close',
      onPress: () => Navigator.pop(context),
    );
  }

  _buildBody(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
      child: _AddRequestForQuotationBody(),
    );
  }
}

class _AddRequestForQuotationBody extends StatefulWidget {
  const _AddRequestForQuotationBody();

  @override
  State<_AddRequestForQuotationBody> createState() =>
      _AddRequestForQuotationBodyState();
}

class _AddRequestForQuotationBodyState
    extends State<_AddRequestForQuotationBody> {
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  bool isMultipleQuotes = false;
  final List<RequestForQuotation> _quotes = [];

  String _newRFQNumber = '';
  String _selectedSupplierId = '';
  String? _selectedRFQStatus;
  DateTime? _selectedDeadlineDate;
  DateTime? _selectedDeliveryDate;

  final _productDescController = TextEditingController();
  final _quantityController = TextEditingController();
  final _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateRFQNumber();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _productDescController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _generateRFQNumber() async {
    await 'rfq'.getShortUID(
      onChanged: (s) => setState(() => _newRFQNumber = s),
    );
  }

  RequestForQuotation get _quoteData => RequestForQuotation(
    rfqNumber: _newRFQNumber,
    status: _selectedRFQStatus ?? '',
    supplierId: _selectedSupplierId,
    productName: _productDescController.text,
    quantity: int.tryParse(_quantityController.text) ?? 0,
    deadline: _selectedDeadlineDate,
    deliveryDate: _selectedDeliveryDate,
    remarks: _remarksController.text,
    storeNumber: context.employee!.storeNumber,
    createdBy: context.employee!.fullName,
  );

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      /// Added Multiple Request for Price Quotation Simultaneously
      _quotes.add(_quoteData);

      context.read<RequestForQuotationBloc>().add(
        AddInventory<List<RequestForQuotation>>(data: _quotes),
      );

      _formKey.currentState!.reset();

      _clearFields();
      isMultipleQuotes = false;

      _confirmPrintoutDialog();
    }
  }

  /// Function for Adding Multiple Request for Price Quotation Simultaneously
  void _addQuoteToList() {
    if (_formKey.currentState!.validate()) {
      setState(() => isMultipleQuotes = true);
      _quotes.add(_quoteData);
      context.showAlertOverlay('Request added to list');
      _clearFields();
    }
  }

  void _clearFields() {
    _quantityController.clear();
    _productDescController.clear();
    _quantityController.clear();
  }

  void _removeOrder(RequestForQuotation quote) {
    setState(() => _quotes.remove(quote));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Wrap(
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: [
          if (isMultipleQuotes && _quotes.isNotEmpty) _buildRFQPreviewChips(),
          _buildBody(),
        ],
      ),
    );
  }

  // Horizontal scrollable row of chips representing the List of batch of Request For Quotation
  Widget _buildRFQPreviewChips() {
    return CustomScrollBar(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _quotes.map((o) {
          return o.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Chip(
                    padding: EdgeInsets.zero,
                    label: Text(
                      '${o.productName} x ${o.quantity}'
                          .toUppercaseFirstLetterEach,
                      style: context.ofTheme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    deleteButtonTooltipMessage: 'Remove ${o.productName}',
                    backgroundColor: kGrayColor.withAlpha((0.3 * 255).toInt()),
                    deleteIcon: const Icon(
                      size: 16,
                      Icons.clear,
                      color: kGrayColor,
                    ),
                    onDeleted: () => _removeOrder(o),
                  ),
                );
        }).toList(),
      ),
    );
  }

  Column _buildBody() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'RFQ Number:\n',
                style: context.ofTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: _newRFQNumber,
                    style: context.ofTheme.textTheme.titleLarge?.copyWith(
                      color: kDangerColor,
                    ),
                  ),
                ],
              ),
            ),
            FittedBox(
              child: context.buildRefreshButton(
                'Refresh RFQ Number',
                onPressed: _generateRFQNumber,
              ),
            ),
          ],
        ),
        const SizedBox(width: 10.0),
        SupplierIDInput(
          onChanged: (id, name) => setState(() => _selectedSupplierId = id),
        ),
        const SizedBox(height: 20.0),
        ProductDescTextField(
          controller: _productDescController,
          onChanged: (t) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
        ),
        const SizedBox(height: 20.0),
        QuantityAndRFQStatusDropdown(
          quantityController: _quantityController,
          onQuantityChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
          onStatusChanged: (s) => setState(() => _selectedRFQStatus = s),
        ),
        const SizedBox(height: 20.0),
        DeadlineAndDeliveryDateInput(
          labelDelivery: "Delivery date",
          labelDeadline: "Deadline date",
          onDeliveryChanged: (date) =>
              setState(() => _selectedDeliveryDate = date),
          onDeadlineChanged: (date) =>
              setState(() => _selectedDeadlineDate = date),
        ),
        const SizedBox(height: 20.0),
        RemarksTextField(
          controller: _remarksController,
          onChanged: (t) => setState(() {}),
        ),
        const SizedBox(height: 20.0),
        context.elevatedIconBtn(
          Icons.add,
          onPressed: _addQuoteToList,
          label: 'Add to List',
        ),
        const SizedBox(height: 20.0),
        context.elevatedBtn(
          label: isMultipleQuotes ? 'Create All Quotes' : 'Create Quote',
          onPressed: _onSubmit,
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }

  Future<void> _confirmPrintoutDialog() async {
    final isConfirmed = await context.confirmAction(
      const Text('Would you like to print the purchase order: PO?'),
      title: "Print Purchase Order",
      onAccept: "Print",
      onReject: "Cancel",
    );

    if (mounted && isConfirmed) {
      // Show progress dialog while loading data
      await context.progressBarDialog(
        request: _printout(),
        onSuccess: (_) => context.showAlertOverlay('PO successfully created'),
        onError: (error) => context.showAlertOverlay(
          'PO printout failed',
          bgColor: kDangerColor,
        ),
      );
    }
  }

  Future<dynamic> _printout() => Future.delayed(wAnimateDuration, () async {
    // Simulate loading supplier and company info
    final sup = await GetSuppliers.bySupplierId(_quotes.first.supplierId);
    if (sup.isNotEmpty) {
      // Perform action after loading
      PrintRequestForQuotation(quotes: _quotes, supplier: sup).onPrintRFQ();
    }
  });
}
