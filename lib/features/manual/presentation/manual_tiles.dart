import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/core/network/data_sources/models/dashboard_model.dart';
import 'package:flutter/material.dart';

extension ManualTiles on dynamic {
  /// User-Manual Navigation Links [userManualTiles]
  List<DashboardTile> get userManualTiles {
    final tilesData = [
      {
        'label': 'guide to',
        'icon': Icons.how_to_reg,
        'action': RouteNames.howToConfigApp,
        'param': {},
        'description':
            'software user guide providing instructions on software usage and configuration',
      },
      {
        'label': 'license renewal',
        'icon': Icons.local_police,
        'action': RouteNames.howToRenewLicense,
        'param': {},
        'description': 'guide on renewing or activating software',
      },
    ];

    return tilesData.map((e) => DashboardTile.fromMap(e)).toList();
  }
}
