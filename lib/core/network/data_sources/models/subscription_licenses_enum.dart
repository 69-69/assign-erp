enum SubscriptionLicenses {
  // Write-only access, typically granted to Agents and Developers for system setup purposes.
  inventory,

  // Full access to read, write, and execute operations for managing POS (Point of Sale) systems.
  pos,

  // Full access to read, write, and execute operations for customer relationship management (CRM).
  crm,

  // Full access to read, write, and execute operations for managing warehouse operations.
  warehouse,

  // Full access to all system operations (read, write, and execute) without any restrictions.
  full,

  // Full access to read, write, and execute operations for agents managing subscribers.
  agent,

  // Full access to read, write, and execute operations for developers maintaining and troubleshooting the system.
  dev,

  // Full access to write and execute operations for setting up agent workspaces and configurations.
  setup,

  // Denied access or unauthorized operations.
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
