import 'package:assign_erp/features/access_control/data/model/access_control_model.dart';

/// PERMISSION BASED ACCESS-CONTROL
enum WarehousePermission {
  manageWarehouse,
  viewWmsInventory,
  manageWmsInventory,
  createWmsInboundShipment,
  receiveWmsShipment,
  updateWmsStockLevels,
  moveWmsItems,
  auditWmsStock,
  deleteWmsItems,
  viewWmsReports,
  exportWarehouseData,
  manageWmsSettings,
  viewWmsSecrets,
}

final List<AccessControl> _warehousePermissionDetails = [
  AccessControl(
    module: "warehouse",
    title: "Manage warehouse",
    description: "Allow full control over warehouse creation and management.",
    access: WarehousePermission.manageWarehouse,
  ),
];

final List<AccessControl> _inventoryPermissions = [
  AccessControl(
    module: "warehouse inventory",
    title: "View Inventory",
    description: "Allow users to view inventory and stock levels.",
    access: WarehousePermission.viewWmsInventory,
  ),
  AccessControl(
    module: "warehouse inventory",
    title: "Manage Inventory",
    description: "Allow users to add, edit, or remove inventory items.",
    access: WarehousePermission.manageWmsInventory,
  ),
  AccessControl(
    module: "warehouse inventory",
    title: "Update Stock Levels",
    description: "Allow users to manually adjust stock quantities.",
    access: WarehousePermission.updateWmsStockLevels,
  ),
  AccessControl(
    module: "warehouse inventory",
    title: "Delete Items",
    description: "Allow users to permanently remove inventory records.",
    access: WarehousePermission.deleteWmsItems,
  ),
];

final List<AccessControl> _shipmentsPermissions = [
  AccessControl(
    module: "warehouse shipments",
    title: "Create Inbound Shipments",
    description: "Allow users to create and schedule inbound shipments.",
    access: WarehousePermission.createWmsInboundShipment,
  ),
  AccessControl(
    module: "warehouse shipments",
    title: "Receive Shipments",
    description: "Allow users to receive and process incoming shipments.",
    access: WarehousePermission.receiveWmsShipment,
  ),
];

final List<AccessControl> _operationsPermissions = [
  AccessControl(
    module: "warehouse operations",
    title: "Move Items",
    description:
        "Allow users to move items between bins, shelves, or warehouses.",
    access: WarehousePermission.moveWmsItems,
  ),
  AccessControl(
    module: "warehouse operations",
    title: "Audit Stock",
    description: "Allow users to perform stock audits or cycle counts.",
    access: WarehousePermission.auditWmsStock,
  ),
];

final List<AccessControl> _metricsPermissions = [
  AccessControl(
    module: "warehouse metrics",
    title: "View Reports",
    description: "Allow users to access warehouse reports and analytics.",
    access: WarehousePermission.viewWmsReports,
  ),
  AccessControl(
    module: "warehouse metrics",
    title: "Export Data",
    description: "Allow users to export inventory and shipment data.",
    access: WarehousePermission.exportWarehouseData,
  ),
  AccessControl(
    module: "warehouse metrics",
    title: "Manage Warehouse Settings",
    description: "Allow users to configure warehouse zones and settings.",
    access: WarehousePermission.manageWmsSettings,
  ),
];

final List<AccessControl> _secretPermissionDetails = [
  AccessControl(
    module: "Warehouse Secrets",
    title: "View Packages IDs",
    description:
        "Allow users to view the reference numbers or IDs of packages.",
    access: WarehousePermission.viewWmsSecrets,
  ),
];

final wmsDisplayName = 'warehouse';

final List<AccessControl> warehousePermissions = [
  ..._warehousePermissionDetails,
  ..._inventoryPermissions,
  ..._shipmentsPermissions,
  ..._operationsPermissions,
  ..._metricsPermissions,
  ..._secretPermissionDetails,
];
