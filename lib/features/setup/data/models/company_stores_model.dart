import 'package:assign_erp/core/util/format_date_utl.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:equatable/equatable.dart';

var _today = DateTime.now();

class CompanyStores extends Equatable {
  final String id;
  final String storeNumber;
  final String name;
  final String phone;
  final String location;
  final String? remarks;
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;

  CompanyStores({
    this.id = '',
    required this.name,
    this.phone = '',
    required this.location,
    required this.storeNumber,
    this.remarks,
    required this.createdBy,
    DateTime? createdAt,
    this.updatedBy = '',
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? _today,
       updatedAt = updatedAt ?? _today; // Set default value

  /// fromFirestore / fromJson Function [StoreLocation.fromMap]
  factory CompanyStores.fromMap(Map<String, dynamic> data, String documentId) {
    return CompanyStores(
      id: documentId,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      location: data['location'] ?? '',
      storeNumber: data['storeNumber'] ?? '',
      remarks: data['remarks'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: toDateTimeFn(data['createdAt']),
      updatedBy: data['updatedBy'] ?? '',
      updatedAt: toDateTimeFn(data['updatedAt']),
    );
  }

  // map template
  Map<String, dynamic> _mapTemp() => {
    'id': id,
    'name': name,
    'phone': phone,
    'location': location,
    'storeNumber': storeNumber,
    'remarks': remarks,
    'createdBy': createdBy,
    'createdAt': createdAt,
    'updatedBy': updatedBy,
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

  bool get isEmpty => id.isEmpty && storeNumber.isEmpty;

  bool get isNotEmpty => !isEmpty;

  /// Formatted to Standard-DateTime in String [getCreatedAt]
  String get getCreatedAt => createdAt.toStandardDT;

  /// Formatted to Standard-DateTime in String [getUpdatedAt]
  String get getUpdatedAt => updatedAt.toStandardDT;

  /// Current / Today's Products/Stocks
  bool get isToday {
    var dt = createdAt.toDateTime;

    return dt.year == _today.year &&
        dt.month == _today.month &&
        dt.day == _today.day;
  }

  String get itemAsString => '$name - $storeNumber'.toTitleCase;

  /// Filter Search
  bool filterByAny(String filter) =>
      name.contains(filter) ||
      storeNumber.contains(filter) ||
      location.contains(filter) ||
      phone.contains(filter);

  /// [findStoresById]
  static Iterable<CompanyStores> findStoresById(
    List<CompanyStores> stores,
    String id,
  ) => stores.where((d) => d.id == id);

  /// copyWith method
  CompanyStores copyWith({
    String? id,
    String? name,
    String? phone,
    String? location,
    String? storeNumber,
    String? remarks,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return CompanyStores(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      storeNumber: storeNumber ?? this.storeNumber,
      remarks: remarks ?? this.remarks,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    location,
    storeNumber,
    remarks,
    createdBy,
    createdAt,
    updatedBy,
    updatedAt,
  ];

  /// ToList for StoreLocation [toListL]
  List<String> itemAsList() => [
    id,
    storeNumber,
    name.toTitleCase,
    phone,
    location.toTitleCase,
    (remarks ?? 'none').toTitleCase,
    createdBy.toTitleCase,
    getCreatedAt,
    updatedBy.toTitleCase,
    getUpdatedAt,
  ];

  static List<String> get dataTableHeader => const [
    'ID',
    'Store Number',
    'Name',
    'Phone',
    'Address / Location',
    'Remarks',
    'Created By',
    'Created At',
    'Updated By',
    'Updated At',
  ];
}
