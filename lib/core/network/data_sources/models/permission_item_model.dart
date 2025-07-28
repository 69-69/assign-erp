import 'package:equatable/equatable.dart';

/// [PermissionMode] MODE OF PERMISSIONS FOR EACH EMPLOYEE ROLE
enum PermissionMode { allowAll, select }

/// [PermissionItem] MODEL OF PERMISSION ITEM FOR EACH EMPLOYEE ROLE
class PermissionItem extends Equatable {
  final String title;
  final String subtitle;

  /// [permission] Enum of the Permission. E.g., "createPosSale"
  final Enum permission;

  /// [module] Name of the Module. E.g., "pos sales"
  final String module;

  const PermissionItem({
    required this.title,
    required this.subtitle,
    required this.module,
    required this.permission,
  });

  /// [permissionName] Name of the Permission. E.g., "createPosSale"
  String get permissionName => permission.name;

  @override
  List<Object?> get props => [
    title,
    subtitle,
    permission.name, // ensure enum comparison
    module.toLowerCase(), // normalize casing for module
  ];
}
