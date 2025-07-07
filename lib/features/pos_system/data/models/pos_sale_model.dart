import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/util/format_date_utl.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:equatable/equatable.dart';

var _today = DateTime.now();

// POSSale Model class
class POSSale extends Equatable {
  final String id; // Firestore will assign a unique ID (documentId)
  final String storeNumber;
  final String receiptNumber;
  final String customerId;
  final String orderNumber;
  final String productId;
  final double unitPrice;
  final int quantity;
  final double totalAmount;
  final String status;
  final String paymentMethod;
  final double discountPercent;
  final double taxPercent;
  final double revenue;
  final double profit;
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;

  POSSale({
    this.id = '', // Firestore will assign a unique ID (documentId)
    required this.storeNumber,
    required this.orderNumber,
    required this.receiptNumber,
    this.customerId = '',
    required this.productId,
    required this.unitPrice,
    required this.quantity,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    this.discountPercent = 0.0,
    this.taxPercent = 0.0,
    this.revenue = 0.0,
    this.profit = 0.0,
    this.createdBy = '',
    this.updatedBy = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? _today,
        updatedAt = updatedAt ?? _today; // Set default value

  factory POSSale.fromMap(Map<String, dynamic> map, String documentId) {
    var rev = calculateRevenue(map);

    return POSSale(
      id: documentId,
      storeNumber: map['storeNumber'] ?? '',
      orderNumber: map['orderNumber'] ?? '',
      receiptNumber:
          map['receiptNumber'] ?? '${map['orderNumber']}'.convertOrderNumberTo,
      customerId: map['customerId'] ?? '',
      productId: map['productId'] ?? '',
      unitPrice: map['unitPrice'] ?? 0.0,
      quantity: map['quantity'] ?? 0,
      totalAmount: map['totalAmount'] ?? 0.0,
      status: map['status'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
      discountPercent: map['discountPercent'] ?? 0.0,
      taxPercent: map['taxPercent'] ?? 0.0,
      revenue: map['revenue'] ?? rev,
      profit: map['profit'] ?? 0.0,
      createdBy: map['createdBy'] ?? '',
      createdAt: toDateTimeFn(map['createdAt']),
      updatedBy: map['updatedBy'],
      updatedAt: toDateTimeFn(map['updatedAt']),
    );
  }

  // map template
  Map<String, dynamic> _mapTemp() => {
        'id': id,
        'storeNumber': storeNumber,
        'orderNumber': orderNumber,
        'receiptNumber': receiptNumber,
        'customerId': customerId,
        'productId': productId,
        'unitPrice': unitPrice,
        'quantity': quantity,
        'totalAmount': totalAmount,
        'status': status,
        'paymentMethod': paymentMethod,
        'taxPercent': taxPercent,
        'discountPercent': discountPercent,
        'revenue': revenue,
        'profit': profit,
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

  bool get isEmpty => id.isEmpty && productId.isEmpty;

  bool get isNotEmpty => !isEmpty;

  double get subTotal => quantity * unitPrice;

  // NetPrice: After discountAmt is deducted & other charges are added from 'subTotal'
  double get netPrice => subTotal - discountAmount;

  double get discountAmount => (discountPercent / 100) * subTotal;

  double get taxAmount => (taxPercent / 100) * netPrice;

  /// Calculate Revenue [getRevenue]
  double get getRevenue => quantity * unitPrice;

  /// Formatted to Standard-DateTime in String [getCreatedAt]
  String get getCreatedAt => createdAt.toStandardDT;

  /// Formatted to Standard-DateTime in String [getUpdatedAt]
  String get getUpdatedAt => updatedAt.toStandardDT;

  /// Current / Today's Products/Stocks [isToday]
  bool get isToday {
    var dt = createdAt.toDateTime;

    return dt.year == _today.year &&
        dt.month == _today.month &&
        dt.day == _today.day;
  }

  static double calculateRevenue(Map<String, dynamic> d) => switch (d) {
        {
          'totalAmount': double totalAmount,
          'unitPrice': double unitPrice,
        } =>
          totalAmount * unitPrice,
        _ => 0.0
      };

  /// Calculate Profit [calculateProfit]
  /// Profit = Revenue − Cost or Profit = (unitPrice - costPrice) * quantity
  double calculateProfit(double costPrice) =>
      costPrice == 0.0 ? 0.0 : (unitPrice - costPrice) * quantity.toDouble();

  /// Find a Specific sale by id [findSaleById]
  static Iterable<POSSale> findSaleById(List<POSSale> sales,
          {required String saleId}) =>
      sales.where((sale) => sale.id == saleId);

  /// Filter sales [filterSalesByDate]
  static List<POSSale> filterSalesByDate(List<POSSale> sales,
          {bool isSameDay = true}) =>
      sales.where((sale) => isSameDay ? sale.isToday : !sale.isToday).toList();

  /// Check if any required fields are missing or empty
  bool isDataComplete() {
    // Check for non-empty string fields
    bool areStringFieldsValid = [
      storeNumber,
      receiptNumber,
      orderNumber,
      productId,
      customerId,
      paymentMethod,
      status,
      status,
      createdBy
    ].every((field) => field.isNotEmpty);

    // Check for numerical fields
    bool areNumericFieldsValid =
        quantity > 0 && unitPrice > 0 && totalAmount > 0;

    // Check for complete data
    return areStringFieldsValid && areNumericFieldsValid;
  }

  /// copyWith method
  POSSale copyWith({
    String? id,
    String? storeNumber,
    String? orderNumber,
    String? productId,
    String? customerId,
    String? receiptNumber,
    int? quantity,
    double? unitPrice,
    double? discountPercent,
    double? taxPercent,
    double? totalAmount,
    double? revenue,
    double? profit,
    String? status,
    String? paymentMethod,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return POSSale(
      id: id ?? this.id,
      storeNumber: storeNumber ?? this.storeNumber,
      orderNumber: orderNumber ?? this.orderNumber,
      productId: productId ?? this.productId,
      customerId: customerId ?? this.customerId,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discountPercent: discountPercent ?? this.discountPercent,
      taxPercent: taxPercent ?? this.taxPercent,
      totalAmount: totalAmount ?? this.totalAmount,
      revenue: revenue ?? this.revenue,
      profit: profit ?? this.profit,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object> get props => [
        id,
        storeNumber,
        orderNumber,
        receiptNumber,
        customerId,
        productId,
        unitPrice,
        quantity,
        totalAmount,
        status,
        paymentMethod,
        taxPercent,
        discountPercent,
        revenue,
        profit,
        createdBy,
        createdAt,
        updatedBy,
        updatedAt,
      ];

  /// ToList for SALES [itemAsList]
  List<String> itemAsList() => [
        id,
        storeNumber,
        productId.toUppercaseAllLetter,
        orderNumber,
        receiptNumber,
        customerId,
        status.toUppercaseFirstLetterEach,
        '$ghanaCedis${unitPrice.toCurrency}',
        '$quantity',
        '$ghanaCedis${subTotal.toCurrency}',
        '$discountPercent% = $ghanaCedis${discountAmount.toCurrency}',
        '$taxPercent% = $ghanaCedis${taxAmount.toCurrency}',
        '$ghanaCedis${totalAmount.toCurrency}',
        paymentMethod.toUppercaseFirstLetterEach,
        '$ghanaCedis${getRevenue.toCurrency}',
        '$ghanaCedis${profit.toCurrency}',
        createdBy.toUppercaseFirstLetterEach,
        getCreatedAt,
        updatedBy.toUppercaseFirstLetterEach,
        getUpdatedAt,
      ];

  static List<String> get dataTableHeader => const [
        'ID',
        'Store Number',
        'Product ID',
        'Order Number',
        'Receipt Number',
        'Customer ID',
        'Status',
        'Unit Price',
        'Quantity',
        'Sub Total',
        'Discount',
        'Tax',
        'Total Amount',
        'Payment Method',
        'Revenue',
        'Gross Profit',
        'Created By',
        'Created At',
        'Updated By',
        'Updated At',
      ];
}
