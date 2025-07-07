import 'package:assign_erp/core/constants/app_db_collect.dart';
import 'package:assign_erp/features/setup/data/models/company_stores_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';

class CompanyStoreBloc extends SetupBloc<CompanyStores> {
  CompanyStoreBloc({required super.firestore})
      : super(
          collectionPath: companyStoreDBCollectionPath,
          fromFirestore: (data, id) => CompanyStores.fromMap(data, id),
          toFirestore: (store) => store.toMap(),
          toCache: (store) => store.toCache(),
        );
}
