import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/core/network/data_sources/models/dashboard_model.dart';
import 'package:assign_erp/features/setup/data/permission/setup_permission.dart';
import 'package:flutter/material.dart';

/// Settings Navigation Links [SetupTiles]
extension SetupTiles on dynamic {
  List<DashboardTile> get setupTiles {
    final tilesData = [
      {
        'label': 'company',
        'icon': Icons.info_outline,
        'action': RouteNames.companyInfo,
        'param': {'openTab': '0'},
        'permission': 'createCompanyInfo',
        'description': 'enter company information for invoices or receipts',
      },
      {
        'label': 'staff - account',
        'icon': Icons.manage_accounts,
        'action': RouteNames.staffAccount,
        'param': {'openTab': '1'},
        'permission': 'createEmployee',
        'description':
            'create staff accounts, assign roles for their utilization of the software',
      },
      {
        'label': 'manage - roles',
        'icon': Icons.admin_panel_settings,
        'action': RouteNames.manageRoles,
        'param': {'openTab': '2'},
        'permission': 'createRole',
        'description':
            'Create, edit, assign roles with specific permissions to control access within your team.',
      },
      {
        'label': 'Product - config',
        'icon': Icons.category,
        'action': RouteNames.productConfig,
        'param': {'openTab': '3'},
        'permission': 'createProductSupplier',
        'description':
            "add suppliers & product categories to fit the company's specific needs",
      },
      {
        'label': 'back - up',
        'icon': Icons.backup,
        'action': RouteNames.backup,
        'param': {'openTab': '4'},
        'permission': 'createBackup',
        'description':
            'back up local and offline data to a cloud to access from anywhere',
      },
      {
        'label': 'license - renewal',
        'icon': Icons.local_police,
        'action': RouteNames.licenseRenewal,
        'param': {'openTab': '5'},
        'permission': 'createBackup',
        'description':
            'renew and activate software licenses, and view the history of previous licenses',
      },
    ];

    // return tilesData.map((e) => DashboardTile.fromMap(e)).toList();
    return tilesData
        .map(
          (e) => DashboardTile<SetupPermission>.fromMap(
            e,
            permissionResolver: (str) =>
                SetupPermission.values.firstWhere((perm) => perm.name == str),
          ),
        )
        .toList();
  }
}

/*List<DashboardTile> get setupTiles => [
    // NavLinks(label: 'create - account', icon: Icons.create, action: RouteNames.createUserAccount, param: {'openTab': '0'}),
    _dashboardTile(
      label: 'company',
      icon: Icons.info_outline,
      action: RouteNames.companyInfo,
      param: {'openTab': '0'},
      description: 'enter company information for invoices or receipts',
    ),
    _dashboardTile(
      label: 'staff - account',
      icon: Icons.manage_accounts,
      action: RouteNames.manageUserAccount,
      param: {'openTab': '1'},
      description:
      'create staff accounts and assign roles for their utilization of the software',
    ),
    _dashboardTile(
      label: 'Product - suppliers',
      icon: Icons.category,
      action: RouteNames.checkForUpdate,
      param: {'openTab': '2'},
      description:
      "add suppliers & product categories to fit the company's specific needs",
    ),
    _dashboardTile(
      label: 'back - up',
      icon: Icons.backup,
      action: RouteNames.backup,
      param: {'openTab': '3'},
      description:
      'back up local and offline data to a cloud to access from anywhere',
    ),
    _dashboardTile(
      label: 'license - renewal',
      icon: Icons.local_police,
      action: RouteNames.licenseRenewal,
      param: {'openTab': '4'},
      description:
      'renew and activate software licenses, and view the history of previous licenses',
    ),
    _dashboardTile(
      label: 'app - update',
      icon: Icons.update,
      action: RouteNames.checkForUpdate,
      param: {'openTab': '5'},
      description:
      'update the software and monitor both current and past release updates',
    ),
  ];*/
