import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/util/format_date_utl.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:equatable/equatable.dart';

var _today = DateTime.now(); /*.millisecondsSinceEpoch.toString()*/

class PurchaseOrder extends Equatable {
  final String id; // Firestore will assign a unique ID (documentId)
  final String storeNumber;
  final String poNumber;
  final String supplierId;

  final String productName;

  final double unitPrice;
  final int quantity;

  final String status;
  final String paymentTerms;

  final String? remarks;

  final double taxPercent;
  final double discountPercent;

  final double subTotal;

  final DateTime? deliveryDate;
  final double totalAmount;

  final String orderType;

  final String approvedBy;

  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;

  PurchaseOrder({
    this.id = '',
    this.poNumber = '',
    required this.storeNumber,
    required this.supplierId,
    required this.status,
    required this.quantity,
    required this.productName,
    this.orderType = 'purchase order',
    required this.unitPrice,
    required this.paymentTerms,
    this.remarks,
    this.subTotal = 0.0,
    this.approvedBy = '',
    this.discountPercent = 0.0,
    this.taxPercent = 0.0,
    required this.totalAmount,
    DateTime? deliveryDate,
    required this.createdBy,
    DateTime? createdAt,
    this.updatedBy = '',
    DateTime? updatedAt,
  }) : deliveryDate = deliveryDate ?? _today,
       createdAt = createdAt ?? _today,
       updatedAt = updatedAt ?? _today; // Set default value

  /// fromFirestore / fromJson Function [PurchaseOrder.fromMap]
  factory PurchaseOrder.fromMap(Map<String, dynamic> data, String documentId) {
    return PurchaseOrder(
      id: documentId,
      storeNumber: data['storeNumber'] ?? '',
      poNumber: data['poNumber'] ?? '',
      supplierId: data['supplierId'] ?? '',
      status: data['status'] ?? '',
      productName: data['productName'] ?? '',
      orderType: data['orderType'] ?? 'purchase order',
      quantity: data['quantity'] ?? 0,
      unitPrice: data['unitPrice'] ?? 0.0,
      paymentTerms: data['paymentTerms'] ?? '',
      remarks: data['remarks'] ?? '',
      subTotal: data['subTotal'] ?? 0.0,
      taxPercent: data['taxPercent'] ?? 0.0,
      discountPercent: data['discountPercent'] ?? 0.0,
      totalAmount: data['totalAmount'] ?? 0.0,
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
    'storeNumber': storeNumber,
    'poNumber': poNumber,
    'supplierId': supplierId,
    'productName': productName,
    'unitPrice': unitPrice,
    'quantity': quantity,
    'status': status,
    'orderType': orderType,
    'paymentTerms': paymentTerms,
    'remarks': remarks,
    'subTotal': subTotal,
    'approvedBy': approvedBy,
    'taxPercent': taxPercent,
    'discountPercent': discountPercent,
    'totalAmount': totalAmount,
    'deliveryDate': deliveryDate,
    'createdBy': createdBy,
    'createdAt': createdAt,
    'updatedBy': updatedBy,
    'updatedAt': updatedAt,
  };

  /// Convert Model to toFirestore / toJson Function [toMap]
  Map<String, dynamic> toMap() {
    var newMap = _mapTemp();
    newMap['deliveryDate'] = createdAt.toISOString;
    newMap['createdAt'] = createdAt.toISOString;
    newMap['updatedAt'] = updatedAt.toISOString;

    return newMap;
  }

  /// toCache Function [toCache]
  Map<String, dynamic> toCache() {
    var newMap = _mapTemp();
    newMap['deliveryDate'] = createdAt.millisecondsSinceEpoch;
    newMap['createdAt'] = createdAt.millisecondsSinceEpoch;
    newMap['updatedAt'] = updatedAt.millisecondsSinceEpoch;

    return {'id': id, 'data': newMap};
  }

  bool get isEmpty => productName.isEmpty;

  bool get isNotEmpty => !isEmpty;

  // NetPrice: After discountAmt is deducted & other charges are added from 'subTotal'
  double get netPrice => subTotal - discountAmt;

  double get discountAmt => (discountPercent / 100) * subTotal;

  double get taxAmt => (taxPercent / 100) * netPrice;

  /// approved POs [isApproved]
  bool get isApproved => status == 'approved' && approvedBy.isNotEmpty;

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
      poNumber.contains(filter) ||
      storeNumber.contains(filter) ||
      productName.contains(filter) ||
      status.contains(filter) ||
      supplierId.contains(filter) ||
      paymentTerms.contains(filter);

  /// [findPurchaseOrderById]
  static Iterable<PurchaseOrder> findPurchaseOrderById(
    List<PurchaseOrder> po,
    String poId,
  ) => po.where((order) => order.id == poId);

  /// [filterPurchaseOrderByDate]
  static List<PurchaseOrder> filterPurchaseOrderByDate(
    List<PurchaseOrder> po, {
    bool isSameDay = true,
  }) => po
      .where(
        (order) =>
            !order.isApproved && (isSameDay ? order.isToday : !order.isToday),
      )
      .toList();

  /// [filterApprovedPOs]
  static List<PurchaseOrder> filterApprovedPOs(List<PurchaseOrder> po) =>
      po.where((order) => order.isApproved).toList();

  @override
  String toString() =>
      'PO: $poNumber - $productName @ ${isToday ? 'Today' : 'Past'}';

  /// copyWith method
  PurchaseOrder copyWith({
    String? id,
    String? storeNumber,
    String? poNumber,
    String? supplierId,
    String? productName,
    String? orderType,
    double? unitPrice,
    int? quantity,
    String? status,
    String? paymentTerms,
    String? remarks,
    double? subTotal,
    String? approvedBy,
    double? taxPercent,
    double? discountPercent,
    double? totalAmount,
    DateTime? deliveryDate,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      storeNumber: storeNumber ?? this.storeNumber,
      poNumber: poNumber ?? this.poNumber,
      supplierId: supplierId ?? this.supplierId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice ?? this.unitPrice,
      orderType: orderType ?? this.orderType,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      remarks: remarks ?? this.remarks,
      subTotal: subTotal ?? this.subTotal,
      approvedBy: approvedBy ?? this.approvedBy,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      discountPercent: discountPercent ?? this.discountPercent,
      taxPercent: taxPercent ?? this.taxPercent,
      totalAmount: totalAmount ?? this.totalAmount,
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
    poNumber,
    supplierId,
    status,
    productName,
    quantity,
    orderType,
    unitPrice,
    paymentTerms,
    remarks,
    subTotal,
    deliveryDate ?? '',
    taxPercent,
    discountPercent,
    totalAmount,
    approvedBy,
    createdBy,
    createdAt,
    updatedBy,
    updatedAt,
  ];

  /// ToList for PurchaseOrder [itemAsList]
  List<String> itemAsList({int? start, int? end}) {
    var list = [
      id,
      storeNumber,
      poNumber,
      supplierId,
      orderType.toUppercaseFirstLetterEach,
      status.toUppercaseFirstLetterEach,
      paymentTerms.toUppercaseFirstLetterEach,
      productName.toUppercaseFirstLetterEach,
      '$ghanaCedis$unitPrice',
      '$quantity',
      '$ghanaCedis$subTotal',
      '$discountPercent% = $ghanaCedis$discountAmt',
      '$taxPercent% = $ghanaCedis$taxAmt',
      '$ghanaCedis$totalAmount',
      getDeliveryDate,
      approvedBy.toUppercaseFirstLetterEach,
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
    'PO Number',
    'Supplier ID',
    'Order Type',
    'Status',
    'Payment Terms',
    'Product Name',
    'Unit Price',
    'Quantity',
    'SubTotal',
    'Discount',
    'Tax',
    'Total Amount',
    'Delivery',
    'Approved By',
    'Created By',
    'Created At',
    'Updated By',
    'Updated At',
  ];
}
