import 'package:assign_erp/core/constants/hosting_type.dart';
import 'package:assign_erp/core/util/format_date_utl.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/features/auth/data/role/workspace_role.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

var _today = DateTime.now();

/// Role-Based Access-Control [Workspace]
class Workspace extends Equatable {
  final String id; // Unique identifier for the workspace
  final String username;

  /// [name] Name of the workspace, e.g., "My Workspace"
  final String name;
  final String clientName;
  final String mobileNumber;
  final double subscriptionFee;
  final HostingType hostingType;

  /// [role] Workspace Role: subscriber, agent, etc.
  final WorkspaceRole role;
  final String email;

  /// [category] Workspace Category of the Software; manufacturer, distributor, retailer, etc.
  final String category;
  final String subscriptionId;

  /// The maximum number of devices a user is allowed to install/use this software on,
  /// based on their subscription or purchase plan.
  final int maxAllowedDevices;

  /// The list of device IDs currently authorized to use the software,
  /// limited by the [maxAllowedDevices] plan.
  final List<String> authorizedDeviceIds;

  /// agentId: The One who setup this Software up for your company/organization [agentId]
  final String agentId;
  final String updatedBy;
  final DateTime effectiveFrom;
  final DateTime expiresOn;
  final DateTime createdAt;

  Workspace({
    this.id = '',
    this.username = '',
    this.hostingType = HostingType.onPremise,
    required this.clientName,
    required this.name,
    required this.mobileNumber,
    required this.role,
    required this.email,
    required this.category,
    this.subscriptionFee = 0,
    required this.subscriptionId,
    this.maxAllowedDevices = 1,
    this.authorizedDeviceIds = const [],
    // agentId: The ID of the individual(agent) that configured this software for your organization.
    required this.agentId,
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
    final fee =
        double.tryParse(map['subscriptionFee']?.toString() ?? '0') ?? 0.0;

    return Workspace(
      id: (map['id']) ?? id ?? '',
      agentId: map['agentId'] ?? '',
      email: map['email'] ?? '',
      subscriptionId: map['subscriptionId'] ?? '',
      subscriptionFee: fee,
      username: '${map['username']}'.emailToUsername,
      hostingType: getHostingByString(
        map['hostingType'] ?? HostingType.onPremise.label,
      ),
      role: getRoleByString(map['role'] ?? WorkspaceRole.subscriber.label),
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      clientName: map['clientName'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      maxAllowedDevices: map['maxAllowedDevices'] ?? 1,
      authorizedDeviceIds: List<String>.from(map['authorizedDeviceIds'] ?? []),
      effectiveFrom: toDateTimeFn(map['effectiveFrom']),
      updatedBy: map['updatedBy'] ?? '',
      expiresOn: toDateTimeFn(map['expiresOn'] ?? ''),
      createdAt: toDateTimeFn(map['createdAt'] ?? ''),
    );
  }

  static WorkspaceRole getRoleByString(String role) =>
      WorkspaceRole.values.firstWhere((e) => roleAsString(e) == role);

  static String roleAsString(WorkspaceRole e) => e.toString().split('.').last;

  // map template
  Map<String, dynamic> _mapTemp() => {
    'id': id,
    'agentId': agentId,
    'hostingType': hostingType.label,
    'username': email.emailToUsername,
    // Convert enum to string
    'role': roleAsString(role),
    'email': email,
    'name': name,
    'category': category,
    'subscriptionFee': subscriptionFee,
    'clientName': clientName,
    'mobileNumber': mobileNumber,
    'subscriptionId': subscriptionId,
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

  /// subscriptionId UnExpired [unExpired]
  bool get unExpired =>
      subscriptionId.isNotEmpty && _today.isBefore(expiresOn.toDateTime);

  /// subscriptionId Expired [isExpired]
  bool get isExpired => !unExpired || _today.isAfter(expiresOn.toDateTime);

  /// Whether the current user's device is already authorized [isDeviceAuthorized]
  bool isDeviceAuthorized(String userDeviceId) =>
      authorizedDeviceIds.contains(userDeviceId);

  /// Whether the maximum number of devices allowed by the subscriptionId has been reached [isDeviceLimitReached]
  bool get isDeviceLimitReached =>
      authorizedDeviceIds.length >= maxAllowedDevices;

  static List<Workspace> filterByAgentId(
    List<Workspace> workspaces,
    String id,
  ) => workspaces.where((work) => work.id == id).toList();

  /*static Iterable<Workspace> filterById(
    List<Workspace> workspaces,
    String id,
  ) => workspaces.where((work) => work.id == id);*/

  static Workspace? filterById(List<Workspace> workspaces, String id) =>
      workspaces.firstWhereOrNull((w) => w.id == id);

  static List<Workspace> filterStatus(
    List<Workspace> workspaces, {
    bool expired = false,
  }) => workspaces
      .where((work) => expired ? work.isExpired : work.unExpired)
      .toList();

  /// Can Access Agent Dashboard [canAccessAgentDashboard]
  bool canAccessAgentDashboard(Workspace work) =>
      work.role == WorkspaceRole.agentFranchise ||
      work.role == WorkspaceRole.developer;

  /// Can Create first-time Agent Workspace [canAccessOnboarding]
  bool canAccessOnboarding(Workspace work) =>
      work.role == WorkspaceRole.developer ||
      work.role == WorkspaceRole.onboarding;

  /// Can Access Developer/Troubleshoot Dashboard [canAccessDeveloperDashboard]
  bool canAccessDeveloperDashboard(Workspace work) =>
      work.role == WorkspaceRole.developer;

  /// Can Access Paid Subscribers/Tenants Dashboard [canAccessSubscriberDashboard]
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
    String? category,
    double? subscriptionFee,
    String? name,
    String? clientName,
    String? mobileNumber,
    WorkspaceRole? role,
    String? email,
    String? subscriptionId,
    int? maxAllowedDevices,
    List<String>? authorizedDeviceIds,
    String? agentId,
    String? updatedBy,
    DateTime? effectiveFrom,
    DateTime? expiresOn,
    DateTime? createdAt,
  }) {
    return Workspace(
      id: id ?? this.id,
      username: username ?? this.username,
      hostingType: hostingType ?? this.hostingType,
      category: category ?? this.category,
      subscriptionFee: subscriptionFee ?? this.subscriptionFee,
      name: name ?? this.name,
      clientName: clientName ?? this.clientName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      role: role ?? this.role,
      email: email ?? this.email,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      maxAllowedDevices: maxAllowedDevices ?? this.maxAllowedDevices,
      authorizedDeviceIds: authorizedDeviceIds ?? this.authorizedDeviceIds,
      agentId: agentId ?? this.agentId,
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
    category,
    name,
    mobileNumber,
    subscriptionId,
    subscriptionFee,
    maxAllowedDevices,
    authorizedDeviceIds,
    agentId,
    effectiveFrom,
    expiresOn,
    updatedBy,
    createdAt,
  ];

  /// ToList for PRODUCTS [itemAsList]
  List<String> itemAsList() => [
    id,
    role.name.toTitleCase,
    category.toTitleCase,
    name.toTitleCase,
    clientName.toTitleCase,
    mobileNumber,
    '$maxAllowedDevices',
    hostingType.name.toUpperCaseAll,
    '$subscriptionFee',
    subscriptionId,
    getCreatedAt,
    getEffectiveFrom,
    getExpiresOn,
  ];

  static List<String> get dataTableHeader => const [
    'id',
    'Role',
    'Business',
    'Workspace',
    'Client',
    'Mobile number',
    'Max-Devices',
    'Hosting type',
    'Sub. Fee',
    'sub. key',
    'Created At',
    'Effective Date',
    'Expiry Date',
  ];
}
