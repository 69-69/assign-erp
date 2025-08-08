import 'dart:async';

import 'package:assign_erp/config/routes/route_logger.dart';
import 'package:assign_erp/core/constants/account_status.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/constants/app_db_collect.dart';
import 'package:assign_erp/core/constants/collection_type_enum.dart';
import 'package:assign_erp/core/network/data_sources/remote/repository/firestore_helper.dart';
import 'package:assign_erp/core/network/data_sources/remote/repository/firestore_repository.dart';
import 'package:assign_erp/core/result/result_data.dart';
import 'package:assign_erp/core/util/debug_printify.dart';
import 'package:assign_erp/core/util/device_info_service.dart';
import 'package:assign_erp/core/util/format_date_utl.dart';
import 'package:assign_erp/core/util/secret_hasher.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/features/auth/data/data_sources/local/auth_cache_service.dart';
import 'package:assign_erp/features/auth/data/data_sources/remote/geo_location_service.dart';
import 'package:assign_erp/features/auth/data/model/workspace_model.dart';
import 'package:assign_erp/features/auth/data/role/workspace_role.dart';
import 'package:assign_erp/features/auth/presentation/bloc/auth_status_enum.dart';
import 'package:assign_erp/features/setup/data/models/attendance_model.dart';
import 'package:assign_erp/features/setup/data/models/employee_model.dart';
import 'package:assign_erp/features/setup/data/permission/setup_permission.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// User? authUser = FirebaseAuth.instance.currentUser;

/// Using dynamicLinkDomain in Desktop Applications
/// Custom URL Schemes
/// Example Workflow for Desktop Apps
/// Example of Using ActionCodeSettings
/// Alternatives to Firebase Dynamic Links
/// Universal Links (iOS) and App Links (Android)
///
class AuthRepository extends FirestoreRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore firestore;
  final RouteLogger routeLogger;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    required this.firestore,
    required this.routeLogger,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       super(
         firestore: firestore,
         collectionRef: firestore.collection(workspaceAccDBCollectionPath),
       );

  final _controller = StreamController<AuthStatus>.broadcast();

  User? get firebaseUser => _firebaseAuth.currentUser;
  final AuthCacheService _authCacheService = AuthCacheService();

  /// Stream FirebaseAuth AuthState Changes [firebaseAuthStateChanges]
  Stream<User?> get firebaseAuthStateChanges =>
      _firebaseAuth.authStateChanges();

  /// Stream AuthStatus Changes [authStatusChanges]
  Stream<AuthStatus> get authStatusChanges async* {
    await Future<void>.delayed(kRProgressDelay);

    yield (firebaseUser?.uid ?? '').isNotEmpty
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;

    yield* _controller.stream;
  }

  /// A temporary variable to hold new-user's Workspace ID & Agent ID
  String _newWorkspaceId = '';
  String _registrarAgentId = '';

  Future<Workspace?> getWorkspace({String? uid}) async {
    try {
      final id = uid ?? firebaseUser?.uid;
      if (id == null) {
        return null;
      }

      // Try to get the workspace from the cache
      Workspace? cacheWorkspace = _getWorkspaceCache();
      if (cacheWorkspace != null || cacheWorkspace!.unExpired) {
        return cacheWorkspace;
      }

      // else, Fetch the workspace from remote source
      final docSnapshot = await findById(id);

      // Check if the document exists and is not empty
      if (docSnapshot.exists && !docSnapshot.data().isNullEmpty) {
        final workspace = Workspace.fromMap(docSnapshot.data()!);

        if (workspace.isExpired) return null;

        // Write to cache
        await _cacheWorkspace(workspace);
        return workspace;
      }

      // Return null if no valid data found
      return null;
    } catch (e /*, stackTrace*/) {
      _handleAuthException("An error occurred during sign-in.");
      return null; // Return null or handle the exception according to your needs
    }
  }

  Future<Employee?> getEmployee() async {
    try {
      // Try to get the Employee from the cache
      Employee? cacheEmployee = _getEmployeeCache();
      if (cacheEmployee != null &&
          cacheEmployee.status == AccountStatus.enabled.label &&
          cacheEmployee.workspaceId == firebaseUser?.uid) {
        return cacheEmployee;
      }

      // Return null if the document does not exist or is empty
      return null;
    } catch (e /*, stackTrace*/) {
      _handleAuthException("An error occurred during sign-in.");
      return null; // Return null or handle the exception according to your needs
    }
  }

  Workspace? _getWorkspaceCache() => _authCacheService.getWorkspace();

  Employee? _getEmployeeCache() => _authCacheService.getEmployee();

  /// [assignWorkspaceRole] Determines the role for a "New Workspace Setup" based on the
  /// currently signed-in user's role (cached workspace role).
  ///
  /// - NOTE: `WorkspaceRole.onboarding` role is used as first-time login during initial APP or WorkSpace setup.
  ///
  /// Role Assignment Logic:
  /// - If the currently signed-in workspace's role is:
  ///   - `onboarding`, assigns `WorkspaceRole.agentFranchise`.
  ///   - `agentFranchise`, assigns `WorkspaceRole.subscriber`.
  ///   - `developer`, retains `WorkspaceRole.developer`.
  ///   - If the role is `null`, defaults to `WorkspaceRole.subscriber`.
  ///
  /// Used during the "Setup/Create New Workspace" flow. [assignWorkspaceRole]
  WorkspaceRole get assignWorkspaceRole {
    Workspace? cacheWorkspace = _getWorkspaceCache();

    return switch (cacheWorkspace?.role) {
      WorkspaceRole.onboarding => WorkspaceRole.agentFranchise,
      WorkspaceRole.agentFranchise => WorkspaceRole.subscriber,
      WorkspaceRole.developer => WorkspaceRole.developer,
      _ => WorkspaceRole.subscriber,
    };
  }

  Future<void> _cacheWorkspace(Workspace workspace) async =>
      await _authCacheService.setWorkspace(workspace);

  Future<void> _cacheEmployee(Employee employee) async =>
      await _authCacheService.setEmployee(employee);

  Future<Result<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _validateWorkspaceAccess(String email) async {
    try {
      // Fetch the workspace document by email
      final doc = await _fetchWorkspaceByEmail(email);

      // workspace not created
      if (doc == null) {
        return Failure(
          message:
              '$errorPrefix:Email is not associated with any existing workspace.',
        );
      }

      // Convert doc data to Workspace
      final workspace = Workspace.fromMap(doc.data());

      // Validate workspace and license status
      if (workspace.isExpired || workspace.subscriptionId.isEmpty) {
        return Failure(
          message: '$errorPrefix:Software is unlicensed / expired',
        );
      }

      final userDeviceId = await DeviceInfoService.getDeviceId();

      // Device-Id not previously authorized, else skip
      if (!workspace.isDeviceAuthorized(userDeviceId)) {
        if (workspace.isDeviceLimitReached) {
          return Failure(
            message: '$errorPrefix:Upgrade your Plan: Too many devices in use',
          );
        }

        // Add current deviceId to authorized list
        await updateById(
          doc.id,
          data: {
            'authorizedDeviceIds': FieldValue.arrayUnion([userDeviceId]),
            /* Remove an item from the array
            'authorizedDeviceIds': FieldValue.arrayRemove([userDeviceId]),*/
          },
        );
      }

      return Success(data: doc);
    } catch (e) {
      _handleAuthException("An error occurred during sign-in.");

      return Failure(message: 'An error occurred during sign-in.');
    }
  }

  /// [workspaceSignIn] Signs a user into their Workspace account using email and password.
  ///
  /// - Retrieves the workspace document by [email].
  /// - Verifies that the license is active and the account is enabled.
  /// - Ensures the current device is within the allowed list.
  /// - Attempts to authenticate the user using Firebase Authentication.
  /// - If successful, returns the authenticated [Workspace] object.
  ///
  /// Returns a [Future] containing a record of:
  /// - `workspace`: the signed-in [Workspace] object (nullable).
  /// - `message`: an optional message in case of failure.
  ///
  /// Possible failure messages include:
  /// - `Software is unlicensed / expired`
  /// - `Device is unauthorized`
  /// - `Extend Your License: Too many devices in use`
  /// - `Invalid email or password`
  /// - `Please verify your email...`
  Future<({Workspace? workspace, String? message})> workspaceSignIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _validateWorkspaceAccess(email);
      if (result is Failure) {
        return (workspace: null, message: (result as Failure).message);
      }

      // Attempt to sign in with Firebase
      final userCredential = await _signInUser(email, password);
      if (userCredential == null) {
        return (workspace: null, message: 'Invalid email or password');
      }
      final user = userCredential.user;

      // Check if the user's email is verified
      if (user != null && !user.emailVerified) {
        // Send email verification and notify the user
        await _sendEmailVerification(user);
        _handleAuthException(
          "Please verify your email. A verification link has been sent to $email.",
        );
      }

      // Extract data from the document
      final doc = (result as Success).data;
      final data = doc.data();

      // Convert the data to a Workspace object
      final workspace = Workspace.fromMap(data, id: doc.id);

      // Cache the workspace data for future use
      await _cacheWorkspace(workspace);

      await _logAuthSession(
        workspace.id,
        'sign-in',
        name: workspace.name,
        colPath: workspaceSessionLogsCollectionPath,
      );

      _controller.add(AuthStatus.workspaceAuthenticated);

      // Return the Workspace object
      return (workspace: workspace, message: '');
    } on FirebaseAuthException catch (e) {
      // Handle Firebase authentication exceptions with a specific message
      _handleAuthException(
        e,
        message: e.message ?? "An error occurred during sign-in.",
      );
      return (
        workspace: null,
        message: e.message ?? 'An error occurred during sign-in.',
      );
    } catch (e) {
      // Handle any other exceptions with a general message
      _handleAuthException("An unexpected error occurred: $e");
      return (workspace: null, message: 'An unexpected error occurred');
    }
  }

  /*/// Remove device ID from a user's authorized device list.
  Future<void> revokeDeviceFromAuthorizedList({
    required String deviceId,
    required String email,
  }) async {
    final doc = await _fetchWorkspaceUserByEmail(email);

    if (doc == null) return;

    await updateById(
      doc.id,
      data: {
        'authorizedDeviceIds': FieldValue.arrayRemove([deviceId]),
      },
    );
  }*/

  /// Signs in an employee using their email and passcode.
  /// Returns a tuple with the `employee` and `workspace` if successful, otherwise `null` for both.
  ///
  /// [email] - The email address of the employee.
  /// [passCode] - The passcode used for authentication.
  ///
  /// Returns a [Future] containing a tuple with optional `Employee` and `Workspace` objects.
  Future<({Employee? employee, Workspace? workspace, String? message})>
  employeeSignIn({required String email, required String passCode}) async {
    const invalid = (employee: null, workspace: null, message: '');

    try {
      // Fetch Employee document using email and passcode
      final result = await _fetchEmployeeByEmailPasscode(email, passCode);

      if (result is Failure) {
        return (
          employee: null,
          workspace: null,
          message: (result as Failure).message,
        );
      }
      // Get the workspace of the currently authenticated user
      final workspace = firebaseUser;

      // Check if the workspace is available, document is not null, and status is active
      if (workspace == null) {
        return invalid;
      }

      // Extract data from the document
      final doc = (result as Success).data;
      final data = doc.data();

      // Convert the data to an Employee object
      final employee = Employee.fromMap(data, id: doc.id);

      if (employee.status != AccountStatus.enabled.label ||
          employee.workspaceId != workspace.uid ||
          employee.roleId.isEmpty) {
        return invalid;
      }

      // Cache the employee data
      await _cacheEmployee(employee);

      /// Determines whether the provided passcode is a Temporary passcode.
      ///
      /// If [isTemporaryPasscode] is `true`, the user should be prompted to create
      /// a new permanent passcode. Otherwise, the user can be routed to the home dashboard.
      bool isTemporaryPasscode = passCode.startsWith(kTemporaryPasscodePrefix);

      // Retrieve the workspace user details
      final workspaceUser = await getWorkspace(uid: workspace.uid);

      final status = isTemporaryPasscode
          ? AuthStatus.hasTemporaryPasscode
          : AuthStatus.authenticated;

      _controller.add(status);

      // Return the employee and workspace objects
      return (employee: employee, workspace: workspaceUser, message: '');
    } on FirebaseAuthException catch (e) {
      // Handle Firebase authentication exceptions
      _handleAuthException(
        e,
        message: e.message ?? "An error occurred during employee sign-in.",
      );
      return invalid;
    } catch (e) {
      // Handle any other types of exceptions
      _handleAuthException("An unexpected error occurred: $e");
      return invalid;
    }
  }

  /// Changes the temporary PassCode for employee.
  ///
  /// [workspaceId] - The unique identifier of the employee whose passcode needs to be updated.
  /// [newPasscode] - The new passcode to be set for the employee.
  ///
  /// This method performs the following steps:
  /// 1. Fetch the employee info using the provided [workspaceId] and a workspace ID.
  /// 2. Hashes the provided [newPasscode] using the `PasswordHash.hashPassword` method to ensure security.
  /// 3. Updates the employee with the hashed passcode.
  Future<({Employee? employee, Workspace? workspace})>
  changeEmployeeTemporaryPassCode({required String newPasscode}) async {
    final invalid = (employee: null, workspace: null);

    try {
      // Try to get the workspace from the cache
      Workspace? cacheWorkspace = _getWorkspaceCache();
      Employee? cacheEmployee = _getEmployeeCache();

      if (cacheWorkspace == null || cacheEmployee == null) {
        return invalid;
      }

      final docRef = _genericCollection(
        workspaceRole: getEnumName<WorkspaceRole>(cacheWorkspace.role),
        workspaceId: cacheWorkspace.id,
      ).doc(cacheEmployee.id);

      if (docRef.id.isNotEmpty) {
        // Hash the new passcode to enhance security and prevent it from being exposed
        final hashPasscode = SecretHasher.hash(newPasscode);

        // Update the employee document with the hashed passcode
        await docRef.update({'passCode': hashPasscode});

        // Retrieve the workspace user details
        final workspace = await getWorkspace();
        final employee = await getEmployee();

        _controller.add(AuthStatus.authenticated);
        // Return the employee and workspace objects
        return (employee: employee, workspace: workspace);
      }

      _controller.add(AuthStatus.unauthenticated);
      return invalid;
    } catch (e) {
      // Handle any other types of exceptions
      _handleAuthException("An unexpected error occurred: $e");

      return invalid;
    }
  }

  /// Creates a new workspace by registering a user and setting up related data.
  ///
  /// [email] - The email address for the new user.
  /// [fullName] - The full name of the new user.
  /// [password] - The password for the new user.
  /// [mobileNumber] - The mobile number of the new user.
  /// [createWorkspace]
  /// Returns a [Future<bool>] indicating whether the workspace creation was successful.
  Future<bool> createWorkspace({
    required String workspaceName,
    required String email,
    required String fullName,
    required String password,
    required String mobileNumber,
    required String workspaceCategory,
    required String employeeTemporaryPasscode,
  }) async {
    try {
      // Store  agent ID temporarily, so we don't loose it when newUser is created
      _registrarAgentId = firebaseUser!.uid;

      // Create a new User via Firebase Authentication.
      final UserCredential userCredential = await _createUser(email, password);
      final User? newUser = userCredential.user;

      if (newUser != null && newUser.uid != _registrarAgentId) {
        // Store user ID temporarily, so we don't loose it when signOut
        _newWorkspaceId = newUser.uid;

        // Send email verification to the new newUser.
        await _sendEmailVerification(newUser);

        // Sign out immediately
        await _firebaseAuth.signOut();

        /* FOR LICENSED COMPANY SIGN-IN:
        * Create and save workspace data in Firestore Database (via Collection).*/
        await _createWorkspace(
          email: email,
          fullName: fullName,
          mobileNumber: mobileNumber,
          workspaceName: workspaceName,
          workspaceCategory: workspaceCategory,
          agentId: _registrarAgentId,
        );

        /* FOR COMPANY EMPLOYEE SIGN-IN:
        * Create and save employee data in Firestore Database (via Collection).*/
        await _createEmployee(
          email: email,
          fullName: fullName,
          mobileNumber: mobileNumber,
          createdBy: _registrarAgentId,
          employeePasscode: employeeTemporaryPasscode,
        );

        // Link Agent to their Tenants/Clients
        await _linkAgentToClientWorkspace(
          agentId: _registrarAgentId,
          clientWorkspaceId: _newWorkspaceId,
        );

        // SignOut current Workspace & Employee, if new Workspace setup was successfully
        await signOut();
        _controller.add(AuthStatus.unauthenticated);

        return true;
      }

      // Return false if newUser creation was unsuccessful.
      return false;
    } on FirebaseAuthException catch (e) {
      // Handle Firebase authentication errors.
      _handleAuthException(
        e,
        message: e.message ?? "An error occurred during sign-up.",
      );
      return false;
    } catch (e) {
      // Handle unexpected errors.
      _handleAuthException("An unexpected error occurred: ${e.toString()}");
      return false;
    }
  }

  /// Associates an agent with a client workspace.
  /// Firestore path: /agent_clients/{agentId}/clients/{clientWorkspaceId}
  Future<bool> _linkAgentToClientWorkspace({
    required String agentId,
    required String clientWorkspaceId,
  }) async {
    try {
      /// NOTE: workspaceId is used as agentId
      await _genericCollection(
        collectionType: CollectionType.global,
        collectionPath: agentClientsDBCollection,
      ).doc(agentId).collection('clients').doc(clientWorkspaceId).set({
        'clientWorkspaceId': clientWorkspaceId,
        'commission': [],
        'assignedAt': (DateTime.now()).toISOString,
      });

      return true;
    } on FirebaseException catch (e) {
      // Handle Firestore errors.
      _handleAuthException(
        e,
        message: e.message ?? "An error occurred while linking the client.",
      );
      return false;
    } catch (e) {
      // Handle unexpected errors.
      _handleAuthException("Unexpected error: ${e.toString()}");
      return false;
    }
  }

  /// Creates a new user in Firebase Authentication.
  ///
  /// [email] - The email address for the new user.
  /// [password] - The password for the new user.
  ///
  /// Returns a [Future<UserCredential>] with the result of the user creation. [_createUser]
  Future<UserCredential> _createUser(String email, String password) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Creates a new Workspace or updates an existing one in Firestore.
  ///
  /// This method sets up a new workspace for a client or customer, using the
  /// provided information. It assigns a default role and
  /// marks the license as unauthorized until verified.
  ///
  /// Parameters:
  /// - [workspaceName]: The name of the client's company or workspace.
  /// - [email]: The email address associated with the workspace.
  /// - [fullName]: The full name of the client or customer.
  /// - [mobileNumber]: The client's mobile phone number.
  /// - [workspaceCategory]: The type of business type (e.g., real estate, retail, logistics).
  /// - [agentId]: The ID of the agent who is creating or updating the workspace.
  ///
  /// Returns a [Future<void>]. [_createWorkspace]
  Future<void> _createWorkspace({
    required String email,
    required String fullName,
    required String mobileNumber,
    required String workspaceName,
    required String workspaceCategory,
    required String agentId,
  }) async {
    final aId = agentId.isNullOrEmpty ? _registrarAgentId : agentId;

    final workspace = Workspace(
      id: _newWorkspaceId,
      role: assignWorkspaceRole,
      email: email,
      agentId: aId,
      subscriptionId: '',
      name: workspaceName,
      clientName: fullName,
      mobileNumber: mobileNumber,
      category: workspaceCategory,
    );

    await overrideById(_newWorkspaceId, data: workspace.toMap());
  }

  /// Creates and saves employee data in Firestore.
  ///
  /// [user] - The newly created user who will be an employee.
  /// [fullName] - The full name of the new employee.
  /// [mobileNumber] - The mobile number of the new employee.
  /// [password] - The password for the new employee.
  ///
  /// Returns a [Future<void>] [_createEmployee]
  Future<void> _createEmployee({
    required String email,
    required String fullName,
    required String mobileNumber,
    required String createdBy,
    required String employeePasscode,
  }) async {
    final workspaceId = _newWorkspaceId;
    final empRole = getEnumName<WorkspaceRole>(assignWorkspaceRole);

    final role = await _defaultStoreOwnerPermissions(empRole, workspaceId);

    // Add a new document to the collection and get its reference
    final DocumentReference docRef = _genericCollection(
      workspaceRole: empRole,
      workspaceId: workspaceId,
    ).doc(); // Generates a new document reference with an auto-generated ID

    // Extract the document ID
    final String documentId = docRef.id;
    final byWho = await getEmployee();

    // Create an Employee instance with the document ID
    final Employee employee = Employee(
      id: documentId,
      workspaceId: workspaceId,
      roleId: role.id,
      role: role.name,
      email: email,
      fullName: fullName,
      mobileNumber: mobileNumber,
      storeNumber: mainStore,
      status: AccountStatus.enabled.label,
      createdBy: byWho?.fullName ?? createdBy,
      passCode: SecretHasher.hash(employeePasscode),
    );

    // Add the employee data to the Firestore collection
    await docRef.set(employee.toMap());
  }

  /// [_defaultStoreOwnerPermissions] This is the default permissions for the store owner
  /// during first-time workspace setup(Workspace Creation)
  Future<({String id, String name})> _defaultStoreOwnerPermissions(
    String workspaceRole,
    String workspaceId,
  ) async {
    final defaultPerm = defaultStoreOwnerPermissions;

    final docRef = await _genericCollection(
      workspaceId: workspaceId,
      workspaceRole: workspaceRole,
      collectionType: CollectionType.global,
      collectionPath: rolesDBCollectionPath,
    ).add(defaultPerm);

    return (id: docRef.id, name: defaultPerm['name'] as String);
  }

  /// Provides a [CollectionReference] for specified collection path.
  CollectionReference<Map<String, dynamic>> _genericCollection({
    String? workspaceId,
    String? workspaceRole,
    String? collectionPath,
    CollectionType collectionType = CollectionType.workspace,
  }) {
    // Create a FirestoreHelper instance with current workspace role and ID
    final fireHelper = FirestoreHelper(
      firestore: firestore,
      workspaceId: workspaceId,
      workspaceRole: workspaceRole,
    );
    final cPath = collectionPath ?? employeesDBCollectionPath;

    return fireHelper.getCollectionRef(collectionType: collectionType, cPath);
  }

  Future<bool> updateWorkspacePassword({required String newPassword}) async {
    try {
      if (firebaseUser != null) {
        await _updatePassword(newPassword);

        _controller.add(AuthStatus.authenticated);
        return true;
      }
      return false;
    } catch (e) {
      // Handle any other exceptions with a general message
      _handleAuthException("An unexpected error occurred: $e");
      return false;
    }
  }

  Future<bool> forgotWorkspacePassword({required String email}) async {
    try {
      // Fetch the workspace document based on the email
      final queryDocSnap = await _fetchWorkspaceByEmail(email);

      // Check if account is available and not expired
      if (queryDocSnap!.exists && !queryDocSnap.data().isNullEmpty) {
        final workspace = Workspace.fromMap(queryDocSnap.data());

        if (workspace.isExpired) return false;

        await _forgotPassword(email);
        return true;
      }

      return false;
    } catch (e) {
      // Handle any other types of exceptions
      _handleAuthException("An unexpected error occurred: $e");
      return false;
    }
  }

  Future<void> _updatePassword(String newPassword) async {
    try {
      await firebaseUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      _handleAuthException(
        e,
        message: e.message ?? "An error occurred while updating password.",
      );
    }
  }

  Future<void> _forgotPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      _handleAuthException(
        e,
        message:
            e.message ??
            "An error occurred while sending password reset email.",
      );
    }
  }

  // ignore: unused_element
  Future<void> _resendVerificationEmail(User user) async {
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      _handleAuthException(
        e,
        message:
            e.message ??
            "An error occurred while sending the verification email.",
      );
    }
  }

  // ignore: unused_element
  Future<void> _completeEmailVerification(String oobCode) async {
    try {
      await FirebaseAuth.instance.applyActionCode(oobCode);
      // debugPrint('Email successfully verified!');
    } on FirebaseAuthException catch (e) {
      Exception('Error verifying email: ${e.message}');
    }
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> _fetchWorkspaceByEmail(
    String email,
  ) async {
    final querySnapshot = await findOneByAny('email', term: email);
    if (querySnapshot.docs.isNotEmpty) {
      final snap = querySnapshot.docs.first;
      return snap.exists ? snap : null;
    }
    return null;
  }

  // Future<QueryDocumentSnapshot<Map<String, dynamic>>>
  Future<Result<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _fetchEmployeeByEmailPasscode(String email, String passCode) async {
    // Try to get the workspace from the cache
    Workspace? cacheWorkspace = _getWorkspaceCache();

    if (cacheWorkspace == null || cacheWorkspace.isExpired) {
      return Failure(
        message: '$errorPrefix:Workspace not found or license is unauthorized.',
      );
    }

    final workId = cacheWorkspace.id;
    final workRole = getEnumName<WorkspaceRole>(cacheWorkspace.role);

    final querySnap = await _genericCollection(
      workspaceId: workId,
      workspaceRole: workRole,
    ).where('email', isEqualTo: email).get();
    // .where('passCode', isEqualTo: PasswordHash.hashPassword(passCode))

    if (querySnap.docs.isEmpty) {
      return Failure(message: '$errorPrefix:Employee not found');
    }

    // Return the first document if available
    final doc = querySnap.docs.first;
    final data = doc.data();
    final storedHashPasscode = data['passCode'];

    // Compare the provided passCode with the stored hashed passCode
    final isSame = SecretHasher.verify(passCode, hashed: storedHashPasscode);
    if (!isSame) {
      return Failure(message: '$errorPrefix:Invalid Passcode.');
    }

    await _logAuthSession(
      doc.id,
      'sign-in',
      name: data['fullName'],
      workspaceId: workId,
      workspaceRole: workRole,
      colPath: employeeSessionLogsCollectionPath,
    );

    return Success(data: doc);
  }

  /// SignIn with email and password via Firebase Authentication.
  Future<UserCredential?> _signInUser(String email, String password) async {
    try {
      // Attempt to sign in the user with the provided email and password
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // If successful, return the UserCredential
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Use the utility method to get the error message
      final errorMessage = getFirebaseAuthErrorMessage(e);
      debugPrint(errorMessage);
      return null; // Return null if sign-in fails
    } catch (e) {
      // Handle any other errors
      debugPrint('An unexpected error occurred: $e');
      return null; // Return null if an unexpected error occurs
    }
  }

  /// Sends an email verification to the newly created user.
  ///
  /// [user] - The newly created user who will receive the verification email.
  ///
  /// Returns a [Future<void>]. [_sendEmailVerification]
  Future<void> _sendEmailVerification(User user) async {
    /*final ActionCodeSettings actionCodeSettings = ActionCodeSettings(
      // URL to redirect back to after email is verified
      url: 'https://yourapp.com/finishSignUp?user=${user.uid}',
      handleCodeInApp: true,
      // iOS
      iOSBundleId: 'com.example.ios',
      // Android
      androidPackageName: 'com.example.android',
      // Dynamic Link URL for web
      dynamicLinkDomain: 'example.page.link',
    );*/

    await user.sendEmailVerification(/*actionCodeSettings*/);
  }

  /// Log Workspace & Employee Auth Activity; Sign-In or Sign-Out. [_logAuthSession]
  Future<void> _logAuthSession(
    String id,
    String type, {
    String? name,
    String? colPath,
    String? workspaceId,
    String? workspaceRole,
  }) async {
    try {
      final geo = await GeoLocationService().getGeoLocation();

      final colType = workspaceRole == null
          ? CollectionType.global
          : CollectionType.workspace;

      final colRef = _genericCollection(
        collectionPath: colPath,
        collectionType: colType,
        workspaceId: workspaceId,
        workspaceRole: workspaceRole,
      ).doc();

      final areasViewed = routeLogger.visitedRoutes
          .map((e) => '${e.name} @ ${e.visitedAt.toStandardDT}')
          .toList();

      // Prepare log data
      final log = Attendance(
        id: colRef.id,
        type: type,
        userId: id,
        name: name ?? 'employee',
        ip: geo?.ip,
        city: geo?.city,
        region: geo?.region,
        areasViewed: areasViewed,
        location: geo != null ? GeoPoint(geo.latitude, geo.longitude) : null,
      );

      // Write to Firestore
      await colRef.set(log.toMap());

      prettyPrint('Attendance $type', 'logged successfully.');
    } catch (e) {
      prettyPrint('Failed to log attendance', '$e');
    }
  }

  void _handleAuthException(e, {String? message}) {
    throw Exception(message ?? e);
    // debugPrint('FirebaseAuthException: ${e.code} - ${e.message}\n');
    // debugPrint('Error Code: ${e.code}\n');
    // debugPrint('Error Message: ${e.message}\n');
    // debugPrint('Error Details: ${e.stackTrace}\n');
  }

  // Method to get error message based on FirebaseAuthException
  String getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    // debugPrint('Steve-Er:: ${e.code}');

    switch (e.code) {
      case 'user-not-found':
        return 'User not found. Please check your email and try again.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'Your account has been disabled due to too many failed login attempts. Please contact support.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'The operation is not allowed.';
      default:
        return 'Sign in failed: ${e.message}';
    }
  }

  // SignOut current Workspace & Employee
  Future<void> signOut() async {
    Future.wait([
      _logSignOut(),
      _authCacheService.deleteEmployee(),
      _authCacheService.deleteWorkspace(),
      _firebaseAuth.signOut(),
      // _controller.close(),
    ]);
  }

  // Log signOut sessions for tracking and analytics
  Future<void> _logSignOut() async {
    Workspace? cacheWorkspace = _getWorkspaceCache();
    Employee? cacheEmp = _getEmployeeCache();

    if (cacheWorkspace == null) return;

    final workId = cacheWorkspace.id;
    final workRole = getEnumName<WorkspaceRole>(cacheWorkspace.role);

    await _logAuthSession(
      firebaseUser?.uid ?? cacheWorkspace.id,
      'sign-out',
      name: cacheEmp?.fullName,
      workspaceId: workId,
      workspaceRole: workRole,
      colPath: employeeSessionLogsCollectionPath,
    );
  }

  void _closeController() {
    if (!_controller.isClosed) {
      _controller.close();
    }
  }

  // Add this method if using in a context where disposing is required
  void dispose() {
    _closeController();
  }
}
