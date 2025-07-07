import 'package:assign_erp/core/network/data_sources/models/workspace_model.dart';
import 'package:assign_erp/core/util/format_date_utl.dart';
import 'package:equatable/equatable.dart';

var _today = DateTime.now();

/// Agent's Clients(Subscribers) [AgentClient]
class AgentClient extends Equatable {
  final String clientWorkspaceId;
  final List<String> commission;
  final DateTime assignedAt;
  final Workspace? clientWorkspace;

  AgentClient({
    required this.clientWorkspaceId,
    this.commission = const [],
    this.clientWorkspace,
    DateTime? assignedAt,
  }) : assignedAt = assignedAt ?? _today; // Set default value

  /// fromFirestore / fromJson Function [AgentClient.fromMap]
  factory AgentClient.fromMap(Map<String, dynamic> map, {String? id}) {
    final workspace = map['clientWorkspace'] != null
        ? Workspace.fromMap(Map<String, dynamic>.from(map['clientWorkspace']))
        : null;

    return AgentClient(
      clientWorkspaceId: map['clientWorkspaceId'] ?? workspace?.id,
      commission: List<String>.from(map['commission'] ?? []),
      assignedAt: toDateTimeFn(map['assignedAt'] ?? _today),
      clientWorkspace: workspace,
    );
  }

  /// Convert UserModel to a map for storing in Firestore [toMap]
  Map<String, dynamic> toMap() => {
    'clientWorkspaceId': clientWorkspaceId,
    'commission': commission,
    'assignedAt': assignedAt.toISOString,
    'clientWorkspace': clientWorkspace?.toMap(),
  };

  /// Convert UserModel to toCache Function [toCache]
  Map<String, dynamic> toCache() {
    var map = toMap();
    map['assignedAt'] = assignedAt.millisecondsSinceEpoch;

    return {'id': clientWorkspaceId, 'data': map};
  }

  @override
  List<Object?> get props => [
    clientWorkspace,
    clientWorkspaceId,
    commission,
    assignedAt,
  ];
}
