import 'package:assign_erp/core/util/str_util.dart';
import 'package:flutter/material.dart';

class DashboardTile {
  DashboardTile({
    required this.icon,
    required this.label,
    required this.action,
    this.param = const {},
    required this.access,
    this.description,
  });

  final String label;
  final dynamic icon;

  /// [access] Access level required to use this tile: Permission/License checks
  final String access;
  final dynamic action;
  final String? description;
  final Map<String, String> param;

  factory DashboardTile.fromMap(Map<String, dynamic> map) {
    return DashboardTile(
      icon: map['icon'] as IconData,
      label: map['label'] as String,
      action: map['action'] as String,
      param: createNewMap(map['param']),
      access: map['access'] ?? '',
      description: map['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'icon': icon,
    'label': label,
    'action': action,
    'param': param,
    'access': access,
    'description': description,
  };

  /*
  * Filter tiles: matching or excluding labels or patterns.
  * USAGE:
  * filter(tiles, ['Home', 'Settings']);
  * --OR--
  * filter(tiles, [RegExp(r'^Admin'), RegExp(r'log$', caseSensitive: false)]);
  * --OR--
  * filter(tiles, ['Admin', 'log'], exclude: true);*/

  static List<DashboardTile> filter(
    List<DashboardTile> tiles,
    List<dynamic> patterns, { // Can be List<String> or List<RegExp>
    bool exclude = false,
  }) {
    bool matches(String label) {
      for (var pattern in patterns) {
        if (pattern is String && label == pattern) return true;
        if (pattern is RegExp && pattern.hasMatch(label)) return true;
      }
      return false;
    }

    return List<DashboardTile>.unmodifiable(
      tiles.where(
        (tile) => exclude ? !matches(tile.label) : matches(tile.label),
      ),
    );
  }
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
