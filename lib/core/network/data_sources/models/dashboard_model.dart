import 'package:assign_erp/core/util/str_util.dart';
import 'package:flutter/material.dart';

class DashboardTile {
  DashboardTile({
    required this.icon,
    required this.label,
    required this.action,
    this.param = const {},
    this.description,
  });

  final Map<String, String> param;
  final String? description;
  final String label;
  final dynamic icon;
  final dynamic action;

  factory DashboardTile.fromMap(Map<String, dynamic> json) {
    return DashboardTile(
      icon: json['icon'] as IconData,
      label: json['label'] as String,
      action: json['action'] as String,
      param: createNewMap(json['param']),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'icon': icon,
    'label': label,
    'action': action,
    'param': param,
    'description': description,
  };

  // Filter tiles: matching or excluding a specific label.
  static filter(
    List<DashboardTile> packages,
    String label, {
    bool exclude = false,
  }) => List<DashboardTile>.unmodifiable(
    packages.where(
      (package) => exclude ? package.label != label : package.label == label,
    ),
  );
}

class RoleBasedDashboardTile<T> {
  final T roleInfo;
  final List<DashboardTile> tiles;

  RoleBasedDashboardTile({required this.roleInfo, required this.tiles});
}

class DashboardTileManager<T> {
  final Map<T, List<DashboardTile>> _tiles;

  DashboardTileManager({required Map<T, List<DashboardTile>> tiles})
    : _tiles = tiles;

  /// Creates a map of [RoleBasedDashboardTile] instances from the tiles data.
  Map<T, RoleBasedDashboardTile<T>> create() => {
    for (var entry in _tiles.entries)
      entry.key: RoleBasedDashboardTile<T>(
        roleInfo: entry.key,
        tiles: entry.value,
      ),
  };
}
