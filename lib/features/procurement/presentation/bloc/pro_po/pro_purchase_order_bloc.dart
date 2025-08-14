import 'package:assign_erp/core/constants/app_db_collect.dart';
import 'package:assign_erp/features/inventory_ims/data/models/orders/purchase_order_model.dart';
import 'package:assign_erp/features/procurement/presentation/bloc/procurement_bloc.dart';

class ProPurchaseOrderBloc extends ProcurementBloc<PurchaseOrder> {
  ProPurchaseOrderBloc({required super.firestore})
    : super(
        collectionPath: purchaseOrdersDBCollectionPath,
        fromFirestore: (data, id) => PurchaseOrder.fromMap(data, id),
        toFirestore: (po) => po.toMap(),
        toCache: (po) => po.toCache(),
      );
}
