import 'package:assign_erp/core/constants/app_db_collect.dart';
import 'package:assign_erp/core/constants/collection_type_enum.dart';
import 'package:assign_erp/features/manual/data/models/manual_model.dart';
import 'package:assign_erp/features/manual/presentation/bloc/manual_bloc.dart';

class HowToBloc extends ManualBloc<Manual> {
  HowToBloc({required super.firestore})
    : super(
        collectionType: CollectionType.global,
        collectionPath: userManualDBCollectionPath,
        fromFirestore: (data, id) => Manual.fromMap(data, id: id),
        toFirestore: (manual) => manual.toMap(),
        toCache: (manual) => manual.toCache(),
      );
}
