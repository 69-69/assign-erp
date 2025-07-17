enum SubscriptionLicenses {
  /// [pos] Point of Sale (P.O.S) License: Grants customers access to the Point of Sale system.
  pos,

  /// [crm] CRM License: Grants customers full access to the Customer Relationship Management system.
  crm,

  /// [warehouse] Warehouse (W.M.S) License: Grants customers access to the Warehouse Management System.
  warehouse,

  /// [inventory] Inventory (I.M.S) License: Grants customers access to the Inventory Management System.
  inventory,

  /// [full] Full Access License: Grants unrestricted access to all App system operations/packages.
  full,

  /// [agent] Agent License: Allows agents to manage their own and clients' workspaces.
  agent,

  /// [dev] Developer License: Used by developers for testing and troubleshooting purposes.
  dev,

  /// [setup] Setup License: Used for configuring agent workspaces and system setup.
  setup,

  /// [unauthorized] Onboarding License: Used to deactivate/block any Workspace licenses.
  unauthorized,
}

String licenseAsString(SubscriptionLicenses e) => e.toString().split('.').last;

/// Function to convert enum values to a list of strings [workspaceRolesToList]
List<String> subscriptionLicensesToList<T>() {
  // Convert the modified list to a list of strings
  return SubscriptionLicenses.values.map((e) => licenseAsString(e)).toList();
}

SubscriptionLicenses getLicenseByString(String license) => SubscriptionLicenses
    .values
    .firstWhere((e) => licenseAsString(e) == license);
