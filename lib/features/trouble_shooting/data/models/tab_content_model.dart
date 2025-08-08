import 'package:assign_erp/features/access_control/data/model/access_control_model.dart';
import 'package:flutter/material.dart';

/// Model for tab content
class LicenseTabContent {
  final String label;
  final IconData icon;
  final String displayName;
  final List<AccessControl> licenses;
  final List<String>? restrictedAccess;

  LicenseTabContent({
    required this.label,
    required this.icon,
    required this.displayName,
    required this.licenses,
    this.restrictedAccess,
  });
}
