import 'package:assign_erp/features/access_control/data/model/access_control_model.dart';

enum TroubleShootPermission {
  manageDiagnostics,
  manageTenants,
  manageSubscriptions,
}

final tShootDisplayName = 'trouble shoot';

final List<AccessControl> tShootPermission = [
  AccessControl(
    access: TroubleShootPermission.manageDiagnostics,
    module: 'diagnostics',
    title: 'Manage Diagnostics',
    description: 'Manage, view error logs and diagnose issues in the system.',
  ),
  AccessControl(
    access: TroubleShootPermission.manageTenants,
    module: 'tenants',
    title: 'Manage Tenants',
    description: 'Manage and monitor all tenant workspaces.',
  ),
  AccessControl(
    access: TroubleShootPermission.manageSubscriptions,
    module: 'subscriptions',
    title: 'Manage Subscriptions',
    description: 'Manage Subscription Licenses and Plans',
  ),
];
