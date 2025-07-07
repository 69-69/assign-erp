import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assign_erp/core/constants/app_db_collect.dart';
import 'package:assign_erp/features/pos_system/presentation/bloc/pos_bloc.dart';
import 'package:assign_erp/features/pos_system/data/models/pos_sale_model.dart';
import 'package:assign_erp/features/pos_system/data/models/pos_order_model.dart';
import 'package:assign_erp/features/inventory_ims/data/models/product_model.dart';


class POSOrderBloc extends POSBloc<POSOrder> {
  final FirebaseFirestore _firestore;

  POSOrderBloc({required super.firestore})
      : _firestore = firestore,
        super(
        collectionPath: posOrdersDBCollectionPath,
        fromFirestore: (data, id) => POSOrder.fromMap(data, id),
        toFirestore: (so) => so.toMap(),
        toCache: (so) => so.toCache(),
      );

  // Records or creates new sales for a given list of orders.
  // Adds each sale to Firestore and updates the state with the new order data.
  Future<void> createNewSalesForOrder(List<POSOrder> orders, Map<String, double> costPricesMap) async {
    // Prepare a list to hold all the Firestore add operations.
    final List<Future<void>> addOperations = orders.map((order) async {
      // Retrieve the cost price for the product, defaulting to 0.0 if not found.
      final double costPrice = costPricesMap[order.productId] ?? 0.0;

      // Create a Sales object from the POSOrder with initial data.
      final POSSale sale = POSSale.fromMap(order.toMap(), '');

      // Calculate the profit based on the cost price and sales data.
      final double profit = sale.calculateProfit(costPrice);

      // Update the Sales object with new status and profit.
      final POSSale updatedSale = sale.copyWith(status: 'completed', profit: profit);

      // Convert the updated Sales object to a Map for Firestore storage.
      final Map<String, dynamic> saleMap = updatedSale.toMap();

      // Add the Sales entry to Firestore and return the future.
      // return _firestore.collection(posSalesDBCollectionPath).add(saleMap);

      // Execute parallel operations: update product quantity and create a new sale record
      await Future.wait([
        // Add the Sales entry to Firestore and return the future.
        _firestore.collection(posSalesDBCollectionPath).add(saleMap),

        // Update the quantity of the product
        _updateProductQty(order.productId, order.quantity),
      ]);
    }).toList();

    // Wait for all Firestore operations to complete.
    await Future.wait(addOperations);

    // Dispatch an event to update the state or UI with the new sales data.
    add(GetPOS<POSOrder>());
  }

  // Function to update the product quantity
  Future<void> _updateProductQty(String productId, int orderQuantity) async {
    try {
      // Construct a reference to the document of the product in Firestore
      final docRef = _firestore.collection(productsDBCollectionPath).doc(productId);

      // Retrieve the current data of the product document from Firestore
      final docSnapshot = await docRef.get();

      // Check if the document exists and has data
      if (docSnapshot.exists) {
        final productData = docSnapshot.data();
        if (productData != null) {
          // Convert the Firestore data into a Product object using a factory method
          final fromProduct = Product.fromMap(productData, docSnapshot.id);

          if (fromProduct.quantity > 0) {
            // Calculate the new outStock & quantity after updating
            final newQty = fromProduct.quantity - orderQuantity;
            final newOutStock = fromProduct.outOfStock + orderQuantity;

            // Update product quantity & out of Stock in Firestore-DB
            await docRef.update({'quantity': newQty, 'outOfStock': newOutStock});
          } else {
            // print('Product quantity is not sufficient for the update.');
          }
        } else {
          // print('Product data is null.');
        }
      } else {
        // print('Document does not exist.');
      }
    } catch (e) {
      // Handle any errors that occur during the process
      // print('Error updating product quantity and recording sales: $e');
    }
  }

}