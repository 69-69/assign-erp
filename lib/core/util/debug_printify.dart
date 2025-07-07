import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Prints a debug message to the console.
void prettyPrint(String label, dynamic value) {
  const encoder = JsonEncoder.withIndent('  ');
  final prettyString = encoder.convert(value);
  debugPrint('📌 $label:\n$prettyString');
}
