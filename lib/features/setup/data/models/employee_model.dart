import 'package:assign_erp/core/constants/account_status.dart';
import 'package:assign_erp/core/util/format_date_utl.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:equatable/equatable.dart';

var _today = DateTime.now();

/// Role-Based Access-Control [Employee]
class Employee extends Equatable {
  final String id;
  final String storeNumber;
  final String workspaceId;
  final String fullName;
  final String mobileNumber;
  final String username;
  final EmployeeRole role;
  final String email;
  final String status;

  /// Assign Roles to Users [role]
  final String passCode; // or password
  final String createdBy;
  final String updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Employee({
    this.id = '',
    required this.workspaceId,
    this.storeNumber = '', // mainStore,
    this.username = '',
    required this.fullName,
    required this.mobileNumber,
    required this.role,
    required this.email,
    required this.status,
    this.passCode = '',
    this.createdBy = '',
    DateTime? createdAt,
    this.updatedBy = '',
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? _today,
       updatedAt = updatedAt ?? _today; // Set default value

  static const String cacheKey = 'employee_auth_cache';

  /// fromFirestore / fromJson Function [Employee.fromMap]
  factory Employee.fromMap(Map<String, dynamic> map, {String? id}) {
    return Employee(
      id: (id ?? map['id']) ?? '',
      workspaceId: map['workspaceId'] ?? '',
      storeNumber: map['storeNumber'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      username: map['username'].toString().emailToUsername,
      role: getRoleByString(map['role']),
      status: map['status'] ?? AccountStatus.disabled.label,
      passCode: map['passCode'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: toDateTimeFn(map['createdAt']),
      updatedBy: map['updatedBy'] ?? '',
      updatedAt: toDateTimeFn(map['updatedAt']),
    );
  }

  static EmployeeRole getRoleByString(String role) =>
      EmployeeRole.values.firstWhere((e) => roleAsString(e) == role);

  static String roleAsString(EmployeeRole e) => e.toString().split('.').last;

  // map template
  Map<String, dynamic> _mapTemp() => {
    'id': id,
    'workspaceId': workspaceId,
    'storeNumber': storeNumber,
    'username': email.emailToUsername,
    // Convert enum to string
    'role': roleAsString(role),
    'email': email,
    'fullName': fullName,
    'mobileNumber': mobileNumber,
    'passCode': passCode,
    'status': status,
    'createdBy': createdBy,
    'createdAt': createdAt,
    'updatedBy': updatedBy,
    'updatedAt': updatedAt,
  };

  /// Convert Employee to a map for storing in Firestore [toMap]
  Map<String, dynamic> toMap() {
    var newMap = _mapTemp();
    newMap['createdAt'] = createdAt.toISOString;
    newMap['updatedAt'] = updatedAt.toISOString;

    return newMap;
  }

  /// Convert Employee to toCache Function [toCache]
  Map<String, dynamic> toCache() {
    var newMap = _mapTemp();
    newMap['createdAt'] = createdAt.millisecondsSinceEpoch;
    newMap['updatedAt'] = updatedAt.millisecondsSinceEpoch;

    return {'id': cacheKey, 'data': newMap};
  }

  Employee copyWith({
    String? id,
    String? storeNumber,
    String? username,
    String? fullName,
    String? mobileNumber,
    EmployeeRole? role,
    String? email,
    String? status,
    String? workspaceId,
    String? updatedBy,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      storeNumber: storeNumber ?? this.storeNumber,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      role: role ?? this.role,
      email: email ?? this.email,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  /// Check if 'CreatedAt' DateTime is within one week after it was created [isWithinOneWeek]
  bool isWithinOneWeek() {
    // Calculate the date and time one week from now
    DateTime oneWeekFromNow = _today.add(const Duration(days: 7));

    // Check if its greater than now/today but less than a week
    return createdAt.isAfter(_today) && createdAt.isBefore(oneWeekFromNow);
  }

  /// Verified Status [isActive]
  bool get isActive => status == AccountStatus.enabled.label;

  /// Formatted to Standard-DateTime in String [getCreatedAt]
  String get getCreatedAt => createdAt.toStandardDT;

  /// Formatted to Standard-DateTime in String [getUpdatedAt]
  String get getUpdatedAt => updatedAt.toStandardDT;

  /// Formatted to Standard-DateTime in String [getUpdatedAt]
  bool get isEmployee =>
      role != EmployeeRole.manager ||
      role != EmployeeRole.developer ||
      role != EmployeeRole.tester;

  /// [findById]
  static Iterable<Employee> findById(List<Employee> employees, String id) =>
      employees.where((employee) => employee.id == id);

  static List<Employee> filterStatus(
    List<Employee> employees, {
    bool isActive = false,
  }) => employees
      .where((employee) => isActive ? employee.isActive : !employee.isActive)
      .toList();

  /* USAGE Example: Implement Role-Based Access in Your App
  * final currentUser = Employee(username: 'JohnDoe', role: EmployeeRole.developer,  email: 'john.doe@example.com',);
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
  bool canAccessAdminDashboard(Employee user) =>
      user.role == EmployeeRole.administrator;

  bool canEditContent(Employee user) =>
      user.role == EmployeeRole.administrator ||
      user.role == EmployeeRole.contentEditor;

  @override
  List<Object?> get props => [
    id,
    workspaceId,
    role,
    email,
    username,
    fullName,
    mobileNumber,
    passCode,
    status,
    storeNumber,
    createdBy,
    createdAt,
    updatedBy,
    updatedAt,
  ];

  /// ToList for PRODUCTS [itemAsList]
  List<String> itemAsList() => [
    email,
    id,
    fullName.toUppercaseFirstLetterEach,
    role.name.toUppercaseFirstLetterEach,
    mobileNumber,
    storeNumber.toUppercaseFirstLetterEach,
    status.toUppercaseFirstLetterEach,
    getCreatedAt,
    createdBy.toUppercaseFirstLetterEach,
    updatedBy.toUppercaseFirstLetterEach,
    getUpdatedAt,
  ];

  static List<String> get dataTableHeader => const [
    'Email',
    'ID',
    'Name',
    'Position',
    'Mobile number',
    'Store number',
    'Status',
    'Create At',
    'Created By',
    'Updated By',
    'Updated At',
  ];
}

/*const appRoles = [
  'admin',
  'sales',
  'hr',
  'it',
  'auditor',
  'finance',
  'manager',
  'ceo',
];

const appPermissions = [
  'admin', // Full access
  'user', // Read-only access
  'sales', //
  'hr',
  'it',
  'auditor',
  'finance',
  'manager', // Create, read, update, delete (CRUD)
  'ceo',
];
*/
enum EmployeeRole {
  /* Read-only access, typically for general users interacting with the system.*/
  user,
  /* Full access to read, write, and handles the management of inventory levels, including stocking items, ordering new products, tracking stock levels*/
  stockControl,
  /* Full access to read, write, and handles orders; Sales order, Purchase order, Request for quote, misc orders.*/
  procurement,
  /* Full access to read, write, and execute operations.*/
  administrator,
  /* Read and write access, suitable for overseeing team and project data.*/
  manager,
  /* Read-only access, to assist with user support and troubleshooting.*/
  supportStaff,
  /* Read-only access, suitable for auditing and compliance checks.*/
  auditor,
  /* Read and write access, for analyzing and proposing system improvements.*/
  systemAnalyst,
  /* Read-only access, to analyze and interpret data.*/
  dataAnalyst,
  /* Read-only access, to ensure compliance with regulations.*/
  complianceOfficer,
  /* Read and write access, to create and manage content.*/
  contentEditor,
  /* Read and write access, for managing marketing campaigns and materials.*/
  marketing,
  /* Read and write access, for handling financial data and transactions.*/
  finance,
  /* Read and write access, for handling products or services sales.*/
  sale,
  /* Read and write access, for handling payment.*/
  cashier,
  /* Read and write access, for handling products delivery.*/
  delivery,
  /* Read and write access, to manage employee records and HR processes.*/
  hrManager,
  /* Read and write access, to resolve technical issues and maintain system settings.*/
  itSupport,
  /*  Full access to read, write, and execute, for development tasks and managing code.*/
  developer,
  /* Read-only access, primarily for testing purposes.*/
  tester,
}

/// Function to convert enum values to a list of strings [employeeRolesToList]
List<String> employeeRolesToList<T>() {
  // Convert the unmodifiable list to a modifiable list
  List<EmployeeRole> modifiableRoles = List.from(EmployeeRole.values);

  // Remove the unwanted roles
  modifiableRoles
    ..remove(EmployeeRole.developer)
    ..remove(EmployeeRole.tester);

  // Convert the modified list to a list of strings
  return modifiableRoles.map((e) => Employee.roleAsString(e)).toList();
}

/// PERMISSION BASED ACCESS-CONTROL
enum Permission { read, write, execute }

/// Permissions-Based Access-Control RolePermissions Class [RolePermissions]
class RolePermissions {
  final EmployeeRole role;
  final Set<Permission> permissions;

  RolePermissions({required this.role, required this.permissions});
}

/// Set Up Permissions for Each Role [rolePermissions]
final Map<EmployeeRole, RolePermissions> rolePermissions = {
  EmployeeRole.administrator: RolePermissions(
    role: EmployeeRole.administrator,
    permissions: {Permission.read, Permission.write, Permission.execute},
  ),
  EmployeeRole.manager: RolePermissions(
    role: EmployeeRole.manager,
    permissions: {Permission.read, Permission.write},
  ),
  EmployeeRole.user: RolePermissions(
    role: EmployeeRole.user,
    permissions: {Permission.read},
  ),
  EmployeeRole.developer: RolePermissions(
    role: EmployeeRole.developer,
    permissions: {Permission.read, Permission.write, Permission.execute},
  ),
  EmployeeRole.tester: RolePermissions(
    role: EmployeeRole.tester,
    permissions: {Permission.read},
  ),
  EmployeeRole.supportStaff: RolePermissions(
    role: EmployeeRole.supportStaff,
    permissions: {Permission.read},
  ),
  // Define permissions for other roles...
};

/// Check Permissions [hasPermission]
bool hasPermission(Employee employee, Permission permission) {
  final rolePerms = rolePermissions[employee.role];
  return rolePerms?.permissions.contains(permission) ?? false;
}

/* USAGE Example: Implement Permission-Access Control in Your App
  * final currentUser = Employee(username: 'JohnDoe', role: EmployeeRole.developer,  email: 'john.doe@example.com',);
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
