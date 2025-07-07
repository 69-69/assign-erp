enum WorkspaceRole {
  /* Write-only access: is generally provided to Agents and Developers for setting up the system..*/
  initialSetup,
  /* The Agent who setup this Software for 'Subscriber' company/organization
   * Full access to read, write, and execute operations. */
  agentFranchise,
  /* Full access to read, write, and execute, for development tasks and managing code.*/
  subscriber,
  /* Full access to read, write, and execute, for development tasks and managing code.*/
  developer,
}
/* USAGE:
* final role = WorkspaceRole.initialSetup;
* print(role.label); // Output: initialSetup
* */

extension WorkspaceRoleExtension on WorkspaceRole {
  String get label {
    var role = switch (this) {
      WorkspaceRole.initialSetup => 'initialSetup',
      WorkspaceRole.agentFranchise => 'agentFranchise',
      WorkspaceRole.subscriber => 'subscriber',
      WorkspaceRole.developer => 'developer',
    };
    return role;
  }
}
