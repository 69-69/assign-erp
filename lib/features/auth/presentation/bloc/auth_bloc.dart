import 'dart:async';

import 'package:assign_erp/core/constants/account_status.dart';
import 'package:assign_erp/core/network/data_sources/local/error_logs_cache.dart';
import 'package:assign_erp/core/network/data_sources/models/workspace_model.dart';
import 'package:assign_erp/features/auth/domain/repository/auth_repository.dart';
import 'package:assign_erp/features/auth/presentation/bloc/auth_status_enum.dart';
import 'package:assign_erp/features/setup/data/models/employee_model.dart';
import 'package:async/async.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late final StreamSubscription<void> _subscription;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthState.authInitial()) {
    _initialize();
    add(AuthCheckRequested());

    _subscribeToAuthStreams();
  }

  void _initialize() {
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthUserChanged>(_onAuthUserChanged);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  void _subscribeToAuthStreams() {
    _subscription =
        StreamGroup.merge([
          _authRepository.firebaseAuthStateChanges.map(
            (user) => AuthUserChanged(user: user),
          ),

          _authRepository.authStatusChanges.map(
            (status) => AuthStatusChanged(status: status),
          ),
        ])
        // Listen to the merged stream and add each event to the Bloc's event stream.
        // This allows the Bloc to process events from both streams.
        .listen((event) => add(event));
  }

  Future<void> _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    final user = event.user;

    if (user == null) {
      emit(const AuthState.unauthenticated());
      return;
    }

    await _handleUserAuth(user, emit);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = _authRepository.firebaseUser;

      if (user == null) {
        emit(const AuthState.unauthenticated());
        return;
      }

      await _handleUserAuth(user, emit);
    } catch (e /*, stackTrace*/) {
      _handleError(emit, 'Error during status change: $e');
    }
  }

  Future<void> _handleUserAuth(User user, Emitter<AuthState> emit) async {
    try {
      final workspace = await _authRepository.getWorkspace(uid: user.uid);
      final employee = await _authRepository.getEmployee();

      if (workspace?.status == AccountStatus.enabled.label) {
        if (!user.emailVerified) {
          emit(const AuthState.emailNotVerified());
        } else {
          emit(
            AuthState.authenticated(workspace: workspace, employee: employee),
          );
        }
      } else {
        emit(const AuthState.unauthenticated());
      }
    } catch (e /*, stackTrace*/) {
      _handleError(emit, 'Error during status change: $e');
    }
  }

  Future<void> _onAuthStatusChanged(
    AuthStatusChanged event,
    Emitter<AuthState> emit,
  ) async {
    try {
      switch (event.status) {
        case AuthStatusEnum.workspaceAuthenticated:
          await _emitWorkspaceAuthenticatedState(emit);
          break;

        case AuthStatusEnum.unauthenticated:
          emit(const AuthState.unauthenticated());
          break;

        case AuthStatusEnum.authenticated:
          await _emitAuthenticatedState(emit);
          break;

        case AuthStatusEnum.emailNotVerified:
          emit(const AuthState.emailNotVerified());
          break;

        case AuthStatusEnum.initial:
          emit(const AuthState.authInitial());
          break;

        case AuthStatusEnum.isLoading:
          emit(const AuthState.isLoading());
          break;

        case AuthStatusEnum.hasError:
          emit(const AuthState.hasError());
          break;

        case AuthStatusEnum.storesSwitched:
          emit(const AuthState.storesSwitched());
          break;
        case AuthStatusEnum.hasTemporalPasscode:
          emit(const AuthState.hasTemporalPasscode());
      }
    } catch (e /*, stackTrace*/) {
      _handleError(emit, 'Error during status change: $e');
    }
  }

  Future<void> _emitWorkspaceAuthenticatedState(Emitter<AuthState> emit) async {
    final workspace = await _authRepository.getWorkspace();
    emit(AuthState.workspaceAuthenticated(workspace: workspace));
  }

  Future<void> _emitAuthenticatedState(Emitter<AuthState> emit) async {
    final workspace = await _authRepository.getWorkspace();
    final employee = await _authRepository.getEmployee();
    emit(AuthState.authenticated(workspace: workspace, employee: employee));
  }

  void _handleError(Emitter<AuthState> emit, String errorMessage) {
    final errorLogCache = ErrorLogCache();
    errorLogCache.cacheError(error: errorMessage, fileName: 'auth_bloc');
    emit(AuthState.hasError(error: errorMessage));
    // Optionally, log the stack trace for further debugging
    // print('Error: $errorMessage');
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.signOut();
      emit(const AuthState.unauthenticated());
    } catch (e /*, stackTrace*/) {
      emit(AuthState.hasError(error: 'Error during sign out: $e'));
      // Optionally, log the stack trace for further debugging
      // print('StackTrace: $stackTrace');
    }
  }

  @override
  Future<void> close() {
    super.close();
    _subscription.cancel();
    _authRepository.dispose();
    return super.close();
  }
}

/* void _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());

      await authRepository.signUp(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        mobileNumber: event.mobileNumber,
      );

      // emit(AuthAuthenticated(user: user));
    } catch (error) {
      emit(AuthError(message: error.toString()));
    }
  }
  void _onSignInRequested(
      SignInRequested event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());

      final user = await authRepository.signIn(
        email: event.email,
        password: event.password,
      );

      if (user != null) {
        emit(AuthAuthenticated(user: user));
      }
    } catch (error) {
      emit(AuthError(message: error.toString()));
    }
  }

  void _onForgotPasswordRequested(
      ForgotPasswordRequested event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());

      await authRepository.forgotPassword(email: event.email);

      emit(AuthPasswordReset());
    } catch (error) {
      emit(AuthError(message: error.toString()));
    }
  }

  void _onSignOutRequested(
      SignOutRequested event, Emitter<AuthState> emit) async {
    await authRepository.signOut();
    emit(AuthInitial());
  }*/
