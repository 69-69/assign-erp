import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/custom_search_delegate.dart';
import 'package:assign_erp/core/widgets/dialog/prompt_user_for_action.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/inventory_ims/data/models/product_model.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/product/product_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchPosProducts extends StatelessWidget {
  const SearchPosProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return context.buildFloatingBtn(
      '',
      icon: Icons.search,
      tooltip: 'Search Product',
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15),
          topLeft: Radius.circular(15),
        ),
      ),
      onPressed: () async {
        final productBloc = ProductBloc(firestore: FirebaseFirestore.instance);
        final List<Product> allData = []; // Populate with actual data

        if (context.mounted) {
          showSearch(
            context: context,
            delegate: CustomSearchDelegate<Product>(
              firestoreBloc: productBloc,
              allData: allData,
              field: 'name',
              optField: 'category',
              auxField: 'barcode',
              hintText: 'Search...by name, category, barcode...',
              onChanged: (s) {
                Product product = s as Product;
                _buildShowSearchResults(context, product);
              },
            ),
          );
          /*showSearch(
            context: context,
            delegate: CustomSearchDelegate<Product>(
              firestoreBloc: productBloc,
              allData: allData,
              field: 'name',
              optField: 'category',
              auxField: 'expiryDate',
              hintText: 'Search by name, category, expiry-date',
              onChanged: (s) {
                Product product = s as Product;

                context.openAddOrders(product: product);
              },
            ),
          );*/
        }
        const SearchPosProducts();
      },
    );
  }

  Future<void> _buildShowSearchResults(BuildContext context, Product product) {
    return context.confirmDone(
      Wrap(
        direction: Axis.vertical,
        children: [
          Text(
            product.name.toTitleCase,
            textAlign: TextAlign.start,
            style: context.textTheme.titleLarge,
          ),

          RichText(
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: 'Price ',
              style: context.textTheme.titleSmall,
              children: [
                TextSpan(
                  text: '$ghanaCedis${product.sellingPrice}\n',
                  style: context.textTheme.titleSmall?.copyWith(
                    color: kTextColor,
                  ),
                ),
                TextSpan(
                  text: product.category.toTitleCase,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: kTextColor,
                  ),
                ),
                if (product.barcode.isNotEmpty) ...{
                  TextSpan(
                    text: '\nCode: ${product.barcode}',
                    style: context.textTheme.titleSmall?.copyWith(
                      color: kTextColor,
                    ),
                  ),
                },
              ],
            ),
          ),
        ],
      ),
      title: "Product Search",
      onDone: "Close",
    );
  }
}
