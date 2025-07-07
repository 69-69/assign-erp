import 'package:assign_erp/features/inventory_ims/data/models/orders/order_model.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/inventory_bloc.dart';
import 'package:assign_erp/features/inventory_ims/presentation/bloc/orders/order_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GetOrders {
  // static final ordersBloc = SalesOrderBloc(firestore: FirebaseFirestore.instance);

  static Future<InventoryLoaded<Orders>> _dataLoadedState() async {
    final ordersBloc = OrderBloc(firestore: FirebaseFirestore.instance);

    return await ordersBloc.stream.firstWhere(
      (state) => state is InventoryLoaded<Orders>,
    ) as InventoryLoaded<Orders>;
  }

  static Future<List<Orders>> load() async {
    final ordersBloc = OrderBloc(firestore: FirebaseFirestore.instance);

    // Load all data initially to pass to the search delegate
    ordersBloc.add(GetInventory<Orders>());

    // Ensure to wait for the data to be loaded
    final allData = await _dataLoadedState();

    return allData.data;
  }

  /// Get by either orderNumber, customerId, productName [byAnyTerm]
  /// @Return: `List<Orders>`
  static Future<List<Orders>> byAnyTerm(term) async {
    final ordersBloc = OrderBloc(firestore: FirebaseFirestore.instance);

    // Load all data initially to pass to the search delegate
    ordersBloc.add(SearchInventory<Orders>(
      field: 'orderNumber',
      optField: 'customerId',
      auxField: 'productName',
      query: term,
    ));

    // Ensure to wait for the data to be loaded
    final allData = await _dataLoadedState();

    return allData.data;
  }

  /// Get by same term [byAnyTerm]
  /// @Return: `List<Orders>`
  static Future<List<Orders>> getWithSameId(term) async {
    final ordersBloc = OrderBloc(firestore: FirebaseFirestore.instance);

    // Load all data initially to pass to the search delegate
    ordersBloc.add(GetAllInventoryWithSameId<Orders>(
      field: 'orderNumber',
      documentId: term,
    ));

    // Ensure to wait for the data to be loaded
    final allData = await _dataLoadedState();

    return allData.data;
  }
}
