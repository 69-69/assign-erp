import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/barcode_scanner.dart';
import 'package:assign_erp/core/widgets/button/custom_button.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/dialog/custom_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/dialog/form_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/inventory_ims/data/models/product_model.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/inventory_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/product/product_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/products/widget/form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension UpdateProductForm on BuildContext {
  Future<void> openUpdateProduct({required Product product}) => openBottomSheet(
    isExpand: false,
    child: FormBottomSheet(
      title: 'Edit Product',
      subtitle: product.name.toTitleCase,
      body: _UpdateProductForm(product: product),
    ),
  );
}

class _UpdateProductForm extends StatefulWidget {
  final Product product;

  const _UpdateProductForm({required this.product});

  @override
  State<_UpdateProductForm> createState() => _UpdateProductFormState();
}

class _UpdateProductFormState extends State<_UpdateProductForm> {
  Product get _product => widget.product;

  String? _selectedCategory;
  String? _selectedSupplierId;
  DateTime? _selectedExpiryDate;
  DateTime? _selectedManufactureDate;

  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: _product.name);
  late final _skuController = TextEditingController(text: _product.sku);
  late final _batchIdController = TextEditingController(text: _product.batchId);
  late final _sellingPriceController = TextEditingController(
    text: '${_product.sellingPrice}',
  );
  late final _discountPercentController = TextEditingController(
    text: '${_product.discountPercent}',
  );
  late final _inStockController = TextEditingController(
    text: '${_product.inStock}',
  );
  late final _quantityController = TextEditingController(
    text: '${_product.quantity}',
  );
  late final _barcodeController = TextEditingController(text: _product.barcode);
  late final _costPriceController = TextEditingController(
    text: '${_product.costPrice}',
  );
  late final _manufacturerController = TextEditingController(
    text: _product.manufacturer,
  );
  late final _remarksController = TextEditingController(text: _product.remarks);

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _batchIdController.dispose();
    _sellingPriceController.dispose();
    _inStockController.dispose();
    _quantityController.dispose();
    _costPriceController.dispose();
    _discountPercentController.dispose();
    _manufacturerController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Product get _productData => _product.copyWith(
    name: _nameController.text,
    barcode: _barcodeController.text,
    sku: _skuController.text,
    batchId: _batchIdController.text,
    supplierId: _selectedSupplierId,
    category: _selectedCategory ?? _product.category,
    costPrice: double.tryParse(_costPriceController.text) ?? _product.costPrice,
    sellingPrice:
        double.tryParse(_sellingPriceController.text) ?? _product.sellingPrice,
    discountPercent:
        double.tryParse(_discountPercentController.text) ??
        _product.discountPercent,
    inStock: _strToInt(_inStockController.text) ?? _product.inStock,
    quantity: _strToInt(_quantityController.text) ?? _product.quantity,
    expiryDate: _selectedExpiryDate ?? _product.expiryDate,
    manufactureDate: _selectedManufactureDate ?? _product.manufactureDate,
    manufacturer: _manufacturerController.text,
    remarks: _remarksController.text,
    storeNumber: _product.storeNumber,
    createdBy: _product.createdBy,
    updatedBy: context.employee!.fullName,
  );

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      final item = _productData;

      /// Update product
      context.read<ProductBloc>().add(
        UpdateInventory<Product>(documentId: _product.id, data: item),
      );

      // _formKey.currentState!.reset();

      context.showAlertOverlay(
        '${_product.name.toTitleCase} has been successfully updated',
      );

      Navigator.of(context).pop();
    }
  }

  /// Update Category Status
  void _updateCategory(category) {
    _product.copyWith(category: category);
    setState(() => _selectedCategory = category);

    /// Update Category Status
    context.read<ProductBloc>().add(
      UpdateInventory<Product>(
        documentId: _product.id,
        mapData: {'category': category},
      ),
    );

    context.showAlertOverlay('Changes saved');
  }

  @override
  Widget build(BuildContext context) {
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
        Text('Update Category', style: context.textTheme.titleLarge),
        const SizedBox(height: 10.0),
        CategoryDropdown(
          key: const Key('Update-Category'),
          serverValue: _product.category,
          onChange: (id, name) => _updateCategory(name),
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
        'Modify this Product',
        textAlign: TextAlign.center,
        style: context.textTheme.titleLarge,
      ),
      subtitle: Text(_product.name.toTitleCase, textAlign: TextAlign.center),
      childrenPadding: const EdgeInsets.only(bottom: 20.0),
      children: <Widget>[
        const SizedBox(height: 20),
        BatchIdAndSKUInput(
          batchController: _batchIdController,
          skuController: _skuController,
          onBatchChanged: (i) {
            if (_formKey.currentState?.validate() ?? false) {
              setState(() {});
            }
          },
          onSkuChanged: (i) {
            if (_formKey.currentState?.validate() ?? false) {
              setState(() {});
            }
          },
        ),
        const SizedBox(height: 20.0),
        NameAndSupplierIDInput(
          nameController: _nameController,
          serverSupplierID: _product.supplierId,
          onNameChanged: (i) {
            if (_formKey.currentState!.validate()) {
              setState(() {});
            }
          },
          onSupplierIdChange: (id, name) =>
              setState(() => _selectedSupplierId = id),
        ),
        const SizedBox(height: 20.0),
        CostAndSellingPriceInput(
          costPriceController: _costPriceController,
          sellingPriceController: _sellingPriceController,
          onCostPriceChanged: (i) {
            if (_formKey.currentState!.validate()) {
              setState(() {});
            }
          },
          onSellingPriceChanged: (i) {
            if (_formKey.currentState!.validate()) {
              setState(() {});
            }
          },
        ),
        const SizedBox(height: 20.0),
        DiscountPercentAndCategory(
          serverCategory: _product.category,
          discountController: _discountPercentController,
          onCategoryChange: (id, category) =>
              setState(() => _selectedCategory = category),
          onDiscountChanged: (i) {
            if (_formKey.currentState!.validate()) {
              setState(() {});
            }
          },
        ),
        const SizedBox(height: 20.0),
        InStockAndQuantityInput(
          qtyController: _quantityController,
          inStockController: _inStockController,
          onInStockChanged: (i) {
            if (_formKey.currentState!.validate()) {
              setState(() {});
            }
          },
          onQtyChanged: (s) {
            if (_formKey.currentState!.validate()) {
              setState(() {});
            }
          },
        ),
        const SizedBox(height: 20.0),
        ExpiryAndManufactureDateInput(
          labelExpiry: "Expiry date",
          labelManufacture: "Manufacture date",
          serverExpiryDate: _product.getExpiryDate,
          serverManufactureDate: _product.getManufactureDate,
          onExpiryChanged: (d) => setState(() => _selectedExpiryDate = d),
          onManufactureChanged: (d) =>
              setState(() => _selectedManufactureDate = d),
        ),
        const SizedBox(height: 20.0),
        BarcodeScannerWithTextField(
          controller: _barcodeController,
          onChanged: (t) => setState(() {}),
        ),
        const SizedBox(height: 20.0),
        // _barcodeScanner(),
        const SizedBox(height: 20.0),
        RemarksAndManufacturerTextField(
          remarksController: _remarksController,
          manufacturerController: _manufacturerController,
          onManufacturerChanged: (s) {
            if (_formKey.currentState!.validate()) {
              setState(() {});
            }
          },
          onRemarksChanged: (s) {
            if (_formKey.currentState!.validate()) {
              setState(() {});
            }
          },
        ),
        const SizedBox(height: 20.0),
        context.confirmableActionButton(onPressed: _onSubmit),

        /*if(_barcodes.isNotEmpty)...{
          ListView(
            padding: const EdgeInsets.only(top: 12.0),
            children: ListTile.divideTiles(
              context: context,
              tiles: _barcodes
                  .map(
                    (barcode) => ListTile(
                  title: Text(barcode.displayValue),
                  subtitle: Text(
                      '${barcode.getFormatString()} (${barcode.format}) - '
                          '${barcode.getValueFormatString()} (${barcode.valueFormat})'),
                ),
              )
                  .toList(),
            ).toList(),
          ),
        },*/
      ],
    );
  }

  int? _strToInt(s) => int.tryParse(s);

  /*BarcodeScanner _barcodeScanner() {
    return BarcodeScanner(
      childWidget: (void Function()? scanFunction, List<Barcode> barcodes) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted &&
              barcodes.isNotEmpty &&
              barcodes.first.displayValue.isNotEmpty) {
            debugPrint('steve ${barcodes.first.rawValue}');
            setState(
                () => _barcodeController.text = barcodes.first.displayValue);
          }
        });
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: BarcodeTextField(
                controller: _barcodeController,
                onChanged: (t) {
                  if (_formKey.currentState!.validate()) {
                    setState(() {});
                  }
                },
              ),
            ),
            const SizedBox(width: 10.0),
            ProductScanButton(onPressed: scanFunction),
          ],
        );
      },
    );
  }*/
}
