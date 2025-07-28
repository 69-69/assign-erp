import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/core/network/data_sources/models/dashboard_model.dart';
import 'package:assign_erp/features/setup/data/role/employee_role.dart';
import 'package:flutter/material.dart';

/// Main-Dashboard containing individual Apps(Tiles) [HomeTiles]
extension HomeTiles on dynamic {
  // rbc: Role Based Dashboard Tiles
  Map<EmployeeRole, List<DashboardTile>> get _rbcMainTiles {
    final tilesData = [
      {
        'label': 'setup',
        'icon': Icons.settings,
        'action': RouteNames.setupApp,
        'param': {},
        'description':
            'company, employees, accounts, backups, licensing, & software update',
      },
      {
        'label': 'user - guide',
        'icon': Icons.library_books,
        'action': RouteNames.userGuideApp,
        'param': {},
        'description':
            'Video guides: setting up & managing key parts of the software',
      },
      /*{
        'label': 'live chat support',
        'icon': Icons.support_agent,
        'action': RouteNames.liveChatSupport,
        'param': {},
        'description': 'Get 24/7 live chat support from our agents and experts',
      },*/
    ];
    final defaultTiles = tilesData
        .map((e) => DashboardTile.fromMap(e))
        .toList();

    final userGuideTiles = DashboardTile.filter(defaultTiles, [
      'setup',
    ], exclude: true);

    // Role Based Access Control
    return {
      EmployeeRole.storeOwner: defaultTiles,
      EmployeeRole.developer: defaultTiles,
      EmployeeRole.sale: userGuideTiles,
      EmployeeRole.cashier: userGuideTiles,
      EmployeeRole.finance: userGuideTiles,
      EmployeeRole.procurement: userGuideTiles,
      EmployeeRole.manager: userGuideTiles,
      EmployeeRole.hrManager: userGuideTiles,
    };
  }

  Map<EmployeeRole, RoleBasedDashboardTile<EmployeeRole>> get mainTiles =>
      DashboardTileManager<EmployeeRole>(tiles: _rbcMainTiles).create();
}
