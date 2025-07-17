part of 'user_guide_bloc.dart';

/// State
///
sealed class GuideState<T> extends Equatable {
  const GuideState();

  @override
  List<Object?> get props => [];
}

class LoadingGuides<T> extends GuideState<T> {}

class GuidesLoaded<T> extends GuideState<T> {
  final List<T> data;

  const GuidesLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class GuideLoaded<T> extends GuideState<T> {
  final T data;

  const GuideLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class GuideAdded<T> extends GuideState<T> {
  final String? message;

  const GuideAdded({this.message});

  @override
  List<Object?> get props => [message];
}

class GuideUpdated<T> extends GuideState<T> {
  final String? message;

  const GuideUpdated({this.message});

  @override
  List<Object?> get props => [message];
}

class GuideDeleted<T> extends GuideState<T> {
  final String? message;

  const GuideDeleted({this.message});

  @override
  List<Object?> get props => [message];
}

class GuideError<T> extends GuideState<T> {
  final String error;

  const GuideError(this.error);

  @override
  List<Object?> get props => [error];
}
