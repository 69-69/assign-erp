part of 'live_chat_bloc.dart';

/// Events
///
sealed class LiveChatEvent<T> extends Equatable {
  const LiveChatEvent();

  @override
  List<Object?> get props => [];
}

/// Load a single chat's messages by workspace and chat ID
class LoadChatMessagesById<T> extends LiveChatEvent<T> {
  final String workspaceId;
  final String chatId;

  const LoadChatMessagesById({required this.workspaceId, required this.chatId});

  @override
  List<Object?> get props => [workspaceId, chatId];
}

class AddChat<T> extends LiveChatEvent<T> {
  final String workspaceId;

  ///NOTE: If not provided, Firestore will assign a unique ID (documentId) [chatId]
  final String? chatId;
  final T message;
  final String? userName;

  const AddChat({
    this.chatId,
    this.userName,
    required this.message,
    required this.workspaceId,
  });

  @override
  List<Object?> get props => [chatId, workspaceId, userName, message];
}

/// T data: Generic Data Update: using Model-Class
///   --OR-- Note:: use Generic or Map data update
/// Map? mapData: `Map<String, dynamic>` Data Update
class UpdateChat<T> extends LiveChatEvent<T> {
  final T? data;
  final Map<String, dynamic>? mapData;
  final String documentId;

  const UpdateChat({required this.documentId, this.data, this.mapData});

  @override
  List<Object?> get props => [data, documentId];
}

class DeleteChat<T> extends LiveChatEvent<T> {
  final String documentId;

  const DeleteChat({required this.documentId});

  @override
  List<Object?> get props => [documentId];
}

/// Internal events for state updates
///
// More chats
class _ChatsLoaded<T> extends LiveChatEvent<T> {
  final List<T> data;

  const _ChatsLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

// Single chat
class _ChatLoaded<T> extends LiveChatEvent<T> {
  final T data;

  const _ChatLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class _LiveChatError extends LiveChatEvent {
  final String error;

  const _LiveChatError(this.error);

  @override
  List<Object?> get props => [error];
}
