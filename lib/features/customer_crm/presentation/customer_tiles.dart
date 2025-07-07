import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/core/network/data_sources/models/dashboard_model.dart';
import 'package:assign_erp/features/setup/data/models/employee_model.dart';
import 'package:flutter/material.dart';

/// Customer Management System App(IMS) Navigation Links [CustomerTiles]
extension CustomerTiles on dynamic {
  // rbc: Role Based Access Control (RBAC)
  Map<EmployeeRole, List<DashboardTile>> get _rbcCRMTiles {
    final tilesData = [
      {
        'label': 'manage - account',
        'icon': Icons.group,
        'action': RouteNames.createCustomer,
        'param': {'openTab': '0'},
        'description':
            'Create a new customer account, modify, or remove it as needed',
      },
      {
        'label': 'activities',
        'icon': Icons.account_tree,
        'action': RouteNames.createCustomer,
        'param': {'openTab': '1'},
        'description': 'track customer activities throughout the software',
      },
      {
        'label': 'Statement - of Account',
        'icon': Icons.pending_actions,
        'action': RouteNames.createCustomer,
        'param': {'openTab': '2'},
        'description':
            'Statement detailing purchases, outstanding balances, and due dates',
      },
    ];

    final defaultTiles = tilesData
        .map((e) => DashboardTile.fromMap(e))
        .toList();

    return {
      EmployeeRole.user: [],
      EmployeeRole.manager: defaultTiles,
      EmployeeRole.developer: defaultTiles,
      EmployeeRole.sale: defaultTiles,
      EmployeeRole.administrator: [],
      EmployeeRole.cashier: defaultTiles,
      EmployeeRole.procurement: defaultTiles,
      EmployeeRole.finance: defaultTiles,
    };
  }

  Map<EmployeeRole, RoleBasedDashboardTile<EmployeeRole>> get customerTiles =>
      DashboardTileManager<EmployeeRole>(tiles: _rbcCRMTiles).create();
}
