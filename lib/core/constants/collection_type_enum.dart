//-------------------------------
// 🔥 Firestore Collections types
//-------------------------------
enum CollectionType { global, workspace, chats, stores, clients }

/* USAGE:
* final type = CollectionType.global;
* print(type.label); // Output: global
* */
extension CollectionTypeExtension on CollectionType {
  String get label {
    return switch (this) {
      CollectionType.global => 'global', // Global collections
      CollectionType.chats => 'chats', // Chat conversations
      CollectionType.stores => 'stores', // Company-specific stores/shops
      CollectionType.clients => 'clients', // Agent-clients mapping
      /// Workspace-specific collections: is based on WorkspaceRole (eg.: developer, agentFranchise, subscriber)
      CollectionType.workspace => 'workspace',
    };
  }
}
