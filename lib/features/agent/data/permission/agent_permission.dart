import 'package:assign_erp/features/access_control/data/model/access_control_model.dart';

/// PERMISSION BASED ACCESS-CONTROL
enum AgentPermission {
  manageAgent,
  chatWithClient,
  createWorkspace,
  searchWorkspaces,
  viewWorkspaceSecrets,
}

final List<AccessControl> _agentPermissions = [
  AccessControl(
    module: "agent",
    title: "Manage agent",
    description:
        "Grants users the ability to create, modify, and remove workspace setup configurations",
    access: AgentPermission.manageAgent,
  ),
  AccessControl(
    module: "agent",
    title: "Chat with client",
    description: "Allow users to chat with clients.",
    access: AgentPermission.chatWithClient,
  ),
  AccessControl(
    module: "agent",
    title: "Create workspace",
    description: "Allow users to create a workspace.",
    access: AgentPermission.createWorkspace,
  ),
  AccessControl(
    module: "agent",
    title: "Search workspaces",
    description: "Allow users to search for client workspaces.",
    access: AgentPermission.searchWorkspaces,
  ),
  AccessControl(
    module: "agent",
    title: "View workspace secrets",
    description: "Allow users to view workspace secrets.",
    access: AgentPermission.viewWorkspaceSecrets,
  ),
];

final agentDisplayName = 'agent';

final List<AccessControl> agentPermissions = [..._agentPermissions];
