// Enum for authentication status
enum AuthStatus {
  initial,
  isLoading,

  /// [authenticated] Employee is authenticated: Precedes workspaceAuthenticated
  authenticated,
  unauthenticated,
  emailNotVerified,

  /// [workspaceAuthenticated] Workspace is authenticated
  workspaceAuthenticated,

  /// [hasTemporaryPasscode] Employee used temporary passcode(one-time login)
  hasTemporaryPasscode,
  hasError,
}
