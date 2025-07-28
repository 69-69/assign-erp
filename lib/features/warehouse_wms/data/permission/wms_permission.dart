import 'package:assign_erp/core/network/data_sources/models/permission_item_model.dart';

/// PERMISSION BASED ACCESS-CONTROL
enum WarehousePermission {
  viewInventory,
  manageInventory,
  createInboundShipment,
  receiveShipment,
  updateStockLevels,
  moveItems,
  auditStock,
  deleteItems,
  viewReports,
  exportData,
  manageWarehouseSettings,
}

final List<PermissionItem> _inventoryPermissions = [
  PermissionItem(
    module: "warehouse inventory",
    title: "View Inventory",
    subtitle: "Allow users to view inventory and stock levels.",
    permission: WarehousePermission.viewInventory,
  ),
  PermissionItem(
    module: "warehouse inventory",
    title: "Manage Inventory",
    subtitle: "Allow users to add, edit, or remove inventory items.",
    permission: WarehousePermission.manageInventory,
  ),
  PermissionItem(
    module: "warehouse inventory",
    title: "Update Stock Levels",
    subtitle: "Allow users to manually adjust stock quantities.",
    permission: WarehousePermission.updateStockLevels,
  ),
  PermissionItem(
    module: "warehouse inventory",
    title: "Delete Items",
    subtitle: "Allow users to permanently remove inventory records.",
    permission: WarehousePermission.deleteItems,
  ),
];

final List<PermissionItem> _shipmentsPermissions = [
  PermissionItem(
    module: "warehouse shipments",
    title: "Create Inbound Shipments",
    subtitle: "Allow users to create and schedule inbound shipments.",
    permission: WarehousePermission.createInboundShipment,
  ),
  PermissionItem(
    module: "warehouse shipments",
    title: "Receive Shipments",
    subtitle: "Allow users to receive and process incoming shipments.",
    permission: WarehousePermission.receiveShipment,
  ),
];

final List<PermissionItem> _operationsPermissions = [
  PermissionItem(
    module: "warehouse operations",
    title: "Move Items",
    subtitle: "Allow users to move items between bins, shelves, or warehouses.",
    permission: WarehousePermission.moveItems,
  ),
  PermissionItem(
    module: "warehouse operations",
    title: "Audit Stock",
    subtitle: "Allow users to perform stock audits or cycle counts.",
    permission: WarehousePermission.auditStock,
  ),
];

final List<PermissionItem> _metricsPermissions = [
  PermissionItem(
    module: "warehouse metrics",
    title: "View Reports",
    subtitle: "Allow users to access warehouse reports and analytics.",
    permission: WarehousePermission.viewReports,
  ),
  PermissionItem(
    module: "warehouse metrics",
    title: "Export Data",
    subtitle: "Allow users to export inventory and shipment data.",
    permission: WarehousePermission.exportData,
  ),
  PermissionItem(
    module: "warehouse metrics",
    title: "Manage Warehouse Settings",
    subtitle: "Allow users to configure warehouse zones and settings.",
    permission: WarehousePermission.manageWarehouseSettings,
  ),
];

final List<PermissionItem> warehousePermissions = [
  ..._inventoryPermissions,
  ..._shipmentsPermissions,
  ..._operationsPermissions,
  ..._metricsPermissions,
];

final wmsDisplayName = 'warehouse';
