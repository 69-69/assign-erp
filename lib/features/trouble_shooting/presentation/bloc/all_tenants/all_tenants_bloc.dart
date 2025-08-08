import 'package:assign_erp/core/constants/app_db_collect.dart';
import 'package:assign_erp/core/constants/collection_type_enum.dart';
import 'package:assign_erp/features/auth/data/model/workspace_model.dart';
import 'package:assign_erp/features/trouble_shooting/presentation/bloc/tenant_bloc.dart';

/// [AllTenantsBloc] Get All Tenants Workspaces
class AllTenantsBloc extends TenantBloc<Workspace> {
  AllTenantsBloc({required super.firestore})
    : super(
        collectionType: CollectionType.global,
        collectionPath: workspaceAccDBCollectionPath,
        fromFirestore: (data, id) => Workspace.fromMap(data, id: id),
        toFirestore: (workspace) => workspace.toMap(),
        toCache: (workspace) => workspace.toCache(),
      );
}
