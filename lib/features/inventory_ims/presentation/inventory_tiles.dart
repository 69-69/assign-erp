import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/core/network/data_sources/models/dashboard_model.dart';
import 'package:assign_erp/features/setup/data/role/employee_role.dart';
import 'package:flutter/material.dart';

/// Inventory Management System App(IMS) Dashboard tiles [InventoryTiles]
extension InventoryTiles on dynamic {
  // All Orders types Navigation Links [ordersTiles]
  List<DashboardTile> get ordersTiles {
    final tilesData = [
      {
        'label': 'orders',
        'icon': Icons.shopping_cart,
        'action': RouteNames.placeAnOrder,
        'param': {},
        'description': 'Place an order for customers or clients',
      },
      {
        'label': 'purchase - order',
        'icon': Icons.paypal,
        'action': RouteNames.purchaseOrders,
        'param': {},
        'description': 'generate PO to suppliers to request goods or services',
      },
      {
        'label': 'misc - order',
        'icon': Icons.payments_outlined,
        'action': RouteNames.miscOrders,
        'param': {},
        'description':
            'create additional orders that may include special requests, one-time purchases',
      },
      {
        'label': 'request - quotation',
        'icon': Icons.request_page_outlined,
        'action': RouteNames.requestForQuote,
        'param': {},
        'description': 'create request for price quotation from suppliers',
      },
    ];

    return tilesData.map((e) => DashboardTile.fromMap(e)).toList();
  }

  /// Returns a list of Inventory-Dashboard-Tiles based on the Inventory license [inventoryTiles]
  Map<EmployeeRole, List<DashboardTile>> get _rbcInventoryTiles {
    final tilesData = [
      // products tab
      {
        'label': 'stocks',
        'icon': Icons.receipt_long,
        'action': RouteNames.products,
        'param': {},
        'description': 'add or create new products to the inventory.',
      },
      // orders tab
      {
        'label': 'orders',
        'icon': Icons.shopping_cart,
        'action': RouteNames.orders,
        'param': {},
        'description':
            'create purchase orders (POs), sales orders (SOs), and miscellaneous orders for suppliers or customers',
      },
      // deliveries tab
      {
        'label': 'deliveries',
        'icon': Icons.delivery_dining,
        'action': RouteNames.deliveries,
        'param': {},
        'description':
            'add or create delivery of order(s) and update their status.',
      },
      // sales tab
      {
        'label': 'sales',
        'icon': Icons.shopping_basket,
        'action': RouteNames.sales,
        'param': {},
        'description': 'keep track of, and oversee the progress of sales.',
      },
      // credit/debit cards, mobile payments, and cash tabs
      {
        'label': 'payment',
        'icon': Icons.payments_outlined,
        'action': RouteNames.posPayments,
        'param': {},
        'description':
            'records payment details for each transaction: payment method and any related information',
      },
      // finance tab
      {
        'label': 'finance',
        'icon': Icons.money,
        'action': RouteNames.posPayments,
        'param': {},
        'description':
            'Manages & analyzes company\'s financial resources; budgeting, forecasting, investing',
      },
      // invoice tab
      {
        'label': 'invoice',
        'icon': Icons.receipt,
        'action': RouteNames.invoice,
        'param': {},
        'description':
            'keep history of the creation and processing of receipts',
      },
      // report analytics tab
      {
        'label': 'report - Analytics',
        'icon': Icons.add_chart,
        'action': RouteNames.inventReports,
        'param': {},
        'description':
            'generate sales reports, inventory status, turnover rates, forecasts, and performance analytics',
      },
      // tracking tab
      {
        'label': 'tracking',
        'icon': Icons.location_on,
        'action': RouteNames.ordersTracking,
        'param': {},
        'description': 'monitor the progress of order placement and deliveries',
      },
    ];
    final defaultTiles = tilesData
        .map((e) => DashboardTile.fromMap(e))
        .toList();

    final productsTile = defaultTiles[0];
    final ordersTile = defaultTiles[1];
    final deliveriesTile = defaultTiles[2];
    final salesTile = defaultTiles[3];
    final paymentTile = defaultTiles[4];
    final financeTile = defaultTiles[5];
    final invoiceTile = defaultTiles[6];
    final reportAnalyticsTile = defaultTiles[7];

    // Role Based Access Control
    return {
      EmployeeRole.storeOwner: defaultTiles,
      EmployeeRole.manager: defaultTiles,
      EmployeeRole.sale: [salesTile],
      EmployeeRole.developer: defaultTiles,
      EmployeeRole.cashier: [paymentTile],
      EmployeeRole.delivery: [deliveriesTile],
      EmployeeRole.stockControl: [productsTile],
      EmployeeRole.procurement: [ordersTile, invoiceTile],
      EmployeeRole.finance: [
        financeTile,
        salesTile,
        invoiceTile,
        reportAnalyticsTile,
      ],
    };
  }

  Map<EmployeeRole, RoleBasedDashboardTile<EmployeeRole>> get inventoryTiles =>
      DashboardTileManager<EmployeeRole>(tiles: _rbcInventoryTiles).create();
}
