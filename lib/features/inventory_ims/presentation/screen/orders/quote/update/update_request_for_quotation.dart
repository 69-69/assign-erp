import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/calculate_extras.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/button/custom_button.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/dialog/custom_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/dialog/form_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/inventory_ims/data/models/orders/request_for_quotation_model.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/inventory_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/orders/request_price_quotation_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/orders/quote/widget/form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension UpdateRequestForQuotationForm on BuildContext {
  Future openUpdateRequestForQuotation({required RequestForQuotation quote}) =>
      openBottomSheet(
        isExpand: false,
        child: FormBottomSheet(
          title: 'Edit Request For Quote',
          subtitle: quote.rfqNumber.toUpperCaseAll,
          body: _UpdateRequestForQuote(quote: quote),
        ),
      );
}

class _UpdateRequestForQuote extends StatefulWidget {
  final RequestForQuotation quote;

  const _UpdateRequestForQuote({required this.quote});

  @override
  State<_UpdateRequestForQuote> createState() => _UpdateRequestForQuoteState();
}

class _UpdateRequestForQuoteState extends State<_UpdateRequestForQuote> {
  RequestForQuotation get _quote => widget.quote;

  String _subTotal = '';
  String? _selectedSupplierId;
  String? _selectedRFQStatus;
  DateTime? _selectedDeliveryDate;
  DateTime? _selectedDeadlineDate;
  double _discountAmount = 0.0;
  double _taxAmount = 0.0;

  final _formKey = GlobalKey<FormState>();

  late final _productDescController = TextEditingController(
    text: _quote.productName,
  );
  late final _quantityController = TextEditingController(
    text: '${_quote.quantity}',
  );
  late final _unitPriceController = TextEditingController(
    text: '${_quote.unitPrice}',
  );
  late final _netPriceController = TextEditingController(
    text: '${_quote.netPrice}',
  );
  late final _remarksController = TextEditingController(text: _quote.remarks);
  late final _discountPercentController = TextEditingController(
    text: '${_quote.discountPercent}',
  );
  late final _taxPercentController = TextEditingController(
    text: '${_quote.taxPercent}',
  );

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_calculateSubTotal);
    _unitPriceController.addListener(_calculateSubTotal);
    _discountPercentController.addListener(_calculateDiscountAmt);
    _taxPercentController.addListener(_calculateTaxAmt);
    _calculateTaxAmt();
    _calculateTotalAmount();
  }

  @override
  void dispose() {
    _quantityController.removeListener(_calculateSubTotal);
    _unitPriceController.removeListener(_calculateSubTotal);
    _discountPercentController.removeListener(_calculateDiscountAmt);
    _taxPercentController.removeListener(_calculateTaxAmt);

    _productDescController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _remarksController.dispose();
    _discountPercentController.dispose();
    _taxPercentController.dispose();
    super.dispose();
  }

  double _strToDouble(String s) => double.tryParse(s) ?? 0.0;

  RequestForQuotation get _quoteData => RequestForQuotation(
    rfqNumber: _quote.rfqNumber,
    storeNumber: _quote.storeNumber,
    status: _selectedRFQStatus ?? _quote.status,
    supplierId: _selectedSupplierId ?? _quote.supplierId,
    productName: _productDescController.text,
    quantity: int.tryParse(_quantityController.text) ?? 0,
    unitPrice: _strToDouble(_unitPriceController.text),
    deliveryDate: _selectedDeliveryDate ?? _quote.deliveryDate,
    deadline: _selectedDeadlineDate ?? _quote.deadline,
    netPrice: _strToDouble(_netPriceController.text),
    discountPercent: _strToDouble(_discountPercentController.text),
    taxPercent: _strToDouble(_taxPercentController.text),
    remarks: _remarksController.text,
    createdBy: _quote.createdBy,
    updatedBy: context.employee!.fullName,
  );

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      final item = _quoteData;

      /// Update Request For Quotation
      context.read<RequestForQuotationBloc>().add(
        UpdateInventory<RequestForQuotation>(documentId: _quote.id, data: item),
      );

      context.showAlertOverlay(
        'RFQ number: ${_quote.rfqNumber} has been successfully updated',
      );

      Navigator.pop(context);
    }
  }

  /// Update Request For Quotation Status
  void _updateStatus(s) {
    _quote.copyWith(status: s);
    setState(() => _selectedRFQStatus = s);

    context.read<RequestForQuotationBloc>().add(
      UpdateInventory<RequestForQuotation>(
        documentId: _quote.id,
        mapData: {'status': s},
      ),
    );

    context.showAlertOverlay('Changes saved');
  }

  @override
  Widget build(BuildContext context) {
    _calculateTaxAmt();
    _calculateTotalAmount();

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: _buildBody(),
    );
  }

  Column _buildBody() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('Update RFQ Status', style: context.textTheme.titleLarge),
        const SizedBox(height: 10.0),
        RFQStatusDropdown(
          serverValue: _quote.status,
          onChange: (s) => _updateStatus(s),
        ),
        divLine,
        _formBody(),
      ],
    );
  }

  ExpansionTile _formBody() {
    return ExpansionTile(
      dense: true,
      title: Text(
        'Modify this RFQ',
        textAlign: TextAlign.center,
        style: context.textTheme.titleLarge,
      ),
      subtitle: Text(
        'ID ${_quote.id}'.toUpperCaseAll,
        textAlign: TextAlign.center,
      ),
      childrenPadding: const EdgeInsets.only(bottom: 20.0),
      children: [
        const SizedBox(height: 20.0),
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
        UnitPriceAndQuantity(
          unitPriceController: _unitPriceController,
          quantityController: _quantityController,
          onUnitPriceChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
          onQtyChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
        ),
        const SizedBox(height: 20.0),
        TaxPercentAndDiscountPercentInput(
          taxController: _taxPercentController,
          discountController: _discountPercentController,
          taxAmount: _taxAmount,
          discountAmount: _discountAmount,
          onTaxChanged: (s) => setState(() => _taxPercentController.text = s),
          onDiscountChanged: (s) =>
              setState(() => _discountPercentController.text = s),
        ),
        const SizedBox(height: 20.0),
        NetPriceAndRFQStatusDropdown(
          netPriceController: _netPriceController,
          onNetPriceChanged: (s) =>
              setState(() => _netPriceController.text = s),
          serverStatus: _quote.status,
          onStatusChanged: (s) => setState(() => _selectedRFQStatus = s),
        ),
        const SizedBox(height: 20.0),
        DeadlineAndDeliveryDateInput(
          labelDelivery: "Delivery date",
          labelDeadline: "Deadline date",
          serverDeadlineDate: _quote.getDeadlineDate,
          serverDeliveryDate: _quote.getDeliveryDate,
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
        context.confirmableActionButton(onPressed: _onSubmit),
        const SizedBox(height: 20.0),
      ],
    );
  }

  void _calculateSubTotal() {
    CalculateExtras.subTotal(
      qty: _quantityController.text,
      unitPrice: _unitPriceController.text,
      onChanged: (String s) => setState(() => _subTotal = s),
    );
    _calculateTotalAmount();
  }

  void _calculateDiscountAmt() {
    CalculateExtras.discountAmount(
      discountPercent: _discountPercentController.text,
      subTotal: _subTotal,
      onChanged: (double s) => setState(() => _discountAmount = s),
    );
    _calculateTotalAmount();
  }

  void _calculateTaxAmt() {
    CalculateExtras.taxAmount(
      taxPercent: _taxPercentController.text,
      subTotal: _subTotal,
      discountAmt: _discountAmount,
      onChanged: (s) => setState(() => _taxAmount = s),
    );
    _calculateTotalAmount();
  }

  void _calculateTotalAmount() {
    CalculateExtras.totalAmount(
      taxAmount: _taxAmount,
      discountAmount: _discountAmount,
      subTotal: _subTotal,
      onChanged: (double s) =>
          setState(() => _netPriceController.text = s.toStringAsFixed(2)),
    );
  }
}
