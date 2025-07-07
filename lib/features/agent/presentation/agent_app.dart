import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/agent/data/models/agent_client_model.dart';
import 'package:assign_erp/features/agent/presentation/bloc/agent_bloc.dart';
import 'package:assign_erp/features/agent/presentation/bloc/client/agent_clients_bloc.dart';
import 'package:assign_erp/features/agent/presentation/screen/list/list_clients.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/auth/presentation/screen/workspace/create/create_workspace_acc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgentApp extends StatelessWidget {
  const AgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    /// check if workspaceRole is developer
    final isDeveloper = WorkspaceRoleGuard.canAccessDeveloperDashboard(context);

    return BlocProvider<AgentClientBloc>(
      create: (context) => _agentClientBloc(isDeveloper),
      child: CustomScaffold(
        title: clienteleScreenTitle.toUpperCase(),
        body: ListWorkspaces(isDeveloper: isDeveloper),
        floatingActionButton: _buildFloatingActionButton(context),
      ),
    );
  }

  AgentClientBloc _agentClientBloc(bool isDeveloper) {
    return AgentClientBloc(firestore: FirebaseFirestore.instance)
      ..add(LoadClients<AgentClient>(isDeveloper: isDeveloper));
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return context.buildFloatingBtn(
      'setup client workspace',
      icon: Icons.workspaces_outline,
      onPressed: () => context.openCreateWorkspacePopUp(),
    );
  }
}
