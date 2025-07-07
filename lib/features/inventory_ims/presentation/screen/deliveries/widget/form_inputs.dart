import 'package:assign_erp/core/constants/app_enum.dart';
import 'package:assign_erp/core/util/adaptive_layout.dart';
import 'package:assign_erp/core/widgets/custom_dropdown_field.dart';
import 'package:assign_erp/core/widgets/custom_text_field.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/orders/so/widget/search_orders.dart';
import 'package:flutter/material.dart';

/// Delivery Person & phone TextField [DeliveryPersonAndPhoneInput]
class DeliveryPersonAndPhoneInput extends StatelessWidget {
  const DeliveryPersonAndPhoneInput({
    super.key,
    required this.deliveryPersonController,
    required this.deliveryPhoneController,
    this.onPersonChanged,
    this.onPhoneChanged,
  });

  final TextEditingController deliveryPersonController;
  final TextEditingController deliveryPhoneController;
  final ValueChanged? onPhoneChanged;
  final ValueChanged? onPersonChanged;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DeliveryPersonTextField(
          controller: deliveryPersonController,
          onChanged: onPersonChanged,
        ),
        DeliveryPhoneTextField(
          controller: deliveryPhoneController,
          onChanged: onPhoneChanged,
        ),
      ],
    );
  }
}

/// Order Status & Order Types Dropdown [DeliveryStatusAndTypesDropdown]
class DeliveryStatusAndTypesDropdown extends StatelessWidget {
  final String? serverType;
  final void Function(dynamic s) onTypeChange;
  final String? serverStatus;
  final void Function(dynamic s) onStatusChange;

  const DeliveryStatusAndTypesDropdown({
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
        DeliveryTypeDropdown(
          serverType: serverType,
          onValueChange: onTypeChange,
        ),
        DeliveryStatusDropdown(
          serverStatus: serverStatus,
          onChange: onStatusChange,
        ),
      ],
    );
  }
}

///********* TextFields *************///

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

/// Search Order Number TextField [OrderNumberDropdown]
class OrderNumberDropdown extends StatelessWidget {
  const OrderNumberDropdown({
    super.key,
    this.serverValue,
    required this.onChanged,
  });

  final String? serverValue;
  final Function(String, String) onChanged;

  @override
  Widget build(BuildContext context) {
    return SearchOrders(
      isDropdown: true,
      serverValue: serverValue,
      onChanged: onChanged,
    );
  }
}

/// [DeliveryPersonTextField]
class DeliveryPersonTextField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged? onChanged;

  const DeliveryPersonTextField({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      labelText: 'Delivery person',
      controller: controller,
      onChanged: onChanged,
      helperText: 'Optional',
      keyboardType: TextInputType.name,
      validator: (s) => null,
    );
  }
}

/// [DeliveryPhoneTextField]
class DeliveryPhoneTextField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged? onChanged;

  const DeliveryPhoneTextField({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      labelText: 'Delivery phone',
      helperText: 'Optional',
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.phone,
      validator: (s) => null,
    );
  }
}

/// Delivery Transportation [DeliveryTypeDropdown]
class DeliveryTypeDropdown extends StatelessWidget {
  final void Function(dynamic s) onValueChange;
  final String? serverType;

  const DeliveryTypeDropdown({
    super.key,
    required this.onValueChange,
    this.serverType,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDropdown(
      key: key,
      items: deliveryTypes,
      labelText: 'delivery type',
      serverValue: serverType,
      onValueChange: (String? v) => onValueChange(v),
    );
  }
}

/// Delivery Status [DeliveryStatusDropdown]
class DeliveryStatusDropdown extends StatelessWidget {
  final void Function(dynamic s) onChange;
  final String? serverStatus;

  const DeliveryStatusDropdown({
    super.key,
    required this.onChange,
    this.serverStatus,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDropdown(
      key: key,
      items: deliveryStatus,
      labelText: 'delivery status',
      serverValue: serverStatus,
      onValueChange: (String? v) => onChange(v),
    );
  }
}
