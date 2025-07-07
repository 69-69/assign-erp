import 'package:assign_erp/core/network/data_sources/remote/repository/data_repository.dart';

class ManualRepository extends DataRepository {
  ManualRepository({
    super.collectionType,
    required super.firestore,
    required super.collectionPath,
    super.collectionRef,
  });
}
