import 'package:assign_erp/core/util/date_time_picker.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/adaptive_layout.dart';
import 'package:assign_erp/core/widgets/custom_dropdown_field.dart';
import 'package:assign_erp/core/widgets/custom_text_field.dart';
import 'package:assign_erp/features/trouble_shooting/data/data_sources/remote/get_subscriptions.dart';
import 'package:assign_erp/features/trouble_shooting/data/models/subscription_model.dart';
import 'package:flutter/material.dart';

/// Subscription Name & Fee TextField [SubscriptionNameAndFee]
class SubscriptionNameAndFee extends StatelessWidget {
  const SubscriptionNameAndFee({
    super.key,
    this.enable,
    this.onFeeChanged,
    this.onNameChanged,
    required this.feeController,
    required this.nameController,
  });

  final TextEditingController nameController;
  final TextEditingController feeController;
  final ValueChanged? onNameChanged;
  final ValueChanged? onFeeChanged;
  final bool? enable;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomTextField(
          enable: enable,
          labelText: 'Subscription name',
          onChanged: onNameChanged,
          controller: nameController,
          keyboardType: TextInputType.name,
        ),
        SubscriptionFee(
          enable: enable,
          onSubscribeFeeChanged: onFeeChanged,
          subscribeFeeController: feeController,
        ),
      ],
    );
  }
}

/// Subscription Fee TextField [SubscriptionFee]
class SubscriptionFee extends StatelessWidget {
  const SubscriptionFee({
    super.key,
    this.enable,
    required this.onSubscribeFeeChanged,
    required this.subscribeFeeController,
  });

  final bool? enable;
  final TextEditingController subscribeFeeController;
  final ValueChanged? onSubscribeFeeChanged;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      enable: enable,
      labelText: 'Subscription Fee',
      onChanged: onSubscribeFeeChanged,
      controller: subscribeFeeController,
      keyboardType: TextInputType.number,
      inputDecoration: InputDecoration(
        hintText: 'Subscription Fee',
        label: const Text(
          'Subscription Fee',
          semanticsLabel: 'Subscription Fee',
        ),
        alignLabelWithHint: true,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: const Icon(Icons.payments, size: 15),
      ),
    );
  }
}

/// Subscription Licenses Dropdown [SubscriptionAndTotalDevicesDropdown]
class SubscriptionAndTotalDevicesDropdown extends StatelessWidget {
  final String? serverSub;
  final String? serverTotalDevices;
  final Function(String?) onTotalDevicesChanged;
  final Function(String, String, DateTime?, DateTime?) onChanged;

  const SubscriptionAndTotalDevicesDropdown({
    super.key,
    this.serverSub,
    required this.onChanged,
    this.serverTotalDevices,
    required this.onTotalDevicesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomDropdown(
          key: key,
          items: List.generate(20, (i) => '$i'),
          labelText: 'total devices',
          serverValue: serverTotalDevices,
          onValueChange: (String? v) => onTotalDevicesChanged(v),
        ),
        CustomDropdownSearch<Subscription>(
          labelText: (serverSub ?? 'Search Subscription...').toTitleCase,
          asyncItems: (String filter, loadProps) async =>
              await GetSubscriptions.load(),
          filterFn: (sub, filter) {
            var f = filter.isEmpty ? (serverSub ?? '') : filter;
            return sub.filterByAny(f);
          },
          itemAsString: (sub) => sub.itemAsString,
          onChanged: (sub) =>
              onChanged(sub!.id, sub.name, sub.effectiveFrom, sub.expiresOn),
          validator: (sub) => sub == null ? 'Subscription is required' : null,
        ),
      ],
    );
  }

  /*_getProductCategory() async {
    final categories = await GetProductCategory.load();
    return categories.map((m) => m.name).toList();
  }*/
}

/// Expiry & Effective Date Picker [EffectiveAndExpiryDateInput]
class EffectiveAndExpiryDateInput extends StatelessWidget {
  const EffectiveAndExpiryDateInput({
    super.key,
    this.labelExpiry,
    this.labelManufacture,
    this.onQuantityChanged,
    required this.onExpiryChanged,
    required this.onEffectiveChanged,
    this.serverExpiryDate,
    this.serverEffectiveDate,
  });

  final String? serverExpiryDate;
  final String? serverEffectiveDate;
  final String? labelExpiry;
  final String? labelManufacture;
  final ValueChanged? onQuantityChanged;
  final Function(DateTime) onExpiryChanged;
  final Function(DateTime) onEffectiveChanged;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DatePicker(
          serverDate: serverEffectiveDate,
          label: labelManufacture,
          restorationId: 'Effective date',
          selectedDate: onEffectiveChanged,
        ),
        DatePicker(
          serverDate: serverExpiryDate,
          label: labelExpiry,
          restorationId: 'Expiry date',
          selectedDate: onExpiryChanged,
        ),
      ],
    );
  }
}
