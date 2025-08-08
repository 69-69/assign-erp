import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// We use name route
// To avoid delay in App load, by importing Screens/Pages with Routes
// we use the static Route String Name to access Named Routes

abstract class RouteNames {
  /// ──────────────────────── 🌟 Core Entry Points ────────────────────────
  /// Entry/Startup Point for Home / Landing-Page [initialScreen]
  static const initialScreen = '/';
  static const initialScreenName = 'initial_screen';
  static const homeDashboard = 'home';

  /// ─────────────────────────── 🔐 Workspace Authentication ───────────────────────────
  static const workspaceSignIn = 'workspace_sign_in';
  static const employeeSignIn = 'employee_sign_in';
  static const verifyWorkspaceEmail = 'verify_workspace_email';
  static const changeTemporaryPasscode = 'change_temporary_passcode';
  static const wForgotPassword = 'forgot_password';
  static const wUpdatePassword = 'update_password';
  static const wAddMissingSocialAuthInfo = 'add_missing_social_auth_info';
  // static const workspaceSignup = 'create_workspace_acc';

  /// ──────────────────────── 🏠 Home Modules / Tiles ────────────────────────
  static const inventoryApp = 'inventory_app';
  static const posApp = 'pos_app';
  static const setupApp = 'setup_app';
  static const warehouseApp = 'warehouse_app';
  static const customersApp = 'customers_app';

  /// ───────────────────────── 🔧 Trouble Shooting ─────────────────────────
  static const troubleShootingApp = 'trouble_shooting_app';
  static const diagnoseIssues = 'diagnose_issues';
  static const allTenantWorkspaces = 'all_tenants_workspaces';
  static const manageSubscriptions = 'manage_subscriptions';
  // static const listAppIssues = 'list_app_issues';
  // static const userDeviceSpecs = 'user_device_specs';

  /// ───────────────────────── 💬 Live Chat/Support between Agents with Clients/Subscribers/Tenants ─────────────────────────
  static const liveChatSupport = 'live_chat_support_app';
  static const tenantChat = 'tenant_chat_screen';

  /// ───────────────────────── 📄 User Guide/Manual ─────────────────────────
  static const userGuideApp = 'user_guide_app';
  static const howToConfigApp = 'how_to_config_app';
  static const howToRenewLicense = 'how_to_renew_license';

  /// ───────────────────────── 📦 Inventory Module ─────────────────────────
  static const invoice = 'invoice_screen';
  static const orders = 'all_orders_screen';
  static const placeAnOrder = 'sales_orders_screen';
  static const purchaseOrders = 'purchase_orders_screen';
  static const miscOrders = 'miscellaneous_orders_screen';
  static const requestForQuote = 'request_for_quotation_screen';
  static const deliveries = 'deliveries_screen';
  static const products = 'products_screen';
  static const sales = 'sales_screen';
  static const ordersTracking = 'orders_tracking';
  static const inventReports = 'invent_reports_screen';

  /// ───────────────────────── 🧾 POS Module ─────────────────────────
  static const posPayments = 'pos_payments_screen';
  static const posReports = 'pos_reports_screen';
  static const posOrders = 'pos_orders_screen';
  static const posSales = 'pos_sales_screen';
  static const posReceipt = 'invoice_screen'; // Consider renaming for clarity

  /// ───────────────────────── 👥 CRM Module ─────────────────────────
  static const createCustomer = 'create_customer_screen';

  /// ─────────────────────── 🏢 Warehouse Module ───────────────────────
  static const warehouseProducts = 'warehouse_products_screen';
  static const warehouseSupply = 'warehouse_supply_screen';
  static const warehouseDeliveries = 'warehouse_deliveries_screen';
  static const warehouseSales = 'warehouse_sales_screen';

  /// ─────────────────────── ⚙️ Setup / Settings Module ───────────────────────
  // static const switchStoresAccount = 'switch_stores_account_screen';
  static const companyInfo = 'company_info_screen';
  static const allEmployees = 'all_employees_screen';
  static const manageRoles = 'manage_roles_screen';
  static const productConfig = 'product_config_screen';
  static const backup = 'backup_screen';
  static const licenseRenewal = 'license_renewal_screen';
  // static const manageUserAccount = 'manage_user_account_screen';

  /// ───────────────────────── 🔄 Switch/Change Store/Shop Locations ─────────────────────────
  static const switchStoresAccount = 'switch_store_locations_screen';

  /// ───────────────────────── 📡 CRM / Agent ─────────────────────────
  static const agent = 'agent_clientele_screen';

  /// ───────────────────────── 🛑 Errors / Fallback ─────────────────────────
  // static const notFoundScreen = 'content_not_found';
}

/// Extension on [BuildContext] to simplify access to GoRouter-related properties.
extension GoRouterContextExtensions on BuildContext {
  /// [routePath] Returns the matched location from the current [GoRouterState].
  ///
  /// Example: `/users/123/profile`
  String get routePath => GoRouter.of(this).state.matchedLocation;

  /// Alternative way to get the current path from the config's URI.
  ///
  /// [routeFromUri] Functionally similar to [routePath], but uses the structured [Uri] object.
  String get routeFromUri => routeConfig.uri.path;

  /// [delegate] Returns the [GoRouterDelegate] associated with the current context.
  ///
  /// This delegate manages the navigation stack and route configuration.
  GoRouterDelegate get delegate => GoRouter.of(this).routerDelegate;

  /// [currentRouteConfig] Returns the current route configuration as a [RouteMatchList].
  ///
  /// This provides access to the list of matched routes in the current configuration,
  /// which can be useful for custom navigation logic or breadcrumbs.
  RouteMatchList get routeConfig => delegate.currentConfiguration;
}

/*extension MyWork on String {
  String get isWork =>
      this == 'buyerAccess' ? RouteNames.workspaceSignIn : RouteNames.workspaceSignup;
}*/
