import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/network/data_sources/models/workspace_model.dart';
import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/dynamic_table.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/agent/presentation/bloc/agent_bloc.dart';
import 'package:assign_erp/features/agent/presentation/bloc/client/agent_clients_bloc.dart';
import 'package:assign_erp/features/agent/presentation/screen/list/header_wrap.dart';
import 'package:assign_erp/features/auth/presentation/screen/workspace/create/create_workspace_acc.dart';
import 'package:assign_erp/features/auth/presentation/screen/workspace/update/update_workspace_acc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SystemWideWorkspaces extends StatefulWidget {
  const SystemWideWorkspaces({super.key});

  @override
  State<SystemWideWorkspaces> createState() => _SystemWideWorkspacesState();
}

class _SystemWideWorkspacesState extends State<SystemWideWorkspaces> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<SystemWideBloc>(
      create: (context) =>
          SystemWideBloc(firestore: FirebaseFirestore.instance)
            ..add(LoadClients<Workspace>(isSystemWide: true)),
      child: CustomScaffold(
        title: allWorkspacesScreenTitle.toUpperCase(),
        body: HeaderWrap(
          title: 'Manage All Workspaces'.toUpperCase(),
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

  BlocBuilder<SystemWideBloc, AgentState<Workspace>> _buildBody() {
    return BlocBuilder<SystemWideBloc, AgentState<Workspace>>(
      buildWhen: (oldState, newState) => oldState != newState,
      builder: (context, state) {
        return switch (state) {
          LoadingClients<Workspace>() => context.loader,
          ClientsLoaded<Workspace>(data: var results) =>
            results.isEmpty
                ? context.buildAddButton(
                    'Setup New Workspace',
                    onPressed: () => context.openCreateWorkspacePopUp(),
                  )
                : _buildCard(context, results),
          AgentError<SystemWideBloc>(error: var error) => context.buildError(
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

  Widget _buildCard(BuildContext context, List<Workspace> workspaces) {
    final filters = _filterExpiry(workspaces);

    return DynamicDataTable(
      skip: true,
      skipPos: 2,
      toggleHideID: true,
      headers: Workspace.dataTableHeader,
      anyWidget: _buildAnyWidget(filters.unExpired),
      rows: filters.unExpired.map((w) => w.itemAsList()).toList(),
      childrenRow: filters.expired.map((w) => w.itemAsList()).toList(),
      onEditTap: (row) async => await _onEditTap(workspaces, row),
      onDeleteTap: (row) async => await _onDeleteTap(workspaces, row),
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
        context.read<SystemWideBloc>().add(
          RefreshClients<Workspace>(isSystemWide: true),
        );
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
        context.read<SystemWideBloc>().add(
          DeleteClient<String>(documentId: workspaceId),
        );

        Navigator.of(context).pop();
      }
    }
  }
}
