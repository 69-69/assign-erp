import 'package:assign_erp/core/util/format_date_utl.dart';
import 'package:equatable/equatable.dart';

var dateTime = DateTime.now();

class WorkspaceChatGroup {
  final String workspaceId;
  final List<LiveChatOverview> summary;

  WorkspaceChatGroup({required this.workspaceId, required this.summary});
}

class LiveChatMessage extends Equatable {
  final String id;
  final String senderId;
  final String senderRole;
  final String message;
  final DateTime? timestamp;

  LiveChatMessage({
    this.id = '',
    required this.senderId,
    required this.senderRole,
    required this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? dateTime;

  factory LiveChatMessage.fromMap(Map<String, dynamic> map, {String? id}) {
    return LiveChatMessage(
      id: id ?? map['id'],
      senderId: map['senderId'] ?? '',
      senderRole: map['senderRole'] ?? '',
      message: map['message'] ?? '',
      timestamp: toDateTimeFn(map['timestamp']),
      // (map['timestamp'] as Timestamp).toDate(),
    );
  }

  /// Convert Model to toFirestore / toJson Function [toMap]
  Map<String, dynamic> toMap() => {
    // 'id': id,
    'senderId': senderId,
    'senderRole': senderRole,
    'message': message,
    'timestamp': timestamp?.toISOString,
  };

  /// toCache Function [toCache]
  Map<String, dynamic> toCache() {
    var map = toMap();
    map['timestamp'] = timestamp?.millisecondsSinceEpoch;

    return {'id': id, 'data': map};
  }

  @override
  List<Object?> get props => [id, senderId, senderRole, message, timestamp];
}

class LiveChatOverview {
  final String? userName;
  final String lastMessage;
  final DateTime? lastTimestamp;
  final bool isResolved;

  LiveChatOverview({
    this.userName,
    required this.lastMessage,
    DateTime? lastTimestamp,
    this.isResolved = false,
  }) : lastTimestamp = lastTimestamp ?? dateTime;

  factory LiveChatOverview.fromMap(Map<String, dynamic> map) {
    return LiveChatOverview(
      userName: map['userName'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      isResolved: map['isResolved'] ?? false,
      lastTimestamp: toDateTimeFn(map['lastTimestamp']),
      // (map['lastTimestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'lastMessage': lastMessage,
    'isResolved': isResolved,
    'lastTimestamp': lastTimestamp?.toISOString,
    if (userName != null) 'userName': userName,
  };

  /// toCache Function [toCache]
  Map<String, dynamic> toCache() {
    var map = toMap();
    var sec = lastTimestamp?.millisecondsSinceEpoch;
    map['lastTimestamp'] = sec;

    return {'id': sec, 'data': map};
  }
}
