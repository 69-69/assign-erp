import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/constants/app_enum.dart';
import 'package:assign_erp/core/util/adaptive_layout.dart';
import 'package:assign_erp/core/widgets/custom_dropdown_field.dart';
import 'package:assign_erp/core/widgets/custom_text_field.dart';
import 'package:assign_erp/features/customer_crm/presentation/screen/customers/widget/search_customer.dart';
import 'package:flutter/material.dart';

/// Order-Number And Product-Id TextField [OrderNumberAndProductId]
class OrderNumberAndProductId extends StatelessWidget {
  const OrderNumberAndProductId({
    super.key,
    required this.productIdController,
    required this.orderNumberController,
    required this.onProductIdChanged,
    required this.onIdChanged,
    this.enableOrderNumber,
    this.onOrderNumberEdited,
    this.enableProductId,
    this.onProductIdEdited,
  });

  final TextEditingController productIdController;
  final TextEditingController orderNumberController;
  final ValueChanged? onProductIdChanged;
  final ValueChanged? onIdChanged;
  final VoidCallback? onProductIdEdited;
  final VoidCallback? onOrderNumberEdited;
  final bool? enableProductId;
  final bool? enableOrderNumber;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ProductIdTextField(
          controller: productIdController,
          onChanged: onProductIdChanged,
          onEdited: onProductIdEdited,
          enable: enableProductId,
        ),
        OrderNumberTextField(
          controller: orderNumberController,
          onEdited: onOrderNumberEdited,
          onChanged: onIdChanged,
          enable: enableOrderNumber,
        ),
      ],
    );
  }
}

/// Quantity & UnitPrice TextField [UnitPriceAndQuantity]
class UnitPriceAndQuantity extends StatelessWidget {
  const UnitPriceAndQuantity({
    super.key,
    required this.unitPriceController,
    required this.quantityController,
    this.onUnitPriceChanged,
    this.onQuantityChanged,
  });

  final TextEditingController unitPriceController;
  final TextEditingController quantityController;
  final ValueChanged? onUnitPriceChanged;
  final ValueChanged? onQuantityChanged;

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
          onChanged: onQuantityChanged,
        ),
      ],
    );
  }
}

/// Orders Status [SaleStatusDropdown]
class SaleStatusDropdown extends StatelessWidget {
  final String? serverValue;
  final void Function(dynamic s) onStatusChange;

  const SaleStatusDropdown({
    super.key,
    required this.onStatusChange,
    this.serverValue,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDropdown(
      key: key,
      items: saleStatus,
      labelText: 'sale status',
      serverValue: serverValue,
      onValueChange: (String? v) => onStatusChange(v),
    );
  }
}

/// Receipt Number & CustomerId TextField [ReceiptNumberAndCustomerId]
class ReceiptNumberAndCustomerId extends StatelessWidget {
  const ReceiptNumberAndCustomerId({
    super.key,
    required this.receiptNoController,
    required this.onCustomerChanged,
    required this.onReceiptNoChanged,
    this.serverCustomer,
  });

  final String? serverCustomer;
  final Function(String, String) onCustomerChanged;
  final ValueChanged onReceiptNoChanged;
  final TextEditingController receiptNoController;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ReceiptNumberTextField(
          controller: receiptNoController,
          onChanged: onReceiptNoChanged,
        ),
        CustomerIdDropdown(
          serverValue: serverCustomer,
          onChanged: onCustomerChanged,
        ),
      ],
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
        labelText: 'Discount Percent (Optional)',
        suffixText: '= $ghanaCedis $discountAmount',
        prefixIcon: const Icon(Icons.percent),
        prefixIconColor: kGrayColor,
      ),
      validator: (v) => null,
    );
  }
}

/// Delivery Amount And Payment Method TextField [TotalAmtAndPaymentMethod]
class TotalAmtAndPaymentMethod extends StatelessWidget {
  const TotalAmtAndPaymentMethod({
    super.key,
    this.serverValue,
    required this.onChanged,
    required this.onPaymentChanged,
    required this.totalAmtController,
  });

  final ValueChanged onChanged;
  final ValueChanged onPaymentChanged;
  final String? serverValue;
  final TextEditingController totalAmtController;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TotalAmountTextField(
          controller: totalAmtController,
          onChanged: onChanged,
        ),
        PaymentMethodDropdown(
          serverValue: serverValue,
          onChanged: onPaymentChanged,
        ),
      ],
    );
  }
}

/// TaxPercent & Delivery Amount TextField [TaxPercentAndDiscountPercent]
class TaxPercentAndDiscountPercent extends StatelessWidget {
  const TaxPercentAndDiscountPercent({
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

/// Customer ID Dropdown [CustomerIdDropdown]
class CustomerIdDropdown extends StatelessWidget {
  const CustomerIdDropdown({
    super.key,
    this.serverValue,
    required this.onChanged,
  });

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

  const TotalAmountTextField({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      onChanged: onChanged,
      labelText: 'Total amount',
      keyboardType: TextInputType.number,
    );
  }
}

///********* TextFields *************///

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
        // helperText: 'Optional',
        labelText: 'Tax Percent (Optional)',
        suffixText: '= $ghanaCedis $taxAmount',
        prefixIcon: const Icon(Icons.percent),
        prefixIconColor: kGrayColor,
      ),
      validator: (v) => null,
    );
  }
}

/// [OrderNumberTextField]
class OrderNumberTextField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged? onChanged;
  final VoidCallback? onEdited;
  final bool? enable;

  const OrderNumberTextField({
    super.key,
    this.controller,
    this.onChanged,
    this.enable,
    this.onEdited,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: <Widget>[
        CustomTextField(
          enable: enable,
          labelText: 'Order Number',
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.text,
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

/// [ProductIdTextField]
class ProductIdTextField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged? onChanged;
  final VoidCallback? onEdited;
  final bool? enable;

  const ProductIdTextField({
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
          labelText: 'Product ID',
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.text,
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

/// [ReceiptNumberTextField]
class ReceiptNumberTextField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged? onChanged;

  const ReceiptNumberTextField({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      labelText: 'Receipt Number',
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.text,
    );
  }
}
