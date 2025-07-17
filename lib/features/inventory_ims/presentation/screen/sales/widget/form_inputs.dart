import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/constants/app_enum.dart';
import 'package:assign_erp/core/widgets/adaptive_layout.dart';
import 'package:assign_erp/core/widgets/custom_dropdown_field.dart';
import 'package:assign_erp/core/widgets/custom_text_field.dart';
import 'package:assign_erp/features/customer_crm/presentation/screen/customers/widget/search_customer.dart';
import 'package:flutter/material.dart';

/// Order-Number And Product-Id TextField [OrderNumberAndProductIdInput]
class OrderNumberAndProductIdInput extends StatelessWidget {
  const OrderNumberAndProductIdInput({
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
      mainAxisSize: MainAxisSize.min,
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

/// Quantity & UnitPrice TextField [UnitPriceAndQuantityInput]
class UnitPriceAndQuantityInput extends StatelessWidget {
  const UnitPriceAndQuantityInput({
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
      mainAxisSize: MainAxisSize.min,
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

/// TaxPercent & Delivery Amount TextField [_TaxAndDeliveryInput]
class TaxAndDeliveryInput extends StatelessWidget {
  const TaxAndDeliveryInput({
    super.key,
    required this.deliveryController,
    required this.taxController,
    required this.taxAmount,
    required this.onChanged,
  });

  final double taxAmount;
  final ValueChanged onChanged;
  final TextEditingController taxController;
  final TextEditingController deliveryController;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TaxPercentTextField(
          controller: taxController,
          taxAmount: taxAmount,
          onChanged: onChanged,
        ),

        DeliveryAmountTextField(
          controller: deliveryController,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// TaxPercent & Delivery Amount TextField [InvoiceNumberAndCustomerId]
class InvoiceNumberAndCustomerId extends StatelessWidget {
  const InvoiceNumberAndCustomerId({
    super.key,
    required this.invoiceIdController,
    required this.onCustomerChanged,
    required this.onInvoiceNoChanged,
    this.serverCustomer,
  });

  final String? serverCustomer;
  final Function(String, String) onCustomerChanged;
  final ValueChanged onInvoiceNoChanged;
  final TextEditingController invoiceIdController;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InvoiceNumberTextField(
          controller: invoiceIdController,
          onChanged: onInvoiceNoChanged,
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

/// Delivery Amount And Payment Method TextField [DeliveryAmtPaymentMethodInput]
class DeliveryAmtPaymentMethodInput extends StatelessWidget {
  const DeliveryAmtPaymentMethodInput({
    super.key,
    this.serverValue,
    required this.onChanged,
    required this.onPaymentChanged,
    required this.deliveryController,
  });

  final ValueChanged onChanged;
  final ValueChanged onPaymentChanged;
  final String? serverValue;
  final TextEditingController deliveryController;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DeliveryAmountTextField(
          controller: deliveryController,
          onChanged: onChanged,
        ),
        PaymentTermsDropdown(
          serverValue: serverValue,
          onChanged: onPaymentChanged,
        ),
      ],
    );
  }
}

/// Sales Status And Payment Status TextField [SalesAndPaymentStatusDropdown]
class SalesAndPaymentStatusDropdown extends StatelessWidget {
  const SalesAndPaymentStatusDropdown({
    super.key,
    this.serverSale,
    this.serverPayment,
    required this.onSaleChanged,
    required this.onPaymentChanged,
  });

  final ValueChanged onSaleChanged;
  final ValueChanged onPaymentChanged;
  final String? serverPayment;
  final String? serverSale;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        PaymentStatusDropdown(
          serverValue: serverPayment,
          onChanged: onPaymentChanged,
        ),
        SalesStatusDropdown(serverValue: serverSale, onChanged: onSaleChanged),
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
      mainAxisSize: MainAxisSize.min,
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

/// Remarks & Total Amount TextField [RemarksAndTotalAmtTextField]
class RemarksAndTotalAmtTextField extends StatelessWidget {
  final TextEditingController? remarksController;
  final TextEditingController? totalAmtController;
  final ValueChanged? onTotalAmtChanged;
  final ValueChanged? onRemarksChanged;
  final VoidCallback? onEdited;
  final bool? enable;

  const RemarksAndTotalAmtTextField({
    super.key,
    this.remarksController,
    this.onRemarksChanged,
    this.totalAmtController,
    this.onTotalAmtChanged,
    this.onEdited,
    this.enable,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TotalAmountTextField(
          enable: enable,
          onEdited: onEdited,
          controller: totalAmtController,
          onChanged: onTotalAmtChanged,
        ),
        RemarksTextField(
          controller: remarksController,
          onChanged: onRemarksChanged,
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

///********* TextFields *************///

/// Payment Status Dropdown [PaymentStatusDropdown]
class PaymentStatusDropdown extends StatelessWidget {
  const PaymentStatusDropdown({
    super.key,
    this.serverValue,
    required this.onChanged,
  });

  final ValueChanged onChanged;
  final String? serverValue;

  @override
  Widget build(BuildContext context) {
    return CustomDropdown(
      key: key,
      items: paymentStatus,
      labelText: 'payment status',
      serverValue: serverValue,
      onValueChange: (String? v) => onChanged(v),
    );
  }
}

/// Orders Status [SalesStatusDropdown]
class SalesStatusDropdown extends StatelessWidget {
  final String? serverValue;
  final void Function(dynamic s) onChanged;

  const SalesStatusDropdown({
    super.key,
    required this.onChanged,
    this.serverValue,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDropdown(
      key: key,
      items: saleStatus,
      labelText: 'sale status',
      serverValue: serverValue,
      onValueChange: (String? v) => onChanged(v),
    );
  }
}

/// Payment Terms Dropdown [PaymentTermsDropdown]
class PaymentTermsDropdown extends StatelessWidget {
  final String? serverValue;
  final void Function(dynamic s) onChanged;

  const PaymentTermsDropdown({
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

/// [DiscountTextField]
class DiscountTextField extends StatelessWidget {
  final TextEditingController? controller;
  final double discountAmount;
  final ValueChanged? onChanged;

  const DiscountTextField({
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
        labelText: 'Discount Percent',
        suffixText: '= $ghanaCedis $discountAmount',
        prefixIcon: const Icon(Icons.percent),
        prefixIconColor: kGrayColor,
      ),
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

/// [DeliveryAmountTextField]
class DeliveryAmountTextField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged? onChanged;

  const DeliveryAmountTextField({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      labelText: 'Delivery amount',
      controller: controller,
      onChanged: onChanged,
      helperText: 'Optional',
      keyboardType: TextInputType.number,
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
    );
  }
}

/// [InvoiceNumberTextField]
class InvoiceNumberTextField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged? onChanged;

  const InvoiceNumberTextField({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      labelText: 'Invoice Number',
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.text,
    );
  }
}
