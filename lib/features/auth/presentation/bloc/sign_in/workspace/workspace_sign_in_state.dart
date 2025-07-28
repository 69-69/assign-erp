part of 'workspace_sign_in_bloc.dart';

class WorkspaceSignInState extends Equatable {
  const WorkspaceSignInState({
    this.status = FormzSubmissionStatus.initial,
    this.workspaceCategory = const WorkspaceCategory.pure(),
    this.workspaceName = const WorkspaceName.pure(),
    this.mobileNumber = const MobileNumber.pure(),
    this.password = const Password.pure(),
    this.temporaryPasscode = const Passcode.pure(),
    this.clientName = const Name.pure(),
    this.email = const Email.pure(),
    this.isValid = false,
    this.errorMessage,
  });

  final FormzSubmissionStatus status;
  final WorkspaceCategory workspaceCategory;
  final WorkspaceName workspaceName;
  final MobileNumber mobileNumber;
  final Password password; // Only for Workspace
  final Passcode temporaryPasscode; // Only for Employee Onetime
  final Name clientName;
  final Email email;
  final bool isValid;
  final String? errorMessage;

  // Creates a copy of the current state with possible modifications
  WorkspaceSignInState copyWith({
    FormzSubmissionStatus? status,
    WorkspaceCategory? workspaceCategory,
    WorkspaceName? workspaceName,
    MobileNumber? mobileNumber,
    Password? password,
    Passcode? temporaryPasscode,
    Name? clientName,
    Email? email,
    bool? isValid,
    String? errorMessage,
  }) {
    return WorkspaceSignInState(
      status: status ?? this.status,
      workspaceCategory: workspaceCategory ?? this.workspaceCategory,
      workspaceName: workspaceName ?? this.workspaceName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      clientName: clientName ?? this.clientName,
      password: password ?? this.password,
      temporaryPasscode: temporaryPasscode ?? this.temporaryPasscode,
      email: email ?? this.email,
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
    temporaryPasscode,
    status,
    isValid,
    errorMessage,
  ];
}

// State when an error occurs during authentication
class WorkspaceSignInError extends WorkspaceSignInState {
  final String error;

  const WorkspaceSignInError({required this.error});

  @override
  List<Object?> get props => [error, ...super.props];
}
