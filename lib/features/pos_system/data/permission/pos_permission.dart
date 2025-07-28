import 'package:assign_erp/core/network/data_sources/models/permission_item_model.dart';
import 'package:assign_erp/features/setup/data/models/employee_model.dart';
import 'package:assign_erp/features/setup/data/models/role_permission_model.dart';
import 'package:assign_erp/features/setup/data/role/employee_role.dart';

/// PERMISSION BASED ACCESS-CONTROL
/*enum PosPermission {
  createPosSale,
  viewSalesHistory,
  applyDiscount,
  refundTransaction,
  holdSale,
  reopenSale,
  reprintReceipt,
  manageCashDrawer,
  closeRegister,
  openRegister,
  viewZReports,
  exportSalesData,
}
*/
enum PosPermission {
  // fullAccess,
  createPosSale,
  viewPosSale,
  updatePosSale,
  deletePosSale,
  applyDiscount,
  // Order
  viewPosOrder,
  createPosOrder,
  updatePosOrder,
  deletePosOrder,
  // Customer
  createPosCustomer,
  viewPosCustomer,
  updatePosCustomer,
  deletePosCustomer,
  // Inventory
  viewPosInventory,
  createPosInventory,
  updatePosInventory,
  deletePosInventory,
  // Transaction
  reprintReceipt,
  viewSalesHistory,
  viewPosReport,
}

final List<PermissionItem> _salesPermissions = [
  // Sales
  PermissionItem(
    module: "pos sales",
    title: "Create new sales",
    subtitle: "Allow users to process new sales at any location.",
    permission: PosPermission.createPosSale,
  ),
  PermissionItem(
    module: "pos sales",
    title: "View sales records",
    subtitle: "Allow access to a list of all completed sales.",
    permission: PosPermission.viewPosSale,
  ),
  PermissionItem(
    module: "pos sales",
    title: "Edit existing sales",
    subtitle: "Allow users to modify details of an existing sale.",
    permission: PosPermission.updatePosSale,
  ),
  PermissionItem(
    module: "pos sales",
    title: "Delete sales",
    subtitle: "Allow users to permanently remove a sale record.",
    permission: PosPermission.deletePosSale,
  ),
  PermissionItem(
    module: "pos",
    title: "Apply Discount",
    subtitle: "Allow users to apply discounts to items or total.",
    permission: PosPermission.applyDiscount,
  ),
];

final List<PermissionItem> _ordersPermissions = [
  PermissionItem(
    module: "pos orders",
    title: "View order details",
    subtitle: "Allow access to a list of placed and fulfilled orders.",
    permission: PosPermission.viewPosOrder,
  ),
  PermissionItem(
    module: "pos orders",
    title: "Create new orders",
    subtitle: "Allow users to place new customer orders.",
    permission: PosPermission.createPosOrder,
  ),
  PermissionItem(
    module: "pos orders",
    title: "Edit existing orders",
    subtitle: "Allow users to update order details or statuses.",
    permission: PosPermission.updatePosOrder,
  ),
  PermissionItem(
    module: "pos orders",
    title: "Delete orders",
    subtitle: "Allow users to delete orders from the system.",
    permission: PosPermission.deletePosOrder,
  ),
];

final List<PermissionItem> _customersPermissions = [
  PermissionItem(
    module: "pos customers",
    title: "View customers",
    subtitle: "Allow access to customer lists, profiles, and contact details.",
    permission: PosPermission.viewPosCustomer,
  ),
  PermissionItem(
    module: "pos customers",
    title: "Add new customers",
    subtitle: "Allow users to create new customer records.",
    permission: PosPermission.createPosCustomer,
  ),
  PermissionItem(
    module: "pos customers",
    title: "Edit customer information",
    subtitle: "Allow updates to customer contact info, tags, and notes.",
    permission: PosPermission.updatePosCustomer,
  ),
  PermissionItem(
    module: "pos customers",
    title: "Delete customers",
    subtitle: "Allow permanent removal of customer records from the system.",
    permission: PosPermission.deletePosCustomer,
  ),
];

final List<PermissionItem> _inventoryPermissions = [
  PermissionItem(
    module: "pos inventory",
    title: "View inventory",
    subtitle:
        "Allow access to inventory items, stock levels, and product details.",
    permission: PosPermission.viewPosInventory,
  ),
  PermissionItem(
    module: "pos inventory",
    title: "Add new inventory items",
    subtitle: "Allow users to create new products or stock items.",
    permission: PosPermission.createPosInventory,
  ),
  PermissionItem(
    module: "pos inventory",
    title: "Edit inventory items",
    subtitle: "Allow users to update product names, prices, or stock details.",
    permission: PosPermission.updatePosInventory,
  ),
  PermissionItem(
    module: "pos inventory",
    title: "Delete inventory items",
    subtitle: "Allow users to remove items from the inventory database.",
    permission: PosPermission.deletePosInventory,
  ),
];

final List<PermissionItem> _metricsPermissions = [
  PermissionItem(
    module: "pos transactions",
    title: "Print receipts",
    subtitle: "Allow users to view customer receipts and print copies.",
    permission: PosPermission.reprintReceipt,
  ),
  PermissionItem(
    module: "pos transactions",
    title: "View Sales History",
    subtitle: "Allow users to browse past sales transactions.",
    permission: PosPermission.viewSalesHistory,
  ),
  PermissionItem(
    module: "pos transactions",
    title: "Access reports and analytics",
    subtitle: "Allow users to access sales, order, and product reports.",
    permission: PosPermission.viewPosReport,
  ),
];

final posDisplayName = 'point of sales';

final List<PermissionItem> posPermissions = [
  ..._salesPermissions,
  ..._ordersPermissions,
  ..._customersPermissions,
  ..._inventoryPermissions,
  ..._metricsPermissions,
];

/// Set Up Permissions for Each Role [rolePermissions]
final Map<EmployeeRole, RolePermissionContext<PosPermission>> rolePermissions =
    {
      EmployeeRole.storeOwner: RolePermissionContext<PosPermission>(
        role: EmployeeRole.storeOwner,
        permissions: PosPermission.values.toSet(),
      ),
      EmployeeRole.manager: RolePermissionContext<PosPermission>(
        role: EmployeeRole.manager,
        permissions: PosPermission.values.toSet(),
      ),
      EmployeeRole.developer: RolePermissionContext<PosPermission>(
        role: EmployeeRole.developer,
        permissions: PosPermission.values.toSet(),
      ),
      EmployeeRole.tester: RolePermissionContext<PosPermission>(
        role: EmployeeRole.tester,
        permissions: {PosPermission.createPosSale},
      ),
    };

/// Check Permissions [hasPOSPermission]
bool hasPOSPermission(Employee employee, {required PosPermission perm}) {
  final rolePerms = rolePermissions[employee.role];
  return hasPermission<PosPermission>(rolePerms, perm: perm);
}

/* USAGE Example: Implement Permission-Access Control in Your App
  * final currentUser = Employee(userpermission: 'JohnDoe', role: EmployeeRole.developer,  email: 'john.doe@example.com',);
  * if (hasPermission(currentUser, perm: Permission.read))
              Text('You have read access.'),
  * if (hasPermission(currentUser, perm: Permission.write))
              ElevatedButton(
                onPressed: () {},
                child: Text('Content Editor'),
              ),
  * if (hasPermission(currentUser, perm: Permission.execute))
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
