import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/dynamic_table.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/agent/data/models/agent_client_model.dart';
import 'package:assign_erp/features/agent/presentation/bloc/agent_bloc.dart';
import 'package:assign_erp/features/agent/presentation/bloc/client/agent_clients_bloc.dart';
import 'package:assign_erp/features/agent/presentation/screen/list/header_wrap.dart';
import 'package:assign_erp/features/auth/data/model/workspace_model.dart';
import 'package:assign_erp/features/auth/presentation/screen/workspace/create/create_workspace_acc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AgentClientsWorkspaces extends StatefulWidget {
  const AgentClientsWorkspaces({super.key});

  @override
  State<AgentClientsWorkspaces> createState() => _AgentClientsWorkspacesState();
}

class _AgentClientsWorkspacesState extends State<AgentClientsWorkspaces> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AgentClientBloc>(
      create: (context) =>
          AgentClientBloc(firestore: FirebaseFirestore.instance)
            ..add(LoadClients<AgentClient>()),
      child: CustomScaffold(
        title: clienteleScreenTitle.toUpperCase(),
        body: HeaderWrap(
          title: 'Client Workspaces'.toUpperCase(),
          body: _buildBody(),
        ),
        floatingActionButton: context.buildFloatingBtn(
          'setup new workspace',
          icon: Icons.workspaces_outline,
          onPressed: () => context.openCreateWorkspacePopUp(),
        ),
      ),
    );
  }

  BlocBuilder<AgentClientBloc, AgentState<AgentClient>> _buildBody() {
    return BlocBuilder<AgentClientBloc, AgentState<AgentClient>>(
      buildWhen: (oldState, newState) => oldState != newState,
      builder: (context, state) {
        return switch (state) {
          LoadingClients<AgentClient>() => context.loader,
          ClientsLoaded<AgentClient>(data: var results) =>
            results.isEmpty
                ? context.buildAddButton(
                    'setup new workspace',
                    onPressed: () => context.openCreateWorkspacePopUp(),
                  )
                : _buildCard(context, results),
          AgentError<AgentClient>(error: var error) => context.buildError(
            error,
          ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  ({List<Workspace> expired, List<Workspace> unExpired}) _filterExpiry(
    List<Workspace> workspaces,
  ) {
    final unExpired = Workspace.filterStatus(workspaces);
    final expired = Workspace.filterStatus(workspaces, expired: true);

    return (expired: expired, unExpired: unExpired);
  }

  Widget _buildCard(BuildContext context, List<AgentClient> clientWorkspaces) {
    List<Workspace> workspaces = clientWorkspaces
        .where((e) => e.clientWorkspace != null)
        .map((e) => e.clientWorkspace!)
        .toList();

    final filters = _filterExpiry(workspaces);

    return DynamicDataTable(
      skip: true,
      skipPos: 2,
      toggleHideID: true,
      headers: Workspace.dataTableHeader,
      anyWidget: _buildAnyWidget(filters.unExpired),
      rows: filters.unExpired.map((w) => w.itemAsList()).toList(),
      childrenRow: filters.expired.map((w) => w.itemAsList()).toList(),
      optButtonIcon: Icons.support_agent,
      optButtonLabel: 'Client Chat',
      onOptButtonTap: (row) => context.goNamed(
        RouteNames.agentChat,
        pathParameters: {'clientWorkspaceId': row[1]},
      ),
    );
  }

  _buildAnyWidget(List<Workspace> tenants) {
    return context.buildTotalItems(
      'Refresh Workspaces',
      label: 'Workspaces',
      count: tenants.length,
      onPressed: () {
        // Refresh Workspace Data
        context.read<AgentClientBloc>().add(RefreshClients<AgentClient>());
      },
    );
  }
}
