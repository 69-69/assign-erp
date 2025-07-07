import 'package:assign_erp/features/setup/data/models/supplier_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/product_config/suppliers_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GetSuppliers {
  // static  final supplierBloc = SupplierBloc(firestore: FirebaseFirestore.instance);

  static Future<List<Supplier>> load() async {
    final supplierBloc = SupplierBloc(firestore: FirebaseFirestore.instance);

    // Load all data initially to pass to the search delegate
    supplierBloc.add(GetSetup<Supplier>());

    // Ensure to wait for the data to be loaded
    final state = await supplierBloc.stream.firstWhere(
      (state) => state is SetupLoaded<Supplier>,
    ) as SetupLoaded<Supplier>;

    return state.data.isEmpty ? [Supplier.notFound] : state.data;
  }

  /// Get by either supplierName, phone, contactPersonName [byAnyTerm]
  /// @Return: `List<Supplier>`
  static Future<List<Supplier>> byAnyTerm(term) async {
    final supplierBloc = SupplierBloc(firestore: FirebaseFirestore.instance);

    // Load all data initially to pass to the search delegate
    supplierBloc.add(SearchSetup<Supplier>(
      field: 'supplierName',
      optField: 'phone',
      auxField: 'contactPersonName',
      query: term,
    ));

    // Ensure to wait for the data to be loaded
    final state = await supplierBloc.stream.firstWhere(
      (state) => state is SetupLoaded<Supplier>,
    ) as SetupLoaded<Supplier>;

    return state.data.isEmpty ? [Supplier.notFound] : state.data;
  }

  /// Get by supplierId [bySupplierId]
  static Future<Supplier> bySupplierId(supplierId) async {
    final supplierBloc = SupplierBloc(firestore: FirebaseFirestore.instance);
// Load all data initially to pass to the search delegate
    supplierBloc.add(GetSetupById<Supplier>(documentId: supplierId));

    // Ensure to wait for the data to be loaded
    final state = await supplierBloc.stream.firstWhere(
      (state) => state is SetupLoaded<Supplier>,
      orElse: () => Supplier
          .notFound, // Handle case where stream may not emit the expected state
    );

    if (state is SetupLoaded<Supplier>) {
      // debugPrint('steve ${state.data}');
      return state.data.isEmpty ? Supplier.notFound : state.data.first;
    } else {
      // Handle case where state is null or not of expected type
      // For example, return Supplier.notFound or throw an exception
      return Supplier.notFound;
    }
  }
}
