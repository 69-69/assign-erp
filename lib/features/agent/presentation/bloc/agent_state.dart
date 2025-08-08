part of 'agent_bloc.dart';

/// State
///
sealed class AgentState<T> extends Equatable {
  const AgentState();

  @override
  List<Object?> get props => [];
}

class LoadingClients<T> extends AgentState<T> {}

// multiple clients
class ClientsLoaded<T> extends AgentState<T> {
  final List<T> data;

  const ClientsLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

// single client
class ClientLoaded<T> extends AgentState<T> {
  final T data;

  const ClientLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class AgentError<T> extends AgentState<T> {
  final String error;

  const AgentError(this.error);

  @override
  List<Object?> get props => [error];
}
