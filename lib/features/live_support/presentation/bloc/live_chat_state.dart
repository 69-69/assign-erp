part of 'live_chat_bloc.dart';

/// State
///
sealed class LiveChatState<T> extends Equatable {
  const LiveChatState();

  @override
  List<Object?> get props => [];
}

class LoadingChats<T> extends LiveChatState<T> {}

class ChatsLoaded<T> extends LiveChatState<T> {
  final List<T> data;

  const ChatsLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class ChatLoaded<T> extends LiveChatState<T> {
  final T data;

  const ChatLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class ChatOverviewsLoaded<T> extends LiveChatState<T> {
  final List<T> data;

  const ChatOverviewsLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class ChatOverviewLoaded<T> extends LiveChatState<T> {
  final T data;

  const ChatOverviewLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class ChatAdded<T> extends LiveChatState<T> {
  final String? message;

  const ChatAdded({this.message});

  @override
  List<Object?> get props => [message];
}

class ChatUpdated<T> extends LiveChatState<T> {
  final String? message;

  const ChatUpdated({this.message});

  @override
  List<Object?> get props => [message];
}

class ChatDeleted<T> extends LiveChatState<T> {
  final String? message;

  const ChatDeleted({this.message});

  @override
  List<Object?> get props => [message];
}

class LiveChatError<T> extends LiveChatState<T> {
  final String error;

  const LiveChatError(this.error);

  @override
  List<Object?> get props => [error];
}
