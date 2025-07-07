part of 'manual_bloc.dart';

/// State
///
sealed class ManualState<T> extends Equatable {
  const ManualState();

  @override
  List<Object?> get props => [];
}

class LoadingManuals<T> extends ManualState<T> {}

class ManualsLoaded<T> extends ManualState<T> {
  final List<T> data;

  const ManualsLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class ManualLoaded<T> extends ManualState<T> {
  final T data;

  const ManualLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class ManualAdded<T> extends ManualState<T> {
  final String? message;

  const ManualAdded({this.message});

  @override
  List<Object?> get props => [message];
}

class ManualUpdated<T> extends ManualState<T> {
  final String? message;

  const ManualUpdated({this.message});

  @override
  List<Object?> get props => [message];
}

class ManualDeleted<T> extends ManualState<T> {
  final String? message;

  const ManualDeleted({this.message});

  @override
  List<Object?> get props => [message];
}

class ManualError<T> extends ManualState<T> {
  final String error;

  const ManualError(this.error);

  @override
  List<Object?> get props => [error];
}
