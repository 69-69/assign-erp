// We use name route
// To avoid delay in App load, by importing Screens/Pages with Routes
// we use the static Route String Name to access Named Routes

abstract class RouteNames {
  /// ──────────────────────── 🌟 Core Entry Points ────────────────────────
  /// Entry/Startup Point for Home / Landing-Page [initialScreen]
  static const initialScreen = '/';
  static const initialScreenName = 'initial_screen';
  static const mainDashboard = 'main_dashboard';

  /// ─────────────────────────── 🔐 Workspace Authentication ───────────────────────────
  static const workspaceSignIn = 'workspace_sign_in';
  static const employeeSignIn = 'employee_sign_in';
  static const verifyWorkspaceEmail = 'verify_workspace_email';
  static const changeTemporalPasscode = 'change_temporal_passcode';
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
  static const listAppIssues = 'list_app_issues';
  static const userDeviceSpecs = 'user_device_specs';

  /// ───────────────────────── 💬 Live Chat/Support between Agents with Clients/Subscribers/Tenants ─────────────────────────
  static const liveChatSupport = 'live_chat_support_app';
  static const agentChat = 'agent_chat_screen';

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

  /// ───────────────────────── 👥 Customers Module ─────────────────────────
  static const createCustomer = 'create_customer_screen';

  /// ─────────────────────── 🏢 Warehouse Module ───────────────────────
  static const warehouseProducts = 'warehouse_products_screen';
  static const warehouseSupply = 'warehouse_supply_screen';
  static const warehouseDeliveries = 'warehouse_deliveries_screen';
  static const warehouseSales = 'warehouse_sales_screen';

  /// ─────────────────────── ⚙️ Setup / Settings ───────────────────────
  static const switchStoresAccount = 'switch_stores_account_screen';
  static const createUserAccount = 'create_user_account_screen';
  static const manageUserAccount = 'manage_user_account_screen';
  static const checkForUpdate = 'check_for_update_screen';
  static const licenseRenewal = 'license_renewal_screen';
  static const backup = 'backup_screen';
  static const companyInfo = 'company_info_screen';
  static const productConfig = 'product_config_screen';

  /// ───────────────────────── 📡 CRM / Agent ─────────────────────────
  static const agent = 'agent_clientele_screen';

  /// ───────────────────────── 🛑 Errors / Fallback ─────────────────────────
  // static const notFoundScreen = 'content_not_found';
}

/*extension MyWork on String {
  String get isWork =>
      this == 'buyerAccess' ? RouteNames.workspaceSignIn : RouteNames.workspaceSignup;
}*/
