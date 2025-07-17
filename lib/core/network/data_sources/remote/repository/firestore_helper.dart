import 'package:assign_erp/core/constants/collection_type_enum.dart';
import 'package:assign_erp/core/network/data_sources/models/workspace_role.dart';
import 'package:assign_erp/features/auth/data/data_sources/local/auth_cache_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  final AuthCacheService _authCacheService;
  final FirebaseFirestore _firestore;
  final String? _workspaceRole;
  final String? _workspaceId;

  FirestoreHelper({
    FirebaseFirestore? firestore,
    AuthCacheService? authCacheService,
    String? workspaceRole,
    String? workspaceId,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _authCacheService = authCacheService ?? AuthCacheService(),
       _workspaceRole = workspaceRole,
       _workspaceId = workspaceId;

  // Common Firestore sub-collection paths
  static const String chatsPath = 'chats';
  static const String storesPath = 'stores';
  static const String clientsPath = 'clients';

  /// [_workspaceDetails] Retrieves the current workspace role and ID.
  ///
  /// The workspace represents a user's group or organization. This method fetches the role and ID
  /// from the authentication cache service, which may return workspace details.
  ///
  /// Returns:
  /// - A tuple of two strings:
  ///   - workspace Role (e.g., subscriber, agentFranchise, developer, initialSetup)
  ///   - and workspace ID (e.g., "9789fs23fg2123").
  (String role, String id) get _workspaceDetails {
    final workspace = _authCacheService.getWorkspace();
    return (
      _workspaceRole ?? workspace?.role.name ?? WorkspaceRole.subscriber.label,
      _workspaceId ?? workspace?.id ?? '',
    );
  }

  /// Returns a collection reference based on [CollectionType].
  ///
  /// For specialized types (chats, stores, clients), this routes to their respective scoped references.
  /// Defaults to `CollectionType.workspace`,
  /// which builds the path as: `/workspaceRole/workspaceId/collectionPath`
  CollectionReference<Map<String, dynamic>> getCollectionRef(
    String collectionPath, {
    CollectionType collectionType = CollectionType.workspace,
  }) {
    return switch (collectionType) {
      CollectionType.workspace => _getWorkspaceRoleCollectionRef(
        collectionPath,
      ),
      CollectionType.global => _getGlobalCollectionRef(collectionPath),
      CollectionType.chats => getChatCollectionRef(collectionPath),
      CollectionType.stores => getStoresCollectionRef(collectionPath),
      CollectionType.clients => getAgentClientsCollectionRef(collectionPath),
    };

    /*// Determine whether to use a global collection reference or a workspace-scoped one.
    return useGlobalRef
        ? _getGlobalCollectionRef(collectionPath) // Global reference
        : _getWorkspaceCollectionRef(
            collectionPath,
          ); // Workspace-scoped reference*/
  }

  /// Returns a workspace-scoped collection reference: `/workspaceRole/workspaceId/collectionPath`
  CollectionReference<Map<String, dynamic>> _getWorkspaceRoleCollectionRef(
    String collectionPath,
  ) {
    final (role, id) = _workspaceDetails;

    return _firestore.collection(role).doc(id).collection(collectionPath);
  }

  /// Returns a top-level global collection reference: `/collectionPath`
  CollectionReference<Map<String, dynamic>> _getGlobalCollectionRef(
    String collectionPath,
  ) => _firestore.collection(collectionPath);

  /// Returns a collection inside a specific store (e.g. products, inventory).
  ///
  /// Example path: `/workspaceRole/workspaceId/stores/storeNumber/collectionPath`
  CollectionReference<Map<String, dynamic>> getStoresCollectionRef(
    String collectionPath,
  ) {
    final storeNumber = _authCacheService.getEmployee()?.storeNumber ?? '';

    // Collection('workspaceRole/workspaceId/stores/storeNumber/collectionPath')
    // Example: Collection('subscriber/3449854123s/stores/Store-46557-ER/products_db')
    return _getWorkspaceRoleCollectionRef(
      storesPath,
    ).doc(storeNumber).collection(collectionPath);
  }

  /// Returns the chat collection reference for the current workspace: `/collectionPath/workspaceId/chats`
  CollectionReference<Map<String, dynamic>> getChatCollectionRef(
    String collectionPath, {
    String? workspaceId,
  }) {
    // Use the provided client-workspaceId or the current workspace ID
    workspaceId ??= _workspaceDetails.$2;

    return _getGlobalCollectionRef(
      collectionPath,
    ).doc(workspaceId).collection(chatsPath);
  }

  /// Returns the agent-clients mapping reference: `/collectionPath/workspaceId/clients`
  CollectionReference<Map<String, dynamic>> getAgentClientsCollectionRef(
    String collectionPath,
  ) {
    final (_, id) = _workspaceDetails;
    return _getGlobalCollectionRef(
      collectionPath,
    ).doc(id).collection(clientsPath);
  }
}

/*RULE::
/workspace_auth_db/{workspaceId}/inventory/

* service cloud.firestore {
  match /databases/{database}/documents {
    match /workspace_auth_db/{workspaceId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == subscriberId;
    }
  }
}

Question to AI:
  you have an ERP system; inventory system, POS, CRM and Warehouse system,
  with multiple subscribers with their individual workspaces. The ERP is developed
  in dart flutter for desktop and mobile app using firebase database.

  Question: how can the ERP system create a distinct or respective firestore database for subscribers once they sign in to the application in flutter

  **OR**
  To manage distinct Firestore databases for each subscriber in your ERP system,
  you'll need a way to dynamically create and access a unique database instance
  for each subscriber upon login. Here’s a step-by-step guide to achieve this in a Flutter application using Firebase:
*/
