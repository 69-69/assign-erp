import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/features/customer_crm/data/permission/crm_permission.dart';
import 'package:assign_erp/features/inventory_ims/data/permission/inventory_permission.dart';
import 'package:assign_erp/features/pos_system/data/permission/pos_permission.dart';
import 'package:assign_erp/features/setup/data/models/role_permission_model.dart';
import 'package:assign_erp/features/setup/data/permission/setup_permission.dart';
import 'package:assign_erp/features/setup/presentation/screen/manage_roles/widget/permission_selector.dart';
import 'package:assign_erp/features/setup/presentation/screen/manage_roles/widget/permission_tab_view.dart';
import 'package:assign_erp/features/setup/presentation/screen/manage_roles/widget/tabs_labels.dart';
import 'package:assign_erp/features/warehouse_wms/data/permission/wms_permission.dart';
import 'package:flutter/material.dart';

class PermissionCard extends StatelessWidget {
  final void Function(String module, {required Set<RolePermission> permissions})
  onSelectedFunc;
  final Set<RolePermission>? initialPermissions;

  const PermissionCard({
    super.key,
    required this.onSelectedFunc,
    this.initialPermissions,
  });

  @override
  Widget build(BuildContext context) {
    return _buildPermission(context);
  }

  _buildPermission(BuildContext context) {
    return SizedBox(
      height: context.screenHeight * 0.6,
      child: PermissionsTabView(
        tabs: tabsLabels,
        isVerticalTab: true,
        children: [
          PermissionSelector(
            displayName: posDisplayName,
            permissions: posPermissions,
            initialPermissions: initialPermissions,
            onSelected: (perms) =>
                onSelectedFunc(posDisplayName, permissions: perms),
            sectionColor: kPrimaryAccentColor,
          ),
          PermissionSelector(
            displayName: inventoryDisplayName,
            initialPermissions: initialPermissions,
            permissions: inventoryPermissionDetails,
            onSelected: (perms) =>
                onSelectedFunc(inventoryDisplayName, permissions: perms),
            sectionColor: kPrimaryAccentColor,
          ),
          PermissionSelector(
            displayName: crmDisplayName,
            permissions: crmPermissions,
            initialPermissions: initialPermissions,
            onSelected: (perms) =>
                onSelectedFunc(crmDisplayName, permissions: perms),
            sectionColor: kPrimaryAccentColor,
          ),
          PermissionSelector(
            displayName: wmsDisplayName,
            permissions: warehousePermissions,
            initialPermissions: initialPermissions,
            onSelected: (perms) =>
                onSelectedFunc(wmsDisplayName, permissions: perms),
            sectionColor: kPrimaryAccentColor,
          ),
          PermissionSelector(
            displayName: setupDisplayName,
            permissions: setupPermissions,
            initialPermissions: initialPermissions,
            onSelected: (perms) =>
                onSelectedFunc(setupDisplayName, permissions: perms),
            sectionColor: kPrimaryAccentColor,
          ),
        ],
      ),
    );
  }
}
