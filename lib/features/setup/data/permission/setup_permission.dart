import 'package:assign_erp/core/network/data_sources/models/permission_item_model.dart';

/// PERMISSION BASED ACCESS-CONTROL
enum SetupPermission {
  // Company Info
  createCompanyInfo,
  viewCompanyInfo,
  updateCompanyInfo,
  deleteCompanyInfo,

  // store Location
  createStoreLocation,
  viewStoreLocation,
  updateStoreLocation,
  deleteStoreLocation,
  assignStoreLocation,

  // Employee
  createEmployee,
  viewEmployee,
  updateEmployee,
  deleteEmployee,

  // Role
  createRole,
  viewRole,
  updateRole,
  deleteRole,

  // Assign Permission
  assignPermission,

  // backup
  createBackup,
  deleteBackup,
  restoreBackup,
  historyBackup,

  // product suppliers
  createProductSupplier,
  viewProductSupplier,
  updateProductSupplier,
  deleteProductSupplier,

  // product categories
  createProductCategory,
  viewProductCategory,
  updateProductCategory,
  deleteProductCategory,

  // print settings
  updatePrintSetting,
}

final List<PermissionItem> _companyInfoPermissions = [
  PermissionItem(
    module: "company info",
    title: "Create company info",
    subtitle: "Allow users to create new company information.",
    permission: SetupPermission.createCompanyInfo,
  ),
  PermissionItem(
    module: "company info",
    title: "View company info",
    subtitle: "Allow access to a list of all company information.",
    permission: SetupPermission.viewCompanyInfo,
  ),
  PermissionItem(
    module: "company info",
    title: "Edit company info",
    subtitle: "Allow users to modify details of an existing company info.",
    permission: SetupPermission.updateCompanyInfo,
  ),
  PermissionItem(
    module: "company info",
    title: "Delete company info",
    subtitle: "Allow users to permanently remove a company info record.",
    permission: SetupPermission.deleteCompanyInfo,
  ),
];

final List<PermissionItem> _storeLocationPermissions = [
  PermissionItem(
    module: "store location",
    title: "Create new store location",
    subtitle: "Allow users to create new store locations.",
    permission: SetupPermission.createStoreLocation,
  ),
  PermissionItem(
    module: "store location",
    title: "View store locations",
    subtitle: "Allow access to a list of all store locations.",
    permission: SetupPermission.viewStoreLocation,
  ),
  PermissionItem(
    module: "store location",
    title: "Edit store locations",
    subtitle: "Allow users to modify details of an existing store location.",
    permission: SetupPermission.updateStoreLocation,
  ),
  PermissionItem(
    module: "store location",
    title: "Delete store locations",
    subtitle: "Allow users to permanently remove a store location record.",
    permission: SetupPermission.deleteStoreLocation,
  ),
  PermissionItem(
    module: "store location",
    title: "Assign store locations",
    subtitle: "Allow users to assign store locations to employees.",
    permission: SetupPermission.assignStoreLocation,
  ),
];

final List<PermissionItem> _employeePermissions = [
  PermissionItem(
    module: "employee",
    title: "Create new employee",
    subtitle: "Allow users to create new employees account.",
    permission: SetupPermission.createEmployee,
  ),
  PermissionItem(
    module: "employee",
    title: "View employees",
    subtitle: "Allow access to a list of all employees account.",
    permission: SetupPermission.viewEmployee,
  ),
  PermissionItem(
    module: "employee",
    title: "Edit employees",
    subtitle: "Allow users to modify details of an existing employee account.",
    permission: SetupPermission.updateEmployee,
  ),
  PermissionItem(
    module: "employee",
    title: "Delete employees",
    subtitle: "Allow users to permanently remove an employee record.",
    permission: SetupPermission.deleteEmployee,
  ),
];

final List<PermissionItem> _rolePermissions = [
  PermissionItem(
    module: "role",
    title: "Create new role",
    subtitle: "Allow users to create new roles.",
    permission: SetupPermission.createRole,
  ),
  PermissionItem(
    module: "role",
    title: "View roles",
    subtitle: "Allow access to a list of all roles.",
    permission: SetupPermission.viewRole,
  ),
  PermissionItem(
    module: "role",
    title: "Edit roles",
    subtitle: "Allow users to modify details of an existing role.",
    permission: SetupPermission.updateRole,
  ),
  PermissionItem(
    module: "role",
    title: "Delete roles",
    subtitle: "Allow users to permanently remove a role record.",
    permission: SetupPermission.deleteRole,
  ),
];

final List<PermissionItem> _assignPermissions = [
  PermissionItem(
    module: "assign permission",
    title: "Assign permissions to roles",
    subtitle: "Allow users to assign permissions to roles.",
    permission: SetupPermission.assignPermission,
  ),
];

final List<PermissionItem> _backupPermissions = [
  PermissionItem(
    module: "backup",
    title: "Create new backup",
    subtitle: "Allow users to create new backups.",
    permission: SetupPermission.createBackup,
  ),
  PermissionItem(
    module: "backup",
    title: "Restore backups",
    subtitle: "Allow users to restore backups from a cloud.",
    permission: SetupPermission.restoreBackup,
  ),
  PermissionItem(
    module: "backup",
    title: "backup history",
    subtitle: "Allow users to view the history of previous backups.",
    permission: SetupPermission.historyBackup,
  ),
  PermissionItem(
    module: "backup",
    title: "Delete backups",
    subtitle: "Allow users to permanently remove a backup record.",
    permission: SetupPermission.deleteBackup,
  ),
];

final List<PermissionItem> _productSupplierPermissions = [
  PermissionItem(
    module: "product supplier",
    title: "Create new product supplier",
    subtitle: "Allow users to create new product suppliers.",
    permission: SetupPermission.createProductSupplier,
  ),
  PermissionItem(
    module: "product supplier",
    title: "View product suppliers",
    subtitle: "Allow access to a list of all product suppliers.",
    permission: SetupPermission.viewProductSupplier,
  ),
  PermissionItem(
    module: "product supplier",
    title: "Edit product suppliers",
    subtitle: "Allow users to modify details of an existing product supplier.",
    permission: SetupPermission.updateProductSupplier,
  ),
  PermissionItem(
    module: "product supplier",
    title: "Delete product suppliers",
    subtitle: "Allow users to permanently remove a product supplier record.",
    permission: SetupPermission.deleteProductSupplier,
  ),
];

final List<PermissionItem> _productCategoryPermissions = [
  PermissionItem(
    module: "product category",
    title: "Create new product category",
    subtitle: "Allow users to create new product categories.",
    permission: SetupPermission.createProductCategory,
  ),
  PermissionItem(
    module: "product category",
    title: "View product categories",
    subtitle: "Allow access to a list of all product categories.",
    permission: SetupPermission.viewProductCategory,
  ),
  PermissionItem(
    module: "product category",
    title: "Edit product categories",
    subtitle: "Allow users to modify details of an existing product category.",
    permission: SetupPermission.updateProductCategory,
  ),
  PermissionItem(
    module: "product category",
    title: "Delete product categories",
    subtitle: "Allow users to permanently remove a product category record.",
    permission: SetupPermission.deleteProductCategory,
  ),
];

final List<PermissionItem> _printSettingPermissions = [
  PermissionItem(
    module: "print setting",
    title: "Update print settings",
    subtitle: "Allow users to update print settings.",
    permission: SetupPermission.updatePrintSetting,
  ),
];

final setupDisplayName = 'setup';

final List<PermissionItem> setupPermissions = [
  ..._companyInfoPermissions,
  ..._storeLocationPermissions,
  ..._employeePermissions,
  ..._rolePermissions,
  ..._assignPermissions,
  ..._backupPermissions,
  ..._productSupplierPermissions,
  ..._productCategoryPermissions,
  ..._printSettingPermissions,
];
