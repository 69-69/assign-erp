import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/widgets/dialog/prompt_user_for_action.dart';
import 'package:assign_erp/core/widgets/layout/adaptive_layout.dart';
import 'package:assign_erp/core/widgets/layout/dynamic_table.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/inventory_ims/data/models/product_model.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/inventory_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/product/product_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/products/add/add_product.dart';
import 'package:assign_erp/features/inventory_ims/presentation/screen/products/update/update_product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListExpired extends StatefulWidget {
  const ListExpired({super.key});

  @override
  State<ListExpired> createState() => _ListExpiredState();
}

class _ListExpiredState extends State<ListExpired> {
  final List<Product> _groupMultiDelete = [];

  /*@override
  void didUpdateWidget(ListExpired oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.barcode.isNotEmpty && widget.barcode != oldWidget.barcode) {
      _searchForScannedProduct(widget.barcode);
    }
  }*/

  // dataRepository: RepositoryProvider.of<DataRepository>(context),
  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  BlocBuilder<ProductBloc, InventoryState<Product>> _buildBody() {
    return BlocBuilder<ProductBloc, InventoryState<Product>>(
      builder: (context, state) {
        return switch (state) {
          LoadingInventory<Product>() => context.loader,
          InventoriesLoaded<Product>(data: var results) =>
            results.isEmpty
                ? context.buildAddButton(
                    'Add Stock',
                    onPressed: () => context.openAddProduct(),
                  )
                : _buildCard(context, results),
          InventoryError<Product>(error: var error) => context.buildError(
            error,
          ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  Widget _buildCard(BuildContext context, List<Product> products) {
    final expiredProducts = Product.findExpiredProduct(products);

    return DynamicDataTable(
      skip: true,
      showIDToggle: true,
      headers: Product.dataTableHeader,
      anyWidget: _buildAnyWidget(expiredProducts),
      rows: expiredProducts.map((p) => p.itemAsList()).toList(),
      onChecked: (bool? isChecked, row) => _onChecked(products, row, isChecked),
      onAllChecked:
          (
            bool isChecked,
            List<bool> isAllChecked,
            List<List<String>> checkedRows,
          ) {
            // if all unChecked, empty _groupReportsForPrintout List
            if (!isAllChecked.first) {
              setState(() => _groupMultiDelete.clear());
            }
            if (checkedRows.isNotEmpty) {
              for (int i = 0; i < checkedRows.length; i++) {
                _onChecked(products, checkedRows[i], isChecked);
              }
            }
          },
      onEditTap: (row) async => await _onEditTap(products, row),
      onDeleteTap: (row) async => await _onDeleteTap(row),
    );
  }

  _buildAnyWidget(List<Product> products) {
    return AdaptiveLayout(
      isFormBuilder: false,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        context.buildTotalItems(
          'Refresh Expired',
          label: 'Expired',
          count: products.length,
          onPressed: () {
            // Refresh Products Data
            context.read<ProductBloc>().add(RefreshInventories<Product>());
          },
        ),
        // final productBloc = context.read<ProductBloc>();
        // final productBloc = BlocProvider.of<ProductBloc>(context, listen: false);
        const SizedBox(height: 20),
        _IssueMultiDelete(
          products: _groupMultiDelete,
          onDone: (s) => setState(() => _groupMultiDelete.clear()),
        ),
      ],
    );
  }

  // Handle onChecked Deliveries
  void _onChecked(
    List<Product> products,
    List<String> row,
    bool? isChecked,
  ) async {
    setState(() {
      final product = products.firstWhere((p) => p.id == row.first);

      if (isChecked != null && isChecked) {
        _groupMultiDelete.add(product);
      } else {
        _groupMultiDelete.remove(product);
      }
    });
  }

  Future<void> _onEditTap(List<Product> products, List<String> row) async {
    final product = Product.findProductById(products, row.first).first;
    await context.openUpdateProduct(product: product);
  }

  Future<void> _onDeleteTap(List<String> row) async {
    {
      final productId = row.first;

      final isConfirmed = await context.confirmUserActionDialog();
      if (mounted && isConfirmed) {
        /// Remove product from stock
        context.read<ProductBloc>().add(
          DeleteInventory<String>(documentId: productId),
        );
      }
    }
  }
}

/// Delete grouped or multiple Products [_IssueMultiInvoicePrintout]
class _IssueMultiDelete extends StatelessWidget {
  final List<Product> products;
  final Function(bool) onDone;

  const _IssueMultiDelete({required this.products, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return products.isEmpty
        ? const SizedBox.shrink()
        : Center(child: _buildBody(context));
  }

  _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Wrap(
        spacing: 20,
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [_buildNote(), _buildDeleteButton(context)],
      ),
    );
  }

  Future<bool> _confirmDeleteDialog(BuildContext context) async {
    return context.confirmAction<bool>(
      const Text('Are you sure you want to delete the selected products?'),
      title: "Confirm Delete",
      onAccept: "Delete",
      onReject: "Cancel",
    );
  }

  ElevatedButton _buildDeleteButton(BuildContext context) {
    return ElevatedButton.icon(
      style: OutlinedButton.styleFrom(
        backgroundColor: context.colorScheme.error,
      ),
      icon: const Icon(Icons.delete, color: kLightColor),
      onPressed: () async {
        final isConfirmed = await _confirmDeleteDialog(context);
        if (context.mounted && isConfirmed) {
          final ids = products.map((p) => p.id).toList();

          // Remove products from products-DB
          ProductBloc(
            firestore: FirebaseFirestore.instance,
          ).add(DeleteInventory<List<String>>(documentId: ids));

          // Check if totalDeleted isEqual to total products,
          // is so, then deletion completed
          onDone(true);

          /* int totalDeleted = 0;
            totalDeleted++;
            for (var product in products) {}
            if (totalDeleted == products.length) {
              onDone(true);
            }*/
        }
      },
      label: const Text('Delete', style: TextStyle(color: kLightColor)),
    );
  }

  Padding _buildNote() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: RichText(
        text: const TextSpan(
          text: 'Group Delete: ',
          style: TextStyle(color: kDangerColor, fontWeight: FontWeight.bold),
          children: [
            TextSpan(
              text: 'Delete multiple products simultaneously',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*class ScanProducts extends StatefulWidget {
  const ScanProducts({super.key, required this.barcode});

  final String barcode;

  @override
  _ScanProductState createState() => _ScanProductState();
}

class _ScanProductState extends State<ScanProducts> {
  final TextEditingController _documentIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _documentIdController,
              decoration: const InputDecoration(
                labelText: 'Document ID',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                final documentId = _documentIdController.text;
                if (documentId.isNotEmpty) {
                  context.read<ProductBloc<Inventory>>().add(
                    LoadSingleDataEvent(inventoryPath, documentId),
                  );
                }
              },
              child: const Text('Load Data'),
            ),
            const SizedBox(height: 16.0),
        BlocBuilder<ProductBloc<Inventory>, FirestoreState<Inventory>>(
              builder: (context, state) {
                if (state is LoadingState<Inventory>) {
                  return const CircularProgressIndicator();
                } else if (state is SingleDataLoadedState<Inventory>) {
                  return Text('Data: ${state.data}');
                } else if (state is ErrorState<Inventory>) {
                  return Text('Error: ${state.error}');
                } else {
                  return const Text('No data loaded');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

return StreamBuilder<FirestoreState>(
      stream: _ProductBloc.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final state = snapshot.data!; // Define the state variable

          switch (state.runtimeType) {
            case const (LoadingState):
              return const Center(child: CircularProgressIndicator());
            case const (DataLoadedState):
              final data = (state as DataLoadedState).data;
              return data.isNotEmpty
                  ? _buildCard(data)
                  : Center(
                      child: SizedBox(
                        width: (context.screenWidth - 100),
                        child: ElevatedButton(
                          onPressed: () => context.openAddStock(),
                          child: const Text('Add Stock'),
                        ),
                      ),
                    );

            case const (DataAddedState):
              return const Text('Data added successfully');

            case const (DataUpdatedState):
              return const Text('Data updated successfully');

            case const (DataDeletedState):
              return const Text('Data deleted successfully');

            case const (ErrorState):
              final error = (state as ErrorState).error;
              return Text('Error: $error');

            default:
              return const Center(child: Text('Something went wrong'));
          }
        }
        return ElevatedButton(
          onPressed: () => context.openAddStock(),
          child: const Text('Add Stock'),
        );
      },
    );*/
