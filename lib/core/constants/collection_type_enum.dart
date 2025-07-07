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
      CollectionType.global => 'global',
      CollectionType.chats => 'chats',
      CollectionType.stores => 'stores',
      CollectionType.clients => 'clients',
      CollectionType.workspace => 'workspace',
    };
  }
}
