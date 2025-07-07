import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/constants/app_enum.dart';
import 'package:assign_erp/core/util/adaptive_layout.dart';
import 'package:assign_erp/core/util/date_time_picker.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/custom_dropdown_field.dart';
import 'package:assign_erp/core/widgets/custom_text_field.dart';
import 'package:assign_erp/features/setup/presentation/screen/product_config/widget/search_suppliers.dart';
import 'package:flutter/material.dart';

/// Customer ID TextField [SupplierIDInput]
class SupplierIDInput extends StatelessWidget {
  const SupplierIDInput({super.key, this.serverValue, required this.onChanged});

  final String? serverValue;
  final Function(String, String) onChanged;

  @override
  Widget build(BuildContext context) {
    return SearchSuppliers(serverValue: serverValue, onChanged: onChanged);
  }
}

/// Purchase Order Status & Payment Terms Dropdown [POStatusAndPaymentTermsDropdown]
class POStatusAndPaymentTermsDropdown extends StatelessWidget {
  final String? serverPay;
  final void Function(dynamic s) onPayChange;
  final String? serverStatus;
  final void Function(dynamic s) onStatusChange;

  const POStatusAndPaymentTermsDropdown({
    super.key,
    this.serverPay,
    this.serverStatus,
    required this.onPayChange,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        POStatusDropdown(serverValue: serverStatus, onChange: onStatusChange),
        CustomDropdown(
          key: key,
          items: paymentTerms,
          labelText: 'payment terms',
          serverValue: serverPay,
          onValueChange: (String? v) => onPayChange(v),
        ),
      ],
    );
  }
}

/// Delivery Date & Total Amount TextField [DeliveryDateAndTotalAmtInput]
class DeliveryDateAndTotalAmtInput extends StatelessWidget {
  const DeliveryDateAndTotalAmtInput({
    super.key,
    this.labelDelivery,
    required this.totalAmtController,
    required this.onDeliveryChanged,
    required this.onTotalAmtChanged,
    this.serverDeliveryDate,
    this.onEdited,
    this.enable,
  });

  final VoidCallback? onEdited;
  final bool? enable;
  final String? serverDeliveryDate;
  final String? labelDelivery;
  final TextEditingController totalAmtController;
  final ValueChanged? onTotalAmtChanged;
  final Function(DateTime) onDeliveryChanged;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DatePicker(
          serverDate: serverDeliveryDate,
          label: labelDelivery,
          restorationId: 'Delivery date',
          selectedDate: onDeliveryChanged,
          validator: (v) => v.isNullOrEmpty ? "Delivery date required" : null,
        ),
        TotalAmountTextField(
          enable: enable,
          onEdited: onEdited,
          controller: totalAmtController,
          onChanged: onTotalAmtChanged,
        ),
      ],
    );
  }
}

/// SubTotal & UnitPrice TextField [_SubTotalAndUnitPriceInput]
class UnitPriceAndQuantity extends StatelessWidget {
  const UnitPriceAndQuantity({
    super.key,
    required this.unitPriceController,
    required this.quantityController,
    this.onUnitPriceChanged,
    this.onQtyChanged,
  });

  final TextEditingController unitPriceController;
  final TextEditingController quantityController;
  final ValueChanged? onUnitPriceChanged;
  final ValueChanged? onQtyChanged;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        UnitPriceTextField(
          controller: unitPriceController,
          onChanged: onUnitPriceChanged,
        ),
        QuantityTextField(
          controller: quantityController,
          onChanged: onQtyChanged,
        ),
      ],
    );
  }
}

/// TaxPercent & DiscountPercent TextField [TaxPercentAndDiscountPercentInput]
class TaxPercentAndDiscountPercentInput extends StatelessWidget {
  const TaxPercentAndDiscountPercentInput({
    super.key,
    required this.taxController,
    required this.taxAmount,
    required this.onChanged,
    this.discountController,
    required this.discountAmount,
    this.onDiscountChanged,
  });

  final double taxAmount;
  final ValueChanged onChanged;
  final TextEditingController taxController;
  final TextEditingController? discountController;
  final double discountAmount;
  final ValueChanged? onDiscountChanged;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TaxPercentTextField(
          controller: taxController,
          taxAmount: taxAmount,
          onChanged: onChanged,
        ),
        CustomTextField(
          controller: discountController,
          onChanged: onDiscountChanged,
          keyboardType: TextInputType.number,
          inputDecoration: InputDecoration(
            labelText: 'Discount Percent (Optional)',
            // helperText: 'Optional',
            suffixText: '= $ghanaCedis $discountAmount',
            prefixIcon: const Icon(Icons.percent),
            prefixIconColor: kGrayColor,
          ),
          validator: (v) => null,
        ),
      ],
    );
  }
}

///********* TextFields *************///

/// [AmountPaidTextField]
class AmountPaidTextField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged? onChanged;

  const AmountPaidTextField({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      labelText: 'Amount paid',
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      validator: (v) => null,
    );
  }
}

/// [TotalAmountTextField]
class TotalAmountTextField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged? onChanged;
  final VoidCallback? onEdited;
  final bool? enable;

  const TotalAmountTextField({
    super.key,
    this.controller,
    this.onChanged,
    this.onEdited,
    this.enable,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: <Widget>[
        CustomTextField(
          enable: enable,
          controller: controller,
          onChanged: onChanged,
          labelText: 'Total amount',
          keyboardType: TextInputType.number,
        ),
        TextButton(
          onPressed: onEdited,
          style: TextButton.styleFrom(padding: const EdgeInsets.only(top: 15)),
          child: const Text('Edit'),
        ),
      ],
    );
  }
}

/// [RemarksTextField]
class RemarksTextField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged? onChanged;

  const RemarksTextField({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      labelText: 'Remarks...',
      helperText: 'Optional',
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.multiline,
      maxLines: 4,
      validator: (s) => null,
    );
  }
}

/// Product Desc or name [ProductDescTextField]
class ProductDescTextField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged? onChanged;

  const ProductDescTextField({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      labelText: 'Product name or description...',
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.text,
      maxLines: 2,
    );
  }
}

/// [QuantityTextField]
class QuantityTextField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged? onChanged;

  const QuantityTextField({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      labelText: 'Quantity',
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
    );
  }
}

/// [UnitPriceTextField]
class UnitPriceTextField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged? onChanged;

  const UnitPriceTextField({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      labelText: 'Unit price',
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
    );
  }
}

/// [SubTotalTextField]
class SubTotalTextField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged? onChanged;

  const SubTotalTextField({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      labelText: 'Sub total',
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
    );
  }
}

/// [DiscountPercentTextField]
class DiscountPercentTextField extends StatelessWidget {
  final TextEditingController? controller;
  final double discountAmount;
  final ValueChanged? onChanged;

  const DiscountPercentTextField({
    super.key,
    this.controller,
    this.discountAmount = 0.0,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      inputDecoration: InputDecoration(
        // helperText: 'Optional',
        labelText: 'Discount Percent (Optional)',
        suffixText: '= $ghanaCedis $discountAmount',
        prefixIcon: const Icon(Icons.percent),
        prefixIconColor: kGrayColor,
      ),
      validator: (v) => null,
    );
  }
}

/// [TaxPercentTextField]
class TaxPercentTextField extends StatelessWidget {
  final double taxAmount;
  final ValueChanged? onChanged;
  final TextEditingController? controller;

  const TaxPercentTextField({
    super.key,
    this.controller,
    this.taxAmount = 0.0,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      labelText: 'Tax Percent',
      onChanged: onChanged,
      controller: controller,
      keyboardType: TextInputType.number,
      inputDecoration: InputDecoration(
        labelText: 'Tax Percent (Optional)',
        // helperText: 'Optional',
        suffixText: '= $ghanaCedis $taxAmount',
        prefixIcon: const Icon(Icons.percent),
        prefixIconColor: kGrayColor,
      ),
      validator: (v) => null,
    );
  }
}

/// Orders Status [POStatusDropdown]
class POStatusDropdown extends StatelessWidget {
  final String? serverValue;
  final void Function(dynamic s) onChange;

  const POStatusDropdown({super.key, required this.onChange, this.serverValue});

  @override
  Widget build(BuildContext context) {
    return CustomDropdown(
      key: key,
      items: purchaseOrderStatus,
      labelText: 'order status',
      serverValue: serverValue,
      onValueChange: (String? v) => onChange(v),
    );
  }
}
