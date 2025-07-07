import 'package:assign_erp/core/network/data_sources/models/workspace_model.dart';
import 'package:assign_erp/core/network/data_sources/remote/bloc/firestore_bloc.dart';
import 'package:assign_erp/features/agent/data/models/agent_client_model.dart';
import 'package:assign_erp/features/agent/presentation/bloc/agent_bloc.dart';
import 'package:assign_erp/features/agent/presentation/bloc/client/agent_clients_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GetAgent {
  /// Get Agent Info By AgentId [byAgentId]
  static Future<Workspace?> byAgentId(workspaceId) async {
    final agentBloc = MyAgentBloc(firestore: FirebaseFirestore.instance);

    // Load all data initially to pass to the search delegate
    agentBloc.add(GetDataById<Workspace>(documentId: workspaceId));

    // Ensure to wait for the data to be loaded
    final state =
        await agentBloc.stream.firstWhere(
              (state) => state is SingleDataLoaded<Workspace>,
            )
            as SingleDataLoaded<Workspace>;

    return state.data;
  }

  /// Get Agent's Clients(Subscribers) Info By ClientWorkspaceId [byClientsAgentId]
  static Future<List<AgentClient>> byClientsAgentId() async {
    final agentClientBloc = AgentClientBloc(
      firestore: FirebaseFirestore.instance,
    );

    agentClientBloc.add(LoadClients<AgentClient>());
    final state =
        await agentClientBloc.stream.firstWhere(
              (state) => state is ClientsLoaded<AgentClient>,
            )
            as ClientsLoaded<AgentClient>;
    return state.data;
  }
}
