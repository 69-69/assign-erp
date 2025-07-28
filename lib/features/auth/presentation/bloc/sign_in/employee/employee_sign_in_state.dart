part of 'employee_sign_in_bloc.dart';

class EmployeeSignInState extends Equatable {
  const EmployeeSignInState({
    this.email = const Email.pure(),
    this.passcode = const Passcode.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.errorMessage,
  });

  final Email email;
  final Passcode passcode; // Only for Employee
  final FormzSubmissionStatus status;
  final bool isValid;
  final String? errorMessage;

  // Creates a copy of the current state with possible modifications
  EmployeeSignInState copyWith({
    FormzSubmissionStatus? status,
    Email? email,
    Passcode? passcode,
    bool? isValid,
    String? errorMessage,
  }) {
    return EmployeeSignInState(
      status: status ?? this.status,
      email: email ?? this.email,
      passcode: passcode ?? this.passcode,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [email, passcode, status, isValid, errorMessage];
}

// State when an error occurs during authentication
class EmployeeSignInError extends EmployeeSignInState {
  final String error;

  const EmployeeSignInError({required this.error});

  @override
  List<Object?> get props => [error, ...super.props];
}
