import 'package:assign_erp/core/network/data_sources/models/permission_item_model.dart';

/// PERMISSION BASED ACCESS-CONTROL
/*enum InventoryPermission {
  viewItems,
  addItem,
  editItem,
  deleteItem,
  adjustStock,
  transferStock,
  viewStockLevels,
  viewInventoryHistory,
  exportInventoryData,
  manageInventorySettings,
}
*/
enum InventoryPermission {
  // Stock/Product
  createStock,
  updateStock,
  deleteStock,
  viewStock,
  // Sale
  createSale,
  updateSale,
  deleteSale,
  viewSale,
  // Order
  createOrder,
  viewOrder,
  updateOrder,
  deleteOrder,
  // Customer
  createCustomer,
  viewCustomer,
  updateCustomer,
  deleteCustomer,
  // Delivery
  createDelivery,
  updateDelivery,
  deleteDelivery,
  viewDelivery,
  // Invoice
  printInvoice,
  viewInvoice,
  // Report
  viewReport,
}

final List<PermissionItem> _salesPermissionDetails = [
  // Sales
  PermissionItem(
    module: "ims sales",
    title: "Create new sales",
    subtitle: "Allow users to process new sales at any location.",
    permission: InventoryPermission.createSale,
  ),
  PermissionItem(
    module: "ims sales",
    title: "View sales records",
    subtitle: "Allow access to a list of all completed sales.",
    permission: InventoryPermission.viewSale,
  ),
  PermissionItem(
    module: "ims sales",
    title: "Edit existing sales",
    subtitle: "Allow users to modify details of an existing sale.",
    permission: InventoryPermission.updateSale,
  ),
  PermissionItem(
    module: "ims sales",
    title: "Delete sales",
    subtitle: "Allow users to permanently remove a sale record.",
    permission: InventoryPermission.deleteSale,
  ),
];

final List<PermissionItem> _ordersPermissionDetails = [
  PermissionItem(
    module: "ims orders",
    title: "View order details",
    subtitle: "Allow access to a list of placed and fulfilled orders.",
    permission: InventoryPermission.viewOrder,
  ),
  PermissionItem(
    module: "ims orders",
    title: "Create new orders",
    subtitle: "Allow users to place new customer orders.",
    permission: InventoryPermission.createOrder,
  ),
  PermissionItem(
    module: "ims orders",
    title: "Edit existing orders",
    subtitle: "Allow users to update order details or statuses.",
    permission: InventoryPermission.updateOrder,
  ),
  PermissionItem(
    module: "ims orders",
    title: "Delete orders",
    subtitle: "Allow users to delete orders from the system.",
    permission: InventoryPermission.deleteOrder,
  ),
];

final List<PermissionItem> _customersPermissionDetails = [
  PermissionItem(
    module: "ims customers",
    title: "View customers",
    subtitle: "Allow access to customer lists, profiles, and contact details.",
    permission: InventoryPermission.viewCustomer,
  ),
  PermissionItem(
    module: "ims customers",
    title: "Add new customers",
    subtitle: "Allow users to create new customer records.",
    permission: InventoryPermission.createCustomer,
  ),
  PermissionItem(
    module: "ims customers",
    title: "Edit customer information",
    subtitle: "Allow updates to customer contact info, tags, and notes.",
    permission: InventoryPermission.updateCustomer,
  ),
  PermissionItem(
    module: "ims customers",
    title: "Delete customers",
    subtitle: "Allow permanent removal of customer records from the system.",
    permission: InventoryPermission.deleteCustomer,
  ),
];

final List<PermissionItem> _stockPermissionDetails = [
  PermissionItem(
    module: "ims stock",
    title: "View inventory",
    subtitle:
        "Allow access to inventory items, stock levels, and product details.",
    permission: InventoryPermission.viewStock,
  ),
  PermissionItem(
    module: "ims stock",
    title: "Add new inventory items",
    subtitle: "Allow users to create new products or stock items.",
    permission: InventoryPermission.createStock,
  ),
  PermissionItem(
    module: "ims stock",
    title: "Edit inventory items",
    subtitle: "Allow users to update product names, prices, or stock details.",
    permission: InventoryPermission.updateStock,
  ),
  PermissionItem(
    module: "ims stock",
    title: "Delete inventory items",
    subtitle: "Allow users to remove items from the inventory database.",
    permission: InventoryPermission.deleteStock,
  ),
];

final List<PermissionItem> _deliveryPermissionDetails = [
  PermissionItem(
    module: "ims delivery",
    title: "View delivery records",
    subtitle: "Allow access to a list of all completed deliveries.",
    permission: InventoryPermission.viewDelivery,
  ),
  PermissionItem(
    module: "ims delivery",
    title: "Create new deliveries",
    subtitle: "Allow users to process new deliveries at any location.",
    permission: InventoryPermission.createDelivery,
  ),
  PermissionItem(
    module: "ims delivery",
    title: "Edit existing deliveries",
    subtitle: "Allow users to modify details of an existing delivery.",
    permission: InventoryPermission.updateDelivery,
  ),
  PermissionItem(
    module: "ims delivery",
    title: "Delete deliveries",
    subtitle: "Allow users to permanently remove a delivery record.",
    permission: InventoryPermission.deleteDelivery,
  ),
];

final List<PermissionItem> _metricsPermissionDetails = [
  PermissionItem(
    module: "ims metrics",
    title: "Print Invoices",
    subtitle: "Allow users to view customer invoices and print copies.",
    permission: InventoryPermission.printInvoice,
  ),
  PermissionItem(
    module: "ims metrics",
    title: "View financial data",
    subtitle: "Allow access to financial reports and summaries.",
    permission: InventoryPermission.viewInvoice,
  ),
  PermissionItem(
    module: "ims metrics",
    title: "Access reports and analytics",
    subtitle: "Allow users to access sales, order, and product reports.",
    permission: InventoryPermission.viewReport,
  ),
];

final inventoryDisplayName = 'inventory';

final List<PermissionItem> inventoryPermissionDetails = [
  ..._stockPermissionDetails,
  ..._ordersPermissionDetails,
  ..._salesPermissionDetails,
  ..._deliveryPermissionDetails,
  ..._customersPermissionDetails,
  ..._metricsPermissionDetails,
];
