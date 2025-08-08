import 'package:equatable/equatable.dart';

enum AccessControlStatus { initial, loading, loaded, error }

class AccessControlState extends Equatable {
  final Set<String> permissions;
  final Set<String> licenses;
  final AccessControlStatus status;

  const AccessControlState({
    required this.permissions,
    required this.licenses,
    this.status = AccessControlStatus.initial,
  });

  AccessControlState copyWith({
    Set<String>? permissions,
    Set<String>? licenses,
    AccessControlStatus? status,
  }) {
    return AccessControlState(
      permissions: permissions ?? this.permissions,
      licenses: licenses ?? this.licenses,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [permissions, licenses, status];
}
