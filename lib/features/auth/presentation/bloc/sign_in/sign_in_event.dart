part of 'sign_in_bloc.dart';

sealed class SignInEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Event to switch between Stores among different stores
class SwitchStoresRequested extends SignInEvent {
  final String storeNumber;

  SwitchStoresRequested({required this.storeNumber});

  @override
  List<Object> get props => [storeNumber];
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

// Event when the CompanyCategory field changes
class CompanyCategoryChanged extends SignInEvent {
  final String companyCategory;

  CompanyCategoryChanged(this.companyCategory);

  @override
  List<Object> get props => [companyCategory];
}

// Event when the Company name field changes
class WorkspaceNameChanged extends SignInEvent {
  final String companyName;

  WorkspaceNameChanged(this.companyName);

  @override
  List<Object> get props => [companyName];
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
