// Enum for authentication status
enum AuthStatusEnum {
  initial,
  isLoading,
  authenticated,
  unauthenticated,
  storesSwitched,
  emailNotVerified,
  workspaceAuthenticated,
  hasTemporalPasscode,
  hasError,
}