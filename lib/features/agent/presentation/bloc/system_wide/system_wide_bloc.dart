import 'package:assign_erp/core/constants/app_db_collect.dart';
import 'package:assign_erp/core/constants/collection_type_enum.dart';
import 'package:assign_erp/features/agent/presentation/bloc/agent_bloc.dart';
import 'package:assign_erp/features/auth/data/model/workspace_model.dart';

/// [SystemWideBloc] Get All Workspaces Account Data (Both Clients and Agents)
class SystemWideBloc extends AgentBloc<Workspace> {
  SystemWideBloc({required super.firestore})
    : super(
        collectionType: CollectionType.global,
        collectionPath: workspaceUserDBCollectionPath,
        fromFirestore: (data, id) => Workspace.fromMap(data, id: id),
        toFirestore: (workspace) => workspace.toMap(),
        toCache: (workspace) => workspace.toCache(),
      );
}
