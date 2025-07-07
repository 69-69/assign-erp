import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/custom_dropdown_field.dart';
import 'package:assign_erp/features/setup/data/data_sources/remote/get_suppliers.dart';
import 'package:assign_erp/features/setup/data/models/supplier_model.dart';
import 'package:flutter/material.dart';

/// Search Suppliers [SearchSuppliers]
class SearchSuppliers extends StatelessWidget {
  final String? serverValue;
  final Function(String, String) onChanged;

  const SearchSuppliers({super.key, this.serverValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CustomDropdownSearch<Supplier>(
      labelText:
          (serverValue ?? 'Search Suppliers...').toUppercaseFirstLetterEach,
      asyncItems: (String filter, loadProps) async =>
          await GetSuppliers.byAnyTerm(filter),
      filterFn: (supplier, filter) {
        var f = filter.isEmpty ? (serverValue ?? '') : filter;
        return supplier.filterByAny(f);
      },
      itemAsString: (supplier) => supplier.itemAsString,
      onChanged: (supplier) => onChanged(supplier!.id, supplier.supplierName),
      validator: (supplier) => supplier == null ? 'Supplier is required' : null,
    );
  }
}
