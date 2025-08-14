import 'package:assign_erp/core/network/data_sources/remote/repository/data_repository.dart';

class ProcurementRepository extends DataRepository {
  ProcurementRepository({
    required super.firestore,
    required super.collectionPath,
    super.collectionType,
    super.collectionRef,
  });
}
