import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/button/custom_dropdown_field.dart';
import 'package:assign_erp/features/customer_crm/data/data_sources/remote/get_customers.dart';
import 'package:assign_erp/features/customer_crm/data/models/customer_model.dart';
import 'package:flutter/material.dart';

/// Search Customer to place an Order [SearchCustomer]
class SearchCustomer extends StatelessWidget {
  final String? serverValue;
  final Function(String, String) onChanged;

  const SearchCustomer({super.key, this.serverValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CustomDropdownSearch<Customer>(
      labelText: (serverValue ?? 'Search Customer...').toTitleCase,
      asyncItems: (String filter, loadProps) async =>
          await GetAllCustomers.byAnyTerm(filter),
      filterFn: (customer, filter) {
        var f = filter.isEmpty ? (serverValue ?? '') : filter;
        return customer.filterByAny(f);
      },
      itemAsString: (customer) => customer.itemAsString,
      onChanged: (customer) => onChanged(customer!.customerId, customer.name),
      validator: (customer) => customer == null ? 'Please add customer' : null,
    );
  }
}
