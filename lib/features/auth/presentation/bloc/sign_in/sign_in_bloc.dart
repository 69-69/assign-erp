import 'dart:async';

import 'package:assign_erp/core/network/data_sources/models/form_validators/index.dart';
import 'package:assign_erp/features/index.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:formz/formz.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const SignInState()) {
    _initialize();
  }

  final AuthRepository _authRepository;

  _initialize() {
    on<SignInEmailChanged>(_onEmailChanged);
    on<SignInPasswordChanged>(_onPasswordChanged);
    on<WorkspaceCategoryChanged>(_onWorkspaceCategoryChanged);
    on<WorkspaceNameChanged>(_onWorkspaceNameChanged);
    on<ClientNameChanged>(_onNameChanged);
    on<SignInMobileChanged>(_onMobileChanged);
    on<WorkspaceSignInRequested>(_onWorkspaceSignInRequested);
    on<EmployeeSignInRequested>(_onEmployeeSignInRequested);
    on<ChangeTemporalPasscodeRequested>(
      _onChangeEmployeeTemporalPasscodeRequested,
    );
    on<UpdateWorkspacePasswordRequested>(_onUpdateWorkspacePasswordRequested);
    on<WorkspacePasswordRecoveryRequested>(
      _onWorkspacePasswordRecoveryRequested,
    );
    on<CreateWorkspaceRequested>(_onCreateWorkspaceRequested);
  }

  void _onWorkspaceCategoryChanged(
    WorkspaceCategoryChanged event,
    Emitter<SignInState> emit,
  ) {
    final workspaceCategory = WorkspaceCategory.dirty(event.workspaceCategory);
    emit(
      state.copyWith(
        workspaceCategory: workspaceCategory,
        isValid: Formz.validate([
          workspaceCategory,
          state.clientName,
          state.mobileNumber,
          state.email,
          state.password,
        ]),
      ),
    );
  }

  void _onWorkspaceNameChanged(
    WorkspaceNameChanged event,
    Emitter<SignInState> emit,
  ) {
    final workspaceName = WorkspaceName.dirty(event.workspaceName);
    emit(
      state.copyWith(
        workspaceName: workspaceName,
        isValid: Formz.validate([
          workspaceName,
          state.workspaceCategory,
          state.clientName,
          state.mobileNumber,
          state.email,
          state.password,
        ]),
      ),
    );
  }

  void _onNameChanged(ClientNameChanged event, Emitter<SignInState> emit) {
    final fullName = Name.dirty(event.fullName);
    emit(
      state.copyWith(
        clientName: fullName,
        isValid: Formz.validate([
          fullName,
          state.workspaceCategory,
          state.workspaceName,
          state.mobileNumber,
          state.email,
          state.password,
        ]),
      ),
    );
  }

  void _onMobileChanged(SignInMobileChanged event, Emitter<SignInState> emit) {
    final mobile = MobileNumber.dirty(event.mobileNumber);
    emit(
      state.copyWith(
        mobileNumber: mobile,
        isValid: Formz.validate([
          mobile,
          state.workspaceCategory,
          state.workspaceName,
          state.email,
          state.clientName,
          state.password,
        ]),
      ),
    );
  }

  void _onEmailChanged(SignInEmailChanged event, Emitter<SignInState> emit) {
    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        email: email,
        isValid: Formz.validate([
          email,
          state.workspaceCategory,
          state.workspaceName,
          state.mobileNumber,
          state.clientName,
          state.password,
        ]),
      ),
    );
  }

  void _onPasswordChanged(
    SignInPasswordChanged event,
    Emitter<SignInState> emit,
  ) {
    final password = Password.dirty(event.password);
    emit(
      state.copyWith(
        password: password,
        isValid: Formz.validate([
          password,
          state.workspaceCategory,
          state.workspaceName,
          state.clientName,
          state.mobileNumber,
          state.email,
        ]),
      ),
    );
  }

  Future<void> _onCreateWorkspaceRequested(
    CreateWorkspaceRequested event,
    Emitter<SignInState> emit,
  ) async {
    if (state.isValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

      try {
        // emit(SignInLoading());

        final isCreated = await _authRepository.createWorkspace(
          workspaceCategory: state.workspaceCategory.value,
          workspaceName: state.workspaceName.value,
          fullName: state.clientName.value,
          email: state.email.value,
          mobileNumber: state.mobileNumber.value,
          password: state.password.value,
        );

        // delay to complete Authentication
        await Future.delayed(wAnimateDuration);

        FormzSubmissionStatus newStatus = isCreated
            ? FormzSubmissionStatus.success
            : FormzSubmissionStatus.failure;
        emit(state.copyWith(status: newStatus));

        // emit(AuthWorkspaceCreated());
      } on FirebaseAuthException catch (e) {
        // Use the utility method to get the error message
        final errorMessage = _authRepository.getFirebaseAuthErrorMessage(e);
        emit(
          state.copyWith(
            errorMessage: errorMessage,
            status: FormzSubmissionStatus.failure,
          ),
        );
        emit(SignInError(error: errorMessage));
      } catch (e) {
        // Handle any other exceptions
        emit(
          state.copyWith(
            errorMessage: 'An unexpected error occurred: ${e.toString()}',
            status: FormzSubmissionStatus.failure,
          ),
        );
        emit(SignInError(error: e.toString()));
      }
    }
  }

  Future<void> _onWorkspaceSignInRequested(
    WorkspaceSignInRequested event,
    Emitter<SignInState> emit,
  ) async {
    final email = state.email;
    final password = state.password;

    // Validate only email and password for sign-in
    if (Formz.validate([email, password])) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

      try {
        final data = await _authRepository.workspaceSignIn(
          email: state.email.value,
          password: state.password.value,
        );

        // Delay to complete Authentication
        await Future.delayed(wAnimateDuration);

        if (data.workspace != null) {
          emit(state.copyWith(status: FormzSubmissionStatus.success));
        } else {
          // This case handles if the workspace is null for any reason
          emit(
            state.copyWith(
              status: FormzSubmissionStatus.failure,
              errorMessage:
                  data.message ??
                  'Something went wrong...Refresh app and SignIn again!',
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        // Use the utility method to get the error message
        final errorMessage = _authRepository.getFirebaseAuthErrorMessage(e);
        emit(
          state.copyWith(
            errorMessage: errorMessage,
            status: FormzSubmissionStatus.failure,
          ),
        );
        emit(SignInError(error: errorMessage));
      } catch (e) {
        // Handle any other exceptions
        emit(
          state.copyWith(
            errorMessage: 'An unexpected error occurred: ${e.toString()}',
            status: FormzSubmissionStatus.failure,
          ),
        );
        emit(SignInError(error: e.toString()));
      }
    }
  }

  /// Handles the employee sign-in request event.
  /// Updates the state based on the result of the sign-in operation.
  ///
  /// [event] - The sign-in request event that triggered this method.
  /// [emit] - A function to emit new states.
  Future<void> _onEmployeeSignInRequested(
    EmployeeSignInRequested event,
    Emitter<SignInState> emit,
  ) async {
    // Extract email and password from the current state
    final email = state.email;
    final password = state.password;

    // Validate the email and password fields
    if (Formz.validate([email, password])) {
      // Update state to indicate that the sign-in process is in progress
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

      try {
        // Perform the sign-in operation using the repository
        final data = await _authRepository.employeeSignIn(
          email: state.email.value,
          passCode: state.password.value,
        );

        // Simulate a delay to complete the authentication process
        await Future.delayed(wAnimateDuration);

        // If sign-in was successful and both employee and workspace data are available
        if (data.employee != null && data.workspace != null) {
          emit(state.copyWith(status: FormzSubmissionStatus.success));
        } else {
          // This case handles if the workspace/employee is null for any reason
          emit(
            state.copyWith(
              status: FormzSubmissionStatus.failure,
              errorMessage: data.message ?? 'Incorrect email or password',
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        // Use the utility method to get the error message
        final errorMessage = _authRepository.getFirebaseAuthErrorMessage(e);
        emit(
          state.copyWith(
            errorMessage: errorMessage,
            status: FormzSubmissionStatus.failure,
          ),
        );
        emit(SignInError(error: errorMessage));
      } catch (e) {
        // Handle any other exceptions
        emit(
          state.copyWith(
            errorMessage: 'An unexpected error occurred: ${e.toString()}',
            status: FormzSubmissionStatus.failure,
          ),
        );
        emit(SignInError(error: e.toString()));
      }
    }
  }

  /// Handles the event when a request is made to change an employee's temporal passcode.
  ///
  /// [event] The event containing the employee ID and other relevant information.
  /// [emit] The function to emit new states to the state management system.
  ///
  /// This method validates the input, performs the passcode change operation, and updates
  /// the state based on the result of the operation. It also handles errors and manages
  /// additional processes such as silent sign-in check.
  Future<void> _onChangeEmployeeTemporalPasscodeRequested(
    ChangeTemporalPasscodeRequested event,
    Emitter<SignInState> emit,
  ) async {
    // Check if the password is valid and the employee ID is not empty
    if (Formz.validate([state.password])) {
      // Update the state to indicate that the passcode change operation is in progress
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

      try {
        // Attempt to change the employee's temporal passcode using the repository
        final data = await _authRepository.changeEmployeeTemporalPassCode(
          newPasscode: state.password.value,
        );

        // Simulate a delay to represent the time taken for the authentication process
        await Future.delayed(wAnimateDuration);

        // If the passcode change was successful, perform a silent sign-in check
        if (data.employee != null && data.workspace != null) {
          emit(state.copyWith(status: FormzSubmissionStatus.success));
        } else {
          // This case handles if the workspace/employee is null for any reason
          emit(
            state.copyWith(
              status: FormzSubmissionStatus.failure,
              errorMessage: 'Something went wrong...Sign out and SignIn again!',
            ),
          );
        }
      } catch (e) {
        // Handle any exceptions that occur during the process
        // Update the state with an error message and set the status to failure
        emit(
          state.copyWith(
            errorMessage: 'An unexpected error occurred: ${e.toString()}',
            status: FormzSubmissionStatus.failure,
          ),
        );
        // Emit an error state with the exception details
        emit(SignInError(error: e.toString()));
      }
    }
  }

  /// Handles the Update Workspace Password request event.
  /// Updates the state based on the result of the UpdatePassword operation.
  ///
  /// [event] - The UpdatePassword request event that triggered this method.
  /// [emit] - A function to emit new states.
  Future<void> _onUpdateWorkspacePasswordRequested(
    UpdateWorkspacePasswordRequested event,
    Emitter<SignInState> emit,
  ) async {
    // Extract password from the current state
    final newPassword = state.password;

    // Validate the new Password fields
    if (Formz.validate([newPassword])) {
      // Update state to indicate that the updatePassword process is in progress
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

      try {
        // Perform the updatePassword operation using the repository
        final data = await _authRepository.updateWorkspacePassword(
          newPassword: newPassword.value,
        );

        // Simulate a delay to complete the password update process
        await Future.delayed(wAnimateDuration);

        // Determine the new state based on the updatePassword result
        final newState = data
            ? FormzSubmissionStatus.success
            : FormzSubmissionStatus.failure;

        // Update the state with the result of the updatePassword operation
        emit(state.copyWith(status: newState));
      } on FirebaseAuthException catch (e) {
        // Use the utility method to get the error message
        final errorMessage = _authRepository.getFirebaseAuthErrorMessage(e);
        emit(
          state.copyWith(
            errorMessage: errorMessage,
            status: FormzSubmissionStatus.failure,
          ),
        );
        emit(SignInError(error: errorMessage));
      } catch (e) {
        // Handle any other exceptions
        emit(
          state.copyWith(
            errorMessage: 'An unexpected error occurred: ${e.toString()}',
            status: FormzSubmissionStatus.failure,
          ),
        );
        emit(SignInError(error: e.toString()));
      }
    }
  }

  /// Handles the forgot Workspace Password request event.
  /// Updates the state based on the result of the forgot operation.
  ///
  /// [event] - The forgot password request event that triggered this method.
  /// [emit] - A function to emit new states.
  Future<void> _onWorkspacePasswordRecoveryRequested(
    WorkspacePasswordRecoveryRequested event,
    Emitter<SignInState> emit,
  ) async {
    // Extract email from the current state
    final email = state.email;

    // Validate the email fields
    if (Formz.validate([email])) {
      // Update state to indicate that the forgotPassword process is in progress
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

      try {
        // Perform the forgotPassword operation using the repository
        final data = await _authRepository.forgotWorkspacePassword(
          email: state.email.value,
        );

        // Simulate a delay to complete the password reset email process
        await Future.delayed(wAnimateDuration);

        // Determine the new state based on the forgotPassword result
        final newState = data
            ? FormzSubmissionStatus.success
            : FormzSubmissionStatus.failure;

        // Update the state with the result of the forgotPassword operation
        emit(state.copyWith(status: newState));
      } on FirebaseAuthException catch (e) {
        // Use the utility method to get the error message
        final errorMessage = _authRepository.getFirebaseAuthErrorMessage(e);
        emit(
          state.copyWith(
            errorMessage: errorMessage,
            status: FormzSubmissionStatus.failure,
          ),
        );
        emit(SignInError(error: errorMessage));
      } catch (e) {
        // Handle any other exceptions
        emit(
          state.copyWith(
            errorMessage: 'An unexpected error occurred: ${e.toString()}',
            status: FormzSubmissionStatus.failure,
          ),
        );
        emit(SignInError(error: e.toString()));
      }
    }
  }
}
