import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/util/format_date_utl.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:equatable/equatable.dart';

var _today = DateTime.now(); /*.millisecondsSinceEpoch.toString()*/

class RequestForQuotation extends Equatable {
  final String id; // Firestore will assign a unique ID (documentId)
  final String storeNumber;
  final String rfqNumber;
  final String supplierId;
  // final List<RFQLineItem> lineItems; // A list of items in the RFQ
  final String productName;

  final double unitPrice;
  final int quantity;

  final String status;

  final String? remarks;

  final double taxPercent;
  final double discountPercent;

  final double netPrice;

  final DateTime? deadline;
  final DateTime? deliveryDate;

  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;

  /// @TODO request for quotation fields
  // * Terms & conditions
  // * List of invited suppliers
  // * Attachments (drawings/specs)
  // * Responses (linked or stored in sub-table)

  // Calculated net price from the line items
  /*double get netPrice {
    double total = 0;
    for (var item in lineItems) {
      total += item.unitPrice * item.quantity;
    }
    return total - (total * discountPercent / 100) + (total * taxPercent / 100);
  }*/

  RequestForQuotation({
    this.id = '',
    this.rfqNumber = '',
    required this.storeNumber,
    required this.supplierId,
    required this.status,
    required this.quantity,
    required this.productName,
    this.unitPrice = 0.0,
    this.remarks,
    this.netPrice = 0.0,
    this.discountPercent = 0.0,
    this.taxPercent = 0.0,
    DateTime? deadline,
    DateTime? deliveryDate,
    required this.createdBy,
    DateTime? createdAt,
    this.updatedBy = '',
    DateTime? updatedAt,
  }) : deadline = deadline ?? _today,
       deliveryDate = deliveryDate ?? _today,
       createdAt = createdAt ?? _today,
       updatedAt = updatedAt ?? _today; // Set default value

  /// fromFirestore / fromJson Function [RequestForQuotation.fromMap]
  factory RequestForQuotation.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return RequestForQuotation(
      id: documentId,
      storeNumber: data['storeNumber'] ?? '',
      rfqNumber: data['rfqNumber'] ?? '',
      supplierId: data['supplierId'] ?? '',
      status: data['status'] ?? '',
      productName: data['productName'] ?? '',
      quantity: data['quantity'] ?? 0,
      unitPrice: data['unitPrice'] ?? 0.0,
      remarks: data['remarks'] ?? '',
      netPrice: data['netPrice'] ?? 0.0,
      taxPercent: data['taxPercent'] ?? 0.0,
      discountPercent: data['discountPercent'] ?? 0.0,
      deadline: toDateTimeFn(data['deadline']),
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
    'rfqNumber': rfqNumber,
    'supplierId': supplierId,
    'productName': productName,
    'unitPrice': unitPrice,
    'quantity': quantity,
    'status': status,
    'remarks': remarks,
    'netPrice': netPrice,
    'taxPercent': taxPercent,
    'discountPercent': discountPercent,
    'deadline': deadline,
    'deliveryDate': deliveryDate,
    'createdBy': createdBy,
    'createdAt': createdAt,
    'updatedBy': updatedBy,
    'updatedAt': updatedAt,
  };

  /// Convert Model to toFirestore / toJson Function [toMap]
  Map<String, dynamic> toMap() {
    var newMap = _mapTemp();
    newMap['deadline'] = deadline.toISOString;
    newMap['deliveryDate'] = deliveryDate.toISOString;
    newMap['createdAt'] = createdAt.toISOString;
    newMap['updatedAt'] = updatedAt.toISOString;

    return newMap;
  }

  /// toCache Function [toCache]
  Map<String, dynamic> toCache() {
    var newMap = _mapTemp();
    newMap['deadline'] = deadline?.millisecondsSinceEpoch;
    newMap['deliveryDate'] = deliveryDate?.millisecondsSinceEpoch;
    newMap['createdAt'] = createdAt.millisecondsSinceEpoch;
    newMap['updatedAt'] = updatedAt.millisecondsSinceEpoch;

    return {'id': id, 'data': newMap};
  }

  bool get isEmpty => productName.isEmpty;

  bool get isNotEmpty => !isEmpty;

  double get subTotal => quantity * unitPrice;

  double get discountAmt => (discountPercent / 100) * subTotal;

  double get taxAmt => (taxPercent / 100) * (subTotal - discountAmt);

  /// approved POs [isApproved]
  bool get isAwarded => status == 'awarded';

  /// Formatted to Date Only in String [getDeliveryDate]
  String get getDeliveryDate => deliveryDate.dateOnly;

  /// Formatted to Date Only in String [getDeliveryDate]
  String get getDeadlineDate => deadline.dateOnly;

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
      rfqNumber.contains(filter) ||
      productName.contains(filter) ||
      status.contains(filter) ||
      supplierId.contains(filter);

  /// [findRequestForQuotationById]
  static Iterable<RequestForQuotation> findRequestForQuotationById(
    List<RequestForQuotation> quotes,
    String quoteId,
  ) => quotes.where((quote) => quote.id == quoteId);

  /// [filterRequestForQuotationByDate]
  static List<RequestForQuotation> filterRequestForQuotationByDate(
    List<RequestForQuotation> quotes, {
    bool isSameDay = true,
  }) => quotes
      .where(
        (quote) =>
            !quote.isAwarded && (isSameDay ? quote.isToday : !quote.isToday),
      )
      .toList();

  /// [filterAwardedRFQ]
  static List<RequestForQuotation> filterAwardedRFQ(
    List<RequestForQuotation> quotes,
  ) => quotes.where((quote) => quote.isAwarded).toList();

  @override
  String toString() => 'RFQ: $rfqNumber - $productName';

  /// copyWith method
  RequestForQuotation copyWith({
    String? id,
    String? storeNumber,
    String? rfqNumber,
    String? supplierId,
    String? productName,
    double? unitPrice,
    int? quantity,
    String? status,
    String? remarks,
    double? netPrice,
    double? taxPercent,
    double? discountPercent,
    DateTime? deadline,
    DateTime? deliveryDate,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return RequestForQuotation(
      id: id ?? this.id,
      storeNumber: storeNumber ?? this.storeNumber,
      rfqNumber: rfqNumber ?? this.rfqNumber,
      supplierId: supplierId ?? this.supplierId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      netPrice: netPrice ?? this.netPrice,
      deadline: deadline ?? this.deadline,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      discountPercent: discountPercent ?? this.discountPercent,
      taxPercent: taxPercent ?? this.taxPercent,
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
    rfqNumber,
    supplierId,
    status,
    productName,
    quantity,
    unitPrice,
    remarks,
    netPrice,
    deadline ?? '',
    deliveryDate ?? '',
    taxPercent,
    discountPercent,
    createdBy,
    createdAt,
    updatedBy,
    updatedAt,
  ];

  /// ToList for RequestPriceQuotation [itemAsList]
  List<String> itemAsList({int? start, int? end}) {
    var list = [
      id,
      storeNumber,
      rfqNumber,
      supplierId,
      status.toTitleCase,
      productName.toTitleCase,
      '$ghanaCedis$unitPrice',
      '$quantity',
      '$discountPercent% = $ghanaCedis$discountAmt',
      '$ghanaCedis$netPrice',
      '$taxPercent% = $ghanaCedis$taxAmt',
      getDeadlineDate,
      getDeliveryDate,
      createdBy.toTitleCase,
      getCreatedAt,
      updatedBy.toTitleCase,
      getUpdatedAt,
    ];

    return list;
  }

  static List<String> get dataTableHeader => const [
    'ID',
    'Store Number',
    'RFQ Number',
    'Supplier ID',
    'Status',
    'Product Name',
    'Unit Price',
    'Quantity',
    'Discount',
    'Net Price',
    'Tax',
    'Quotation Deadline',
    'Delivery Date',
    'Created By',
    'Created At',
    'Updated By',
    'Updated At',
  ];
}

class RFQLineItem extends Equatable {
  final String productName;
  final double unitPrice;
  final int quantity;

  const RFQLineItem({
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productName, unitPrice, quantity];
}
