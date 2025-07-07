import 'package:assign_erp/core/constants/app_db_collect.dart';
import 'package:assign_erp/features/setup/data/models/category_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';

class CategoryBloc extends SetupBloc<Category> {
  CategoryBloc({required super.firestore})
      : super(
          collectionPath: categoryDBCollectionPath,
          fromFirestore: (data, id) => Category.fromMap(data, id),
          toFirestore: (info) => info.toMap(),
          toCache: (info) => info.toCache(),
        );
}
