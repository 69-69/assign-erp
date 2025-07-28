import 'package:assign_erp/core/constants/account_status.dart';
import 'package:assign_erp/core/constants/hosting_type.dart';
import 'package:assign_erp/core/network/data_sources/models/subscription_licenses_enum.dart';
import 'package:assign_erp/core/util/format_date_utl.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/features/auth/data/role/workspace_role.dart';
import 'package:equatable/equatable.dart';

var _today = DateTime.now();

/// Role-Based Access-Control [Workspace]
class Workspace extends Equatable {
  final String id; // Unique identifier for the workspace
  final String username;
  final String workspaceName;
  final String subscriptionFee;
  final String clientName;
  final String mobileNumber;
  final HostingType hostingType;

  /// Assign Roles to Users [role]
  final WorkspaceRole role;
  final String email;
  final String status;

  // Workspace Category of the Software; manufacturer, distributor, retailer, etc.
  final String workspaceCategory;
  final SubscriptionLicenses license;

  /// The maximum number of devices a user is allowed to install/use this software on,
  /// based on their subscription or purchase plan.
  final int maxAllowedDevices;

  /// The list of device IDs currently authorized to use the software,
  /// limited by the [maxAllowedDevices] plan.
  final List<String> authorizedDeviceIds;

  /// agentID: The One who setup this Software up for your company/organization [agentID]
  final String agentID;
  final String updatedBy;
  final DateTime effectiveFrom;
  final DateTime expiresOn;
  final DateTime createdAt;

  Workspace({
    this.id = '',
    this.username = '',
    this.hostingType = HostingType.onPremise,
    required this.clientName,
    required this.workspaceName,
    required this.mobileNumber,
    required this.role,
    required this.email,
    required this.workspaceCategory,
    this.subscriptionFee = '',
    /** License Options:
     * 1- Full (Have access to all the Software packages)
     * 2- P.O.S Software,
     * 3- IMS - Inventory Software,
     * 4- WMS - Warehouse Software,
     * 5- CMS - Customer Software */
    required this.license,
    required this.status,
    this.maxAllowedDevices = 1,
    this.authorizedDeviceIds = const [],
    // agentID: The ID of the individual(agent) that configured this software for your organization.
    required this.agentID,
    DateTime? effectiveFrom,
    DateTime? createdAt,
    this.updatedBy = '',
    DateTime? expiresOn,
  }) : effectiveFrom = effectiveFrom ?? _today,
       expiresOn = expiresOn ?? _today,
       createdAt = createdAt ?? _today; // Set default value

  static const String cacheKey = 'workspace_auth_cache';

  /// fromFirestore / fromJson Function [Workspace.fromMap]
  factory Workspace.fromMap(Map<String, dynamic> map, {String? id}) {
    return Workspace(
      id: (map['id']) ?? id ?? '',
      email: map['email'] ?? '',
      hostingType: getHostingByString(
        map['hostingType'] ?? HostingType.onPremise.label,
      ),
      workspaceCategory: map['workspaceCategory'] ?? '',
      workspaceName: map['workspaceName'] ?? '',
      clientName: map['clientName'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      subscriptionFee: map['subscriptionFee'] ?? '',
      username: '${map['username']}'.emailToUsername,
      role: getRoleByString(map['role'] ?? WorkspaceRole.subscriber.label),
      status: map['status'] ?? AccountStatus.disabled.label,
      license: getLicenseByString(
        map['license'] ?? SubscriptionLicenses.unauthorized.name,
      ),
      maxAllowedDevices: map['maxAllowedDevices'] ?? 1,
      authorizedDeviceIds: List<String>.from(map['authorizedDeviceIds'] ?? []),
      agentID: map['agentID'] ?? '',
      effectiveFrom: toDateTimeFn(map['effectiveFrom']),
      updatedBy: map['updatedBy'] ?? '',
      expiresOn: toDateTimeFn(map['expiresOn']),
      createdAt: toDateTimeFn(map['createdAt']),
    );
  }

  static WorkspaceRole getRoleByString(String role) =>
      WorkspaceRole.values.firstWhere((e) => roleAsString(e) == role);

  static String roleAsString(WorkspaceRole e) => e.toString().split('.').last;

  // map template
  Map<String, dynamic> _mapTemp() => {
    'id': id,
    'agentID': agentID,
    'hostingType': hostingType.label,
    'username': email.emailToUsername,
    // Convert enum to string
    'role': roleAsString(role),
    'email': email,
    'workspaceCategory': workspaceCategory,
    'subscriptionFee': subscriptionFee,
    'workspaceName': workspaceName,
    'clientName': clientName,
    'mobileNumber': mobileNumber,
    'status': status,
    'license': licenseAsString(license),
    'maxAllowedDevices': maxAllowedDevices,
    'authorizedDeviceIds': authorizedDeviceIds,
    'effectiveFrom': effectiveFrom,
    'updatedBy': updatedBy,
    'expiresOn': expiresOn,
    'createdAt': createdAt,
  };

  /// Convert UserModel to a map for storing in Firestore [toMap]
  Map<String, dynamic> toMap() {
    var newMap = _mapTemp();
    newMap['effectiveFrom'] = effectiveFrom.toISOString;
    newMap['expiresOn'] = expiresOn.toISOString;
    newMap['createdAt'] = createdAt.toISOString;

    return newMap;
  }

  /// Convert UserModel to toCache Function [toCache]
  Map<String, dynamic> toCache() {
    var newMap = _mapTemp();
    newMap['effectiveFrom'] = effectiveFrom.millisecondsSinceEpoch;
    newMap['expiresOn'] = expiresOn.millisecondsSinceEpoch;
    newMap['createdAt'] = createdAt.millisecondsSinceEpoch;

    return {'id': cacheKey, 'data': newMap};
  }

  /// Formatted to Standard-DateTime in String [getEffectiveFrom]
  String get getEffectiveFrom => effectiveFrom.toStandardDT;
  String get getCreatedAt => createdAt.toStandardDT;

  /// Formatted to Standard-DateTime in String [getExpiresOn]
  String get getExpiresOn => expiresOn.toStandardDT;

  /// License UnExpired [unExpired]
  bool get unExpired =>
      license != SubscriptionLicenses.unauthorized &&
      (status == AccountStatus.enabled.label &&
          _today.isBefore(expiresOn.toDateTime));

  /// License Expired [isExpired]
  bool get isExpired => !unExpired || _today.isAfter(expiresOn.toDateTime);

  /// Whether the current user's device is already authorized [isDeviceAuthorized]
  bool isDeviceAuthorized(String userDeviceId) =>
      authorizedDeviceIds.contains(userDeviceId);

  /// Whether the maximum number of devices allowed by the license has been reached [isDeviceLimitReached]
  bool get isDeviceLimitReached =>
      authorizedDeviceIds.length >= maxAllowedDevices;

  static List<Workspace> filterByAgentId(
    List<Workspace> workspaces,
    String agentId,
  ) => workspaces.where((work) => work.agentID == agentId).toList();

  static Iterable<Workspace> filterById(
    List<Workspace> workspaces,
    String id,
  ) => workspaces.where((work) => work.id == id);

  static List<Workspace> filterStatus(
    List<Workspace> workspaces, {
    bool expired = false,
  }) => workspaces
      .where((work) => expired ? work.isExpired : work.unExpired)
      .toList();

  /// Check Permissions Based on Role
  /// USAGE: Implement Role-Based Access in Your App
  ///       final currentUser = UserModel(username: 'JohnDoe', role: UserRole.developer,  email: 'john.doe@example.com',);
  ///       if (canAccessAdminPanel(currentUser))
  ///           ElevatedButton(
  ///             onPressed: () {},
  ///             child: Text('Admin Panel'),
  ///           ),
  ///       if (canEditContent(currentUser))
  ///         ElevatedButton(
  ///           onPressed: () {},
  ///           child: Text('Content Editor'),
  ///         ),
  bool canAccessAgentDashboard(Workspace work) =>
      work.role == WorkspaceRole.agentFranchise ||
      work.role == WorkspaceRole.developer;

  bool canAccessInitialSetup(Workspace work) =>
      work.role == WorkspaceRole.developer ||
      work.role == WorkspaceRole.initialSetup;

  bool canAccessDeveloperDashboard(Workspace work) =>
      work.role == WorkspaceRole.developer;

  bool canAccessSubscriberDashboard(Workspace work) =>
      work.role == WorkspaceRole.subscriber;

  bool canEditContent(Workspace work) =>
      work.role == WorkspaceRole.subscriber ||
      work.role == WorkspaceRole.developer ||
      work.role == WorkspaceRole.agentFranchise;

  Workspace copyWith({
    String? id,
    String? username,
    HostingType? hostingType,
    String? workspaceCategory,
    String? subscriptionFee,
    String? workspaceName,
    String? clientName,
    String? mobileNumber,
    WorkspaceRole? role,
    String? email,
    String? status,
    SubscriptionLicenses? license,
    int? maxAllowedDevices,
    List<String>? authorizedDeviceIds,
    String? agentID,
    String? updatedBy,
    DateTime? effectiveFrom,
    DateTime? expiresOn,
    DateTime? createdAt,
  }) {
    return Workspace(
      id: id ?? this.id,
      username: username ?? this.username,
      hostingType: hostingType ?? this.hostingType,
      workspaceCategory: workspaceCategory ?? this.workspaceCategory,
      subscriptionFee: subscriptionFee ?? this.subscriptionFee,
      workspaceName: workspaceName ?? this.workspaceName,
      clientName: clientName ?? this.clientName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      role: role ?? this.role,
      email: email ?? this.email,
      status: status ?? this.status,
      license: license ?? this.license,
      maxAllowedDevices: maxAllowedDevices ?? this.maxAllowedDevices,
      authorizedDeviceIds: authorizedDeviceIds ?? this.authorizedDeviceIds,
      agentID: agentID ?? this.agentID,
      updatedBy: updatedBy ?? this.updatedBy,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      expiresOn: expiresOn ?? this.expiresOn,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    username,
    role,
    email,
    hostingType,
    workspaceCategory,
    workspaceName,
    mobileNumber,
    status,
    license,
    subscriptionFee,
    maxAllowedDevices,
    authorizedDeviceIds,
    agentID,
    effectiveFrom,
    updatedBy,
    expiresOn,
    createdAt,
  ];

  /// ToList for PRODUCTS [itemAsList]
  List<String> itemAsList() => [
    username.toTitleCase,
    id,
    license.name.toUpperCaseAll,
    role.name.toTitleCase,
    workspaceCategory.toTitleCase,
    workspaceName.toTitleCase,
    clientName.toTitleCase,
    mobileNumber,
    status.toTitleCase,
    subscriptionFee,
    '$maxAllowedDevices',
    hostingType.name.toUpperCaseAll,
    getCreatedAt,
    getEffectiveFrom,
    getExpiresOn,
  ];

  static List<String> get dataTableHeader => const [
    'Username',
    'id',
    'license',
    'Role',
    'Business',
    'Workspace',
    'Client',
    'Mobile number',
    'Status',
    'Subscription Fee',
    'Max-Devices',
    'Hosting type',
    'Created At',
    'Effective Date',
    'Expiry Date',
  ];
}
