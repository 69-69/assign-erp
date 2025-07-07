import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/core/network/data_sources/models/dashboard_model.dart';
import 'package:assign_erp/features/setup/data/models/employee_model.dart';
import 'package:flutter/material.dart';

/// POS Navigation Links [POSTiles]
extension POSTiles on dynamic {
  // rbc: Role Based Dashboard Tiles
  Map<EmployeeRole, List<DashboardTile>> get _rbcPOSTiles {
    final tilesData = [
      // Orders tab
      {
        'label': 'orders',
        'icon': Icons.shopping_cart,
        'action': RouteNames.posOrders,
        'param': {},
        'description':
            'place an order for a customer and then update its status.',
      },
      // POS tab
      {
        'label': 'sales',
        'icon': Icons.shopping_basket,
        'action': RouteNames.posSales,
        'param': {},
        'description': 'keep track of, and oversee the progress of sales.',
      },
      {
        'label': 'report - Analytics',
        'icon': Icons.add_chart,
        'action': RouteNames.posReports,
        'param': {},
        'description':
            'generate sales report, turnover rates, forecasts and performance analytics',
      },
      // Payments tab
      {
        'label': 'payment',
        'icon': Icons.payments_outlined,
        'action': RouteNames.posPayments,
        'param': {},
        'description':
            'records payment details for each transaction: payment method and any related information',
      },
      // Receipt tab
      {
        'label': 'receipt',
        'icon': Icons.receipt,
        'action': RouteNames.posReceipt,
        'param': {},
        'description':
            'keep history of the creation and processing of receipts',
      },
      // Finance tab
      {
        'label': 'finance',
        'icon': Icons.money,
        'action': RouteNames.posPayments,
        'param': {},
        'description':
            'Manages & analyzes company\'s financial resources; budgeting, forecasting, investing',
      },
    ];
    final defaultTiles = tilesData
        .map((e) => DashboardTile.fromMap(e))
        .toList();

    final posSalesTiles = defaultTiles[0];
    final posOrdersTiles = defaultTiles[1];
    final posReportAnalyticTiles = defaultTiles[2];
    final posPaymentTiles = defaultTiles[3];
    final posReceiptTiles = defaultTiles[4];
    final posFinanceTiles = defaultTiles[5];

    return {
      EmployeeRole.user: [],
      EmployeeRole.manager: defaultTiles,
      EmployeeRole.developer: defaultTiles,
      EmployeeRole.sale: [posSalesTiles],
      EmployeeRole.administrator: [],
      EmployeeRole.cashier: [posPaymentTiles],
      EmployeeRole.procurement: [posOrdersTiles, posReceiptTiles],
      EmployeeRole.finance: [
        posFinanceTiles,
        posSalesTiles,
        posReceiptTiles,
        posReportAnalyticTiles,
      ],
    };
  }

  Map<EmployeeRole, RoleBasedDashboardTile<EmployeeRole>> get posTiles =>
      DashboardTileManager<EmployeeRole>(tiles: _rbcPOSTiles).create();
}
