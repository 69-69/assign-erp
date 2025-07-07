import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/util/async_progress_dialog.dart';
import 'package:assign_erp/core/util/custom_bottom_sheet.dart';
import 'package:assign_erp/core/util/custom_snack_bar.dart';
import 'package:assign_erp/core/util/format_date_utl.dart';
import 'package:assign_erp/core/util/generate_new_uid.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/util/top_header_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/barcode_scanner.dart';
import 'package:assign_erp/core/widgets/calculate_extras.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/core/widgets/custom_scroll_bar.dart';
import 'package:assign_erp/core/widgets/prompt_user_for_action.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/customer_crm/data/data_sources/remote/get_customers.dart';
import 'package:assign_erp/features/inventory_ims/data/models/orders/order_model.dart';
import 'package:assign_erp/features/inventory_ims/data/models/product_model.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/inventory_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/orders/order_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/orders/so/widget/form_inputs.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/widget/print_order_invoice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension AddFinanceForm on BuildContext {
  Future<void> openAddFinance({Widget? header}) =>
      openBottomSheet(isExpand: false, child: _AddFinance(header: header));
}

class _AddFinance extends StatelessWidget {
  final Widget? header;

  const _AddFinance({this.header});

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
        'Place an Order'.toUppercaseFirstLetterEach,
        semanticsLabel: 'place an Order',
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
      child: _AddFinanceBody(),
    );
  }
}

class _AddFinanceBody extends StatefulWidget {
  const _AddFinanceBody();

  @override
  State<_AddFinanceBody> createState() => _AddFinanceBodyState();
}

class _AddFinanceBodyState extends State<_AddFinanceBody> {
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();

  // Indicates whether the orders are to be placed on the same invoice
  bool _ordersOnSameInvoice = false;

  bool _isEnabledTotalAmt = false;
  String _newSONumber = '';
  String _selectedCustomerId = '';
  String _selectedProductId = '';
  String _selectedProductName = '';
  String? _selectedOrderStatus;
  String? _selectedOrderType;
  String? _selectedPaymentMethod;
  String? _selectedPaymentStatus;
  DateTime? _selectedValidityDate;
  String? _selectedOrderSource;
  DateTime? _selectedDeliveryDate;
  DateTime? _selectedShippingDate;
  double _discountAmount = 0.0;
  double _taxAmount = 0.0;

  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _subTotalController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _totalAmtController = TextEditingController();
  final _discountPercentController = TextEditingController();
  final _taxPercentController = TextEditingController();
  final _deliveryAmountController = TextEditingController();
  final _remarksController = TextEditingController();
  final _amountPaidController = TextEditingController();

  bool isMultipleOrders = false;
  final List<Orders> _orders = [];

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_calculateSubTotal);
    _unitPriceController.addListener(_calculateSubTotal);
    _discountPercentController.addListener(_calculateDiscountAmt);
    _taxPercentController.addListener(_calculateTaxAmt);
    _generateSONumber();
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
    _barcodeController.dispose();
    _unitPriceController.dispose();
    _subTotalController.dispose();
    _deliveryAmountController.dispose();
    _discountPercentController.dispose();
    _taxPercentController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  // Updates the product details in the Form by setting the unit price,
  // product ID, & name based on the provided Product instance.
  set _setProductId(Product p) {
    _unitPriceController.text = '${p.sellingPrice}';
    _selectedProductId = p.id;
    _selectedProductName = p.name;
  }

  void _toggleCheckbox(bool? value) {
    setState(() => _ordersOnSameInvoice = value ?? false);
  }

  void _toggleEditTotalAmt() =>
      setState(() => _isEnabledTotalAmt = !_isEnabledTotalAmt);

  double _strToDouble(String s) => double.tryParse(s) ?? 0.0;

  void _generateSONumber() async {
    await 'order'.getShortUID(
      onChanged: (s) => setState(() => _newSONumber = s),
    );
  }

  Orders get _orderData => Orders(
    orderNumber: _newSONumber,
    status: _selectedOrderStatus ?? '',
    barcode: _barcodeController.text,
    orderType: _selectedOrderType ?? '',
    productId: _selectedProductId,
    productName: _selectedProductName,
    customerId: _selectedCustomerId,
    quantity: int.tryParse(_quantityController.text) ?? 0,
    unitPrice: _strToDouble(_unitPriceController.text),
    deliveryAmount: _strToDouble(_deliveryAmountController.text),
    paymentTerms: _selectedPaymentMethod ?? '',
    paymentStatus: _selectedPaymentStatus ?? '',
    discountPercent: _strToDouble(_discountPercentController.text),
    taxPercent: _strToDouble(_taxPercentController.text),
    amountPaid: _strToDouble(_amountPaidController.text),
    totalAmount: _strToDouble(_totalAmtController.text),
    orderSource: _selectedOrderSource ?? '',
    validityDate: _selectedValidityDate != null
        ? '${_selectedValidityDate!.toDays} days'
        : '',
    deliveryDate: _selectedDeliveryDate,
    shippingDate: _selectedShippingDate,
    remarks: _remarksController.text,
    storeNumber: context.employee!.storeNumber,
    createdBy: context.employee!.fullName,

    /*taxAmount: _taxAmount,
        discountAmount: _discountAmount,
        subTotal: _strToDouble(_subTotalController.text),*/
  );

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      /// Added Multiple Orders Simultaneously
      _orders.add(_orderData);

      context.read<OrderBloc>().add(AddInventory<List<Orders>>(data: _orders));

      _formKey.currentState!.reset();

      if (_orderData.isNotEmpty) {
        // Create a new delivery once the order(s) have been successfully placed
        context.read<OrderBloc>().createNewDeliveryForOrder(
          _orderData.orderNumber,
          _orderData.storeNumber,
        );
      }
      _clearFields();
      isMultipleOrders = false;

      if (_ordersOnSameInvoice) {
        _confirmPrintoutDialog();
      }
    }
  }

  /// Function for Adding Multiple Orders Simultaneously
  void _addOrderToList() {
    if (_formKey.currentState!.validate()) {
      setState(() => isMultipleOrders = true);
      _orders.add(_orderData);
      context.showAlertOverlay('Order added to list');
      _clearFields();
    }
  }

  void _clearFields() {
    _quantityController.clear();
    _barcodeController.clear();
    _subTotalController.clear();
    _totalAmtController.clear();
    _discountPercentController.clear();
    _deliveryAmountController.clear();
    _taxPercentController.clear();
    _amountPaidController.clear();
    _selectedProductId = '';
    _selectedOrderSource = '';
    _selectedProductName = '';
    _selectedPaymentStatus = null;
    _selectedOrderType = null;
    _selectedPaymentMethod = null;
    _selectedPaymentStatus = null;
    _selectedDeliveryDate = null;
    _selectedShippingDate = null;
    _discountAmount = 0.0;
    _taxAmount = 0.0;
  }

  void _removeOrder(Orders order) {
    setState(() => _orders.remove(order));
  }

  @override
  Widget build(BuildContext context) {
    _calculateTaxAmt();
    _calculateTotalAmount();

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Wrap(
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: [
          if (isMultipleOrders && _orders.isNotEmpty) _buildOrderPreviewChips(),
          _buildBody(),
        ],
      ),
    );
  }

  // Preview Orders add to list
  Widget _buildOrderPreviewChips() {
    return CustomScrollBar(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _orders.map((o) {
          return o.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Chip(
                    padding: EdgeInsets.zero,
                    label: Text(
                      '${o.productName} - $ghanaCedis${o.unitPrice} x ${o.quantity}'
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

  _buildBody() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Order Number:\n',
                style: context.ofTheme.textTheme.titleLarge?.copyWith(
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: _newSONumber,
                    style: context.ofTheme.textTheme.titleLarge?.copyWith(
                      overflow: TextOverflow.ellipsis,
                      color: kDangerColor,
                    ),
                  ),
                ],
              ),
            ),
            FittedBox(
              child: context.buildRefreshButton(
                'Refresh Order Number',
                onPressed: _generateSONumber,
              ),
            ),
          ],
        ),
        const SizedBox(width: 10.0),
        CustomerIDInput(
          onChanged: (id, name) async {
            /// If customer doesn't exist, then fallback on 'Auto ID'.
            /// hence, generate new Customer-ID
            if (name.contains(autoID)) {
              await 'customer'.getShortUID(
                onChanged: (s) => setState(() => _selectedCustomerId = s),
              );
            } else {
              // Customer found...hence use his/her ID
              setState(() => _selectedCustomerId = id);
            }
          },
        ),
        const SizedBox(height: 20.0),
        ProductIdAndQuantityInput(
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
          serverType: _selectedOrderType,
          onTypeChange: (t) => setState(() => _selectedOrderType = t),
          serverStatus: _selectedOrderStatus,
          onStatusChange: (s) => setState(() => _selectedOrderStatus = s),
        ),
        const SizedBox(height: 20.0),
        ShippingAndDeliveryDateInput(
          labelDelivery: "Delivery date",
          labelShipping: "Shipping date",
          onDeliveryChanged: (date) =>
              setState(() => _selectedDeliveryDate = date),
          onShippingChanged: (date) =>
              setState(() => _selectedShippingDate = date),
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
        TaxPercentAndDiscountPercentInput(
          taxAmount: _taxAmount,
          discountAmount: _discountAmount,
          taxController: _taxPercentController,
          discountController: _discountPercentController,
          onDiscountChanged: (s) {
            _calculateTotalAmount();
            if (_formKey.currentState!.validate()) setState(() {});
          },
          onTaxChanged: (s) {
            _calculateTotalAmount();
            if (_formKey.currentState!.validate()) setState(() {});
          },
        ),
        const SizedBox(height: 20.0),
        DeliveryAmtPaymentMethodInput(
          deliveryController: _deliveryAmountController,
          serverValue: _selectedPaymentMethod,
          onPaymentChanged: (s) => setState(() => _selectedPaymentMethod = s),
          onChanged: (s) {
            _calculateTotalAmount();
            if (_formKey.currentState!.validate()) setState(() {});
          },
        ),
        const Divider(thickness: 10.0, height: 50),
        AmountPaidAndPaymentStatusDropdown(
          amountPaidController: _amountPaidController,
          onAmountPaidChanged: (s) => setState(() {}),
          onStatusChanged: (s) => setState(() => _selectedPaymentStatus = s),
        ),
        const SizedBox(height: 20.0),
        ValidityAndOrderSource(
          onSourceChanged: (s) => setState(() => _selectedOrderSource = s),
          onValidityChanged: (date) =>
              setState(() => _selectedValidityDate = date),
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
        Wrap(
          direction: Axis.vertical,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _ordersOnSameInvoice,
                  onChanged: _toggleCheckbox,
                ),
                const Text(
                  'Are these orders on the same invoice?',
                  style: TextStyle(color: kDangerColor),
                ),
              ],
            ),
            context.elevatedIconBtn(
              Icons.add,
              onPressed: _addOrderToList,
              label: 'Add to List',
            ),
          ],
        ),
        const SizedBox(height: 20.0),
        context.elevatedBtn(
          label: isMultipleOrders ? 'Create All Orders' : 'Create Order',
          onPressed: _onSubmit,
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }

  void _calculateSubTotal() {
    CalculateExtras.subTotal(
      qty: _quantityController.text,
      unitPrice: _unitPriceController.text,
      onChanged: (String s) => setState(() => _subTotalController.text = s),
    );
    _calculateTotalAmount();
  }

  void _calculateDiscountAmt() {
    CalculateExtras.discountAmount(
      discountPercent: _discountPercentController.text,
      subTotal: _subTotalController.text,
      onChanged: (double s) => setState(() => _discountAmount = s),
    );
    _calculateTotalAmount();
  }

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

  Future<void> _confirmPrintoutDialog() async {
    final isConfirmed = await context.confirmAction(
      const Text('Would you prefer to print the Proforma Invoice?'),
      title: "Proforma Invoice",
      onAccept: "Print",
      onReject: "Cancel",
    );

    if (mounted && isConfirmed) {
      // Show progress dialog while loading data
      await context.progressBarDialog(
        request: _printout(),
        onSuccess: (_) =>
            context.showAlertOverlay('Order successfully created'),
        onError: (error) => context.showAlertOverlay(
          'Proforma Invoice printout failed',
          bgColor: kDangerColor,
        ),
      );
    }
  }

  Future<dynamic> _printout() =>
      Future.delayed(const Duration(seconds: 3), () async {
        // Simulate loading supplier and company info
        final cus = await GetCustomers.byCustomerId(_orders.first.customerId);
        if (cus.isNotEmpty) {
          PrintOrderInvoice(
            orders: _orders,
            customer: cus,
          ).onPrintIn(title: 'proforma invoice');
        }
      });
}
