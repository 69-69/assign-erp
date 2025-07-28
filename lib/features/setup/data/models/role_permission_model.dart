import 'package:assign_erp/features/setup/data/role/employee_role.dart';
import 'package:equatable/equatable.dart';

/// [RolePermission] Represents a single permission entry (e.g., "editStock" under "Inventory" module).
/// This is the atomic unit of a permission, saved to Firestore in this format:
///
/// Example JSON:
/// {
///   "module": "Inventory",
///   "name": "editStock"
/// }
class RolePermission extends Equatable {
  /// [module] Name of the Module. E.g., "pos sales"
  final String module;

  /// [permission] Name of the Permission. E.g., "createPosSale"
  final String permission;

  const RolePermission({required this.module, required this.permission});

  factory RolePermission.fromMap(Map<String, dynamic> map) => RolePermission(
    module: map['module'] ?? '',
    permission: map['permission'] ?? '',
  );

  Map<String, dynamic> toMap() => {'module': module, 'permission': permission};

  /// Equality check needed for storing in `Set<RolePermission>`.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RolePermission &&
          runtimeType == other.runtimeType &&
          module.toLowerCase() == other.module.toLowerCase() &&
          permission == other.permission;

  /// Used by Sets and Maps for uniqueness.
  @override
  int get hashCode => module.hashCode ^ permission.hashCode;

  @override
  List<Object?> get props => [module, permission];

  @override
  String toString() =>
      'RolePermission: Module = $module Permissions = $permission';
}

/// [RolePermissionContext] A container holding the currently active role and its permissions at runtime.
/// Used for checking if a role has a specific permission.
///
/// Example:
/// ```dart
/// final rolePerms = RolePermissionContext<RolePermission>(
///   role: EmployeeRole.manager,
///   permissions: {
///     RolePermission(module: 'Inventory', permission: 'editStock'),
///     RolePermission(module: 'POS', permission: 'viewOrders'),
///   },
/// );
///
/// final canEdit = hasPermission(rolePerms, module: 'Inventory', name: 'editStock'); // true
/// final canDelete = hasPermission(rolePerms, module: 'POS', name: 'deleteOrders');  // false
/// `
class RolePermissionContext<T> {
  final EmployeeRole role;
  final Set<T> permissions;

  RolePermissionContext({required this.role, required this.permissions});
}

/// Check Permissions [hasPermission]
bool hasPermission<T>(RolePermissionContext<T>? rolePerms, {required T perm}) =>
    rolePerms?.permissions.contains(perm) ?? false;

/*/// Checks if the given role has a permission for a specific module + name.
bool hasPermission(
  RolePermissionContext<RolePermission>? rolePerms, {
  required String module,
  required String name,
}) {
  return rolePerms?.permissions.any(
    (p) => p.module == module && p.name == name,
  ) ?? false;
}
*/
