import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/custom_dropdown_field.dart';
import 'package:assign_erp/features/setup/data/data_sources/remote/get_category.dart';
import 'package:assign_erp/features/setup/data/models/category_model.dart';
import 'package:flutter/material.dart';

/// Search Product Categories [SearchCategory]
class SearchCategory extends StatelessWidget {
  final String? serverValue;
  final Function(String, String) onChanged;

  const SearchCategory({super.key, this.serverValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    /*return CustomDropdown(
      key: key,
      items: category,
      labelText: 'Search Category',
      serverValue: serverValue,
      onValueChange: (String? v) => onChanged,
    );*/
    return CustomDropdownSearch<Category>(
      labelText: (serverValue ?? 'Search Category...').toTitleCase,
      asyncItems: (String filter, loadProps) async =>
          await GetProductCategory.load(),
      filterFn: (category, filter) {
        var f = filter.isEmpty ? (serverValue ?? '') : filter;
        return category.filterByAny(f);
      },
      itemAsString: (category) => category.itemAsString,
      onChanged: (category) => onChanged(category!.id, category.name),
      validator: (category) => category == null ? 'Category is required' : null,
    );
  }

  /*_getProductCategory() async {
    final categories = await GetProductCategory.load();
    return categories.map((m) => m.name).toList();
  }*/
}
