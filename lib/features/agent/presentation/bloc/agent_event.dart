part of 'agent_bloc.dart';

/// Events
///
sealed class AgentEvent<T> extends Equatable {
  const AgentEvent();

  @override
  List<Object?> get props => [];
}

class LoadClients<T> extends AgentEvent<T> {
  const LoadClients();
}

class RefreshClients<T> extends AgentEvent<T> {
  const RefreshClients();
}

/// Internal events for state updates
///
// Multiple clients loaded
class _ClientsLoaded<T> extends AgentEvent<T> {
  final List<T> data;

  const _ClientsLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

// single client loaded
class _ClientLoaded<T> extends AgentEvent<T> {
  final T data;

  const _ClientLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class _AgentError extends AgentEvent {
  final String error;

  const _AgentError(this.error);

  @override
  List<Object?> get props => [error];
}
