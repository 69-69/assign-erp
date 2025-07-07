import 'package:assign_erp/core/constants/account_status.dart';
import 'package:assign_erp/core/network/data_sources/models/subscription_licenses_enum.dart';
import 'package:assign_erp/core/network/data_sources/models/workspace_role.dart';
import 'package:assign_erp/core/util/format_date_utl.dart';
import 'package:assign_erp/core/util/str_util.dart';
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

  /// Assign Roles to Users [role]
  final WorkspaceRole role;
  final String email;
  final String status;

  // Category of the Software; manufacturer, distributor, retailer, etc.
  final String companyCategory;
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

  Workspace({
    this.id = '',
    this.username = '',
    required this.clientName,
    required this.workspaceName,
    required this.mobileNumber,
    required this.role,
    required this.email,
    required this.companyCategory,
    this.subscriptionFee = '0',
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
    // agentID: The One who setup this Software up for your company/organization
    required this.agentID,
    DateTime? effectiveFrom,
    this.updatedBy = '',
    DateTime? expiresOn,
  }) : effectiveFrom = effectiveFrom ?? _today,
       expiresOn = expiresOn ?? _today; // Set default value

  static const String cacheKey = 'workspace_auth_cache';

  /// fromFirestore / fromJson Function [Workspace.fromMap]
  factory Workspace.fromMap(Map<String, dynamic> map, {String? id}) {
    return Workspace(
      id: (id ?? map['id']) ?? '',
      email: map['email'] ?? '',
      companyCategory: map['companyCategory'] ?? '',
      workspaceName: map['workspaceName'] ?? '',
      clientName: map['clientName'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      subscriptionFee: map['subscriptionFee'] ?? '0',
      username: map['username'].toString().emailToUsername,
      role: getRoleByString(map['role']),
      status: map['status'] ?? AccountStatus.disabled.label,
      license: getLicenseByString(
        map['license'] ?? SubscriptionLicenses.unauthorized,
      ),
      maxAllowedDevices: map['maxAllowedDevices'] ?? 1,
      authorizedDeviceIds: List<String>.from(map['authorizedDeviceIds'] ?? []),
      agentID: map['agentID'] ?? '',
      effectiveFrom: toDateTimeFn(map['effectiveFrom']),
      updatedBy: map['updatedBy'] ?? '',
      expiresOn: toDateTimeFn(map['expiresOn']),
    );
  }

  static WorkspaceRole getRoleByString(String role) =>
      WorkspaceRole.values.firstWhere((e) => roleAsString(e) == role);

  static String roleAsString(WorkspaceRole e) => e.toString().split('.').last;

  // map template
  Map<String, dynamic> _mapTemp() => {
    'id': id,
    'agentID': agentID,
    'username': email.emailToUsername,
    // Convert enum to string
    'role': roleAsString(role),
    'email': email,
    'companyCategory': companyCategory,
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
  };

  /// Convert UserModel to a map for storing in Firestore [toMap]
  Map<String, dynamic> toMap() {
    var newMap = _mapTemp();
    newMap['effectiveFrom'] = effectiveFrom.toISOString;
    newMap['expiresOn'] = expiresOn.toISOString;

    return newMap;
  }

  /// Convert UserModel to toCache Function [toCache]
  Map<String, dynamic> toCache() {
    var newMap = _mapTemp();
    newMap['effectiveFrom'] = effectiveFrom.millisecondsSinceEpoch;
    newMap['expiresOn'] = expiresOn.millisecondsSinceEpoch;

    return {'id': cacheKey, 'data': newMap};
  }

  /// Formatted to Standard-DateTime in String [getEffectiveFrom]
  String get getEffectiveFrom => effectiveFrom.toStandardDT;

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

  /* USAGE Example: Implement Role-Based Access in Your App
  * final currentUser = UserModel(username: 'JohnDoe', role: UserRole.developer,  email: 'john.doe@example.com',);
  * if (canAccessAdminPanel(currentUser))
              ElevatedButton(
                onPressed: () {},
                child: Text('Admin Panel'),
              ),
            if (canEditContent(currentUser))
              ElevatedButton(
                onPressed: () {},
                child: Text('Content Editor'),
              ),
  * */

  /// Check Permissions Based on Role
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
    String? companyCategory,
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
  }) {
    return Workspace(
      id: id ?? this.id,
      username: username ?? this.username,
      companyCategory: companyCategory ?? this.companyCategory,
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
    );
  }

  @override
  List<Object?> get props => [
    id,
    username,
    role,
    email,
    companyCategory,
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
  ];

  /// ToList for PRODUCTS [itemAsList]
  List<String> itemAsList() => [
    username.toUppercaseFirstLetterEach,
    id,
    companyCategory.toUppercaseFirstLetterEach,
    workspaceName.toUppercaseFirstLetterEach,
    clientName.toUppercaseFirstLetterEach,
    role.name.toUppercaseFirstLetterEach,
    mobileNumber,
    status.toUppercaseFirstLetterEach,
    license.name.toUppercaseFirstLetterEach,
    subscriptionFee,
    '$maxAllowedDevices',
    getEffectiveFrom,
    getExpiresOn,
  ];

  static List<String> get dataTableHeader => const [
    'Username',
    'id',
    'Business',
    'Workspace',
    'Client',
    'Capacity',
    'Mobile number',
    'Status',
    'license',
    'Subscription Fee',
    'Devices',
    'Effective Date',
    'Expiry Date',
  ];
}

/// PERMISSION BASED ACCESS-CONTROL
enum Permission { read, write, execute }

/// Function to convert enum values to a list of strings [workspaceRolesToList]
List<String> workspaceRolesToList<T>() {
  // Convert the modified list to a list of strings
  return WorkspaceRole.values.map((e) => Workspace.roleAsString(e)).toList();
}

/// Permissions-Based Access-Control RolePermissions Class [RolePermissions]
class RolePermissions {
  final WorkspaceRole role;
  final Set<Permission> permissions;

  RolePermissions({required this.role, required this.permissions});
}

/// Set Up Permissions for Each Role [rolePermissions]
final Map<WorkspaceRole, RolePermissions> rolePermissions = {
  WorkspaceRole.agentFranchise: RolePermissions(
    role: WorkspaceRole.agentFranchise,
    permissions: {Permission.read, Permission.write, Permission.execute},
  ),
  WorkspaceRole.subscriber: RolePermissions(
    role: WorkspaceRole.subscriber,
    permissions: {Permission.read, Permission.write, Permission.execute},
  ),
  WorkspaceRole.developer: RolePermissions(
    role: WorkspaceRole.developer,
    permissions: {Permission.read, Permission.write, Permission.execute},
  ),
  // Define permissions for other roles...
};

/// Check Permissions [hasPermission]
bool hasPermission(Workspace work, Permission permission) {
  final rolePerms = rolePermissions[work.role];
  return rolePerms?.permissions.contains(permission) ?? false;
}

/* USAGE Example: Implement Permission-Access Control in Your App
  * final currentUser = Workspace(username: 'JohnDoe', role: UserRole.developer,  email: 'john.doe@example.com',);
  * if (hasPermission(currentUser, Permission.read))
              Text('You have read access.'),
  * if (hasPermission(currentUser, Permission.write))
              ElevatedButton(
                onPressed: () {},
                child: Text('Content Editor'),
              ),
  * if (hasPermission(currentUser, Permission.execute))
              ElevatedButton(
                onPressed: () {},
                child: Text('Content Editor'),
              ),
  * */

/* FIRESTORE IMPLEMENTATION OF ROLE-BASE:
*
* First, you need to define roles for your users. This typically involves storing
* role information either within Firestore or in Firebase Authentication custom claims.
*
* FIRESTORE-DB COLLECTION-STRUCTURE:
* {
  "users": {
  * // Users Collection: users/{userId}
    "userId1": {
      "username": "john_doe",
      "role": "administrator"
    },
    "userId2": {
      "username": "jane_smith",
      "role": "manager"
    }
    // Documents Collection: documents/{documentId}:
  }
}

* * FIRESTORE-DB SECURITY RULE
*
// Firestore Security Rules
*
* You can check the state of the authentication request itself, such as whether a user is authenticated or not.
* service cloud.firestore {
  match /databases/{database}/documents {
    match /documents/{documentId} {
      allow read: if request.auth != null && request.auth.token.email_verified == true;
    }
  }
}

*
* You can design more complex role-based access control by combining multiple roles and permissions.
service cloud.firestore {
  match /databases/{database}/documents {
    match /documents/{documentId} {
      allow read: if hasReadAccess() && isUserVerified();
      allow write: if hasWriteAccess() && isUserVerified();

      function isUserVerified() {
        return request.auth.token.email_verified == true;
      }

      function hasReadAccess() {
        return request.auth != null &&
               (isAdmin() || isManager() || isCollaborator());
      }

      function hasWriteAccess() {
        return request.auth != null &&
               (isAdmin() || isManager());
      }

      function isAdmin() {
        return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'administrator';
      }

      function isManager() {
        return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'manager';
      }

      function isCollaborator() {
        return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'collaborator';
      }
    }
  }
}

*
*
service cloud.firestore {
  match /databases/{database}/documents {

    // Allow access to the 'workspace' collection
    // workspaceId: is the ID assign company or firm that uses my software
    match /works_pace_auth_db/{workspaceId} {
      allow read, write: if request.auth != null && request.auth.uid == workspaceId && isUserVerified();
    }

    // General rules for documents based on roles
    match /documents/{documentId} {
      allow read: if hasReadAccess();
      allow write: if hasWriteAccess();
    }

    function isUserVerified() {
      return request.auth.token.email_verified == true;
    }

    function hasReadAccess() {
      return request.auth != null &&
             get(/databases/$(database)/documents/users_auth_db/$(request.auth.uid)).data.role in ['administrator', 'manager', 'developer'];
    }

    function hasWriteAccess() {
      return request.auth != null &&
             get(/databases/$(database)/documents/users_auth_db/$(request.auth.uid)).data.role in ['administrator', 'manager'];
    }
  }
}
*
* Practical Example::
* /databases/{database}/documents/projects/projectA — This is a document with ID projectA within the projects collection.
* /databases/{database}/documents/projects/projectB — This is another document with ID projectB within the projects collection.
*
* get(/databases/$(database)/documents/projects/$(projectId)).data.members[request.auth.uid] == true:
* Checks if the authenticated user (identified by request.auth.uid) is listed as a member of the project document being accessed. The members field in the document should be a map where each key is a user ID and the value is true if the user is a member.
*
* Suppose you have the following documents in your projects collection:
* Document projectA: {
  "members": {
    "user123": true,
    "user456": false
  },
  "admins": ["user123"]
}
*
* Document projectB:
* {
  "members": {
    "user123": false,
    "user789": true
  },
  "admins": ["user789"]
}
*
* How Rules Apply

* For projectA:
* A user with uid = user123 can read and write if authenticated, because user123 is in both the members and admins fields.
* A user with uid = user456 can read but cannot write, because user456 is not in the admins field.
* For projectB:
* A user with uid = user123 cannot read or write to projectB, because user123 is not listed as a member or admin for projectB.
* A user with uid = user789 can read and write to projectB, because user789 is listed as an admin and a member.
*
* service cloud.firestore {
  match /databases/{database}/documents {
    match /projects/{projectId} {
      allow read: if request.auth != null && get(/databases/$(database)/documents/projects/$(projectId)).data.members[request.auth.uid] == true;
      allow write: if request.auth != null && request.auth.uid in get(/databases/$(database)/documents/projects/$(projectId)).data.admins;
    }
  }
}


* * DATA-REPOSITORY IMPLEMENTATION:
*
*
// Function to get documents based on user role
Future<void> fetchDocumentsBasedOnRole() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userSnapshot = await userDoc.get();

    if (userSnapshot.exists) {
      final userRole = userSnapshot.data()?['role'];
      QuerySnapshot documentsSnapshot;

      if (userRole == 'administrator' || userRole == 'manager') {
        documentsSnapshot = await FirebaseFirestore.instance.collection('documents').get();
      } else if (userRole == 'developer') {
        documentsSnapshot = await FirebaseFirestore.instance.collection('documents').where('category', isEqualTo: 'development').get();
      } else {
        documentsSnapshot = await FirebaseFirestore.instance.collection('documents').where('visibility', isEqualTo: 'public').get();
      }

      // Handle the documents snapshot
      documentsSnapshot.docs.forEach((doc) {
        print(doc.data());
      });
    }
  }
}

* */
