import 'package:assign_erp/core/constants/app_db_collect.dart';
import 'package:assign_erp/features/setup/data/models/supplier_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';

class SupplierBloc extends SetupBloc<Supplier> {
  SupplierBloc({required super.firestore})
      : super(
          collectionPath: supplierDBCollectionPath,
          fromFirestore: (data, id) => Supplier.fromMap(data, id),
          toFirestore: (info) => info.toMap(),
          toCache: (info) => info.toCache(),
        );
}
