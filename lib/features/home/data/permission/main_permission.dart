import 'package:assign_erp/core/util/str_util.dart';

enum MainPermission {
  unknown, // For unspecified permissions
}

bool isUnknownPermission(String p) =>
    p == getEnumName<MainPermission>(MainPermission.unknown);
