// ---------------------------
// ⚙️ Hosting Type Definitions
// ---------------------------

enum HostingType { cloud, onPremise, hybrid }

/* USAGE:
* final type = HostingType.cloud;
* print(type.label); // Output: cloud
* */
extension HostingTypeExtension on HostingType {
  String get label {
    return switch (this) {
      HostingType.cloud => 'cloud', // Hosted on a cloud provider (e.g., GCP)
      HostingType.hybrid =>
        'hybrid', // Hosted on a cloud provider and on-premises
      HostingType.onPremise => 'onPremise', // Locally hosted on user's computer
    };
  }
}

final accountStatusList = HostingType.values.map((e) => e.label).toList();

HostingType getHostingByString(String value) {
  return HostingType.values.firstWhere(
    (e) => e.label == value,
    orElse: () => HostingType.onPremise,
  );
}

final hostingTypeList = [
  'hosting type',
  ...HostingType.values.map((e) => e.label),
];
