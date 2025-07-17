import 'package:assign_erp/core/network/data_sources/remote/repository/data_repository.dart';

class InventoryRepository extends DataRepository {
  InventoryRepository({
    required super.firestore,
    required super.collectionPath,
    super.collectionType,
    super.collectionRef,
  });
}
