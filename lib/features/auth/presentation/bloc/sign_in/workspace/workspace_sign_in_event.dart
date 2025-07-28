part of 'workspace_sign_in_bloc.dart';

/// [WorkspaceSignInEvent] Abstract class for all sign-in events
sealed class WorkspaceSignInEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// [SignInEmailChanged] TEXT-FIELD: Event when the email field changes
class SignInEmailChanged extends WorkspaceSignInEvent {
  SignInEmailChanged(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

/// [SignInMobileChanged] TEXT-FIELD: Event when the mobile number field changes
class SignInMobileChanged extends WorkspaceSignInEvent {
  SignInMobileChanged(this.mobileNumber);

  final String mobileNumber;

  @override
  List<Object> get props => [mobileNumber];
}

/// [WorkspaceCategoryChanged] TEXT-FIELD: Event when the Workspace Category field changes
class WorkspaceCategoryChanged extends WorkspaceSignInEvent {
  final String workspaceCategory;

  WorkspaceCategoryChanged(this.workspaceCategory);

  @override
  List<Object> get props => [workspaceCategory];
}

/// [WorkspaceNameChanged] TEXT-FIELD: Event when the Workspace name field changes
class WorkspaceNameChanged extends WorkspaceSignInEvent {
  final String workspaceName;

  WorkspaceNameChanged(this.workspaceName);

  @override
  List<Object> get props => [workspaceName];
}

/// [ClientNameChanged] TEXT-FIELD: Event when the full name field changes
class ClientNameChanged extends WorkspaceSignInEvent {
  final String fullName;

  ClientNameChanged(this.fullName);

  @override
  List<Object> get props => [fullName];
}

/// [TemporaryPasscodeChanged] TEXT-FIELD: Event when the employee passcode field changes (Only For Employee)
class TemporaryPasscodeChanged extends WorkspaceSignInEvent {
  TemporaryPasscodeChanged(this.passcode);

  final String passcode;

  @override
  List<Object> get props => [passcode];
}

/// [SignInPasswordChanged] TEXT-FIELD: Event when the password field changes
class SignInPasswordChanged extends WorkspaceSignInEvent {
  SignInPasswordChanged(this.password);

  final String password;

  @override
  List<Object> get props => [password];
}

/// [SignInRequested] BUTTON: Event to submit Workspace sign-in form
class SignInRequested extends WorkspaceSignInEvent {}

/// [UpdatePasswordRequested] BUTTON: Event to submit Update Workspace Password form
class UpdatePasswordRequested extends WorkspaceSignInEvent {}

/// [PasswordRecoveryRequested] BUTTON: Event to submit Workspace Password Recovery form
class PasswordRecoveryRequested extends WorkspaceSignInEvent {}

/// [CreateRequested] BUTTON: Event to submit sign-up form
class CreateRequested extends WorkspaceSignInEvent {}

/*/// [EmployeeSignInRequested] BUTTON: Event to submit Employee sign-in form
class EmployeeSignInRequested extends SignInEvent {}
/// [ChangeTemporaryPasscodeRequested] BUTTON: Event to submit Change Employee Temporary Passcode form
class ChangeTemporaryPasscodeRequested extends SignInEvent {}
 */
