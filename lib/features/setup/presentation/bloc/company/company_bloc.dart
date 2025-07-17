import 'package:assign_erp/core/constants/app_db_collect.dart';
import 'package:assign_erp/features/setup/data/models/company_info_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';

class CompanyBloc extends SetupBloc<Company> {
  CompanyBloc({required super.firestore})
    : super(
        collectionPath: companyInfoDBCollectionPath,
        fromFirestore: (data, id) => Company.fromMap(data, id),
        toFirestore: (info) => info.toMap(),
        toCache: (info) => info.toCache(),
      );
}
