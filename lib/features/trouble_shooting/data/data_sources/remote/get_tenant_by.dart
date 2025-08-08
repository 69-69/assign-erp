import 'package:assign_erp/features/auth/data/model/workspace_model.dart';
import 'package:assign_erp/features/trouble_shooting/presentation/bloc/all_tenants/all_tenants_bloc.dart';
import 'package:assign_erp/features/trouble_shooting/presentation/bloc/tenant_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GetTenant {
  static final _firestore = FirebaseFirestore.instance;

  /// Get Agent Info By AgentId (workspaceId) [byAgentId]
  static Future<Workspace?> byWorkspaceId(workspaceId) async {
    final systemWideBloc = AllTenantsBloc(firestore: _firestore);

    // Load all data initially to pass to the search delegate
    systemWideBloc.add(LoadTenantById<Workspace>(documentId: workspaceId));

    // Ensure to wait for the data to be loaded
    final state =
        await systemWideBloc.stream.firstWhere(
              (state) => state is TenantLoaded<Workspace>,
            )
            as TenantLoaded<Workspace>;

    return state.data;
  }
}
