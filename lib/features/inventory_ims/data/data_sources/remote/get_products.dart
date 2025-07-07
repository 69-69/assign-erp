import 'package:assign_erp/features/inventory_ims/data/models/product_model.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/inventory_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/product/product_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GetProducts {
  // static final productBloc = ProductBloc(firestore: FirebaseFirestore.instance);

  static Future<InventoryLoaded<Product>> _dataLoadedState(
      ProductBloc bloc) async {
    return await bloc.stream.firstWhere(
      (state) => state is InventoryLoaded<Product>,
    ) as InventoryLoaded<Product>;
  }

  static Future<List<Product>> load() async {
    final productBloc = ProductBloc(firestore: FirebaseFirestore.instance);

    // Load all data initially to pass to the search delegate
    productBloc.add(GetInventory<Product>());

    // Ensure to wait for the data to be loaded
    final allData = await _dataLoadedState(productBloc);

    return allData.data;
  }

  static Future<Product> byProductId(productId, {Object? field}) async {
    final productBloc = ProductBloc(firestore: FirebaseFirestore.instance);

    // Load all data initially to pass to the search delegate
    productBloc
        .add(GetInventoryById<Product>(field: field, documentId: productId));

    // Ensure to wait for the data to be loaded
    final state = await productBloc.stream.firstWhere(
      (state) => state is SingleInventoryLoaded<Product>,
    ) as SingleInventoryLoaded<Product>;

    return state.data.isEmpty ? Product.notFound : state.data;
  }

  /// Get by either documentId, batchId, sku [byAnyTerm]
  /// @Return: `List<Product>`
  static Future<List<Product>> byAnyTerm(term) async {
    final productBloc = ProductBloc(firestore: FirebaseFirestore.instance);

    // Load all data initially to pass to the search delegate
    productBloc.add(SearchInventory<Product>(
      field: 'sku',
      optField: 'batchId',
      auxField: 'name',
      query: term,
    ));

    // Ensure to wait for the data to be loaded
    final allData = await _dataLoadedState(productBloc);

    return allData.data;
  }

  /*void _updateInventory(String barcode) {
    // Fetch product by barcode and update its quantity
    // final productBloc = BlocProvider.of<ProductBloc>(context);
    final productBloc = ProductBloc(firestore: FirebaseFirestore.instance);

    // Load all data initially to pass to the search delegate
    final products = (productBloc.state as InventoryLoaded<Product>).data;

    final product = products.firstWhere(
      (product) => product.barcode == barcode,
      orElse: () => Product.notFound,
    );

    if (product.id.isNotEmpty) {
      // Update existing product
      productBloc.add(
        UpdateInventory<Product>(
          documentId: product.id,
          data: product.copyWith(quantity: product.quantity + 1),
        ),
      );
    } else {
      // Add new product (you may want to show a form to enter product details)
      productBloc
          .add(AddInventory<Product>(data: product.copyWith(quantity: 1)));
    }
  }*/

  static Future<Product?> findByBarcode(String barcode) async {
    // Fetch product by barcode and update its quantity
    // final productBloc = BlocProvider.of<ProductBloc>(context);
    final productBloc = ProductBloc(firestore: FirebaseFirestore.instance);

    // Load all data initially to pass to the search delegate
    productBloc
        .add(GetInventoryById<Product>(field: 'barcode', documentId: barcode));

    // Ensure to wait for the data to be loaded
    final state = await productBloc.stream.firstWhere(
      (state) => state is SingleInventoryLoaded<Product>,
    ) as SingleInventoryLoaded<Product>;

    final product = state.data;

    return product.isNotEmpty ? product : null;
  }
}
