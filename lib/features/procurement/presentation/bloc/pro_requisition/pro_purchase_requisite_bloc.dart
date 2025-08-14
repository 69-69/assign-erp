import 'package:assign_erp/core/constants/app_db_collect.dart';
import 'package:assign_erp/features/inventory_ims/data/models/orders/purchase_order_model.dart';
import 'package:assign_erp/features/procurement/presentation/bloc/procurement_bloc.dart';

class ProPurchaseRequisiteBloc extends ProcurementBloc<PurchaseOrder> {
  ProPurchaseRequisiteBloc({required super.firestore})
    : super(
        collectionPath: purchaseRequisitionDBCollectionPath,
        fromFirestore: (data, id) => PurchaseOrder.fromMap(data, id),
        toFirestore: (po) => po.toMap(),
        toCache: (po) => po.toCache(),
      );
}
