part of 'auth_bloc.dart';

// Base state class for authentication
class AuthState extends Equatable {
  final AuthStatusEnum authStatus;
  final Workspace? workspace;
  final Employee? employee;
  final String? error;

  const AuthState._({
    this.authStatus = AuthStatusEnum.initial,
    this.workspace,
    this.employee,
    this.error,
  });

  // Base states
  const AuthState.authInitial() : this._();

  const AuthState.isLoading() : this._(authStatus: AuthStatusEnum.isLoading);

  const AuthState.emailNotVerified()
      : this._(authStatus: AuthStatusEnum.emailNotVerified);

  // Authenticated and workspace related states
  const AuthState.workspaceAuthenticated({Workspace? workspace})
      : this._(
          authStatus: AuthStatusEnum.workspaceAuthenticated,
          workspace: workspace,
        );

  const AuthState.authenticated({Workspace? workspace, Employee? employee})
      : this._(
          authStatus: AuthStatusEnum.authenticated,
          workspace: workspace,
          employee: employee,
        );

  // Error and unauthenticated states
  const AuthState.unauthenticated()
      : this._(authStatus: AuthStatusEnum.unauthenticated);

  const AuthState.storesSwitched()
      : this._(authStatus: AuthStatusEnum.storesSwitched);

  const AuthState.hasTemporalPasscode()
      : this._(authStatus: AuthStatusEnum.hasTemporalPasscode);

  const AuthState.hasError({String? error})
      : this._(authStatus: AuthStatusEnum.hasError, error: error);

  @override
  List<Object?> get props => [authStatus, workspace, employee, error];
}

/*class AuthState extends Equatable {
  const AuthState({
    this.email = const Email.pure(),
    this.companyName = const CompanyName.pure(),
    this.fullName = const Name.pure(),
    this.mobileNumber = const MobileNumber.pure(),
    this.password = const Password.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.errorMessage,
  });

  final Email email;
  final CompanyName companyName;
  final Name fullName;
  final MobileNumber mobileNumber;
  final Password password;
  final FormzSubmissionStatus status;
  final bool isValid;
  final String? errorMessage;

  // Creates a copy of the current state with possible modifications
  AuthState copyWith({
    FormzSubmissionStatus? status,
    CompanyName? companyName,
    Email? email,
    Name? fullName,
    MobileNumber? mobileNumber,
    Password? password,
    bool? isValid,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      companyName: companyName ?? this.companyName,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        companyName,
        email,
        fullName,
        mobileNumber,
        password,
        status,
        isValid,
        errorMessage,
      ];
}

// Initial state of authentication
class AuthInitial extends AuthState {}

// State when authentication is loading
class AuthLoading extends AuthState {}

// State when Workspace authentication is successful
class WorkspaceAuthenticated extends AuthState {
  final Workspace? workspace;

  const WorkspaceAuthenticated({this.workspace});

  @override
  List<Object?> get props => [workspace, ...super.props];
}

// State when authentication is successful
class AuthAuthenticated extends AuthState {
  final Workspace? workspace;
  final Employee? employee;

  const AuthAuthenticated({this.workspace, this.employee});

  @override
  List<Object?> get props => [...super.props];
}

// State when authentication fails
class AuthUnauthenticated extends AuthState {}

// State when email is not verified
class AuthEmailNotVerified extends AuthState {}

// State when password reset is in progress
class AuthPasswordReset extends AuthState {}

// State when an error occurs during authentication
class AuthError extends AuthState {
  final String error;

  const AuthError({required this.error});

  @override
  List<Object?> get props => [error, ...super.props];
}*/
