import 'package:assign_erp/features/agent/presentation/bloc/agent_bloc.dart';
import 'package:assign_erp/features/agent/presentation/bloc/system_wide/system_wide_bloc.dart';
import 'package:assign_erp/features/auth/data/model/workspace_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GetAgent {
  static final _firestore = FirebaseFirestore.instance;

  /// Get Agent Info By AgentId (workspaceId) [byAgentId]
  static Future<Workspace?> byAgentId(workspaceId) async {
    final systemWideBloc = SystemWideBloc(firestore: _firestore);

    // Load all data initially to pass to the search delegate
    systemWideBloc.add(LoadAgentById<Workspace>(agentId: workspaceId));

    // Ensure to wait for the data to be loaded
    final state =
        await systemWideBloc.stream.firstWhere(
              (state) => state is AgentLoaded<Workspace>,
            )
            as AgentLoaded<Workspace>;

    return state.data;
  }

  /// Get Agent's Clients(Subscribers) Info By ClientWorkspaceId [clientsByAgentId]
  /*static Future<List<AgentClient>> clientsByAgentId() async {
    final agentClientBloc = AgentClientBloc(firestore: _firestore);

    agentClientBloc.add(LoadClients<AgentClient>());

    final state =
        await agentClientBloc.stream.firstWhere(
              (state) => state is ClientsLoaded<AgentClient>,
            )
            as ClientsLoaded<AgentClient>;
    return state.data;
  }*/
}
