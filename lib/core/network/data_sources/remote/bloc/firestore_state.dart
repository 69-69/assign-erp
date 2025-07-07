part of 'firestore_bloc.dart';

/// State
///
sealed class FirestoreState<T> extends Equatable {
  const FirestoreState();

  @override
  List<Object?> get props => [];
}

class LoadingData<T> extends FirestoreState<T> {}

class DataLoaded<T> extends FirestoreState<T> {
  final List<T> data;

  const DataLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class SingleDataLoaded<T> extends FirestoreState<T> {
  final T data;

  const SingleDataLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

// just
class DataAdded<T> extends FirestoreState<T> {
  final String? message;

  const DataAdded({this.message});

  @override
  List<Object?> get props => [message];
}

class DataUpdated<T> extends FirestoreState<T> {
  final String? message;

  const DataUpdated({this.message});

  @override
  List<Object?> get props => [message];
}

class DataDeleted<T> extends FirestoreState<T> {
  final String? message;

  const DataDeleted({this.message});

  @override
  List<Object?> get props => [message];
}

class DataError<T> extends FirestoreState<T> {
  final String error;

  const DataError(this.error);

  @override
  List<Object?> get props => [error];
}

/*sealed class FirestoreState extends Equatable {
  const FirestoreState();

  @override
  List<Object?> get props => [];
}

class LoadingState extends FirestoreState {}

class DataLoadedState extends FirestoreState {
  final List<Inventory> data;

  const DataLoadedState(this.data);

  @override
  List<Object?> get props => [data];
}

class DataAddedState extends FirestoreState {}

class DataUpdatedState extends FirestoreState {}

class DataDeletedState extends FirestoreState {}

class ErrorState extends FirestoreState {
  final String error;

  const ErrorState(this.error);

  @override
  List<Object?> get props => [error];
}*/
