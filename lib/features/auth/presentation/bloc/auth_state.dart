part of 'auth_bloc.dart';

// Base state class for authentication
class AuthState extends Equatable {
  final AuthStatus authStatus;
  final Workspace? workspace;
  final Employee? employee;
  final String? error;

  const AuthState._({
    this.authStatus = AuthStatus.initial,
    this.workspace,
    this.employee,
    this.error,
  });

  // Base states
  const AuthState.authInitial() : this._();

  const AuthState.isLoading() : this._(authStatus: AuthStatus.isLoading);

  const AuthState.emailNotVerified()
    : this._(authStatus: AuthStatus.emailNotVerified);

  // Authenticated Workspace states
  const AuthState.workspaceAuthenticated({Workspace? workspace})
    : this._(
        authStatus: AuthStatus.workspaceAuthenticated,
        workspace: workspace,
      );

  // Authenticated Employee states with Workspace
  const AuthState.authenticated({Workspace? workspace, Employee? employee})
    : this._(
        authStatus: AuthStatus.authenticated,
        workspace: workspace,
        employee: employee,
      );

  // Error and unauthenticated states
  const AuthState.unauthenticated()
    : this._(authStatus: AuthStatus.unauthenticated);

  const AuthState.hasTemporaryPasscode()
    : this._(authStatus: AuthStatus.hasTemporaryPasscode);

  const AuthState.hasError({String? error})
    : this._(authStatus: AuthStatus.hasError, error: error);

  @override
  List<Object?> get props => [authStatus, workspace, employee, error];
}
