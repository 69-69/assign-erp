import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/custom_dropdown_field.dart';
import 'package:assign_erp/features/setup/data/data_sources/remote/get_stores.dart';
import 'package:assign_erp/features/setup/data/models/company_stores_model.dart';
import 'package:flutter/material.dart';

/// Search Stores [SearchStores]
class SearchStores extends StatelessWidget {
  final String? serverValue;
  final Function(String, String) onChanged;

  const SearchStores({super.key, this.serverValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CustomDropdownSearch<CompanyStores>(
      labelText: (serverValue ?? 'Assign Store locations...').toTitleCase,
      asyncItems: (String filter, loadProps) async =>
          await GetStores.byAnyTerm(filter),
      filterFn: (store, filter) {
        // var f = filter.isEmpty ? (serverValue ?? '') : filter;
        return store.filterByAny(filter);
      },
      itemAsString: (store) => store.itemAsString,
      onChanged: (store) => onChanged(store!.storeNumber, store.name),
      validator: (store) => store == null ? 'Assign Store location' : null,
    );
  }
}
