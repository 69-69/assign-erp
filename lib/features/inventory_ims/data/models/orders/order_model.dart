import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/util/format_date_utl.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:equatable/equatable.dart';

var _today = DateTime.now(); /*.millisecondsSinceEpoch.toString()*/

class Orders extends Equatable {
  final String id; // Firestore will assign a unique ID (documentId)
  final String storeNumber;
  final String orderNumber;
  final String productId;
  final String customerId;
  final int quantity;
  final String status;
  final String barcode;
  final String orderType;
  final String productName;
  final double unitPrice;
  final String paymentTerms;
  final String paymentStatus;
  final String orderSource;
  final double deliveryAmount;
  final double discountPercent;
  final double taxPercent;
  final double totalAmount;
  final double amountPaid;

  // final double subTotal;
  // final double taxAmount;
  // final double discountAmount;
  final String? remarks;
  final String validityDate;
  final DateTime? shippingDate;
  final DateTime? deliveryDate;
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;

  Orders({
    this.id = '',
    this.orderNumber = '',
    required this.storeNumber,
    required this.productId,
    required this.customerId,
    required this.status,
    required this.barcode,
    required this.quantity,
    required this.orderType,
    required this.productName,
    required this.unitPrice,
    this.deliveryAmount = 0.0,
    required this.paymentTerms,
    required this.paymentStatus,
    this.discountPercent = 0.0,
    this.taxPercent = 0.0,
    this.totalAmount = 0.0,
    // this.taxAmount = 0.0,
    // required this.subTotal,
    // this.discountAmount = 0.0,
    this.amountPaid = 0.0,
    this.remarks,
    required this.orderSource,
    this.validityDate = '',
    DateTime? shippingDate,
    DateTime? deliveryDate,
    required this.createdBy,
    DateTime? createdAt,
    this.updatedBy = '',
    DateTime? updatedAt,
  }) : shippingDate = shippingDate ?? _today,
       deliveryDate = deliveryDate ?? _today,
       createdAt = createdAt ?? _today,
       updatedAt = updatedAt ?? _today; // Set default value

  /// fromFirestore / fromJson Function [Orders.fromMap]
  factory Orders.fromMap(Map<String, dynamic> data, String documentId) {
    return Orders(
      id: documentId,
      storeNumber: data['storeNumber'] ?? '',
      orderNumber: data['orderNumber'] ?? '',
      productId: data['productId'] ?? '',
      customerId: data['customerId'] ?? '',
      status: data['status'] ?? '',
      barcode: data['barcode'] ?? '',
      orderType: data['orderType'] ?? '',
      productName: data['productName'] ?? '',
      quantity: data['quantity'] ?? 0,
      unitPrice: data['unitPrice'] ?? 0.0,
      paymentTerms: data['paymentTerms'] ?? '',
      paymentStatus: data['paymentStatus'] ?? '',
      deliveryAmount: data['deliveryAmount'] ?? 0.0,
      taxPercent: data['taxPercent'] ?? 0.0,
      discountPercent: data['discountPercent'] ?? 0.0,
      totalAmount: data['totalAmount'] ?? 0.0,
      amountPaid: data['amountPaid'] ?? 0.0,
      // subTotal: data['subTotal'] ?? 0.0,
      // taxAmount: data['taxAmount'] ?? 0.0,
      // discountAmount: data['discountAmount'] ?? 0.0,
      orderSource: data['orderSource'] ?? '',
      remarks: data['remarks'] ?? '',
      validityDate: data['validityDate'] ?? '',
      shippingDate: toDateTimeFn(data['shippingDate']),
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
    'orderNumber': orderNumber,
    'productId': productId,
    'customerId': customerId,
    'status': status,
    'productName': productName,
    'barcode': barcode,
    'orderType': orderType,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'paymentTerms': paymentTerms,
    'paymentStatus': paymentStatus,
    'deliveryAmount': deliveryAmount,
    'taxPercent': taxPercent,
    'discountPercent': discountPercent,
    // 'subTotal': subTotal,
    // 'taxAmount': taxAmount,
    // 'discountAmount': discountAmount,
    'orderSource': orderSource,
    'remarks': remarks,
    'totalAmount': totalAmount,
    'amountPaid': amountPaid,
    'validityDate': validityDate,
    'shippingDate': shippingDate,
    'deliveryDate': deliveryDate,
    'createdBy': createdBy,
    'createdAt': createdAt,
    'updatedBy': updatedBy,
    'updatedAt': updatedAt,
  };

  /// Convert Model to toFirestore / toJson Function [toMap]
  Map<String, dynamic> toMap() {
    var newMap = _mapTemp();
    newMap['shippingDate'] = createdAt.toISOString;
    newMap['deliveryDate'] = createdAt.toISOString;
    newMap['createdAt'] = createdAt.toISOString;
    newMap['updatedAt'] = updatedAt.toISOString;

    return newMap;
  }

  /// toCache Function [toCache]
  Map<String, dynamic> toCache() {
    var newMap = _mapTemp();
    newMap['shippingDate'] = createdAt.millisecondsSinceEpoch;
    newMap['deliveryDate'] = createdAt.millisecondsSinceEpoch;
    newMap['createdAt'] = createdAt.millisecondsSinceEpoch;
    newMap['updatedAt'] = updatedAt.millisecondsSinceEpoch;

    return {'id': id, 'data': newMap};
  }

  bool get isEmpty => id.isEmpty && productId.isEmpty;

  bool get isNotEmpty => !isEmpty;

  /// Check Orders Status [isPending]
  bool get isPending => status == 'pending';

  /// Check Orders Status [isDispatched]
  bool get isDispatched => status == 'shipped / dispatched';

  /// Check Orders Status [isCompleted]
  bool get isCompleted => status == 'completed';

  /// Check Orders Status [isCancelled]
  bool get isCancelled => status == 'cancelled';

  double get getSubTotal => quantity * unitPrice;

  // NetPrice: After discountAmt is deducted & other charges are added from 'subTotal'
  double get getNetPrice => getSubTotal - getDiscountAmount;

  double get getDiscountAmount => (discountPercent / 100) * getSubTotal;

  double get getTaxAmount => (taxPercent / 100) * getNetPrice;

  /// Formatted to Date Only in String [getShippingDate]
  String get getShippingDate => shippingDate.dateOnly;

  /// Formatted to Date Only in String [getDeliveryDate]
  String get getDeliveryDate => deliveryDate.dateOnly;

  /// Formatted to Standard-DateTime in String [getCreatedAt]
  String get getCreatedAt => createdAt.toStandardDT;

  /// Formatted to Date Only in String [getUpdatedAt]
  String get getUpdatedAt => updatedAt.toStandardDT;

  /// Calculate outStanding Balance [getOutStandingBalance]
  double get getOutStandingBalance => totalAmount - amountPaid;

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
      orderNumber.contains(filter) ||
      productId.contains(filter) ||
      productName.contains(filter) ||
      status.contains(filter) ||
      customerId.contains(filter) ||
      validityDate.contains(filter) ||
      orderType.contains(filter);

  /// [findOrderById]
  static Iterable<Orders> findOrderById(List<Orders> orders, String id) =>
      orders.where((order) => order.id == id);

  /// [filterOrdersByDate]
  static List<Orders> filterOrdersByDate(
    List<Orders> orders, {
    bool isSameDay = true,
  }) => orders
      .where((order) => isSameDay ? order.isToday : !order.isToday)
      .toList();

  @override
  String toString() =>
      '$orderNumber - $productName @ ${isToday ? 'Today' : 'Past'}';

  /// copyWith method
  Orders copyWith({
    String? id,
    String? storeNumber,
    String? orderNumber,
    String? productId,
    String? customerId,
    String? status,
    int? quantity,
    String? barcode,
    String? orderType,
    String? productName,
    double? unitPrice,
    String? paymentTerms,
    String? paymentStatus,
    double? deliveryAmount,
    double? taxPercent,
    double? amountPaid,
    double? discountPercent,
    double? totalAmount,
    String? remarks,
    String? orderSource,
    String? validityDate,
    DateTime? deliveryDate,
    DateTime? shippingDate,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
    /*double? subTotal,
    double? taxAmount,
    double? discountAmount,*/
  }) {
    return Orders(
      id: id ?? this.id,
      storeNumber: storeNumber ?? this.storeNumber,
      orderNumber: orderNumber ?? this.orderNumber,
      productId: productId ?? this.productId,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
      orderType: orderType ?? this.orderType,
      quantity: quantity ?? this.quantity,
      barcode: barcode ?? this.barcode,
      productName: productName ?? this.productName,
      unitPrice: unitPrice ?? this.unitPrice,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      deliveryAmount: deliveryAmount ?? this.deliveryAmount,
      discountPercent: discountPercent ?? this.discountPercent,
      taxPercent: taxPercent ?? this.taxPercent,
      totalAmount: totalAmount ?? this.totalAmount,
      amountPaid: amountPaid ?? this.amountPaid,
      orderSource: orderSource ?? this.orderSource,
      remarks: remarks ?? this.remarks,
      validityDate: validityDate ?? this.validityDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      shippingDate: shippingDate ?? this.shippingDate,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      /*subTotal: subTotal ?? this.subTotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,*/
    );
  }

  @override
  List<Object?> get props => [
    id,
    storeNumber,
    orderNumber,
    productId,
    customerId,
    status,
    orderSource,
    productName,
    orderType,
    barcode,
    quantity,
    unitPrice,
    paymentTerms,
    paymentStatus,
    deliveryAmount,
    taxPercent,
    discountPercent,
    totalAmount,
    amountPaid,
    remarks,
    validityDate,
    deliveryDate ?? '',
    shippingDate ?? '',
    createdBy,
    createdAt,
    updatedBy,
    updatedAt,
    // subTotal,
    // taxAmount,
    // discountAmount,
  ];

  /// ToList for ORDERS [itemAsList]
  List<String> itemAsList({int? start, int? end}) {
    var list = [
      id,
      storeNumber,
      orderNumber,
      customerId,
      status.toTitleCase,
      orderSource.toTitleCase,
      productName.toTitleCase,
      orderType.toTitleCase,
      '$quantity',
      '$ghanaCedis$unitPrice',
      '$ghanaCedis$getSubTotal',
      '$discountPercent% = $ghanaCedis${getDiscountAmount.toCurrency}',
      '$ghanaCedis$getNetPrice',
      '$ghanaCedis$deliveryAmount',
      '$taxPercent% = $ghanaCedis${getTaxAmount.toCurrency}',
      '$ghanaCedis${totalAmount.toCurrency}',
      '$ghanaCedis${amountPaid.toCurrency}',
      '$ghanaCedis${getOutStandingBalance.toCurrency}',
      paymentTerms.toTitleCase,
      paymentStatus.toTitleCase,
      validityDate,
      getShippingDate,
      getDeliveryDate,
      createdBy.toTitleCase,
      getCreatedAt,
      updatedBy.toTitleCase,
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
    'Order Number',
    'Customer ID',
    'Status',
    'Order Source',
    'Product Name',
    'Type',
    'Quantity',
    'Unit Price',
    'SubTotal',
    'Discount',
    'Net Price',
    'Delivery fee',
    'Tax',
    'Total Amount',
    'Amount Paid',
    'OutStanding Balance',
    'Payment Terms',
    'Payment Status',
    'Validity',
    'Shipping',
    'Delivery',
    'Created By',
    'Created At',
    'Updated By',
    'Updated At',
  ];
}
