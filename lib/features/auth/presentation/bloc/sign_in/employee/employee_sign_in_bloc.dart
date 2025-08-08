import 'dart:async';

import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/network/data_sources/models/form_validators/index.dart';
import 'package:assign_erp/features/auth/domain/repository/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

part 'employee_sign_in_event.dart';
part 'employee_sign_in_state.dart';

class EmployeeSignInBloc
    extends Bloc<EmployeeSignInEvent, EmployeeSignInState> {
  final AuthRepository _authRepository;

  EmployeeSignInBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const EmployeeSignInState()) {
    _initialize();
  }

  _initialize() {
    on<EmployeeSignInEmailChanged>(_onEmailChanged);
    on<EmployeePasscodeChanged>(_onEmployeePasscodeChanged);
    on<EmployeeSignInRequested>(_onEmployeeSignInRequested);
    on<ChangePasscodeRequested>(_onChangePasscodeRequested);
  }

  void _onEmailChanged(
    EmployeeSignInEmailChanged event,
    Emitter<EmployeeSignInState> emit,
  ) {
    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        email: email,
        isValid: Formz.validate([email, state.passcode]),
      ),
    );
  }

  void _onEmployeePasscodeChanged(
    EmployeePasscodeChanged event,
    Emitter<EmployeeSignInState> emit,
  ) {
    final passcode = Passcode.dirty(event.passcode);
    emit(
      state.copyWith(
        passcode: passcode,
        isValid: Formz.validate([passcode, state.email]),
      ),
    );
  }

  /// Handles the employee sign-in request event.
  /// Updates the state based on the result of the sign-in operation.
  ///
  /// [event] - The sign-in request event that triggered this method.
  /// [emit] - A function to emit new states.
  Future<void> _onEmployeeSignInRequested(
    EmployeeSignInRequested event,
    Emitter<EmployeeSignInState> emit,
  ) async {
    // Extract email and password from the current state
    final email = state.email;
    final passcode = state.passcode;

    // Validate the email and password fields
    if (Formz.validate([email, passcode])) {
      // Update state to indicate that the sign-in process is in progress
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

      try {
        // Perform the sign-in operation using the repository
        final data = await _authRepository.employeeSignIn(
          email: email.value,
          passCode: passcode.value,
        );

        // Simulate a delay to complete the authentication process
        await Future.delayed(kRProgressDelay);

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
        emit(EmployeeSignInError(error: errorMessage));
      } catch (e) {
        // Handle any other exceptions
        emit(
          state.copyWith(
            errorMessage: 'An unexpected error occurred: ${e.toString()}',
            status: FormzSubmissionStatus.failure,
          ),
        );
        emit(EmployeeSignInError(error: e.toString()));
      }
    }
  }

  /// Handles the event when a request is made to change an employee's Temporary passcode.
  ///
  /// [event] The event containing the employee ID and other relevant information.
  /// [emit] The function to emit new states to the state management system.
  ///
  /// This method validates the input, performs the passcode change operation, and updates
  /// the state based on the result of the operation. It also handles errors and manages
  /// additional processes such as silent sign-in check.
  Future<void> _onChangePasscodeRequested(
    ChangePasscodeRequested event,
    Emitter<EmployeeSignInState> emit,
  ) async {
    // Check if the password is valid and the employee ID is not empty
    if (Formz.validate([state.passcode])) {
      // Update the state to indicate that the passcode change operation is in progress
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

      try {
        // Attempt to change the employee's Temporary passcode using the repository
        final data = await _authRepository.changeEmployeeTemporaryPassCode(
          newPasscode: state.passcode.value,
        );

        // Simulate a delay to represent the time taken for the authentication process
        await Future.delayed(kRProgressDelay);

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
        emit(EmployeeSignInError(error: e.toString()));
      }
    }
  }
}
