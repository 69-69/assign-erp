import 'package:assign_erp/features/access_control/data/model/access_control_model.dart';
import 'package:assign_erp/features/setup/data/models/permission_model.dart';
import 'package:assign_erp/features/setup/data/models/role_model.dart';

/// PERMISSION BASED ACCESS-CONTROL
enum SetupPermission {
  manageSetup,
  // Company Info
  manageCompany,
  createCompanyInfo,
  viewCompanyInfo,
  updateCompanyInfo,
  deleteCompanyInfo,

  // store Location
  manageStoreLocation,
  createStoreLocation,
  viewStoreLocation,
  updateStoreLocation,
  deleteStoreLocation,
  assignStoreLocation,

  // Employee
  manageEmployee,
  createEmployee,
  viewEmployee,
  updateEmployee,
  deleteEmployee,

  // Role
  manageRole,
  createRole,
  viewRole,
  updateRole,
  deleteRole,

  // Assign Permission
  assignPermission,

  // backup
  manageBackup,
  createBackup,
  deleteBackup,
  restoreBackup,
  historyBackup,

  // license
  viewLicense,

  // product suppliers
  manageProductSupplier,
  createProductSupplier,
  viewProductSupplier,
  updateProductSupplier,
  deleteProductSupplier,

  // product categories
  manageProductCategory,
  createProductCategory,
  viewProductCategory,
  updateProductCategory,
  deleteProductCategory,

  // print settings
  updatePrintSetting,
  viewSetupSecrets, // For viewing configuration IDs
  // For unspecified permissions
}

final List<AccessControl> _setupPermissions = [
  AccessControl(
    module: "setup",
    title: "Manage setup",
    description:
        "Grants users the ability to create, modify, and remove workspace setup configurations",
    access: SetupPermission.manageSetup,
  ),
];

final List<AccessControl> _companyInfoPermissions = [
  AccessControl(
    module: "company info",
    title: "Manage company info",
    description: "Allow users to create, edit, and delete company information.",
    access: SetupPermission.manageCompany,
  ),
  AccessControl(
    module: "company info",
    title: "Create company info",
    description: "Allow users to create new company information.",
    access: SetupPermission.createCompanyInfo,
  ),
  AccessControl(
    module: "company info",
    title: "View company info",
    description: "Allow access to a list of all company information.",
    access: SetupPermission.viewCompanyInfo,
  ),
  AccessControl(
    module: "company info",
    title: "Edit company info",
    description: "Allow users to modify details of an existing company info.",
    access: SetupPermission.updateCompanyInfo,
  ),
  AccessControl(
    module: "company info",
    title: "Delete company info",
    description: "Allow users to permanently remove a company info record.",
    access: SetupPermission.deleteCompanyInfo,
  ),
];

final List<AccessControl> _storeLocationPermissions = [
  AccessControl(
    module: "store locations",
    title: "Manage store locations",
    description: "Allow users to create, edit, and delete store locations.",
    access: SetupPermission.manageStoreLocation,
  ),
  AccessControl(
    module: "store location",
    title: "Create new store location",
    description: "Allow users to create new store locations.",
    access: SetupPermission.createStoreLocation,
  ),
  AccessControl(
    module: "store location",
    title: "View store locations",
    description: "Allow access to a list of all store locations.",
    access: SetupPermission.viewStoreLocation,
  ),
  AccessControl(
    module: "store location",
    title: "Edit store locations",
    description: "Allow users to modify details of an existing store location.",
    access: SetupPermission.updateStoreLocation,
  ),
  AccessControl(
    module: "store location",
    title: "Delete store locations",
    description: "Allow users to permanently remove a store location record.",
    access: SetupPermission.deleteStoreLocation,
  ),
  AccessControl(
    module: "store location",
    title: "Assign store locations",
    description: "Allow users to assign store locations to employees.",
    access: SetupPermission.assignStoreLocation,
  ),
];

final List<AccessControl> _employeePermissions = [
  AccessControl(
    module: "employee",
    title: "Manage employees",
    description: "Allow users to create, edit, and delete employees.",
    access: SetupPermission.manageEmployee,
  ),
  AccessControl(
    module: "employee",
    title: "Create new employee",
    description: "Allow users to create new employees account.",
    access: SetupPermission.createEmployee,
  ),
  AccessControl(
    module: "employee",
    title: "View employees",
    description: "Allow access to a list of all employees account.",
    access: SetupPermission.viewEmployee,
  ),
  AccessControl(
    module: "employee",
    title: "Edit employees",
    description:
        "Allow users to modify details of an existing employee account.",
    access: SetupPermission.updateEmployee,
  ),
  AccessControl(
    module: "employee",
    title: "Delete employees",
    description: "Allow users to permanently remove an employee record.",
    access: SetupPermission.deleteEmployee,
  ),
];

final List<AccessControl> _rolePermissions = [
  AccessControl(
    module: "role",
    title: "roles & permissions",
    description: "Allow users to create, edit, and delete roles.",
    access: SetupPermission.manageRole,
  ),
  AccessControl(
    module: "role",
    title: "Create new role",
    description: "Allow users to create new roles.",
    access: SetupPermission.createRole,
  ),
  AccessControl(
    module: "role",
    title: "View roles",
    description: "Allow access to a list of all roles.",
    access: SetupPermission.viewRole,
  ),
  AccessControl(
    module: "role",
    title: "Edit roles",
    description: "Allow users to modify details of an existing role.",
    access: SetupPermission.updateRole,
  ),
  AccessControl(
    module: "role",
    title: "Delete roles",
    description: "Allow users to permanently remove a role record.",
    access: SetupPermission.deleteRole,
  ),
];

final List<AccessControl> _assignPermissions = [
  AccessControl(
    module: "assign permission",
    title: "Assign permissions to roles",
    description: "Allow users to assign permissions to roles.",
    access: SetupPermission.assignPermission,
  ),
];

final List<AccessControl> _backupPermissions = [
  AccessControl(
    module: "backup",
    title: "Manage backups",
    description: "Allow users to create, edit, and delete backups.",
    access: SetupPermission.manageBackup,
  ),
  AccessControl(
    module: "backup",
    title: "Create new backup",
    description: "Allow users to create new backups.",
    access: SetupPermission.createBackup,
  ),
  AccessControl(
    module: "backup",
    title: "Restore backups",
    description: "Allow users to restore backups from a cloud.",
    access: SetupPermission.restoreBackup,
  ),
  AccessControl(
    module: "backup",
    title: "backup history",
    description: "Allow users to view the history of previous backups.",
    access: SetupPermission.historyBackup,
  ),
  AccessControl(
    module: "backup",
    title: "Delete backups",
    description: "Allow users to permanently remove a backup record.",
    access: SetupPermission.deleteBackup,
  ),
];

final List<AccessControl> _productSupplierPermissions = [
  AccessControl(
    module: "product supplier",
    title: "Manage product suppliers",
    description: "Allow users to create, edit, and delete product suppliers.",
    access: SetupPermission.manageProductSupplier,
  ),
  AccessControl(
    module: "product supplier",
    title: "Create new product supplier",
    description: "Allow users to create new product suppliers.",
    access: SetupPermission.createProductSupplier,
  ),
  AccessControl(
    module: "product supplier",
    title: "View product suppliers",
    description: "Allow access to a list of all product suppliers.",
    access: SetupPermission.viewProductSupplier,
  ),
  AccessControl(
    module: "product supplier",
    title: "Edit product suppliers",
    description:
        "Allow users to modify details of an existing product supplier.",
    access: SetupPermission.updateProductSupplier,
  ),
  AccessControl(
    module: "product supplier",
    title: "Delete product suppliers",
    description: "Allow users to permanently remove a product supplier record.",
    access: SetupPermission.deleteProductSupplier,
  ),
];

final List<AccessControl> _productCategoryPermissions = [
  AccessControl(
    module: "product category",
    title: "Manage product categories",
    description: "Allow users to create, edit, and delete product categories.",
    access: SetupPermission.manageProductCategory,
  ),
  AccessControl(
    module: "product category",
    title: "Create new product category",
    description: "Allow users to create new product categories.",
    access: SetupPermission.createProductCategory,
  ),
  AccessControl(
    module: "product category",
    title: "View product categories",
    description: "Allow access to a list of all product categories.",
    access: SetupPermission.viewProductCategory,
  ),
  AccessControl(
    module: "product category",
    title: "Edit product categories",
    description:
        "Allow users to modify details of an existing product category.",
    access: SetupPermission.updateProductCategory,
  ),
  AccessControl(
    module: "product category",
    title: "Delete product categories",
    description: "Allow users to permanently remove a product category record.",
    access: SetupPermission.deleteProductCategory,
  ),
];

final List<AccessControl> _printSettingPermissions = [
  AccessControl(
    module: "print setting",
    title: "Update print settings",
    description: "Allow users to update print settings.",
    access: SetupPermission.updatePrintSetting,
  ),
];

final List<AccessControl> _licensePermissions = [
  AccessControl(
    module: "license",
    title: "View license",
    description: "Allow users to view the license.",
    access: SetupPermission.viewLicense,
  ),
];

final List<AccessControl> _secretPermissions = [
  AccessControl(
    module: "Setup Secrets",
    title: "View Configuration IDs",
    description: "Allow users to view the IDs of configuration.",
    access: SetupPermission.viewSetupSecrets,
  ),
];

final setupDisplayName = 'setup';

/// High-level = access the section (Manage)
/// Low-level = control button-level permissions (Create, Edit, Delete)
final List<AccessControl> setupPermissions = [
  ..._setupPermissions,
  ..._companyInfoPermissions,
  ..._storeLocationPermissions,
  ..._employeePermissions,
  ..._rolePermissions,
  ..._assignPermissions,
  ..._backupPermissions,
  ..._productSupplierPermissions,
  ..._productCategoryPermissions,
  ..._printSettingPermissions,
  ..._licensePermissions,
  ..._secretPermissions,
];

Set<Permission> _defaultStoreOwnerPermissions = setupPermissions
    .map(
      (permission) => Permission(
        module: permission.module,
        permission: permission.accessName,
      ),
    )
    .toSet();

/// [defaultStoreOwnerPermissions] This is the default permissions for the store owner
/// during first-time workspace setup(Workspace Creation)
Map<String, dynamic> get defaultStoreOwnerPermissions => Role(
  name: 'store owner',
  permissions: _defaultStoreOwnerPermissions,
  createdBy: 'system default',
).toMap();
