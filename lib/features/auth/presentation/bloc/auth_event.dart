part of 'auth_bloc.dart';

// Base event class for authentication events
sealed class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthUserChanged extends AuthEvent {
  final User? user;

  AuthUserChanged({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthStatusChanged extends AuthEvent {
  final AuthStatusEnum status;

  AuthStatusChanged({required this.status});

  @override
  List<Object?> get props => [status];
}

class AuthSignOutRequested extends AuthEvent {}
