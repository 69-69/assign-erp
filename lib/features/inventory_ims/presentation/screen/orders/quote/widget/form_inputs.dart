import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/constants/app_enum.dart';
import 'package:assign_erp/core/util/date_time_picker.dart';
import 'package:assign_erp/core/widgets/button/custom_dropdown_field.dart';
import 'package:assign_erp/core/widgets/custom_text_field.dart';
import 'package:assign_erp/core/widgets/layout/adaptive_layout.dart';
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

/// Quantity & RFQStatus Dropdown TextField [QuantityAndRFQStatusDropdown]
class QuantityAndRFQStatusDropdown extends StatelessWidget {
  const QuantityAndRFQStatusDropdown({
    super.key,
    this.onQuantityChanged,
    required this.onStatusChanged,
    this.serverStatus,
    this.quantityController,
  });

  final String? serverStatus;
  final ValueChanged? onQuantityChanged;
  final void Function(dynamic) onStatusChanged;
  final TextEditingController? quantityController;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        QuantityTextField(
          controller: quantityController,
          onChanged: onQuantityChanged,
        ),
        RFQStatusDropdown(serverValue: serverStatus, onChange: onStatusChanged),
      ],
    );
  }
}

/// NetPrice & RFQStatus Dropdown TextField [NetPriceAndRFQStatusDropdown]
class NetPriceAndRFQStatusDropdown extends StatelessWidget {
  const NetPriceAndRFQStatusDropdown({
    super.key,
    this.onNetPriceChanged,
    required this.onStatusChanged,
    this.serverStatus,
    this.netPriceController,
  });

  final String? serverStatus;
  final ValueChanged? onNetPriceChanged;
  final void Function(dynamic) onStatusChanged;
  final TextEditingController? netPriceController;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        NetPriceTextField(
          controller: netPriceController,
          onChanged: onNetPriceChanged,
        ),
        RFQStatusDropdown(serverValue: serverStatus, onChange: onStatusChanged),
      ],
    );
  }
}

/// Deadline & Delivery Date TextField [DeadlineAndDeliveryDateInput]
class DeadlineAndDeliveryDateInput extends StatelessWidget {
  const DeadlineAndDeliveryDateInput({
    super.key,
    this.labelDelivery,
    this.labelDeadline,
    required this.onDeliveryChanged,
    required this.onDeadlineChanged,
    this.serverDeliveryDate,
    this.serverDeadlineDate,
  });

  final String? serverDeliveryDate;
  final String? serverDeadlineDate;
  final String? labelDelivery;
  final String? labelDeadline;
  final Function(DateTime) onDeliveryChanged;
  final Function(DateTime) onDeadlineChanged;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DatePicker(
          serverDate: serverDeliveryDate,
          label: labelDelivery,
          restorationId: 'Delivery date',
          selectedDate: onDeliveryChanged,
        ),
        DatePicker(
          serverDate: serverDeadlineDate,
          label: labelDeadline,
          restorationId: 'Deadline date',
          selectedDate: onDeadlineChanged,
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
    required this.onTaxChanged,
    this.discountController,
    required this.discountAmount,
    this.onDiscountChanged,
  });

  final double taxAmount;
  final ValueChanged onTaxChanged;
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
          onChanged: onTaxChanged,
        ),
        DiscountPercentTextField(
          controller: discountController,
          discountAmount: discountAmount,
          onChanged: onDiscountChanged,
        ),
      ],
    );
  }
}

///********* TextFields *************///

/// [NetPriceTextField]
class NetPriceTextField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged? onChanged;

  const NetPriceTextField({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      labelText: 'Net price',
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      validator: (v) => null,
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

/// Request for Price Quote Status [RFQStatusDropdown]
class RFQStatusDropdown extends StatelessWidget {
  final String? serverValue;
  final void Function(dynamic s) onChange;

  const RFQStatusDropdown({
    super.key,
    required this.onChange,
    this.serverValue,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDropdown(
      key: key,
      items: ['quote status', ...requestForQuoteStatus],
      labelText: 'quote status',
      serverValue: serverValue,
      onValueChange: (String? v) => onChange(v),
    );
  }
}
