import 'package:assign_erp/core/util/str_util.dart';
import 'package:equatable/equatable.dart';

/// [AccessMode] Enum defining the modes of permissions for each employee role.
/// - [allowAll]: All permissions are granted to the employee.
enum AccessMode { allowAll, select }

/// [AccessControl] Model representing a permission or license item
/// for each employee role within a workspace.
/// - [title]: The title or name of the permission/license.
class AccessControl extends Equatable {
  final String title;
  final String description;

  /// [access] The Enum that represents either a permission or license.
  /// Example values: "createPosSale" (Permission) or "POS" (License).
  final Enum access;

  /// [module] The module to which the permission/license belongs.
  /// Example: "POS" for point of sale or "inventory" for inventory management.
  final String module;

  const AccessControl({
    required this.title,
    required this.module,
    required this.access,
    required this.description,
  });

  /// [accessName] Returns the name of the permission or license.
  /// This is the string representation of the [access] Enum value.
  /// Example: "createPosSale" or "POS".
  String get accessName => access.name;

  @override
  List<Object?> get props => [
    title,
    description,
    accessName, // ensure enum comparison
    module.toLowercaseAll, // normalize casing for module
  ];
}
