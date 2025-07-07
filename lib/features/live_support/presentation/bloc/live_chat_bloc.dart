import 'dart:async';

import 'package:assign_erp/core/constants/collection_type_enum.dart';
import 'package:assign_erp/core/network/data_sources/local/cache_data_model.dart';
import 'package:assign_erp/core/network/data_sources/local/error_logs_cache.dart';
import 'package:assign_erp/features/live_support/domain/repository/live_chat_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'live_chat_event.dart';
part 'live_chat_state.dart';

/// LiveSupportBloc
///
class LiveChatBloc<T> extends Bloc<LiveChatEvent, LiveChatState<T>> {
  final LiveChatRepository _chatRepository;
  // final FirebaseFirestore _firestore;
  final String collectionPath;
  final CollectionType? collectionType;

  /// toCache/toJson Function [toCache]
  final Map<String, dynamic> Function(T data) toCache;

  /// toJson/toMap Function [toFirestore]
  final Map<String, dynamic> Function(T data) toFirestore;

  /// fromJson/fromMap Function [fromFirestore]
  final T Function(Map<String, dynamic> data, String documentId) fromFirestore;

  LiveChatBloc({
    this.collectionType,
    required FirebaseFirestore firestore,
    required this.collectionPath,
    required this.fromFirestore,
    required this.toFirestore,
    required this.toCache,
  }) : _chatRepository = LiveChatRepository(
         firestore: firestore,
         collectionType: collectionType,
         collectionPath: collectionPath,
       ),
       super(LoadingChats<T>()) {
    _initialize();

    _chatRepository.dataStream.listen(
      (cacheData) => add(_ChatsLoaded<T>(_toList(cacheData))),
    );
  }

  Future<void> _initialize() async {
    on<LoadChatMessagesById<T>>(_onLoadChatMessagesById);
    on<LoadChatOverviews<T>>(_onLoadChatOverviews);
    on<AddChat<T>>(_onSendMessage);
    on<_ChatsLoaded<T>>(_onChatsLoaded);
    on<_ChatLoaded<T>>(_onChatLoaded);
    on<_LiveChatError>(_onChatLoadError);
  }

  Future<void> _onLoadChatMessagesById(
    LoadChatMessagesById<T> event,
    Emitter<LiveChatState<T>> emit,
  ) async {
    emit(LoadingChats<T>());
    try {
      // Await the first value emitted by the stream
      final stream = _chatRepository.getChatByWorkspace(
        workspaceId: event.workspaceId,
        chatId: event.chatId,
      );

      final cacheList = await stream.first;

      debugPrint('Chat List: ${cacheList.length}');
      if (cacheList.isNotEmpty) {
        // Assuming you're interested in the first chat item
        final cacheData = cacheList.first;
        final data = fromFirestore(cacheData.data, cacheData.id);
        emit(ChatLoaded<T>(data));
      } else {
        emit(LiveChatError<T>('Chat Message not found'));
      }
    } catch (e) {
      emit(LiveChatError<T>(e.toString()));
    }
  }

  Future<void> _onLoadChatOverviews(
    LoadChatOverviews<T> event,
    Emitter<LiveChatState<T>> emit,
  ) async {
    emit(LoadingChats<T>());
    try {
      // Await the first value emitted by the stream
      final stream = _chatRepository.getChatOverviewsByWorkspaceStream(
        workspaceId: event.workspaceId,
      );

      final cacheList = await stream.first;

      if (cacheList.isNotEmpty) {
        // Assuming you're interested in the first chat item
        final cacheData = cacheList.first;
        final data = fromFirestore(cacheData.data, cacheData.id);
        emit(ChatOverviewLoaded<T>(data));
      } else {
        emit(LiveChatError<T>('Chat Overview not found'));
      }

      /*await emit.forEach<List<CacheData>>(
        _chatRepository.getChatByWorkspace(
          workspaceId: event.workspaceId,
          userId: event.documentId,
        ),
        onData: (cacheList) => LiveChatLoaded<T>(_toList(cacheList)),
        onError: (e, _) => LiveChatError<T>('Error: $e'),
      );*/
    } catch (e) {
      emit(LiveChatError<T>(e.toString()));
    }
  }

  /*final cacheList = await stream.first;
  if (cacheList.isNotEmpty) {
    final dataList = cacheList
        .map((cacheData) => fromFirestore(cacheData.data, cacheData.id))
        .toList();

    emit(LiveSupportLoaded<T>(dataList)); // Emits all messages
  } else {
    emit(LiveSupportError<T>('No messages found'));
  }*/

  Future<void> _onSendMessage(
    AddChat<T> event,
    Emitter<LiveChatState<T>> emit,
  ) async {
    try {
      // Add data to Firestore and update local storage
      await _chatRepository.sendChat(
        toCache(event.message),
        workspaceId: event.workspaceId,
        userName: event.userName,
        chatId: event.chatId,
      );

      // Update State: Notify that data added
      emit(ChatAdded<T>(message: 'Chat added successfully'));
    } catch (e) {
      emit(LiveChatError<T>(e.toString()));
    }
  }

  void _onChatsLoaded(_ChatsLoaded<T> event, Emitter<LiveChatState<T>> emit) {
    emit(ChatsLoaded<T>(event.data));
  }

  void _onChatLoaded(_ChatLoaded<T> event, Emitter<LiveChatState<T>> emit) {
    emit(ChatLoaded<T>(event.data));
  }

  void _onChatLoadError(_LiveChatError event, Emitter<LiveChatState<T>> emit) {
    final errorLogCache = ErrorLogCache();
    errorLogCache.cacheError(error: event.error, fileName: 'LiveSupport_bloc');
    emit(LiveChatError<T>(event.error));
  }

  List<T> _toList(List<CacheData> cacheData) {
    return cacheData
        .map((cache) => fromFirestore(cache.data, cache.id))
        .toList();
  }

  /*Future<String> _generateUniqueID(CollectionReference ref) async {
    String shortId;

    while (true) {
      shortId = shortid.generate();
      final trimNewId = _replaceSpecialCharsWithRandomNumbers(shortId);
      DocumentSnapshot doc = await ref.doc(trimNewId).get();

      if (!doc.exists) {
        break;
      }
    }

    return shortId.toUpperCase();
  }

  String _replaceSpecialCharsWithRandomNumbers(String str) {
    final Random random = Random();
    RegExp regExp = RegExp(r'[^a-zA-Z0-9]');
    String result = str.replaceAllMapped(regExp, (Match match) {
      return random.nextInt(10).toString();
    });

    return result;
  }*/

  @override
  Future<void> close() {
    _chatRepository.cancelDataSubscription();
    return super.close();
  }
}
