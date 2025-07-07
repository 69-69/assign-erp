import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/custom_bottom_sheet.dart';
import 'package:assign_erp/core/util/custom_snack_bar.dart';
import 'package:assign_erp/core/util/format_date_utl.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/util/top_header_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/barcode_scanner.dart';
import 'package:assign_erp/core/widgets/calculate_extras.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/inventory_ims/data/models/orders/order_model.dart';
import 'package:assign_erp/features/inventory_ims/data/models/product_model.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/inventory_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/orders/order_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/finance/widget/form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension UpdateOrderForm on BuildContext {
  Future openUpdateOrder({required Orders order}) =>
      openBottomSheet(isExpand: false, child: _UpdateOrder(order: order));
}

class _UpdateOrder extends StatelessWidget {
  final Orders order;

  const _UpdateOrder({required this.order});

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
          'Edit Order',
          semanticsLabel: 'edit order',
          textAlign: TextAlign.center,
          style: context.ofTheme.textTheme.titleLarge?.copyWith(
            color: kGrayColor,
          ),
        ),
        subtitle: Text(
          order.orderNumber.toUpperCase(),
          semanticsLabel: order.orderNumber,
          textAlign: TextAlign.center,
          style: context.ofTheme.textTheme.titleMedium?.copyWith(
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
      child: _UpdateOrderBody(order: order),
    );
  }
}

class _UpdateOrderBody extends StatefulWidget {
  final Orders order;

  const _UpdateOrderBody({required this.order});

  @override
  State<_UpdateOrderBody> createState() => _UpdateOrderBodyState();
}

class _UpdateOrderBodyState extends State<_UpdateOrderBody> {
  Orders get _order => widget.order;

  // Updates the product details in the Form by setting the unit price,
  // product ID, & name based on the provided Product instance.
  set _setProductId(Product p) {
    _unitPriceController.text = '${p.sellingPrice}';
    _selectedProductId = p.id;
    _selectedProductName = p.name;
  }

  bool _isEnabledTotalAmt = false;

  String? _selectedProductId;
  String? _selectedProductName;
  String? _selectedPaymentTerms;
  String? _selectedPaymentStatus;
  String? _selectedOrderStatus;
  String? _selectedOrderType;
  DateTime? _selectedDeliveryDate;
  DateTime? _selectedShippingDate;
  DateTime? _selectedValidityDate;
  String? _selectedOrderSource;
  double _discountAmount = 0.0;
  double _taxAmount = 0.0;

  final _formKey = GlobalKey<FormState>();
  late final _quantityController = TextEditingController(
    text: '${_order.quantity}',
  );
  late final _unitPriceController = TextEditingController(
    text: '${_order.unitPrice}',
  );
  late final _subTotalController = TextEditingController(
    text: '${_order.getSubTotal}',
  );
  late final _barcodeController = TextEditingController(text: _order.barcode);

  // Additional Charges
  late final _discountPercentController = TextEditingController(
    text: '${_order.discountPercent}',
  );
  late final _taxPercentController = TextEditingController(
    text: '${_order.taxPercent}',
  );
  late final _deliveryAmountController = TextEditingController(
    text: '${_order.deliveryAmount}',
  );
  late final _amountPaidController = TextEditingController(
    text: '${_order.amountPaid}',
  );
  late final _totalAmtController = TextEditingController(
    text: '${_order.totalAmount}',
  );
  late final _remarksController = TextEditingController(
    text: '${_order.remarks}',
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

    _quantityController.dispose();
    _barcodeController.dispose();
    _unitPriceController.dispose();
    _subTotalController.dispose();
    _discountPercentController.dispose();
    _taxPercentController.dispose();
    _deliveryAmountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Orders get _orderData => _order.copyWith(
    productId: _selectedProductId ?? _order.productId,
    storeNumber: _order.storeNumber,
    customerId: _order.customerId,
    productName: _selectedProductName ?? _order.productName,
    barcode: _barcodeController.text,
    status: _selectedOrderStatus ?? _order.status,
    orderType: _selectedOrderType ?? _order.orderType,
    quantity: int.tryParse(_quantityController.text) ?? _order.quantity,
    unitPrice: double.tryParse(_unitPriceController.text) ?? _order.unitPrice,
    deliveryAmount:
        double.tryParse(_deliveryAmountController.text) ??
        _order.deliveryAmount,
    // Additional Charges
    discountPercent:
        double.tryParse(_discountPercentController.text) ??
        _order.discountPercent,
    paymentTerms: _selectedPaymentTerms ?? _order.paymentTerms,
    paymentStatus: _selectedPaymentStatus ?? _order.paymentStatus,
    taxPercent:
        double.tryParse(_taxPercentController.text) ?? _order.taxPercent,
    totalAmount:
        double.tryParse(_totalAmtController.text) ?? _order.totalAmount,
    amountPaid:
        double.tryParse(_amountPaidController.text) ?? _order.amountPaid,
    orderSource: _selectedOrderSource ?? _order.orderSource,
    // date
    validityDate: _selectedValidityDate != null
        ? '${_selectedValidityDate!.toDays} days'
        : '',
    deliveryDate: _selectedDeliveryDate ?? _order.deliveryDate,
    shippingDate: _selectedShippingDate ?? _order.shippingDate,
    remarks: _remarksController.text,
    createdBy: _order.createdBy,
    updatedBy: context.employee!.fullName,
    /*taxAmount: _taxAmount,
        discountAmount: _discountAmount,
        subTotal: double.tryParse(_subTotalController.text) ?? _order.subTotal,*/
  );

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      final item = _orderData;

      /// Update Orders
      context.read<OrderBloc>().add(
        UpdateInventory<Orders>(documentId: _order.id, data: item),
      );

      context.showAlertOverlay(
        'Order ${_order.orderNumber} has been successfully updated',
      );

      Navigator.pop(context);
    }
  }

  /// Update Order Status
  void _updateStatus(s) {
    _order.copyWith(status: s);
    setState(() => _selectedOrderStatus = s);

    context.read<OrderBloc>().add(
      UpdateInventory<Orders>(documentId: _order.id, mapData: {'status': s}),
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
        Text(
          'Update Order Status',
          style: context.ofTheme.textTheme.titleLarge,
        ),
        const SizedBox(height: 10.0),
        OrdersStatusDropdown(
          serverValue: _order.status,
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
        'Modify this Order',
        textAlign: TextAlign.center,
        style: context.ofTheme.textTheme.titleLarge,
      ),
      subtitle: Text(
        'ID ${_order.id}'.toUppercaseAllLetter,
        textAlign: TextAlign.center,
      ),
      childrenPadding: const EdgeInsets.only(bottom: 20.0),
      children: [
        const SizedBox(height: 20.0),
        ProductIdAndQuantityInput(
          serverValue: _order.productName,
          qtyController: _quantityController,
          onQtyChanged: (_) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
          onChanged: (product) => setState(() => _setProductId = product),
        ),
        const SizedBox(height: 20.0),
        SubTotalAndUnitPriceInput(
          unitPriceController: _unitPriceController,
          subTotalController: _subTotalController,
          onUnitPriceChanged: (t) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
          onSubTotalChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
        ),
        const SizedBox(height: 20.0),
        OrderStatusAndTypesDropdown(
          serverType: _order.orderType,
          onTypeChange: (t) => setState(() => _selectedOrderType = t),
          serverStatus: _order.status,
          onStatusChange: (s) => setState(() => _selectedOrderStatus = s),
        ),
        const SizedBox(height: 20.0),
        ShippingAndDeliveryDateInput(
          labelDelivery: "Delivery date",
          labelShipping: "Shipping date",
          serverDeliveryDate: _order.getDeliveryDate,
          serverShippingDate: _order.getShippingDate,
          onDeliveryChanged: (d) => setState(() => _selectedDeliveryDate = d),
          onShippingChanged: (d) => setState(() => _selectedShippingDate = d),
        ),
        const SizedBox(height: 20.0),
        BarcodeScannerWithTextField(
          controller: _barcodeController,
          onChanged: (t) => setState(() {}),
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
        const SizedBox(height: 10.0),
        TaxPercentAndDiscountPercentInput(
          taxAmount: _taxAmount,
          discountAmount: _discountAmount,
          taxController: _taxPercentController,
          discountController: _discountPercentController,
          onDiscountChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
          onTaxChanged: (v) => setState(() {}),
        ),
        const SizedBox(height: 20.0),
        DeliveryAmtPaymentMethodInput(
          deliveryController: _deliveryAmountController,
          serverValue: _order.paymentTerms,
          onPaymentChanged: (s) => setState(() => _selectedPaymentTerms = s),
          onChanged: (s) {
            _calculateTotalAmount();
            if (_formKey.currentState!.validate()) setState(() {});
          },
        ),
        const SizedBox(height: 20.0),
        ValidityAndOrderSource(
          serverValidityDate: _order.validityDate,
          serverOrderSource: _order.orderSource,
          onSourceChanged: (s) => setState(() => _selectedOrderSource = s),
          onValidityChanged: (date) =>
              setState(() => _selectedValidityDate = date),
        ),
        const SizedBox(height: 20.0),
        AmountPaidAndPaymentStatusDropdown(
          amountPaidController: _amountPaidController,
          serverStatus: _order.paymentStatus,
          onAmountPaidChanged: (s) => setState(() {}),
          onStatusChanged: (s) => setState(() => _selectedPaymentStatus = s),
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
      onChanged: (String s) => setState(() => _subTotalController.text = s),
    );
    _calculateTotalAmount();
  }

  /// Calculate Discount-Amount by Total-Price & Discount-Percentile [_calculateDiscountAmt]
  void _calculateDiscountAmt() {
    CalculateExtras.discountAmount(
      discountPercent: _discountPercentController.text,
      subTotal: _subTotalController.text,
      onChanged: (double s) => setState(() => _discountAmount = s),
    );
    _calculateTotalAmount();
  }

  /// Calculate Tax-Amount by Total-Price & Tax-Percentile [_calculateTaxAmt]
  void _calculateTaxAmt() {
    CalculateExtras.taxAmount(
      taxPercent: _taxPercentController.text,
      subTotal: _subTotalController.text,
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
      subTotal: _subTotalController.text,
      deliveryAmt: _deliveryAmountController.text,
      onChanged: (double s) =>
          setState(() => _totalAmtController.text = s.toStringAsFixed(2)),
    );
  }
}
