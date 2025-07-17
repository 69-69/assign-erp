import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/calculate_extras.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/custom_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/core/widgets/top_header_bottom_sheet.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/inventory_ims/data/models/sale_model.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/inventory_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/sales/sale_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/sales/widget/form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension UpdateSaleForm on BuildContext {
  Future<void> openUpdateSale({required Sale sale}) =>
      openBottomSheet(isExpand: false, child: _UpdateSale(sale: sale));
}

class _UpdateSale extends StatelessWidget {
  final Sale sale;

  const _UpdateSale({required this.sale});

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
      title: ListTile(
        dense: true,
        title: Text(
          'Edit Sale',
          textAlign: TextAlign.center,
          style: context.ofTheme.textTheme.titleLarge?.copyWith(
            color: kGrayColor,
          ),
        ),
        subtitle: Text(
          'ID: ${sale.id}'.toUppercaseAllLetter,
          textAlign: TextAlign.center,
          style: context.ofTheme.textTheme.titleSmall?.copyWith(
            color: kGrayColor,
          ),
        ),
      ),
      btnText: 'Close',
      onPress: () => Navigator.pop(context),
    );
  }

  _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
      child: _UpdateSaleBody(sale: sale),
    );
  }
}

class _UpdateSaleBody extends StatefulWidget {
  final Sale sale;

  const _UpdateSaleBody({required this.sale});

  @override
  State<_UpdateSaleBody> createState() => _UpdateSaleBodyState();
}

class _UpdateSaleBodyState extends State<_UpdateSaleBody> {
  Sale get _sale => widget.sale;

  bool _isEnabledTotalAmt = false;
  String _subTotal = '';

  late double _discountAmount = _sale.discountAmount;
  late double _taxAmount = _sale.taxAmount;
  late String _selectedPaymentTerms = _sale.paymentTerms;
  late String _selectedPaymentStatus = _sale.paymentStatus;
  late String _selectedSaleStatus = _sale.status;

  final _formKey = GlobalKey<FormState>();

  late final _quantityController = TextEditingController(
    text: '${_sale.quantity}',
  );
  late final _unitPriceController = TextEditingController(
    text: '${_sale.unitPrice}',
  );
  late final _totalAmtController = TextEditingController(
    text: '${_sale.totalAmount}',
  );
  late final _remarksController = TextEditingController(text: _sale.remarks);
  late final _amountPaidController = TextEditingController(
    text: '${_sale.amountPaid}',
  );

  // Additional Charges
  late final _discountPercentController = TextEditingController(
    text: '${_sale.discountPercent}',
  );
  late final _taxPercentController = TextEditingController(
    text: '${_sale.taxPercent}',
  );
  late final _deliveryAmountController = TextEditingController(
    text: '${_sale.deliveryAmount}',
  );

  void _toggleEditTotalAmt() =>
      setState(() => _isEnabledTotalAmt = !_isEnabledTotalAmt);

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

    _amountPaidController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _discountPercentController.dispose();
    _taxPercentController.dispose();
    _deliveryAmountController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      final item = _sale.copyWith(
        quantity: int.parse(_quantityController.text),
        unitPrice: _strToDouble(_unitPriceController.text) ?? _sale.unitPrice,
        deliveryAmount:
            _strToDouble(_deliveryAmountController.text) ??
            _sale.deliveryAmount,
        status: _selectedSaleStatus,
        // Additional Charges
        discountPercent:
            _strToDouble(_discountPercentController.text) ??
            _sale.discountPercent,
        discountAmount: _discountAmount,
        taxPercent:
            _strToDouble(_taxPercentController.text) ?? _sale.taxPercent,
        amountPaid: _strToDouble(_amountPaidController.text),
        taxAmount: _taxAmount,
        paymentStatus: _selectedPaymentStatus,
        storeNumber: _sale.storeNumber,
        // Total Amount
        totalAmount:
            _strToDouble(_totalAmtController.text) ?? _sale.totalAmount,
        paymentTerms: _selectedPaymentTerms,
        remarks: _remarksController.text,
        createdBy: _sale.createdBy,
        updatedBy: context.employee!.fullName,
      );

      /// Update Sale
      context.read<SaleBloc>().add(
        UpdateInventory<Sale>(documentId: _sale.id, data: item),
      );

      _formKey.currentState!.reset();
      context.showAlertOverlay(
        'Sales with ID: ${_sale.id} has been successfully updated',
      );

      Navigator.of(context).pop();
    }
  }

  /// Update Sales Status
  void _updateStatus(status) {
    _sale.copyWith(status: status);
    setState(() => _selectedSaleStatus = status);

    /// Update Sales Status
    context.read<SaleBloc>().add(
      UpdateInventory<Sale>(documentId: _sale.id, mapData: {'status': status}),
    );

    context.showAlertOverlay('Changes saved');
  }

  double? _strToDouble(s) => double.tryParse(s);

  @override
  Widget build(BuildContext context) {
    _calculateTaxAmt();
    _calculateTotalAmount();

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: _buildBody(context),
    );
  }

  Column _buildBody(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Update Sales Status',
          style: context.ofTheme.textTheme.titleLarge,
        ),
        const SizedBox(height: 10.0),
        SalesStatusDropdown(
          serverValue: _sale.status,
          onChanged: (s) => _updateStatus(s),
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
        'Modify this Sales',
        textAlign: TextAlign.center,
        style: context.ofTheme.textTheme.titleLarge,
      ),
      subtitle: Text(
        'ID ${_sale.id}'.toUppercaseAllLetter,
        textAlign: TextAlign.center,
      ),
      childrenPadding: const EdgeInsets.only(bottom: 20.0),
      children: <Widget>[
        const SizedBox(height: 20.0),
        UnitPriceAndQuantityInput(
          unitPriceController: _unitPriceController,
          quantityController: _quantityController,
          onUnitPriceChanged: (t) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
          onQuantityChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
        ),
        const SizedBox(height: 20.0),
        AmountPaidTextField(
          controller: _amountPaidController,
          onChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
        ),
        const SizedBox(height: 20.0),
        ListTile(
          dense: true,
          title: Text(
            'Additional Charges:',
            textAlign: TextAlign.center,
            style: context.ofTheme.textTheme.titleMedium,
          ),
          subtitle: const Text('Optional', textAlign: TextAlign.center),
        ),
        TaxPercentAndDiscountPercentInput(
          taxAmount: _taxAmount,
          discountAmount: _discountAmount,
          taxController: _taxPercentController,
          discountController: _discountPercentController,
          onDiscountChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
          onChanged: (t) {
            if (_formKey.currentState!.validate()) {
              setState(() {});
            }
          },
        ),
        const SizedBox(height: 20.0),
        DeliveryAmtPaymentMethodInput(
          deliveryController: _deliveryAmountController,
          serverValue: _selectedPaymentTerms,
          onPaymentChanged: (s) => setState(() => _selectedPaymentTerms = s),
          onChanged: (s) {
            _calculateTotalAmount();
            setState(() {});
          },
        ),
        const Divider(thickness: 10.0, height: 50),
        SalesAndPaymentStatusDropdown(
          serverSale: _sale.status,
          serverPayment: _sale.paymentStatus,
          onSaleChanged: (s) => setState(() => _selectedSaleStatus = s),
          onPaymentChanged: (s) => setState(() => _selectedPaymentStatus = s),
        ),
        const SizedBox(height: 20.0),
        RemarksAndTotalAmtTextField(
          enable: _isEnabledTotalAmt,
          onEdited: _toggleEditTotalAmt,
          remarksController: _remarksController,
          totalAmtController: _totalAmtController,
          onTotalAmtChanged: (t) {
            if (_formKey.currentState!.validate()) {
              setState(() {});
            }
          },
        ),
        const SizedBox(height: 20.0),
        context.elevatedBtn(onPressed: _onSubmit),
      ],
    );
  }

  /// Calculate Sub-Total by Quantity & Unit Price [_calculateSubTotal]
  void _calculateSubTotal() {
    CalculateExtras.subTotal(
      qty: _quantityController.text,
      unitPrice: _unitPriceController.text,
      onChanged: (String s) => setState(() => _subTotal = s),
    );
    _calculateTotalAmount();
  }

  /// Calculate Discount-Amount by Total-Price & Discount-Percentile [_calculateDiscountAmt]
  void _calculateDiscountAmt() {
    CalculateExtras.discountAmount(
      discountPercent: _discountPercentController.text,
      subTotal: _subTotal,
      onChanged: (double s) => setState(() => _discountAmount = s),
    );
    _calculateTotalAmount();
  }

  /// Calculate Tax-Amount by Total-Price & Tax-Percentile [_calculateTaxAmt]
  void _calculateTaxAmt() {
    CalculateExtras.taxAmount(
      taxPercent: _taxPercentController.text,
      subTotal: _subTotal,
      discountAmt: _discountAmount,
      deliveryAmt: _deliveryAmountController.text,
      onChanged: (double s) => setState(() => _taxAmount = s),
    );
    _calculateTotalAmount();
  }

  /// Calculate Total-Amount by All [_calculateTotalAmount]
  void _calculateTotalAmount() {
    CalculateExtras.totalAmount(
      taxAmount: _taxAmount,
      discountAmount: _discountAmount,
      subTotal: _subTotal,
      deliveryAmt: _deliveryAmountController.text,
      onChanged: (double s) => setState(() => _totalAmtController.text = '$s'),
    );
  }
}

/*
* List<Sale> selectedSales = [];
* Wrap(
    spacing: 8.0,
    children: List.generate(
      selectedSales.length,
      (index) => InputChip(
        label: Text(selectedSales[index].productName),
        onDeleted: () {
          setState(() {
            selectedSales.removeAt(index);
          });
        },
      ),
    ),
  ),*/
