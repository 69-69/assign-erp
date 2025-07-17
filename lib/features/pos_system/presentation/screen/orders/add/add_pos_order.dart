import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/util/calculate_extras.dart';
import 'package:assign_erp/core/util/generate_new_uid.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/async_progress_dialog.dart';
import 'package:assign_erp/core/widgets/barcode_scanner.dart';
import 'package:assign_erp/core/widgets/custom_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/core/widgets/custom_scroll_bar.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/prompt_user_for_action.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/core/widgets/top_header_bottom_sheet.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/inventory_ims/data/models/product_model.dart';
import 'package:assign_erp/features/pos_system/data/models/pos_order_model.dart';
import 'package:assign_erp/features/pos_system/presentation/bloc/orders/pos_order_bloc.dart';
import 'package:assign_erp/features/pos_system/presentation/bloc/pos_bloc.dart';
import 'package:assign_erp/features/pos_system/presentation/screen/orders/widget/form_inputs.dart';
import 'package:assign_erp/features/pos_system/presentation/screen/widget/print_pos_receipt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension AddPOSOrderForm on BuildContext {
  Future<void> openAddPOSOrder({Widget? header}) =>
      openBottomSheet(isExpand: false, child: _AddOrder(header: header));
}

class _AddOrder extends StatelessWidget {
  final Widget? header;

  const _AddOrder({this.header});

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
      child: _AddOrderBody(),
    );
  }
}

class _AddOrderBody extends StatefulWidget {
  const _AddOrderBody();

  @override
  State<_AddOrderBody> createState() => _AddOrderBodyState();
}

class _AddOrderBodyState extends State<_AddOrderBody> {
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();

  // Indicates whether the orders are to be placed on the same invoice
  bool _ordersOnSameInvoice = false;
  bool _isEnabledTotalAmt = false;
  bool isMultipleOrders = false;

  double _productCostPrice = 0.0;
  double _discountAmount = 0.0;
  double _taxAmount = 0.0;

  String _newOrderNumber = '';
  String _selectedCustomerId = '';
  String _selectedProductId = '';
  String _selectedProductName = '';
  String? _selectedOrderStatus;
  String? _selectedPaymentMethod;

  final List<POSOrder> _orders = [];

  /// Maps each product's ID to its cost price for sales recording purposes [_costPricesMap]
  final Map<String, double> _costPricesMap = {};

  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _subTotalController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _totalAmtController = TextEditingController();
  final _discountPercentController = TextEditingController();
  final _taxPercentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_calculateSubTotal);
    _unitPriceController.addListener(_calculateSubTotal);
    _discountPercentController.addListener(_calculateDiscountAmt);
    _taxPercentController.addListener(_calculateTaxAmt);
    _generateOrderNumber();
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
    super.dispose();
  }

  void _toggleCheckbox(bool? value) {
    setState(() => _ordersOnSameInvoice = value ?? false);
  }

  void _toggleEditTotalAmt() {
    setState(() => _isEnabledTotalAmt = !_isEnabledTotalAmt);
  }

  double _strToDouble(String s) => double.tryParse(s) ?? 0.0;

  // Updates the product details in the form based on the provided Product instance.
  // Sets the unit price, product ID, product name, and cost price.
  set _setProductId(Product p) {
    _unitPriceController.text = '${p.sellingPrice}';
    _selectedProductId = p.id;
    _selectedProductName = p.name;
    _productCostPrice = p.costPrice;
  }

  void _generateOrderNumber() async {
    await 'pOrder'.getShortUID(
      onChanged: (s) => setState(() => _newOrderNumber = s),
    );
  }

  POSOrder get _orderData => POSOrder(
    orderNumber: _newOrderNumber,
    status: _selectedOrderStatus ?? '',
    barcode: _barcodeController.text,
    productId: _selectedProductId,
    productName: _selectedProductName,
    customerId: _selectedCustomerId,
    quantity: int.tryParse(_quantityController.text) ?? 0,
    unitPrice: _strToDouble(_unitPriceController.text),
    paymentMethod: _selectedPaymentMethod ?? '',
    discountPercent: _strToDouble(_discountPercentController.text),
    taxPercent: _strToDouble(_taxPercentController.text),
    discountAmount: _discountAmount,
    taxAmount: _taxAmount,
    totalAmount: _strToDouble(_totalAmtController.text),
    storeNumber: context.employee!.storeNumber,
    createdBy: context.employee!.fullName,
  );

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      _orders.add(_orderData);
      // Maps each product's ID to its cost price for sales recording purposes
      _costPricesMap.addAll({_orderData.productId: _productCostPrice});

      context.read<POSOrderBloc>().add(AddPOS<List<POSOrder>>(data: _orders));

      _formKey.currentState!.reset();

      _recordNewSales();
      _clearFields();
      isMultipleOrders = false;

      if (_ordersOnSameInvoice) {
        _confirmPrintoutDialog();
      }

      _formKey.currentState!.reset();
      Navigator.pop(context);
    }
  }

  void _recordNewSales() {
    if (_orders.isNotEmpty) {
      context.read<POSOrderBloc>().createNewSalesForOrder(
        _orders,
        _costPricesMap,
      );
    }
  }

  /// Function for Adding Multiple Orders Simultaneously
  void _addOrderToList() {
    if (_formKey.currentState!.validate()) {
      setState(() => isMultipleOrders = true);
      _orders.add(_orderData);

      if (_productCostPrice > 0) {
        debugPrint('form data added');
        _costPricesMap.addAll({_orderData.productId: _productCostPrice});
      }

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
    _taxPercentController.clear();
    _selectedProductId = '';
    _selectedProductName = '';
    _selectedOrderStatus = null;
    _discountAmount = 0.0;
    _taxAmount = 0.0;
  }

  void _removeOrder(POSOrder order) {
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

  // Horizontal scrollable row of chips representing the List of batch of Orders
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
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: _newOrderNumber,
                    style: context.ofTheme.textTheme.titleLarge?.copyWith(
                      color: kDangerColor,
                    ),
                  ),
                ],
              ),
            ),
            FittedBox(
              child: context.buildRefreshButton(
                'Refresh Order Number',
                onPressed: _generateOrderNumber,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20.0),
        CustomerAndProductId(
          onCustomerChanged: (id, name) async {
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
          onProductChanged: (product) =>
              setState(() => _setProductId = product),
        ),
        const SizedBox(height: 20.0),
        UnitPriceAndQuantityInput(
          qtyController: _quantityController,
          unitPriceController: _unitPriceController,
          onQtyChanged: (_) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
          onUnitChanged: (t) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
        ),
        const SizedBox(height: 20.0),
        SubTotalAndOrderStatus(
          subTotalController: _subTotalController,
          onSubTotalChange: (t) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
          serverStatus: _selectedOrderStatus,
          onStatusChange: (s) => setState(() => _selectedOrderStatus = s),
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
        TotalAmountAndPaymentMethod(
          enable: _isEnabledTotalAmt,
          onEdited: _toggleEditTotalAmt,
          totalAmtController: _totalAmtController,
          serverValue: _selectedPaymentMethod,
          onTotalAmtChanged: (t) {
            if (_formKey.currentState!.validate()) {
              setState(() {});
            }
          },
          onPaymentChanged: (s) => setState(() => _selectedPaymentMethod = s),
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
                  'Are these orders on the same receipt?',
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
      onChanged: (double s) => setState(() => _taxAmount = s),
    );
    _calculateTotalAmount();
  }

  void _calculateTotalAmount() {
    CalculateExtras.totalAmount(
      taxAmount: _taxAmount,
      discountAmount: _discountAmount,
      subTotal: _subTotalController.text,
      onChanged: (double s) =>
          setState(() => _totalAmtController.text = s.toStringAsFixed(2)),
    );
  }

  Future<void> _confirmPrintoutDialog() async {
    final isConfirmed = await context.confirmAction(
      const Text('Would you prefer to print out receipt?'),
      title: "Receipt Option",
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
          'Receipt printout failed',
          bgColor: kDangerColor,
        ),
      );
    }
  }

  Future<dynamic> _printout() => Future.delayed(wAnimateDuration, () async {
    if (mounted) {
      PrintPOSSalesReceipt(
        orders: _orders,
        storeNumber: context.employee!.storeNumber,
        customerId: _orders.first.customerId,
      ).onPrintPOS();
    }
  });
}
