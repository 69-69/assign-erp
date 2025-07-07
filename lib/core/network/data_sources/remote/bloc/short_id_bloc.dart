import 'package:assign_erp/core/network/data_sources/remote/bloc/firestore_bloc.dart';
import 'package:assign_erp/features/inventory_ims/data/models/short_id_model.dart';

class ShortIDBloc extends FirestoreBloc<ShortUID> {
  ShortIDBloc(String collectionPath, {required super.firestore})
      : super(
    collectionPath: collectionPath,
    fromFirestore: (data, id) => ShortUID.fromMap(data, id),
    toFirestore: (uid) => uid.toMap(),
    toCache: (uid) => uid.toCache(),
  );
}
