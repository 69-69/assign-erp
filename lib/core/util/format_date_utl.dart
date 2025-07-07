import 'package:assign_erp/core/util/str_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

extension ConvertDateTime on dynamic {
  ({String filename, String id}) get generateBackupFileName {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);
    return (filename: '$this-$formattedDate', id: now.toISOString);
  }

  /// Convert microsecondsSinceEpoch to DateTime object [toStandardDT]
  String get toStandardDT {
    if (this == null || this == "" || this == "null" || this == "null null") {
      return '0000-00-00 00:00:00.000';
    }

    DateTime dateTime = toDateTime;

    // Format the DateTime object using a standard date time format
    // DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateFormat formatter = DateFormat.yMEd().add_jms();

    // Return the formatted date time string
    return formatter.format(dateTime);
  }

  /// Convert microsecondsSinceEpoch to DateTime object [toStandardDT]
  String get dateOnly {
    if (this == null || this == "" || this == "null" || this == "null null") {
      return '0000-00-00';
    }

    // Return the formatted date time string
    // return DateFormat('yyyy-MM-dd').format(this);
    var dt = this is String ? toDateTimeFn(this) : this;
    return DateFormat.yMEd().format(dt);
  }

  /// Convert DateTime object to microsecondsSinceEpoch String [toISOString]
  String get toISOString {
    if (this == null || this == "" || this == "null" || this == "null null") {
      return '';
    }

    DateTime dateTime = toDateTime;

    // Return the formatted date time string
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    ).toIso8601String();
  }

  /// To DateTime format [toDateTime]
  DateTime get toDateTime => toDateTimeFn(this);

  /*
  /// MillisecondsSinceEpoch To DateTime format [toDateTime]
  DateTime get fromMillisecondsSinceEpoch => this is DateTime
      ? this
      : DateTime.fromMillisecondsSinceEpoch(int.parse(this));
  */

  /// Convert DateTime to Timestamp [fromDate]
  Timestamp? get fromDate => this != null ? Timestamp.fromDate(this) : null;

  /// Convert Timestamp to DateTime [toDate]
  DateTime? get toDate => this != null ? (this as Timestamp).toDate() : null;
}

extension TotalDaysFromDate on DateTime? {
  /// To calculate the number of days from the current date to a specific future date [toDays]
  int get toDays {
    if (this == null) {
      return 0;
    }
    // Current date
    DateTime currentDate = DateTime.now();

    // Future date (12/24/2024 in this example)
    DateTime futureDate = this ?? DateTime(0000, 00, 00);

    // Calculate the difference
    Duration difference = futureDate.difference(currentDate);

    // Get the number of days from the duration
    int daysDifference = difference.inDays;

    return daysDifference;
  }
}

DateTime toDateTimeFn(dateTime) {
  if ('$dateTime'.isNullOrEmpty) {
    return DateTime.now();
  }
  // If is int else string
  return dateTime is int
      ? DateTime.fromMillisecondsSinceEpoch(dateTime)
      : DateTime.parse(dateTime.toString());
}
