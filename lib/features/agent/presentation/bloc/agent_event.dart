part of 'agent_bloc.dart';

/// Events
///
sealed class AgentEvent<T> extends Equatable {
  const AgentEvent();

  @override
  List<Object?> get props => [];
}

class LoadClients<T> extends AgentEvent<T> {
  final bool isDeveloper;

  const LoadClients({this.isDeveloper = false});
}

class RefreshClients<T> extends AgentEvent<T> {}

class LoadClientById<T> extends AgentEvent<T> {
  final Object? field;
  final String documentId;

  const LoadClientById({required this.documentId, this.field});

  @override
  List<Object?> get props => [documentId, field];
}

/// T data: Generic Data Update: using Model-Class
///   --OR-- Note:: use Generic or Map data update
/// Map? mapData: `Map<String, dynamic>` Data Update
class UpdateClient<T> extends AgentEvent<T> {
  final T? data;
  final Map<String, dynamic>? mapData;
  final String documentId;

  const UpdateClient({required this.documentId, this.data, this.mapData});

  @override
  List<Object?> get props => [data, documentId];
}

class DeleteClient<T> extends AgentEvent<T> {
  final String documentId;

  const DeleteClient({required this.documentId});

  @override
  List<Object?> get props => [documentId];
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
