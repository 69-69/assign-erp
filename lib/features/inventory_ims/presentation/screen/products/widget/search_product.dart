import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/custom_dropdown_field.dart';
import 'package:assign_erp/features/inventory_ims/data/data_sources/remote/get_products.dart';
import 'package:assign_erp/features/inventory_ims/data/models/product_model.dart';
import 'package:flutter/material.dart';

/// Search Product to add to Order Processing [SearchProducts]
class SearchProducts extends StatelessWidget {
  final bool isDropdown;
  final String? serverValue;
  final ValueChanged? onChanged;

  const SearchProducts({
    super.key,
    this.onChanged,
    this.serverValue,
    this.isDropdown = false,
  });

  @override
  Widget build(BuildContext context) {
    /// Search for Products to Add to Order Processing
    return isDropdown
        ? _buildDropdownSearch(context)
        : _buildAppbarSearch(context);
  }

  CustomDropdownSearch<Product> _buildDropdownSearch(BuildContext context) =>
      CustomDropdownSearch<Product>(
        labelText: serverValue ?? 'Search Product...',
        asyncItems: (String filter, loadProps) async =>
            await GetProducts.byAnyTerm(filter),
        filterFn: (product, filter) {
          var f = filter.isEmpty ? (serverValue ?? '') : filter;
          return product.filterByAny(f);
        },
        itemAsString: (Product product) => product.toString().toTitleCase,
        onChanged: (product) => onChanged!(product),
        validator: (product) =>
            product == null ? 'Please choose product' : null,
      );

  _buildAppbarSearch(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        onPressed: () async {
          // final productBloc = ProductBloc(firestore: FirebaseFirestore.instance);

          // Ensure to wait for the data to be loaded
          // final allData = await GetProducts.load();

          if (context.mounted) {
            /*showSearch(
              context: context,
              delegate: CustomSearchDelegate<Product>(
                firestoreBloc: productBloc,
                allData: allData,
                field: 'name',
                optField: 'category',
                auxField: 'expiryDate',
                hintText:'Search by name, category, expiry-date',
                onChanged: (s) {
                  Product product = s as Product;

                  context.openAddOrders(product: product);
                },
              ),
            );*/
          }
        },
        icon: const Icon(Icons.search),
        label: const Text('Find Product'),
      ),
    );
  }
}
