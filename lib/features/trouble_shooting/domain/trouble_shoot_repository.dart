import 'package:assign_erp/core/network/data_sources/remote/repository/data_repository.dart';

class TroubleShootRepository extends DataRepository {
  TroubleShootRepository({
    super.collectionType,
    required super.firestore,
    required super.collectionPath,
    super.collectionRef,
    // collectionType = CollectionType.global,
  });
}
