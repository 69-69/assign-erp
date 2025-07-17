import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/constants/app_enum.dart';
import 'package:assign_erp/core/widgets/adaptive_layout.dart';
import 'package:assign_erp/core/widgets/custom_dropdown_field.dart';
import 'package:assign_erp/core/widgets/custom_text_field.dart';
import 'package:assign_erp/features/customer_crm/presentation/screen/customers/widget/search_customer.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/products/widget/search_product.dart';
import 'package:flutter/material.dart';

/// ProductId & UnitPrice TextField/Dropdown [UnitPriceAndQuantityInput]
class UnitPriceAndQuantityInput extends StatelessWidget {
  const UnitPriceAndQuantityInput({
    super.key,
    this.serverValue,
    required this.onUnitChanged,
    required this.onQtyChanged,
    required this.qtyController,
    required this.unitPriceController,
  });

  final String? serverValue;
  final ValueChanged onUnitChanged;
  final ValueChanged onQtyChanged;
  final TextEditingController qtyController;
  final TextEditingController unitPriceController;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        UnitPriceTextField(
          controller: unitPriceController,
          onChanged: onUnitChanged,
        ),
        QuantityTextField(controller: qtyController, onChanged: onQtyChanged),
      ],
    );
  }
}

/// ProductId & Customer TextField/Dropdown [CustomerAndProductId]
class CustomerAndProductId extends StatelessWidget {
  const CustomerAndProductId({
    super.key,
    this.serverProduct,
    this.serverCustomer,
    required this.onProductChanged,
    required this.onCustomerChanged,
  });

  final String? serverProduct;
  final String? serverCustomer;
  final ValueChanged onProductChanged;
  final Function(String, String) onCustomerChanged;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SearchProducts(
          isDropdown: true,
          serverValue: serverProduct,
          onChanged: onProductChanged,
        ),
        CustomerIDInput(
          serverValue: serverCustomer,
          onChanged: onCustomerChanged,
        ),
      ],
    );
  }
}

/// Order Status & SubTotal Dropdown [SubTotalAndOrderStatus]
class SubTotalAndOrderStatus extends StatelessWidget {
  final String? serverStatus;
  final Function(String)? onSubTotalChange;
  final void Function(dynamic s) onStatusChange;
  final TextEditingController subTotalController;

  const SubTotalAndOrderStatus({
    super.key,
    this.serverStatus,
    required this.onSubTotalChange,
    required this.onStatusChange,
    required this.subTotalController,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SubTotalTextField(
          controller: subTotalController,
          onChanged: onSubTotalChange,
        ),
        OrdersStatusDropdown(
          serverValue: serverStatus,
          onChange: onStatusChange,
        ),
      ],
    );
  }
}

/// Remarks & Total Amount TextField [TotalAmountAndPaymentMethod]
class TotalAmountAndPaymentMethod extends StatelessWidget {
  final TextEditingController? totalAmtController;
  final ValueChanged? onTotalAmtChanged;
  final VoidCallback? onEdited;
  final bool? enable;
  final ValueChanged onPaymentChanged;
  final String? serverValue;

  const TotalAmountAndPaymentMethod({
    super.key,
    this.totalAmtController,
    this.onTotalAmtChanged,
    this.onEdited,
    this.enable,
    this.serverValue,
    required this.onPaymentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TotalAmountTextField(
          enable: enable,
          onEdited: onEdited,
          controller: totalAmtController,
          onChanged: onTotalAmtChanged,
        ),
        PaymentMethodDropdown(
          serverValue: serverValue,
          onChanged: onPaymentChanged,
        ),
      ],
    );
  }
}

/// TaxPercent & Delivery Amount TextField [TaxPercentAndDiscountPercentInput]
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
        CustomTextField(
          controller: discountController,
          onChanged: onDiscountChanged,
          keyboardType: TextInputType.number,
          inputDecoration: InputDecoration(
            labelText: 'Discount Percent (Optional)',
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

/// Customer ID TextField [CustomerIDInput]
class CustomerIDInput extends StatelessWidget {
  const CustomerIDInput({super.key, this.serverValue, required this.onChanged});

  final String? serverValue;
  final Function(String, String) onChanged;

  @override
  Widget build(BuildContext context) {
    return SearchCustomer(serverValue: serverValue, onChanged: onChanged);
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
  final Function(String)? onChanged;

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

/// Payment Method Dropdown [PaymentMethodDropdown]
class PaymentMethodDropdown extends StatelessWidget {
  final String? serverValue;
  final void Function(dynamic s) onChanged;

  const PaymentMethodDropdown({
    super.key,
    required this.onChanged,
    this.serverValue,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDropdown(
      key: key,
      items: paymentTerms,
      labelText: 'payment terms',
      serverValue: serverValue,
      onValueChange: (String? v) => onChanged(v),
    );
  }
}

/// Orders Status [OrdersStatusDropdown]
class OrdersStatusDropdown extends StatelessWidget {
  final String? serverValue;
  final void Function(dynamic s) onChange;

  const OrdersStatusDropdown({
    super.key,
    required this.onChange,
    this.serverValue,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDropdown(
      key: key,
      items: orderStatus,
      labelText: 'order status',
      serverValue: serverValue,
      onValueChange: (String? v) => onChange(v),
    );
  }
}
