class ShortUID {
  final String shortId;

  ShortUID({required this.shortId});

  /// fromFirestore / fromMap
  factory ShortUID.fromMap(Map<String, dynamic> data, String documentId) =>
      ShortUID(shortId: data['shortId'] ?? '');

  /// toFirestore / toMap
  Map<String, dynamic> toMap() => {'shortId': shortId};

  /// toCache / toMap
  Map<String, dynamic> toCache() => {
        'id': shortId,
        'data': {'id': shortId}
      };

  bool get isEmpty => shortId.isEmpty;

  bool get isNotEmpty => !isEmpty;
}
