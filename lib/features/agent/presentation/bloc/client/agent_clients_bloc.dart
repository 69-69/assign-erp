import 'package:assign_erp/core/constants/app_db_collect.dart';
import 'package:assign_erp/core/network/data_sources/models/workspace_model.dart';
import 'package:assign_erp/core/network/data_sources/remote/bloc/firestore_bloc.dart';
import 'package:assign_erp/features/agent/data/models/agent_client_model.dart';
import 'package:assign_erp/features/agent/presentation/bloc/agent_bloc.dart';

/// Clients Agent Info Bloc [MyAgentBloc]
/// Customers/Subscribers/Clients Agent Bloc: Agent, the one who registered/created the workspace account for the subscribers
class MyAgentBloc extends FirestoreBloc<Workspace> {
  MyAgentBloc({required super.firestore})
    : super(
        collectionPath: workspaceUserDBCollectionPath,
        fromFirestore: (data, id) => Workspace.fromMap(data),
        toFirestore: (workspace) => workspace.toMap(),
        toCache: (workspace) => workspace.toCache(),
      );
}

/// Agent's Clients(Subscribers) Bloc [AgentClientBloc]
/// Customers/Subscribers/Clients Agent Bloc: Clients, subscribers of the software
class AgentClientBloc extends AgentBloc<AgentClient> {
  AgentClientBloc({required super.firestore})
    : super(
        collectionPath: agentClientsDBCollection,
        fromFirestore: (data, id) => AgentClient.fromMap(data, id: id),
        toFirestore: (client) => client.toMap(),
        toCache: (client) => client.toCache(),
      );
}
