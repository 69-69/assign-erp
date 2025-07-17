part of 'sign_in_bloc.dart';

class SignInState extends Equatable {
  const SignInState({
    this.email = const Email.pure(),
    this.workspaceCategory = const WorkspaceCategory.pure(),
    this.workspaceName = const WorkspaceName.pure(),
    this.clientName = const Name.pure(),
    this.mobileNumber = const MobileNumber.pure(),
    this.password = const Password.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.errorMessage,
  });

  final Email email;
  final WorkspaceCategory workspaceCategory;
  final WorkspaceName workspaceName;
  final Name clientName;
  final MobileNumber mobileNumber;
  final Password password;
  final FormzSubmissionStatus status;
  final bool isValid;
  final String? errorMessage;

  // Creates a copy of the current state with possible modifications
  SignInState copyWith({
    FormzSubmissionStatus? status,
    WorkspaceCategory? workspaceCategory,
    WorkspaceName? workspaceName,
    Email? email,
    Name? clientName,
    MobileNumber? mobileNumber,
    Password? password,
    bool? isValid,
    String? errorMessage,
  }) {
    return SignInState(
      status: status ?? this.status,
      workspaceCategory: workspaceCategory ?? this.workspaceCategory,
      workspaceName: workspaceName ?? this.workspaceName,
      clientName: clientName ?? this.clientName,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    workspaceCategory,
    workspaceName,
    email,
    clientName,
    mobileNumber,
    password,
    status,
    isValid,
    errorMessage,
  ];
}

// State when an error occurs during authentication
class SignInError extends SignInState {
  final String error;

  const SignInError({required this.error});

  @override
  List<Object?> get props => [error, ...super.props];
}
