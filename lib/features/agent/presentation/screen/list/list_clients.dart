import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/network/data_sources/models/workspace_model.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/dynamic_table.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/agent/data/models/agent_client_model.dart';
import 'package:assign_erp/features/agent/presentation/bloc/agent_bloc.dart';
import 'package:assign_erp/features/agent/presentation/bloc/client/agent_clients_bloc.dart';
import 'package:assign_erp/features/auth/presentation/screen/workspace/create/create_workspace_acc.dart';
import 'package:assign_erp/features/auth/presentation/screen/workspace/update/update_workspace_acc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ListWorkspaces extends StatefulWidget {
  final bool isDeveloper;
  const ListWorkspaces({super.key, required this.isDeveloper});

  @override
  State<ListWorkspaces> createState() => _ListWorkspacesState();
}

class _ListWorkspacesState extends State<ListWorkspaces> {
  bool get isDeveloper => widget.isDeveloper;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            'Manage Clients & Workspaces'.toUppercaseAllLetter,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: kPrimaryLightColor,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
            textScaler: TextScaler.linear(context.textScaleFactor * 0.8),
          ),
        ),
        _buildBody(),
      ],
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
                    'Setup Client Workspace',
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

    final filters = _filterExpiry(workspaces); // My Clients/Subscribers

    return DynamicDataTable(
      skip: true,
      skipPos: 2,
      toggleHideID: true,
      headers: Workspace.dataTableHeader,
      anyWidget: _buildAnyWidget(filters.unExpired),
      rows: filters.unExpired.map((w) => w.itemAsList()).toList(),
      childrenRow: filters.expired.map((w) => w.itemAsList()).toList(),
      onEditTap: isDeveloper
          ? (row) async => await _onEditTap(workspaces, row)
          : null,
      onDeleteTap: isDeveloper
          ? (row) async => await _onDeleteTap(workspaces, row)
          : null,
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

  Future<void> _onEditTap(List<Workspace> workspaces, List<String> row) async {
    final workspace = Workspace.filterById(workspaces, row[1]).first;

    await context.openUpdateWorkspacePopUp(workspace: workspace);
  }

  Future<void> _onDeleteTap(
    List<Workspace> workspaces,
    List<String> row,
  ) async {
    final workspace = Workspace.filterById(workspaces, row[1]).first;
    {
      final workspaceId = workspace.id;

      final isConfirmed = await context.confirmUserActionDialog();
      if (mounted && isConfirmed) {
        // Delete Client Workspace
        context.read<AgentClientBloc>().add(
          DeleteClient<String>(documentId: workspaceId),
        );

        Navigator.of(context).pop();
      }
    }
  }
}
