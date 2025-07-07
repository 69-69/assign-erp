import 'package:equatable/equatable.dart';
import 'package:assign_erp/core/util/format_date_utl.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/constants/app_constant.dart';

var _today = DateTime.now(); /*.millisecondsSinceEpoch.toString()*/

class MiscOrder extends Equatable {
  final String id; // Firestore will assign a unique ID (documentId)
  final String moNumber;
  final String storeNumber;
  final String supplierId;
  final String productId;
  final double unitPrice;
  final String productName;
  final int quantity;
  final String status;
  final String? shipTo;
  final String paymentMethod;
  final String? remarks;
  final DateTime? deliveryDate;
  final String approvedBy;
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;

  MiscOrder({
    this.id = '',
    this.moNumber = '',
    required this.storeNumber,
    required this.productId,
    required this.supplierId,
    required this.status,
    required this.quantity,
    required this.productName,
    required this.unitPrice,
    required this.paymentMethod,
    this.shipTo,
    this.remarks,
    this.approvedBy = '',
    DateTime? deliveryDate,
    required this.createdBy,
    DateTime? createdAt,
    this.updatedBy = '',
    DateTime? updatedAt,
  })  : deliveryDate = deliveryDate ?? _today,
        createdAt = createdAt ?? _today,
        updatedAt = updatedAt ?? _today; // Set default value

  /// fromFirestore / fromJson Function [MiscOrder.fromMap]
  factory MiscOrder.fromMap(Map<String, dynamic> data, String documentId) {
    return MiscOrder(
      id: documentId,
      moNumber: data['moNumber'] ?? '',
      storeNumber: data['storeNumber'] ?? '',
      productId: data['productId'] ?? '',
      supplierId: data['supplierId'] ?? '',
      status: data['status'] ?? '',
      productName: data['productName'] ?? '',
      quantity: data['quantity'] ?? 0,
      unitPrice: data['unitPrice'] ?? 0.0,
      paymentMethod: data['paymentMethod'] ?? '',
      shipTo: data['shipTo'] ?? '',
      remarks: data['remarks'] ?? '',
      approvedBy: data['approvedBy'] ?? '',
      deliveryDate: toDateTimeFn(data['deliveryDate']),
      createdBy: data['createdBy'] ?? '',
      createdAt: toDateTimeFn(data['createdAt']),
      updatedBy: data['updatedBy'] ?? '',
      updatedAt: toDateTimeFn(data['updatedAt']),
    );
  }

  // map template
  Map<String, dynamic> _mapTemp() => {
        'id': id,
        'moNumber': moNumber,
        'storeNumber': storeNumber,
        'productId': productId,
        'supplierId': supplierId,
        'productName': productName,
        'unitPrice': unitPrice,
        'quantity': quantity,
        'status': status,
        'paymentMethod': paymentMethod,
        'shipTo': shipTo,
        'remarks': remarks,
        'approval': approvedBy,
        'deliveryDate': deliveryDate,
        'createdBy': createdBy,
        'createdAt': createdAt,
        'updatedBy': updatedBy,
        'updatedAt': updatedAt,
      };

  /// Convert Model to toFirestore / toJson Function [toMap]
  Map<String, dynamic> toMap() {
    var newMap = _mapTemp();
    newMap['deliveryDate'] = deliveryDate.toISOString;
    newMap['createdAt'] = createdAt.toISOString;
    newMap['updatedAt'] = updatedAt.toISOString;

    return newMap;
  }

  /// toCache Function [toCache]
  Map<String, dynamic> toCache() {
    var newMap = _mapTemp();
    newMap['deliveryDate'] = deliveryDate?.millisecondsSinceEpoch;
    newMap['createdAt'] = createdAt.millisecondsSinceEpoch;
    newMap['updatedAt'] = updatedAt.millisecondsSinceEpoch;

    return {'id': id, 'data': newMap};
  }

  bool get isEmpty => id.isEmpty && productId.isEmpty;

  bool get isNotEmpty => !isEmpty;

  /// Check MiscOrder Status [isPending]
  bool get isPending => status == 'pending';

  /// Check MiscOrder Status [isDispatched]
  bool get isDispatched => status == 'shipped / dispatched';

  /// Check MiscOrder Status [isCompleted]
  bool get isCompleted => status == 'completed';

  /// Check MiscOrder Status [isCancelled]
  bool get isCancelled => status == 'cancelled';

  /// Formatted to Date Only in String [getDeliveryDate]
  String get getDeliveryDate => deliveryDate.dateOnly;

  /// Formatted to Standard-DateTime in String [getCreatedAt]
  String get getCreatedAt => createdAt.toStandardDT;

  /// Formatted to Date Only in String [getUpdatedAt]
  String get getUpdatedAt => updatedAt.toStandardDT;

  /// Current / Today's Products/Stocks
  bool get isToday {
    var dt = createdAt.toDateTime;

    return dt.year == _today.year &&
        dt.month == _today.month &&
        dt.day == _today.day;
  }

  /// Filter
  bool filterByAny(String filter) =>
      storeNumber.contains(filter) ||
      moNumber.contains(filter) ||
      productId.contains(filter) ||
      productName.contains(filter) ||
      status.contains(filter) ||
      supplierId.contains(filter) ||
      createdBy.contains(filter) ||
      approvedBy.contains(filter) ||
      paymentMethod.contains(filter);

  /// [findMiscOrderById]
  static Iterable<MiscOrder> findMiscOrderById(
          List<MiscOrder> po, String poId) =>
      po.where((order) => order.id == poId);

  /// [filterMiscOrderByDate]
  static List<MiscOrder> filterMiscOrderByDate(List<MiscOrder> po,
          {bool isSameDay = true}) =>
      po.where((order) => isSameDay ? order.isToday : !order.isToday).toList();

  @override
  String toString() =>
      'SO: $moNumber - $productName @ ${isToday ? 'Today' : 'Past'}';

  /// copyWith method
  MiscOrder copyWith({
    String? id,
    String? moNumber,
    String? storeNumber,
    String? supplierId,
    String? productId,
    String? productName,
    double? unitPrice,
    int? quantity,
    String? status,
    String? paymentMethod,
    String? shipTo,
    String? remarks,
    String? approvedBy,
    DateTime? deliveryDate,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return MiscOrder(
      id: id ?? this.id,
      storeNumber: storeNumber ?? this.storeNumber,
      moNumber: moNumber ?? this.moNumber,
      supplierId: supplierId ?? this.supplierId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shipTo: shipTo ?? this.shipTo,
      remarks: remarks ?? this.remarks,
      approvedBy: approvedBy ?? this.approvedBy,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
    storeNumber,
        moNumber,
        productId,
        supplierId,
        status,
        productName,
        quantity,
        unitPrice,
        paymentMethod,
        shipTo,
        remarks,
        deliveryDate ?? '',
        approvedBy,
        createdBy,
        createdAt,
        updatedBy,
        updatedAt,
      ];

  /// ToList for MiscOrder [itemAsList]
  List<String> itemAsList({int? start, int? end}) {
    var list = [
      id,
      storeNumber,
      moNumber,
      supplierId,
      status.toUppercaseFirstLetterEach,
      productId,
      productName.toUppercaseFirstLetterEach,
      '$ghanaCedis$unitPrice',
      '$quantity',
      paymentMethod.toUppercaseFirstLetterEach,
      getDeliveryDate,
      approvedBy,
      createdBy.toUppercaseFirstLetterEach,
      getCreatedAt,
      updatedBy.toUppercaseFirstLetterEach,
      getUpdatedAt,
    ];

    /// Removes a range of elements from the list
    if (start != null && end != null) {
      list.removeRange(start, end);
    }

    return list;
  }

  static List<String> get dataTableHeader => const [
        'ID',
        'Store Number',
        'MO Number',
        'Supplier ID',
        'Status',
        'Product ID',
        'Product Name',
        'Unit Price',
        'Quantity',
        'Payment Terms',
        'Delivery',
        'Approved By',
        'Created By',
        'Created At',
        'Updated By',
        'Updated At',
      ];
}
