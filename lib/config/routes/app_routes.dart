import 'dart:async';

import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/features/404_fallback/not_found_screen.dart';
import 'package:assign_erp/features/agent/presentation/agent_app.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/auth/presentation/screen/sign_in/index.dart';
import 'package:assign_erp/features/customer_crm/presentation/index.dart';
import 'package:assign_erp/features/dashboard/main_dashboard.dart';
import 'package:assign_erp/features/inventory_ims/presentation/index.dart';
import 'package:assign_erp/features/live_support/presentation/index.dart';
import 'package:assign_erp/features/pos_system/presentation/index.dart';
import 'package:assign_erp/features/setup/presentation/index.dart';
import 'package:assign_erp/features/startup/initial_screen.dart';
import 'package:assign_erp/features/trouble_shooting/presentation/index.dart';
import 'package:assign_erp/features/user_guide/presentation/index.dart';
import 'package:assign_erp/features/warehouse_wms/presentation/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

typedef DynamicRoute = ({
  String name,
  String? path,
  Widget Function(BuildContext context, GoRouterState state) builder,
  List<GoRoute> subRoutes,
});

final DashboardGuard dashboardGuard = DashboardGuard();
// final EmailVerificationGuard emailVerificationGuard = EmailVerificationGuard();
// final WorkspaceRoleGuard canAccessAgentPanel = WorkspaceRoleGuard();

// Helper methods for authentication and verification checks
/*Future<bool> _checkAuthentication(context, GoRouterState state) async {
  return await dashboardGuard.redirect(context);
}
Future<bool> _checkEmailVerification(context, GoRouterState state) async {
  return await emailVerificationGuard.redirect(context, state);
}*/

CustomTransitionPage<dynamic> _animateTransition(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
        child: child,
      );
    },
  );
}

/* USAGE:
final dynamicRoutes = <DynamicRoute>[
  (
    name: RouteNames.createCustomer,
    path: '${RouteNames.createCustomer}/:openTab',
    builder: (context, state) {
      final tab = state.pathParameters['openTab'] ?? '';
      return CustomerScreen(openTab: tab);
    },
    subRoutes: const [], // You can add nested routes here
  ),
];

final customerRoute = GoRoute(
  name: RouteNames.customersApp,
  path: RouteNames.customersApp,
  pageBuilder: (context, state) =>
      _animateTransition(state, const CustomerApp()),
  routes: _mapDynamicRoutes(dynamicRoutes),
);

List<GoRoute> _mapDynamicRoutes(List<DynamicRoute> routes) => routes
    .map(
      (r) => GoRoute(
        name: r.name,
        path: r.path ?? r.name,
        builder: r.builder,
        routes: r.subRoutes,
      ),
    )
    .toList();
*/

List<GoRoute> _mapStaticRoutes(List<({String name, Widget screen})> routes) =>
    routes
        .map(
          (r) =>
              GoRoute(name: r.name, path: r.name, builder: (_, __) => r.screen),
        )
        .toList();

GoRoute _configBaseRoute({
  required String name,
  required String path,
  required Widget child,
  List<RouteBase> routes = const [],
  FutureOr<String?> Function(BuildContext, GoRouterState)? redirect,
}) {
  return GoRoute(
    name: name,
    path: path,
    pageBuilder: (context, state) => _animateTransition(state, child),
    routes: routes,
    redirect: redirect,
  );
}

/// Customer App
GoRoute _customerRoute() {
  return GoRoute(
    name: RouteNames.customersApp,
    path: RouteNames.customersApp,
    pageBuilder: (context, state) =>
        _animateTransition(state, const CustomerApp()),
    routes: [
      GoRoute(
        name: RouteNames.createCustomer,
        path: '${RouteNames.createCustomer}/:openTab',
        builder: (context, state) =>
            CustomerScreen(openTab: state.pathParameters['openTab'] ?? ''),
      ),
    ],
  );
}

/// POS App
GoRoute _posRoute() {
  final List<({String name, Widget screen})> posScreens = [
    (name: RouteNames.posOrders, screen: const PosOrdersScreen()),
    (name: RouteNames.posSales, screen: const PosSalesScreen()),
    (name: RouteNames.posReports, screen: const ReportsAnalyticsScreen()),
    (name: RouteNames.posPayments, screen: const PosSalesScreen()),
  ];

  return GoRoute(
    name: RouteNames.posApp,
    path: RouteNames.posApp,
    pageBuilder: (context, state) => _animateTransition(state, const POSApp()),
    routes: _mapStaticRoutes(posScreens),
  );
}

/// Setup App
GoRoute _setupRoute() {
  final List<String> setupRoutes = [
    RouteNames.createUserAccount,
    RouteNames.manageUserAccount,
    RouteNames.checkForUpdate,
    RouteNames.licenseRenewal,
    RouteNames.backup,
    RouteNames.companyInfo,
  ];

  return GoRoute(
    name: RouteNames.setupApp,
    path: RouteNames.setupApp,
    pageBuilder: (context, state) =>
        _animateTransition(state, const SetupApp()),
    routes: setupRoutes
        .map(
          (routeName) => GoRoute(
            name: routeName,
            path: '$routeName/:openTab',
            builder: (context, state) =>
                SetupScreen(openTab: state.pathParameters['openTab'] ?? ''),
          ),
        )
        .toList(),
  );
}

/// Stores Switcher App
GoRoute _storesSwitcherRoute() {
  return GoRoute(
    name: RouteNames.switchStoresAccount,
    path: RouteNames.switchStoresAccount,
    pageBuilder: (context, state) =>
        _animateTransition(state, const SwitchStoreLocationsScreen()),
  );
}

/// Warehouse App
GoRoute _warehouseRoute() {
  final List<({String name, Widget screen})> warehouseRoutes = [
    (
      name: RouteNames.warehouseProducts,
      screen: const WarehouseProductScreen(),
    ),
    (name: RouteNames.warehouseSupply, screen: const WarehouseProductScreen()),
    (
      name: RouteNames.warehouseDeliveries,
      screen: const WarehouseProductScreen(),
    ),
    (name: RouteNames.warehouseSales, screen: const WarehouseProductScreen()),
  ];

  return GoRoute(
    name: RouteNames.warehouseApp,
    path: RouteNames.warehouseApp,
    pageBuilder: (context, state) =>
        _animateTransition(state, const WarehouseApp()),
    routes: _mapStaticRoutes(warehouseRoutes),
  );
}

/// Inventory App
GoRoute _inventoryRoute() {
  final List<({String name, Widget screen})> staticRoutes = [
    (name: RouteNames.invoice, screen: const InvoiceScreen()),
    (name: RouteNames.deliveries, screen: const DeliveryScreen()),
    (name: RouteNames.products, screen: const ProductScreen()),
    (name: RouteNames.sales, screen: const SaleScreen()),
    (name: RouteNames.inventReports, screen: const ReportsAnalyticsScreen()),
  ];

  final List<({String name, Widget screen})> orderSubRoutes = [
    (name: RouteNames.placeAnOrder, screen: const OrderScreen()),
    (name: RouteNames.purchaseOrders, screen: const PurchaseOrderScreen()),
    (name: RouteNames.miscOrders, screen: const MiscOrderScreen()),
    (
      name: RouteNames.requestForQuote,
      screen: const RequestForQuotationScreen(),
    ),
  ];

  return GoRoute(
    name: RouteNames.inventoryApp,
    path: RouteNames.inventoryApp,
    pageBuilder: (context, state) =>
        _animateTransition(state, const InventoryApp()),
    routes: [
      // Static inventory routes
      ..._mapStaticRoutes(staticRoutes),

      // Orders with subroutes
      GoRoute(
        name: RouteNames.orders,
        path: RouteNames.orders,
        builder: (context, state) => const OrdersScreen(),
        routes: _mapStaticRoutes(orderSubRoutes),
      ),
    ],
  );
}

/// Agent App
GoRoute _agentRoute() {
  return GoRoute(
    name: RouteNames.agent,
    path: RouteNames.agent,
    pageBuilder: (context, state) =>
        _animateTransition(state, const AgentApp()),
    routes: [
      GoRoute(
        name: RouteNames.agentChat,
        path: '${RouteNames.agentChat}/:clientWorkspaceId',
        builder: (context, state) => AgentChatDashboard(
          clientWorkspaceId: state.pathParameters['clientWorkspaceId'] ?? '',
        ),
      ),
    ],

    /*redirect: (context, state) {
          // Check if the user can access the agent panel
          if (!WorkspaceRoleGuard.canAccessAgentPanel(context)) {
            return '/${RouteNames.employeeSignIn}';
          }
          // Allow access if the user meets the required role
          return null;
        },*/
  );
}

/// User User Guide App
GoRoute _userGuideRoute() {
  final List<({String name, Widget screen})> userGuideRoutes = [
    (name: RouteNames.howToConfigApp, screen: const HowToConfigAppScreen()),
    (
      name: RouteNames.howToRenewLicense,
      screen: const HowToRenewLicenseScreen(),
    ),
  ];

  return GoRoute(
    name: RouteNames.userGuideApp,
    path: RouteNames.userGuideApp,
    pageBuilder: (context, state) =>
        _animateTransition(state, const UserGuideApp()),
    routes: _mapStaticRoutes(userGuideRoutes),
  );
}

/// Live Support/Chat App
GoRoute _liveSupportRoute() {
  return GoRoute(
    name: RouteNames.liveChatSupport,
    path: RouteNames.liveChatSupport,
    pageBuilder: (context, state) =>
        _animateTransition(state, const LiveSupportApp()),
  );
}

/// Developer: Trouble Shooting App
GoRoute _troubleShootRoute() {
  final List<({String name, Widget screen})> troubleShootRoutes = [
    (name: RouteNames.listAppIssues, screen: const ErrorLogScreen()),
    (name: RouteNames.userDeviceSpecs, screen: const UserDeviceSpecScreen()),
  ];

  return GoRoute(
    name: RouteNames.troubleShootingApp,
    path: RouteNames.troubleShootingApp,
    pageBuilder: (context, state) =>
        _animateTransition(state, const TroubleShootingApp()),
    routes: _mapStaticRoutes(troubleShootRoutes),
  );
}

// Define your routes
List<RouteBase> _routerConfig = <RouteBase>[
  _configBaseRoute(
    name: RouteNames.initialScreenName,
    path: RouteNames.initialScreen,
    child: const InitialScreen(),
    routes: [
      /// Protected Workspace Route
      _configBaseRoute(
        name: RouteNames.mainDashboard,
        path: RouteNames.mainDashboard,
        child: const MainDashboard(),
        routes: [
          _setupRoute(),
          _storesSwitcherRoute(),
          _warehouseRoute(),
          _inventoryRoute(),
          _customerRoute(),
          _posRoute(),
          _agentRoute(),
          _troubleShootRoute(),
          _userGuideRoute(),
          _liveSupportRoute(),
        ],
      ),

      /// Auth Routes
      _configBaseRoute(
        name: RouteNames.workspaceSignIn,
        path: RouteNames.workspaceSignIn,
        child: const WorkspaceSignInScreen(),
      ),
      _configBaseRoute(
        name: RouteNames.employeeSignIn,
        path: RouteNames.employeeSignIn,
        child: const EmployeeSignInScreen(),
        redirect: (context, state) async {
          if (state.name == RouteNames.employeeSignIn) {
            final shouldRedirect = await dashboardGuard.redirect(context);
            return shouldRedirect ? '/${RouteNames.mainDashboard}' : null;
          }
          return null;
        },
      ),
      _configBaseRoute(
        name: RouteNames.changeTemporalPasscode,
        path: RouteNames.changeTemporalPasscode,
        child: const ChangeEmployeeTemporalPasscodeScreen(),
      ),
      _configBaseRoute(
        name: RouteNames.verifyWorkspaceEmail,
        path: RouteNames.verifyWorkspaceEmail,
        child: const EmployeeSignInScreen(),
      ),
    ],
  ),
];

final appRouter = GoRouter(
  initialLocation: RouteNames.initialScreen,
  routes: _routerConfig,
  errorBuilder: (context, state) => const NotFoundPage(),
  // refreshListenable: GoRouterRefreshStream(authBloc.stream),
);
