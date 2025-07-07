import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/core/network/data_sources/models/dashboard_model.dart';
import 'package:flutter/material.dart';

/// Warehouse Management System App(WMS) Navigation Links [WarehouseTiles]
extension WarehouseTiles on dynamic {
  List<DashboardTile> get warehouseTiles {
    final tileData = [
      {
        'label': 'stocks',
        'icon': Icons.dashboard,
        'action': RouteNames.warehouseProducts,
        'param': {'openTab': '0'},
        'description': 'add inventory to the warehouse.',
      },
      {
        'label': 'supplies',
        'icon': Icons.shopping_cart,
        'action': RouteNames.warehouseSupply,
        'param': {'openTab': '1'},
        'description': 'add supply products and update their status as needed.',
      },
      {
        'label': 'deliveries',
        'icon': Icons.delivery_dining,
        'action': RouteNames.warehouseDeliveries,
        'param': {'openTab': '2'},
        'description':
            'create or add delivery of supplies and then update their status',
      },
    ];

    return tileData.map((e) => DashboardTile.fromMap(e)).toList();
  }
}
