import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/widgets/button/custom_button.dart';
import 'package:assign_erp/core/widgets/layout/dynamic_table.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/auth/data/model/workspace_model.dart';
import 'package:assign_erp/features/auth/presentation/screen/workspace/create/create_workspace_acc.dart';
import 'package:assign_erp/features/auth/presentation/screen/workspace/update/update_workspace_acc.dart';
import 'package:assign_erp/features/trouble_shooting/presentation/bloc/all_tenants/all_tenants_bloc.dart';
import 'package:assign_erp/features/trouble_shooting/presentation/bloc/tenant_bloc.dart';
import 'package:assign_erp/features/trouble_shooting/presentation/screen/widget/assign_subscription_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ListTenantWorkspaces extends StatefulWidget {
  const ListTenantWorkspaces({super.key});

  @override
  State<ListTenantWorkspaces> createState() => _ListTenantWorkspacesState();
}

class _ListTenantWorkspacesState extends State<ListTenantWorkspaces> {
  bool? _isChecked;
  Workspace? _selectedWorkspace;

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  BlocBuilder<AllTenantsBloc, TenantState<Workspace>> _buildBody() {
    return BlocBuilder<AllTenantsBloc, TenantState<Workspace>>(
      buildWhen: (oldState, newState) => oldState != newState,
      builder: (context, state) {
        return switch (state) {
          LoadingTenants<Workspace>() => context.loader,
          TenantsLoaded<Workspace>(data: var results) =>
            results.isEmpty
                ? context.buildAddButton(
                    'Setup New Workspace',
                    onPressed: () => context.openCreateWorkspacePopUp(),
                  )
                : _buildCard(context, results),
          TenantError<AllTenantsBloc>(error: var error) => context.buildError(
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
      skipPos: 1,
      showIDToggle: true,
      headers: Workspace.dataTableHeader,
      anyWidget: _buildAnyWidget(filters.unExpired),
      rows: filters.unExpired.map((w) => w.itemAsList()).toList(),
      childrenRow: filters.expired.map((w) => w.itemAsList()).toList(),
      onEditTap: (row) async => await _onEditTap(workspaces, row.first),
      onDeleteTap: (row) async => await _onDeleteTap(row.first),
      onChecked: (bool? isChecked, List<String> row) =>
          _onChecked(workspaces, row.first, isChecked),
      optButtonIcon: Icons.support_agent,
      optButtonLabel: 'Tenant Chat',
      onOptButtonTap: (row) => context.goNamed(
        RouteNames.tenantChat,
        pathParameters: {'clientWorkspaceId': row[1]},
      ),
    );
  }

  _buildAnyWidget(List<Workspace> tenants) {
    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      runAlignment: WrapAlignment.spaceBetween,
      children: [
        context.buildTotalItems(
          'Refresh Workspaces',
          label: 'Workspaces',
          count: tenants.length,
          onPressed: () {
            // Refresh Workspace Data
            context.read<AllTenantsBloc>().add(RefreshTenants<Workspace>());
          },
        ),

        if (_isChecked == true) ...{
          context.elevatedButton(
            'Assign Subscription',
            tooltip: 'Assign Workspace Subscription & License',
            onPressed: () async {
              await context.assignSubscriptionToWorkspaceDialog(
                workspaceId: _selectedWorkspace!.id,
                workspaceName: _selectedWorkspace?.name,
              );
            },
            bgColor: kGrayBlueColor,
            color: kLightColor,
          ),
        },
      ],
    );
  }

  Future<void> _onEditTap(List<Workspace> workspaces, String id) async {
    final workspace = _findWorkspace(workspaces, id);

    if (workspace != null) {
      await context.openUpdateWorkspacePopUp(workspace: workspace);
    }
  }

  Workspace? _findWorkspace(List<Workspace> workspaces, String id) =>
      Workspace.filterById(workspaces, id);

  // Handle onChecked orders
  void _onChecked(
    List<Workspace> workspaces,
    String id,
    bool? isChecked,
  ) async {
    final workspace = _findWorkspace(workspaces, id);

    setState(() {
      _isChecked = isChecked;

      if (_isChecked == true) {
        _selectedWorkspace = workspace;
      }
    });
  }

  Future<void> _onDeleteTap(String workspaceId) async {
    {
      final isConfirmed = await context.confirmUserActionDialog();
      if (mounted && isConfirmed) {
        // Delete Tenant Workspace
        context.read<AllTenantsBloc>().add(
          DeleteTenant<String>(documentId: workspaceId),
        );

        Navigator.of(context).pop();
      }
    }
  }
}
