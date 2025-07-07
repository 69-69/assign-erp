import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assign_erp/features/setup/data/models/category_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/product_config/category_bloc.dart';

class GetProductCategory {
  static Future<List<Category>> load() async {
    // Load all data initially to pass to the search delegate
    // categoryBloc.add(GetInfoEvent<Category>());

    // Ensure to wait for the data to be loaded
    final state = await CategoryBloc(firestore: FirebaseFirestore.instance)
        .stream
        .firstWhere(
          (state) => state is SetupLoaded<Category>,
        ) as SetupLoaded<Category>;

    return state.data.isEmpty ? [Category.notFound] : state.data;
  }

  /// Get by categoryId [byCategoryId]
  static Future<Category> byCategoryId(categoryId) async {
    final categoryBloc = CategoryBloc(firestore: FirebaseFirestore.instance);

    // Load all data initially to pass to the search delegate
    categoryBloc.add(GetSetupById<Category>(documentId: categoryId));

    // Ensure to wait for the data to be loaded
    final state = await categoryBloc.stream.firstWhere(
      (state) => state is SetupLoaded<Category>,
    ) as SetupLoaded<Category>;

    return state.data.isEmpty ? Category.notFound : state.data;
  }
}
