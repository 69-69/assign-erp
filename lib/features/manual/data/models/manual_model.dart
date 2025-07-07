import 'package:assign_erp/core/util/format_date_utl.dart';
import 'package:equatable/equatable.dart';

var _today = DateTime.now(); /*.millisecondsSinceEpoch.toString()*/

class Manual extends Equatable {
  Manual({
    this.id = '',
    required this.url,
    required this.title,
    required this.category,
    required this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? _today,
       updatedAt = updatedAt ?? _today; // Set default value

  final String id;
  final dynamic url;
  final String title;
  final String category;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// fromFirestore / fromJson Function [Manual.fromMap]
  factory Manual.fromMap(Map<String, dynamic> map, {String? id}) {
    return Manual(
      id: (id ?? map['id']) ?? '',
      url: map['url'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      description: map['description'] as String,
      createdAt: toDateTimeFn(map['createdAt']),
      updatedAt: toDateTimeFn(map['updatedAt']),
    );
  }

  // map template
  Map<String, dynamic> _mapTemp() => {
    'id': id,
    'url': url,
    'title': title,
    'category': category,
    'description': description,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  /// Convert Model to toFirestore / toJson Function [toMap]
  Map<String, dynamic> toMap() {
    var newMap = _mapTemp();
    newMap['createdAt'] = createdAt.toISOString;
    newMap['updatedAt'] = updatedAt.toISOString;

    return newMap;
  }

  /// toCache Function [toCache]
  Map<String, dynamic> toCache() {
    var newMap = _mapTemp();
    newMap['createdAt'] = createdAt.millisecondsSinceEpoch;
    newMap['updatedAt'] = updatedAt.millisecondsSinceEpoch;

    return {'id': id, 'data': newMap};
  }

  bool get isEmpty => id.isEmpty && title.isEmpty;

  bool get isNotEmpty => !isEmpty;

  /// copyWith method
  Manual copyWith({
    String? id,
    String? url,
    String? title,
    String? category,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Manual(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    url,
    title,
    category,
    description,
    createdAt,
    updatedAt,
  ];
}
