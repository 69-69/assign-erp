part of 'employee_sign_in_bloc.dart';

/// [Employee] Abstract class for all sign-in events
sealed class EmployeeSignInEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// [EmployeeSignInEmailChanged] TEXT-FIELD: Event when the email field changes
class EmployeeSignInEmailChanged extends EmployeeSignInEvent {
  EmployeeSignInEmailChanged(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

/// [EmployeePasscodeChanged] TEXT-FIELD: Event when the employee passcode field changes (Only For Employee)
class EmployeePasscodeChanged extends EmployeeSignInEvent {
  EmployeePasscodeChanged(this.passcode);

  final String passcode;

  @override
  List<Object> get props => [passcode];
}

/// [EmployeeSignInRequested] BUTTON: Event to submit Employee sign-in form
class EmployeeSignInRequested extends EmployeeSignInEvent {}

/// [ChangePasscodeRequested] BUTTON: Event to submit Change Employee Temporary PassCode form
class ChangePasscodeRequested extends EmployeeSignInEvent {}
