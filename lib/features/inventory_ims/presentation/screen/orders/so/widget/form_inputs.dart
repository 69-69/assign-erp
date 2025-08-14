import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/constants/app_enum.dart';
import 'package:assign_erp/core/util/date_time_picker.dart';
import 'package:assign_erp/core/widgets/button/custom_dropdown_field.dart';
import 'package:assign_erp/core/widgets/custom_text_field.dart';
import 'package:assign_erp/core/widgets/layout/adaptive_layout.dart';
import 'package:assign_erp/features/customer_crm/presentation/screen/customers/widget/search_customer.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/products/widget/search_product.dart';
import 'package:flutter/material.dart';

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

/// ProductId & Quantity TextField/Dropdown [ProductIdAndQuantityInput]
class ProductIdAndQuantityInput extends StatelessWidget {
  const ProductIdAndQuantityInput({
    super.key,
    this.serverValue,
    required this.onChanged,
    required this.onQtyChanged,
    required this.qtyController,
  });

  final String? serverValue;
  final ValueChanged onChanged;
  final ValueChanged onQtyChanged;
  final TextEditingController qtyController;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SearchProducts(
          isDropdown: true,
          serverValue: serverValue,
          onChanged: onChanged,
        ),
        QuantityTextField(controller: qtyController, onChanged: onQtyChanged),
      ],
    );
  }
}

/// Order Status & Order Types Dropdown [_OrderStatusAndTypesDropdown]
class OrderStatusAndTypesDropdown extends StatelessWidget {
  final String? serverType;
  final void Function(dynamic s) onTypeChange;
  final String? serverStatus;
  final void Function(dynamic s) onStatusChange;

  const OrderStatusAndTypesDropdown({
    super.key,
    this.serverType,
    this.serverStatus,
    required this.onTypeChange,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OrdersTypesDropdown(
          serverValue: serverType,
          onValueChange: onTypeChange,
        ),
        OrdersStatusDropdown(
          serverValue: serverStatus,
          onChange: onStatusChange,
        ),
      ],
    );
  }
}

/// Shipping & Delivery Date TextField [ShippingAndDeliveryDateInput]
class ShippingAndDeliveryDateInput extends StatelessWidget {
  const ShippingAndDeliveryDateInput({
    super.key,
    this.labelDelivery,
    this.labelShipping,
    this.onQuantityChanged,
    required this.onDeliveryChanged,
    required this.onShippingChanged,
    this.serverDeliveryDate,
    this.serverShippingDate,
  });

  final String? serverDeliveryDate;
  final String? serverShippingDate;
  final String? labelDelivery;
  final String? labelShipping;
  final ValueChanged? onQuantityChanged;
  final Function(DateTime) onDeliveryChanged;
  final Function(DateTime) onShippingChanged;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DatePicker(
          serverDate: serverShippingDate,
          label: labelShipping,
          restorationId: 'Shipping date',
          selectedDate: onShippingChanged,
          helperText: 'Optional',
        ),
        DatePicker(
          serverDate: serverDeliveryDate,
          label: labelDelivery,
          restorationId: 'Delivery date',
          selectedDate: onDeliveryChanged,
          helperText: 'Optional',
        ),
      ],
    );
  }
}

/// Validity date And Order-Source TextField/Dropdown [ValidityAndOrderSource]
class ValidityAndOrderSource extends StatelessWidget {
  const ValidityAndOrderSource({
    super.key,
    this.labelValidity,
    this.serverOrderSource,
    this.serverValidityDate,
    required this.onSourceChanged,
    required this.onValidityChanged,
  });

  final String? serverOrderSource;
  final String? serverValidityDate;
  final String? labelValidity;
  final Function(String?) onSourceChanged;
  final Function(DateTime) onValidityChanged;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomDropdown(
          key: key,
          items: orderSources,
          labelText: 'order source',
          serverValue: serverOrderSource,
          onValueChange: (String? v) => onSourceChanged(v),
        ),
        DatePicker(
          serverDate: serverValidityDate,
          label: labelValidity ?? 'Validity date',
          restorationId: 'Validity date',
          selectedDate: onValidityChanged,
          helperText: 'Optional',
        ),
      ],
    );
  }
}

/// SubTotal & UnitPrice TextField [_SubTotalAndUnitPriceInput]
class SubTotalAndUnitPriceInput extends StatelessWidget {
  const SubTotalAndUnitPriceInput({
    super.key,
    required this.unitPriceController,
    required this.subTotalController,
    this.onUnitPriceChanged,
    this.onSubTotalChanged,
  });

  final TextEditingController unitPriceController;
  final TextEditingController subTotalController;
  final ValueChanged? onUnitPriceChanged;
  final ValueChanged? onSubTotalChanged;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        UnitPriceTextField(
          controller: unitPriceController,
          onChanged: onUnitPriceChanged,
        ),
        SubTotalTextField(
          controller: subTotalController,
          onChanged: onSubTotalChanged,
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

/// Amount Paid & PaymentStatus Dropdown/TextField [AmountPaidAndPaymentStatusDropdown]
class AmountPaidAndPaymentStatusDropdown extends StatelessWidget {
  const AmountPaidAndPaymentStatusDropdown({
    super.key,
    required this.amountPaidController,
    required this.onAmountPaidChanged,
    required this.onStatusChanged,
    this.serverStatus,
  });

  final String? serverStatus;
  final ValueChanged onStatusChanged;
  final ValueChanged onAmountPaidChanged;
  final TextEditingController amountPaidController;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AmountPaidTextField(
          controller: amountPaidController,
          onChanged: onAmountPaidChanged,
        ),
        PaymentStatusDropdown(
          serverValue: serverStatus,
          onChanged: onStatusChanged,
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DeliveryAmountTextField(
          controller: deliveryController,
          onChanged: onChanged,
        ),
        PaymentTermDropdown(
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

/// Payment Terms Dropdown [PaymentTermDropdown]
class PaymentTermDropdown extends StatelessWidget {
  final String? serverValue;
  final void Function(dynamic s) onChanged;

  const PaymentTermDropdown({
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

/// Orders Status [OrdersTypesDropdown]
class OrdersTypesDropdown extends StatelessWidget {
  final String? serverValue;
  final void Function(dynamic s) onValueChange;

  const OrdersTypesDropdown({
    super.key,
    required this.onValueChange,
    this.serverValue,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDropdown(
      key: key,
      items: orderTypes,
      labelText: 'order type',
      serverValue: serverValue,
      onValueChange: (String? v) => onValueChange(v),
    );
  }
}
