// WORKSPACE ROLE or ACCOUNT TYPE
enum WorkspaceRole {
  /// Role for creating first-time Agent Workspaces [onboarding].
  onboarding,

  /// Role for agents to manage their own and client's (tenants) workspaces [agentFranchise].
  agentFranchise,

  /// Role for paid subscribers (tenants) workspaces [subscriber].
  subscriber,

  /// Role for developers to troubleshoot, manage tenants workspaces & subscriptions [developer].
  developer,
}

extension WorkspaceRoleExtension on WorkspaceRole {
  String get label {
    var role = switch (this) {
      WorkspaceRole.onboarding => 'onboarding',
      WorkspaceRole.agentFranchise => 'agentFranchise',
      WorkspaceRole.subscriber => 'subscriber',
      WorkspaceRole.developer => 'developer',
    };
    return role;
  }
}

/// Enum values to a list of strings [workspaceRoleList]
final workspaceRoleList = [
  'workspace role',
  ...WorkspaceRole.values.map((e) => e.label),
];
