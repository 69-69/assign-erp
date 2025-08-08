import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/core/network/data_sources/models/dashboard_model.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/features/trouble_shooting/data/permission/trouble_shoot_permission.dart';
import 'package:flutter/material.dart';

/// Troubleshoot Tiles Navigation [TroubleShootTiles]
extension TroubleShootTiles on dynamic {
  List<DashboardTile> get troubleShootTiles {
    final tilesData = [
      {
        'label': 'Diagnose Issues',
        'icon': Icons.bug_report_outlined,
        'action': RouteNames.diagnoseIssues,
        'param': {},
        'access': _getValue(TroubleShootPermission.manageDiagnostics),
        'description': 'View error logs and diagnose issues in the system.',
      },
      {
        'label': 'Tenant Workspaces',
        'icon': Icons.workspaces_outline,
        'action': RouteNames.allTenantWorkspaces,
        'param': {},
        'access': _getValue(TroubleShootPermission.manageTenants),
        'description': 'Manage and monitor all tenant workspaces.',
      },
      {
        'label': 'Subscription Management',
        'icon': Icons.subscriptions,
        'action': RouteNames.manageSubscriptions,
        'param': {},
        'access': _getValue(TroubleShootPermission.manageSubscriptions),
        'description': 'Manage Subscription Licenses and Plans',
      },
    ];

    return tilesData.map((e) => DashboardTile.fromMap(e)).toList();
  }
}

// Get name from enum
String _getValue(e) => getEnumName<TroubleShootPermission>(e);

// Get name from enum
// String _getValue(e) => getEnumName<TroubleShootPermission>(e);
