import 'package:assign_erp/features/setup/data/models/company_stores_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/company_info/company_store_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GetStores {
  static final storeBloc =
      CompanyStoreBloc(firestore: FirebaseFirestore.instance);

  static Future<List<CompanyStores>> load() async {
    // Load all data initially to pass to the search delegate
    storeBloc.add(GetSetup<CompanyStores>());

    // Ensure to wait for the data to be loaded
    final allData = await storeBloc.stream.firstWhere(
      (state) => state is SetupLoaded<CompanyStores>,
    ) as SetupLoaded<CompanyStores>;

    return allData.data;
  }

  /// Get by either storeNumber, name, location [byAnyTerm]
  /// @Return: `List<CompanyStores>`
  static Future<List<CompanyStores>> byAnyTerm(term) async {
    // Load all data initially to pass to the search delegate
    storeBloc.add(SearchSetup<CompanyStores>(
      field: 'name',
      optField: 'storeNumber',
      auxField: 'location',
      query: term,
    ));

    // Ensure to wait for the data to be loaded
    final allData = await storeBloc.stream.firstWhere(
      (state) => state is SetupLoaded<CompanyStores>,
    ) as SetupLoaded<CompanyStores>;

    return allData.data;
  }
}
