import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/core/network/data_sources/models/dashboard_model.dart';
import 'package:assign_erp/core/network/data_sources/models/subscription_licenses_enum.dart';
import 'package:flutter/material.dart';

/// Returns a list of Main-Dashboard-Tiles based on the specified license package [LicenseTiles]
extension LicenseTiles on dynamic {
  Map<SubscriptionLicenses, List<DashboardTile>> get _licensePackages {
    /// Agent / Developer license (includes all individual packages plus agent/dev package)
    final appPackages = [
      // Agent Package
      {
        'label': 'agent',
        'icon': Icons.real_estate_agent_outlined,
        'action': RouteNames.agent,
        'param': {},
        'description': 'setup, oversee, and monitor workspaces for clients',
      },
      // Inventory Package
      {
        'label': 'inventory',
        'icon': Icons.inventory,
        'action': RouteNames.inventoryApp,
        'param': {},
        'description': 'stocks, orders, deliveries, sales, invoices, tracking',
      },
      // POS Package
      {
        'label': 'pos',
        'icon': Icons.point_of_sale,
        'action': RouteNames.posApp,
        'param': {},
        'description': 'Instant orders, sales & receipts',
      },
      // Warehouse Package
      {
        'label': 'warehouse',
        'icon': Icons.warehouse,
        'action': RouteNames.warehouseApp,
        'param': {},
        'description': 'products, supplies, deliveries, sales',
      },
      {
        'label': 'crm',
        'icon': Icons.group,
        'action': RouteNames.customersApp,
        'param': {},
        'description': 'customers account, statement, activities',
      },
      // Troubleshoot Package
      {
        'label': 'troubleshoot',
        'icon': Icons.troubleshoot,
        'action': RouteNames.troubleShootingApp,
        'param': {},
        'description': 'troubleshoot the software & hardware',
      },
    ];

    final defaultPackages = appPackages
        .map((e) => DashboardTile.fromMap(e))
        .toList();

    final inventoryAppPackage = defaultPackages[1];
    final posAppPackage = defaultPackages[2];
    final warehouseAppPackage = defaultPackages[3];
    final customerAppPackage = defaultPackages[4];
    final agentAppPackage = DashboardTile.filter(
      defaultPackages,
      'troubleshoot',
      exclude: true,
    );

    // Subscription Licenses Package Restrictions
    return {
      /// Setup/Onboarding license: For Creating Agents Workspace
      SubscriptionLicenses.setup: [],

      /// Developer license
      SubscriptionLicenses.dev: defaultPackages,

      /// Agent license
      SubscriptionLicenses.agent: agentAppPackage,

      /// P.O.S license
      SubscriptionLicenses.pos: [posAppPackage],

      /// Inventory - I.M.S license
      SubscriptionLicenses.inventory: [inventoryAppPackage],

      /// Warehouse - W.M.S license
      SubscriptionLicenses.warehouse: [warehouseAppPackage],

      /// Full software license (includes all individual packages, except dev & agent)
      SubscriptionLicenses.full: [
        inventoryAppPackage,
        posAppPackage,
        warehouseAppPackage,
        customerAppPackage,
      ],
    };
  }

  Map<SubscriptionLicenses, RoleBasedDashboardTile<SubscriptionLicenses>>
  get licenseTiles => DashboardTileManager<SubscriptionLicenses>(
    tiles: _licensePackages,
  ).create();
}
