import 'dart:async';

import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/features/404_fallback/not_found_screen.dart';
import 'package:assign_erp/features/agent/presentation/agent_app.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/auth/presentation/screen/sign_in/index.dart';
import 'package:assign_erp/features/customer_crm/presentation/index.dart';
import 'package:assign_erp/features/home/main_dashboard.dart';
import 'package:assign_erp/features/inventory_ims/presentation/index.dart';
import 'package:assign_erp/features/live_support/presentation/index.dart';
import 'package:assign_erp/features/manual/presentation/index.dart';
import 'package:assign_erp/features/onboarding/on_boarding_screen.dart';
import 'package:assign_erp/features/pos_system/presentation/index.dart';
import 'package:assign_erp/features/setup/presentation/index.dart';
import 'package:assign_erp/features/trouble_shooting/presentation/index.dart';
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

/* final dynamicRoutes = <DynamicRoute>[
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

/// User Manual App
GoRoute _userManualRoute() {
  final List<({String name, Widget screen})> userManualRoutes = [
    (name: RouteNames.howToConfigApp, screen: const HowToConfigAppScreen()),
    (
      name: RouteNames.howToRenewLicense,
      screen: const HowToRenewLicenseScreen(),
    ),
  ];

  return GoRoute(
    name: RouteNames.userManualApp,
    path: RouteNames.userManualApp,
    pageBuilder: (context, state) =>
        _animateTransition(state, const UserManualApp()),
    routes: _mapStaticRoutes(userManualRoutes),
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
    name: RouteNames.onBoarding,
    path: '/',
    child: const OnBoardingScreen(),
    routes: [
      /// Protected Workspace Route
      _configBaseRoute(
        name: RouteNames.mainDashboard,
        path: RouteNames.mainDashboard,
        child: const MainDashboard(),
        routes: [
          _setupRoute(),
          _warehouseRoute(),
          _inventoryRoute(),
          _customerRoute(),
          _posRoute(),
          _agentRoute(),
          _troubleShootRoute(),
          _userManualRoute(),
          _liveSupportRoute(),
        ],
      ),

      /// Auth Routes
      _configBaseRoute(
        name: RouteNames.employeeSignIn,
        path: RouteNames.employeeSignIn,
        child: const EmployeeSignInScreen(),
        redirect: (context, state) async {
          final shouldRedirect = await dashboardGuard.redirect(context);
          return shouldRedirect ? '/${RouteNames.mainDashboard}' : null;
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

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: _routerConfig,
  errorBuilder: (context, state) => const NotFoundPage(),
);

/*List<RouteBase> _routerConfig = <RouteBase>[
  GoRoute(
    name: RouteNames.onBoarding,
    path: '/',
    pageBuilder: (context, state) => _animateTransition(state, const OnBoardingScreen()),
    routes: [
      GoRoute(
        name: RouteNames.mainDashboard,
        path: RouteNames.mainDashboard,
        pageBuilder: (context, state) => _animateTransition(state, const MainDashboard()),
        routes: [
          _setupRoute(),
          _warehouseRoute(),
          _inventoryRoute(),
          _customerRoute(),
          _posRoute(),
          _agentRoute(),
        ],
      ),
      GoRoute(
        name: RouteNames.employeeSignIn,
        path: RouteNames.employeeSignIn,
        pageBuilder: (context, state) => _animateTransition(state, const EmployeeSignInScreen()),
        redirect: (context, state) async {
          var redirect = await dashboardGuard.redirect(context);

          // Redirect if Authenticated, show dashboard, else main in current screen/page
          return redirect ? '/${RouteNames.mainDashboard}' : null;
        },
      ),
      GoRoute(
        name: RouteNames.changeTemporalPasscode,
        path: RouteNames.changeTemporalPasscode,
        pageBuilder: (context, state) => _animateTransition(state, const ChangeEmployeeTemporalPasscodeScreen()),
      ),
      GoRoute(
        name: RouteNames.verifyWorkspaceEmail,
        path: RouteNames.verifyWorkspaceEmail,
        pageBuilder: (context, state) => _animateTransition(state, const EmployeeSignInScreen()),
      ),
    ],
  ),
];*/

/*class AppRoutes {
  static Route<dynamic> _materialRoute(Widget view) =>
      MaterialPageRoute(builder: (_) => view, fullscreenDialog: true);

  static Route onGenerateRoutes(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    String? extra;
    Map<String, dynamic>? pathParameters;
    Map<String, dynamic>? queryParameters;

    if (args != null) {
      extra = args['extra'];
      pathParameters = args['pathParameters'] as Map<String, dynamic>? ?? {};
      queryParameters = args['queryParameters'] as Map<String, dynamic>? ?? {};

      debugPrint('extra: $extra');
      debugPrint('pathParameters: $pathParameters');
      debugPrint('queryParameters: $queryParameters');
    }

    switch (settings.name) {
      case RouteNames.onBoarding:
        return _materialRoute(const OnBoardingScreen());
      case RouteNames.mainDashboard || '':
        return _materialRoute(const HomeScreen());
      case RouteNames.agentClientele:
        return _materialRoute(const ClienteleApp());
      case RouteNames.employeeSignIn:
        return _materialRoute(const EmployeeSignInScreen());

      /// Inventory-IMS-App
      case RouteNames.inventoryApp:
        return _materialRoute(const InventoryApp());
      case RouteNames.products:
        return _materialRoute(const ProductScreen());
      case RouteNames.deliveries:
        return _materialRoute(const DeliveryScreen());
      case RouteNames.sales:
        return _materialRoute(const SaleScreen());
      case RouteNames.inventReports:
        return _materialRoute(const ReportsAnalyticsScreen());
      case RouteNames.orders:
        return _materialRoute(const OrdersScreen());
      case RouteNames.placeAnOrder:
        return _materialRoute(const OrderScreen());
      case RouteNames.purchaseOrders:
        return _materialRoute(const PurchaseOrderScreen());
      case RouteNames.miscOrders:
        return _materialRoute(const MiscOrderScreen());
      case RouteNames.requestForQuote:
        return _materialRoute(const RequestForQuotationScreen());

      /// POS-App
      case RouteNames.posApp:
        return _materialRoute(const POSApp());
      case RouteNames.posOrders:
        return _materialRoute(const PosOrdersScreen());
      case RouteNames.posSales:
        return _materialRoute(const PosSalesScreen());
      case RouteNames.posReports:
        return _materialRoute(const ReportsAnalyticsScreen());
      case RouteNames.posPayments:
        return _materialRoute(const PosSalesScreen());

      /// Customer-CRM-App
      case RouteNames.customersApp:
        return _materialRoute(const CustomerApp());
      case RouteNames.createCustomer:
        final args = settings.arguments as Map<String, dynamic>;
        return _materialRoute(CustomerScreen(openTab: args['extra']??=''));

      /// Warehouse-WMS-App
      case RouteNames.warehouseApp:
        return _materialRoute(const WarehouseApp());
      case RouteNames.warehouseProducts:
        return _materialRoute(const WarehouseProductScreen());
      case RouteNames.warehouseSupply:
        return _materialRoute(const WarehouseProductScreen());
      case RouteNames.warehouseDeliveries:
        return _materialRoute(const WarehouseProductScreen());
      case RouteNames.warehouseSales:
        return _materialRoute(const WarehouseProductScreen());

      /// Setup-App
      case RouteNames.settingsApp:
        return _materialRoute(const SetupApp());
      case RouteNames.createUserAccount:
        final args = settings.arguments as Map<String, dynamic>;
        return _materialRoute(SetupScreen(openTab: args['extra']??=''));
      case RouteNames.manageUserAccount:
        final args = settings.arguments as Map<String, dynamic>;
        return _materialRoute(SetupScreen(openTab: args['extra']??=''));
      case RouteNames.checkForUpdate:
        final args = settings.arguments as Map<String, dynamic>;
        return _materialRoute(SetupScreen(openTab: args['extra']??=''));
      case RouteNames.licenseRenewal:
        final args = settings.arguments as Map<String, dynamic>;
        return _materialRoute(SetupScreen(openTab: args['extra']??=''));
      case RouteNames.backup:
        final args = settings.arguments as Map<String, dynamic>;
        return _materialRoute(SetupScreen(openTab: args['extra']??=''));
      case RouteNames.companyInfo:
        final args = settings.arguments as Map<String, dynamic>;
        return _materialRoute(SetupScreen(openTab: args['extra']??=''));

      default:
        return _materialRoute(const SplashScreen());
    }
  }
}*/

/*GoRouter createAppRouterText(AuthState authState) {
  List<RouteBase> routerConfig = <RouteBase>[
    /// Protected Workspace Route
    GoRoute(
      name: RouteNames.onBoarding,
      path: '/',
      builder: (_, __) => const OnBoardingScreen(),
      redirect: (context, state) {
        // Check if the user’s email is verified
        // final isEmailVerified = workspaceUser?.emailVerified == true;

        if (authState is AuthAuthenticated) {
          // print('steve ${workspaceUser?.email}');
          // Clear the stack and navigate to employee sign-in
          return authState.employeeUser != null
              ? '/${RouteNames.mainDashboard}'
              : '/${RouteNames.employeeSignIn}';
        }

        // Redirect to onboarding if email is not verified
        return null;
      },
      routes: [
        GoRoute(
          name: RouteNames.wForgotPassword,
          path: RouteNames.wForgotPassword,
          builder: (context, state) => const WorkSpaceSignUpScreen(),
        ),
        GoRoute(
          name: RouteNames.wUpdatePassword,
          path: RouteNames.wUpdatePassword,
          builder: (context, state) => const WorkSpaceSignUpScreen(),
        ),

        /// Protected Software Routes
        GoRoute(
          name: RouteNames.employeeSignIn,
          path: RouteNames.employeeSignIn,
          builder: (_, __) => const EmployeeSignInScreen(),
          redirect: (context, state) async {
            // final isAuthenticated = await _checkAuthentication(context, state);

            if (authState is AuthAuthenticated) {
              // Redirect unauthenticated users to OnboardingScreen
              // OnboardingScreen has Workspace Login
              return '/${RouteNames.mainDashboard}';
            }

            // final isVerified = await _checkEmailVerification(context, state);
            if (authState is AuthEmailNotVerified) {
              return '/${RouteNames.verifyWorkspaceEmail}'; // Redirect unverified workspaceUsers to email verification
            }

            return null; // Allow access if authenticated and verified
          },
          routes: [],
        ),
        GoRoute(
          name: RouteNames.mainDashboard,
          path: RouteNames.mainDashboard,
          builder: (context, state) => const HomeScreen(),
          redirect: (context, state) {
            // Check if the user’s email is verified
            // final isEmailVerified = workspaceUser?.emailVerified == true;

            if (authState is AuthAuthenticated) {
              // print('steve ${workspaceUser?.email}');
              // Clear the stack and navigate to employee sign-in
              return '/${RouteNames.posApp}';
            }

            // Redirect to onboarding if email is not verified
            return null;
          },
          routes: [
            /// inventoryApp
            _inventoryRoute(),

            /// customersApp
            _customerRoute(),

            /// warehouseApp
            _warehouseRoute(),

            /// setupApp
            _setupRoute(),

            /// userManualApp
            GoRoute(
              name: RouteNames.userManualApp,
              path: RouteNames.userManualApp,
              builder: (context, state) => const AppManual(),
              routes: const [],
            ),
          ],
        ),

        /// posApp
        _posRoute(),

        GoRoute(
          name: RouteNames.auth,
          path: '${RouteNames.auth}/:routeName',
          builder: (context, state) => AuthScreen(
            routeName: state.pathParameters['routeName'] ?? '',
          ),
          redirect: (context, state) {
            if (userIsNotLoggedIn) {
              return "/login";
            }
            return "/";
          },
        ),
      ],
    ),

    GoRoute(
      name: RouteNames.myOrders,
      path: RouteNames.myOrders,
      builder: (context, state) => const MyOrdersScreen(),
    ),
    GoRoute(
      name: RouteNames.adminSettings,
      path: RouteNames.adminSettings,
      builder: (context, state) => const AdminManagementScreen(),
    ),
    GoRoute(
      name: RouteNames.allProducts,
      path: RouteNames.allProducts,
      builder: (context, state) => AllProductsScreen(
        extra: state.extra as String,
      ),
    ),
    GoRoute(
      name: RouteNames.favorite,
      path: RouteNames.favorite,
      builder: (context, state) => const FavoriteScreen(),
    ),

    GoRoute(
      name: RouteNames.shoppingCart,
      path: RouteNames.shoppingCart,
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      name: RouteNames.paymentDone,
      path: "${RouteNames.paymentDone}/:receiptNo",
      builder: (context, state) => PaymentDoneScreen(
        receiptNo: state.pathParameters['receiptNo'] as String,
      ),
    ),
    GoRoute(
      name: RouteNames.checkout,
      path: RouteNames.checkout,
      builder: (context, state) => const CheckoutPage(),
    ),
    GoRoute(
      name: RouteNames.allNotification,
      path: RouteNames.allNotification,
      builder: (context, state) =>
          NotificationScreen(id: state.extra as String),
    ),

    // Auth Routes
    GoRoute(
      name: RouteNames.signup,
      path: RouteNames.signup,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      name: RouteNames.completeProfile,
      path: RouteNames.completeProfile,
      builder: (context, state) => const CompleteProfileScreen(),
    ),
    GoRoute(
      name: RouteNames.otp,
      path: RouteNames.otp,
      builder: (context, GoRouterState state) {
        return const OtpScreen();
      },
    ),
    GoRoute(
      name: RouteNames.forgotPassword,
      path: RouteNames.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      name: RouteNames.updatePassword,
      path: RouteNames.updatePassword,
      builder: (context, state) => UpdatePasswordScreen(
        mobileNumber: state.extra as String,
      ),
    ),
  ];

  return GoRouter(
    routes: routerConfig,
    errorBuilder: (context, state) => const NotFoundPage(),
  );
}*/

/*GoRouter createAppRouter4(AuthState authState) {
  List<RouteBase> routerConfig = <RouteBase>[
    GoRoute(
      name: RouteNames.onBoarding,
      path: '/',
      builder: (_, __) => const OnBoardingScreen(),
      redirect: (context, state) async {
        if (authState is AuthAuthenticated) {
          return authState.employeeUser != null
              ? '/${RouteNames.mainDashboard}'
              : '/${RouteNames.employeeSignIn}';
        }
        return null;
      },
      routes: [
        GoRoute(
          name: RouteNames.employeeSignIn,
          path: RouteNames.employeeSignIn,
          builder: (_, __) => const EmployeeSignInScreen(),
          redirect: (context, state) {
            debugPrint('EmployeeSignIn redirect: authState = $authState');
            if (authState is AuthAuthenticated) {
              if (authState.employeeUser != null) {
                debugPrint('Redirecting to home');
                return '/${RouteNames.mainDashboard}';
              }
            } else if (authState is AuthUnauthenticated) {
              debugPrint('Redirecting to onboarding');
              return '/${RouteNames.onboarding}';
            } else if (authState is AuthEmailNotVerified) {
              debugPrint('Redirecting to verifyWorkspaceEmail');
              return '/${RouteNames.verifyWorkspaceEmail}';
            }
            return null;
          },
        ),
        GoRoute(
          name: RouteNames.mainDashboard,
          path: RouteNames.mainDashboard,
          builder: (context, state) => const HomeScreen(),
          redirect: (context, state) {
            debugPrint('Home redirect: authState = $authState');
            if (authState is AuthAuthenticated &&
                authState.employeeUser != null) {
              return null;
            }
            debugPrint('Redirecting to employeeSignIn');
            return '/${RouteNames.employeeSignIn}';
          },
          routes: [
            // AgentClientele route
            GoRoute(
              name: RouteNames.agentClientele,
              path: RouteNames.agentClientele,
              builder: (context, state) => const ClienteleApp(),
              redirect: (context, state) {
                // Check if the user can access the agent panel
                if (!WorkspaceRoleGuard.canAccessAgentPanel(context)) {
                  return '/${RouteNames.employeeSignIn}';
                }
                // Allow access if the user meets the required role
                return null;
              },
            ),

            /// inventoryApp
            _inventoryRoute(),

            /// posApp
            _posRoute(),

            /// customersApp
            _customerRoute(),

            /// warehouseApp
            _warehouseRoute(),

            /// setupApp
            _setupRoute(),

            /// userManualApp
            GoRoute(
              name: RouteNames.userManualApp,
              path: RouteNames.userManualApp,
              builder: (context, state) => const AppManual(),
              routes: const [],
            ),
          ],
        ),
      ],
    ),
  ];

  return GoRouter(
    routes: routerConfig,
    errorBuilder: (context, state) {
      debugPrint('Error redirect: state = ${state.error}');
      return const NotFoundPage();
    },
  );
}*/

/*GoRouter createAppRouter2(AuthState authState) {
  List<RouteBase> routerConfig = <RouteBase>[
    /// Protected Workspace Route
    // Root route with OnBoardingScreen
    GoRoute(
      name: RouteNames.onBoarding,
      path: '/',
      builder: (_, __) => const OnBoardingScreen(),
      redirect: (context, state) {
        // If the user is authenticated and workspaceUser is not null
        if (authState is AuthAuthenticated && authState.workspaceUser != null) {
          // Redirect to home if employeeUser is not null; otherwise, to employeeSignIn
          return authState.employeeUser != null
              ? '/${RouteNames.mainDashboard}'
              : '/${RouteNames.employeeSignIn}';
        }
        // No redirect needed if the user does not meet the above criteria
        return null;
      },
      routes: [
        /// EmployeeSignIn route
        GoRoute(
          name: RouteNames.employeeSignIn,
          path: RouteNames.employeeSignIn,
          builder: (_, __) => const EmployeeSignInScreen(),
          redirect: (context, state) {
            // If the user is authenticated and employeeUser is not null, redirect to home
            if (authState is AuthAuthenticated) {
              return authState.employeeUser != null
                  ? '/${RouteNames.mainDashboard}'
                  : null;
            }
            // Redirect unauthenticated users to OnboardingScreen
            else if (authState is AuthUnauthenticated) {
              return '/${RouteNames.onBoarding}';
            }
            // Redirect users with unverified email to email verification
            else if (authState is AuthEmailNotVerified) {
              return '/${RouteNames.verifyWorkspaceEmail}';
            }
            // Allow access if none of the above conditions match
            return null;
          },
          routes: [
            // Home route
            GoRoute(
              name: RouteNames.mainDashboard,
              path: RouteNames.mainDashboard,
              builder: (context, state) => const HomeScreen(),
              redirect: (context, state) {
                // Allow access to home if the user is authenticated and employeeUser is not null
                if (authState is AuthAuthenticated &&
                    authState.employeeUser != null) {
                  return null;
                }
                // Redirect to employeeSignIn if conditions are not met
                return '/${RouteNames.employeeSignIn}';
              },
              routes: [
                // AgentClientele route
                GoRoute(
                  name: RouteNames.agentClientele,
                  path: RouteNames.agentClientele,
                  builder: (context, state) => const ClienteleApp(),
                  redirect: (context, state) {
                    // Check if the user can access the agent panel
                    if (!WorkspaceRoleGuard.canAccessAgentPanel(context)) {
                      return '/${RouteNames.employeeSignIn}';
                    }
                    // Allow access if the user meets the required role
                    return null;
                  },
                ),

                /// inventoryApp
                _inventoryRoute(),

                /// posApp
                _posRoute(),

                /// customersApp
                _customerRoute(),

                /// warehouseApp
                _warehouseRoute(),

                /// setupApp
                _setupRoute(),

                /// userManualApp
                GoRoute(
                  name: RouteNames.userManualApp,
                  path: RouteNames.userManualApp,
                  builder: (context, state) => const AppManual(),
                  routes: const [],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ];

  return GoRouter(
    routes: routerConfig,
    errorBuilder: (context, state) => const NotFoundPage(),
  );
}*/

/*GoRoute(
    name: RouteNames.myOrders,
    path: RouteNames.myOrders,
    builder: (context, state) => const MyOrdersScreen(),
  ),
  GoRoute(
    name: RouteNames.adminSettings,
    path: RouteNames.adminSettings,
    builder: (context, state) => const AdminManagementScreen(),
  ),
  GoRoute(
    name: RouteNames.allProducts,
    path: RouteNames.allProducts,
    builder: (context, state) =>
        AllProductsScreen(
          extra: state.extra as String,
        ),
  ),
  GoRoute(
    name: RouteNames.favorite,
    path: RouteNames.favorite,
    builder: (context, state) => const FavoriteScreen(),
  ),

  GoRoute(
    name: RouteNames.shoppingCart,
    path: RouteNames.shoppingCart,
    builder: (context, state) => const CartScreen(),
  ),
  GoRoute(
    name: RouteNames.paymentDone,
    path: "${RouteNames.paymentDone}/:receiptNo",
    builder: (context, state) =>
        PaymentDoneScreen(
          receiptNo: state.pathParameters['receiptNo'] as String,
        ),
  ),
  GoRoute(
    name: RouteNames.checkout,
    path: RouteNames.checkout,
    builder: (context, state) => const CheckoutPage(),
  ),
  GoRoute(
    name: RouteNames.allNotification,
    path: RouteNames.allNotification,
    builder: (context, state) =>
        NotificationScreen(id: state.extra as String),
  ),

  // Auth Routes
  GoRoute(
    name: RouteNames.signup,
    path: RouteNames.signup,
    builder: (context, state) => const SignupScreen(),
  ),
  GoRoute(
    name: RouteNames.completeProfile,
    path: RouteNames.completeProfile,
    builder: (context, state) => const CompleteProfileScreen(),
  ),
  GoRoute(
    name: RouteNames.otp,
    path: RouteNames.otp,
    builder: (context, GoRouterState state) {
      return const OtpScreen();
    },
  ),
  GoRoute(
    name: RouteNames.forgotPassword,
    path: RouteNames.forgotPassword,
    builder: (context, state) => const ForgotPasswordScreen(),
  ),
  GoRoute(
    name: RouteNames.updatePassword,
    path: RouteNames.updatePassword,
    builder: (context, state) =>
        UpdatePasswordScreen(
          mobileNumber: state.extra as String,
        ),
  ),*/
