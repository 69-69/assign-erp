part of 'sign_in_bloc.dart';

sealed class SignInEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Event when the email field changes
class SignInEmailChanged extends SignInEvent {
  SignInEmailChanged(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

// Event when the mobile number field changes
class SignInMobileChanged extends SignInEvent {
  SignInMobileChanged(this.mobileNumber);

  final String mobileNumber;

  @override
  List<Object> get props => [mobileNumber];
}

// Event when the Workspace Category field changes
class WorkspaceCategoryChanged extends SignInEvent {
  final String workspaceCategory;

  WorkspaceCategoryChanged(this.workspaceCategory);

  @override
  List<Object> get props => [workspaceCategory];
}

// Event when the Workspace name field changes
class WorkspaceNameChanged extends SignInEvent {
  final String workspaceName;

  WorkspaceNameChanged(this.workspaceName);

  @override
  List<Object> get props => [workspaceName];
}

// Event when the full name field changes
class ClientNameChanged extends SignInEvent {
  final String fullName;

  ClientNameChanged(this.fullName);

  @override
  List<Object> get props => [fullName];
}

// Event when the password field changes
class SignInPasswordChanged extends SignInEvent {
  SignInPasswordChanged(this.password);

  final String password;

  @override
  List<Object> get props => [password];
}

// Event to submit Workspace sign-in form
class WorkspaceSignInRequested extends SignInEvent {}

// Event to submit Employee sign-in form
class EmployeeSignInRequested extends SignInEvent {}

// Event to submit Update Workspace Password form
class UpdateWorkspacePasswordRequested extends SignInEvent {}

// Event to submit Workspace Password Recovery form
class WorkspacePasswordRecoveryRequested extends SignInEvent {}

// Event to submit Change Employee TemporalPassCode form
class ChangeTemporalPasscodeRequested extends SignInEvent {}

// Event to submit sign-up form
class CreateWorkspaceRequested extends SignInEvent {}
