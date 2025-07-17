import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/core/network/data_sources/models/dashboard_model.dart';
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
        'description': 'enter company information for invoices or receipts',
      },
      {
        'label': 'staff - account',
        'icon': Icons.manage_accounts,
        'action': RouteNames.manageUserAccount,
        'param': {'openTab': '1'},
        'description':
            'create staff accounts and assign roles for their utilization of the software',
      },
      {
        'label': 'Product - suppliers',
        'icon': Icons.category,
        'action': RouteNames.checkForUpdate,
        'param': {'openTab': '2'},
        'description':
            "add suppliers & product categories to fit the company's specific needs",
      },
      {
        'label': 'back - up',
        'icon': Icons.backup,
        'action': RouteNames.backup,
        'param': {'openTab': '3'},
        'description':
            'back up local and offline data to a cloud to access from anywhere',
      },
      {
        'label': 'license - renewal',
        'icon': Icons.local_police,
        'action': RouteNames.licenseRenewal,
        'param': {'openTab': '4'},
        'description':
            'renew and activate software licenses, and view the history of previous licenses',
      },
      {
        'label': 'app - update',
        'icon': Icons.update,
        'action': RouteNames.checkForUpdate,
        'param': {'openTab': '5'},
        'description':
            'update the software and monitor both current and past release updates',
      },
    ];

    return tilesData.map((e) => DashboardTile.fromMap(e)).toList();

    /*return tilesData.map((data) {
      return _dashboardTile(
        label: data['label'] as String,
        icon: data['icon'] as IconData,
        action: data['action'] as String,
        param: {'openTab': data['tab'].toString()},
        description: data['description'] as String,
      );
    }).toList();*/
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
