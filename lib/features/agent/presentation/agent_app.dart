import 'package:assign_erp/features/agent/presentation/screen/list/index.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:flutter/material.dart';

class AgentApp extends StatelessWidget {
  const AgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    /// check if workspaceRole is developer
    final isDeveloper = WorkspaceRoleGuard.canAccessDeveloperDashboard(context);

    return isDeveloper ? SystemWideWorkspaces() : AgentClientsWorkspaces();
  }
}
