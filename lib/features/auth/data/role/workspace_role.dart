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
  /// USAGE: `WorkspaceRole.onboarding.label`
  String get label {
    var role = switch (this) {
      WorkspaceRole.onboarding => 'onboarding',
      WorkspaceRole.agentFranchise => 'agentFranchise',
      WorkspaceRole.subscriber => 'subscriber',
      WorkspaceRole.developer => 'developer',
    };
    return role;
  }

  /// [assign] Determines the role for a "New Workspace Setup" based on the
  /// currently signed-in user's role (cached workspace role).
  ///
  /// - NOTE: `WorkspaceRole.onboarding` role is used as first-time login during initial APP or WorkSpace setup.
  ///
  /// Role Assignment Logic:
  /// - If the currently signed-in workspace's role is:
  ///   - `onboarding`, assigns `WorkspaceRole.agentFranchise`.
  ///   - `agentFranchise`, assigns `WorkspaceRole.subscriber`.
  ///   - `developer`, retains `WorkspaceRole.developer`.
  ///   - If the role is `null`, defaults to `WorkspaceRole.subscriber`.
  ///
  /// Used during the "Setup/Create New Workspace" flow. [assign]
  /// USAGE: `WorkspaceRole.onboarding.assign`
  WorkspaceRole get assign {
    return switch (this) {
      WorkspaceRole.onboarding => WorkspaceRole.agentFranchise,
      WorkspaceRole.agentFranchise => WorkspaceRole.subscriber,
      WorkspaceRole.developer => WorkspaceRole.developer,
      _ => WorkspaceRole.subscriber,
    };
  }
}

/// Enum values to a list of strings [workspaceRoleList]
final workspaceRoleList = [
  'workspace role',
  ...WorkspaceRole.values.map((e) => e.label),
];
