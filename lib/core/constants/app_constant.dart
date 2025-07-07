/*is on line 18
<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>*/

/// 'autoID' is used to generate a new Customer-ID,
/// if customer doesn't exist, while placing Orders [autoID]
const autoID = 'auto-id';

/// Assign: is prefix error message to distinguish Generic (Firestore) error [errorPrefix]
const errorPrefix = 'Assign';

/// APP NAME
const _nChar = '⏺';
const appName = 'ASSIGN.WORK';
const appSubName =
    'P.O.S $_nChar Inventory $_nChar Customer $_nChar Warehouse $_nChar Reports $_nChar Multi-Location';
const ghanaCedis = '¢';

/// APP LOGO
const assetPath = 'assets/images';
const assetPrint = 'assets/print';
const appLogo = '$assetPath/logo.png';
const appLogo2 = '$assetPath/logo_2.png';
const appBg = '$assetPath/app_bg.png';
const appLogoWithBG = '$assetPath/logo_bg.png';
const printFooterBg = '$assetPrint/invoice.svg';
const densePrintLayout = '$assetPrint/dense_print_layout.png';
const loosePrintLayout = '$assetPrint/loose_print_layout.png';

/// DESIGN BY: ASSIGN-DEVELOPER
const appDeveloper = 'assignDeveloper';
const designBy = 'Design By: $appDeveloper';
final copyRight =
    'Copyright \u00a9 ${DateTime.now().year}, All Rights Reserved.';

/// SCREEN TITLES
const welcomeTitle = 'Welcome to Assign';
const employeeSignInTitle = 'Employee Sign In';
const agentTitle = 'agent';
const posAppTitle = 'p.o.s';
const inventoryAppTitle = 'inventory - ims';
const warehouseAppTitle = 'warehouse - wms';
const customerAppTitle = 'customer - crm';
const setupAppTitle = 'setup';
const userManualAppTitle = 'user - manual';

/// MANAGEMENT SUB-SCREENS TITLES
const liveSupportScreenTitle = 'live support';
const userManualScreenTitle = 'orders Management';
const allOrderScreenTitle = 'orders Management';
const stocksScreenTitle = 'product management';
const clienteleScreenTitle = 'clientele';
const troubleshootScreenTitle = 'troubleshoot';
const salesOrderScreenTitle = ' orders (so)';
const purchaseOrderScreenTitle = 'purchase order (po)';
const miscOrderScreenTitle = 'miscellaneous order (mo)';
const requestPriceQuoteScreenTitle = 'request for quotation';
const deliveryScreenTitle = 'delivery management';
const reportsAnalyticsScreenTitle = 'reports analytics';
const salesScreenTitle = 'sales management';
const warehouseScreenTitle = 'warehouse management';
const customersScreenTitle = 'customer management';
const posSalesScreenTitle = 'p.o.s - sales';
const posOrdersScreenTitle = 'p.o.s - orders';
const guideToScreenTitle = 'Guide to...';

const kAppBarHeight = 80.0;
const wAnimateDuration = Duration(seconds: 2);
const kAnimateDuration = Duration(milliseconds: 300);

//RegExp
RegExp onlyNumbersRegExp = RegExp(r'^-?[0-9]+$');

RegExp nameRegExp = RegExp(
  r"^([a-zA-Z]{2,}\s[a-zA-Z]{1,}'?-?[a-zA-Z]{2,}\s?([a-zA-Z]{1,})?)",
);

RegExp emailRegExp = RegExp(
  r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
);

RegExp passwordRegExp = RegExp(
  r"^(?=.*[A-Za-z])(?=.*\d)(?=.*[$!%*#@?&])[A-Za-z\d$!%*#@?&]{8,}$",
);
