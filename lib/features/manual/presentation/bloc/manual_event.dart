part of 'manual_bloc.dart';

/// Events
///
sealed class ManualEvent<T> extends Equatable {
  const ManualEvent();

  @override
  List<Object?> get props => [];
}

class LoadManuals<T> extends ManualEvent<T> {}

class RefreshManuals<T> extends ManualEvent<T> {}

class LoadManualById<T> extends ManualEvent<T> {
  final Object? field;
  final String documentId;

  const LoadManualById({required this.documentId, this.field});

  @override
  List<Object?> get props => [documentId, field];
}

class AddManual<T> extends ManualEvent<T> {
  final T data;

  ///NOTE: If not provided, Firestore will assign a unique ID (documentId) [documentId]
  final String? documentId;

  const AddManual({this.documentId, required this.data});

  @override
  List<Object?> get props => [documentId, data];
}

/// T data: Generic Data Update: using Model-Class
///   --OR-- Note:: use Generic or Map data update
/// Map? mapData: `Map<String, dynamic>` Data Update
class UpdateManual<T> extends ManualEvent<T> {
  final T? data;
  final Map<String, dynamic>? mapData;
  final String documentId;

  const UpdateManual({required this.documentId, this.data, this.mapData});

  @override
  List<Object?> get props => [data, documentId];
}

class DeleteManual<T> extends ManualEvent<T> {
  final String documentId;

  const DeleteManual({required this.documentId});

  @override
  List<Object?> get props => [documentId];
}

/// Internal events for state updates
class _ManualsLoaded<T> extends ManualEvent<T> {
  final List<T> data;

  const _ManualsLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class _ManualLoaded<T> extends ManualEvent<T> {
  final T data;

  const _ManualLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class _ManualError extends ManualEvent {
  final String error;

  const _ManualError(this.error);

  @override
  List<Object?> get props => [error];
}
