import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/hosting_type.dart';
import 'package:assign_erp/core/network/data_sources/models/workspace_model.dart';
import 'package:assign_erp/core/util/format_date_utl.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:assign_erp/features/refresh_entire_app.dart';
import 'package:assign_erp/features/setup/data/models/employee_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'horizontal_line.dart';

class ProfileMenuDropdown extends StatelessWidget {
  final Workspace? workspace;
  final Employee? employee;

  const ProfileMenuDropdown({super.key, this.workspace, this.employee});

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = context.isLargeScreen;
    final routePath = GoRouter.of(context).state.matchedLocation;

    // Hide the profile menu on specific routes
    if (routePath == RouteNames.workspaceSignIn ||
        routePath.contains(RouteNames.employeeSignIn)) {
      return const SizedBox.shrink();
    }

    return CupertinoContextMenu(
      actions: _menuActions(context, workspace: workspace),
      child: Container(
        color: kTransparentColor,
        alignment: Alignment.center,
        margin: const EdgeInsets.all(20),
        child: Tooltip(
          message: 'Long press to show menu',
          child: _buildProfileIcon(context, isLargeScreen),
        ),
      ),
    );
  }

  Widget _buildProfileIcon(BuildContext context, bool isLargeScreen) {
    return Wrap(
      direction: Axis.vertical,
      spacing: 10,
      children: [
        if (isLargeScreen) ...[
          _buildUserDetails(context),
          const SizedBox(width: 10),
        ],
        const CircleAvatar(
          backgroundColor: kLightBlueColor,
          child: Icon(Icons.person, color: kPrimaryColor),
        ),
      ],
    );
  }

  Widget _buildUserDetails(BuildContext context) {
    final clientName = employee?.fullName.toUppercaseFirstLetterEach ?? '';
    final roleName = employee?.role.name.toUppercaseFirstLetter ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          clientName,
          style: context.ofTheme.textTheme.bodyMedium?.copyWith(
            color: kLightBlueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          roleName,
          style: context.ofTheme.textTheme.labelSmall?.copyWith(
            color: kLightBlueColor,
          ),
        ),
      ],
    );
  }

  List<Widget> _menuActions(BuildContext context, {Workspace? workspace}) {
    final actions = <Widget>[
      _buildMenuAction(
        context,
        label: 'Dashboard',
        icon: Icons.dashboard,
        onPressed: () => context.goNamed(RouteNames.mainDashboard),
      ),
      _buildMenuAction(
        context,
        label: 'Refresh App',
        icon: CupertinoIcons.refresh,
        onPressed: () async {
          final isConfirmed = await context.confirmUserActionDialog(
            onAccept: 'Refresh App',
          );
          if (context.mounted && isConfirmed) {
            RefreshEntireApp.restartApp(context);
          }
        },
      ),
      _buildMenuAction(
        context,
        isDefault: true,
        label: 'Sign out',
        icon: Icons.logout,
        onPressed: () => _handleSignOut(context),
      ),
      if (workspace != null) ...{
        _buildWorkspaceCard(context, workspace: workspace),
      },
    ];
    return actions;
  }

  Widget _buildWorkspaceCard(BuildContext context, {Workspace? workspace}) {
    return Container(
      color: kPrimaryLightColor,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (workspace!.workspaceName).toUpperCase(),
            style: context.ofTheme.textTheme.bodyLarge?.copyWith(
              color: kLightBlueColor,
            ),
          ),
          Divider(thickness: 6),

          _buildListTile(
            context,
            title: 'SUBSCRIPTION: ${workspace.license.name}',
            subtitle: 'Valid Until: ${workspace.expiresOn.toStandardDT}',
          ),
          _buildListTile(
            context,
            title: 'MULTI-LOCATION: ${workspace.maxAllowedDevices > 1}',
            subtitle: 'Max-Devices: ${workspace.maxAllowedDevices}',
          ),
          HorizontalLine(color: kGrayColor),
          _buildListTile(
            context,
            title: 'Hosting: ${workspace.hostingType.label}',
            subtitle: 'Store No.: ${employee?.storeNumber}',
          ),
        ],
      ),
    );
  }

  CupertinoContextMenuAction _buildMenuAction(
    BuildContext context, {
    VoidCallback? onPressed,
    String label = '',
    IconData? icon,
    bool isDefault = false,
  }) {
    return CupertinoContextMenuAction(
      isDestructiveAction: isDefault,
      onPressed: onPressed,
      trailingIcon: icon,
      child: Text(label),
    );
  }

  CupertinoListTile _buildListTile(
    BuildContext context, {
    String title = '',
    String subtitle = '',
  }) {
    return CupertinoListTile(
      padding: EdgeInsets.zero,
      title: SelectionArea(
        child: Text(
          title.toUppercaseAllLetter,
          style: context.ofTheme.textTheme.labelLarge?.copyWith(
            color: kLightColor,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      subtitle: SelectionArea(
        child: Text(
          subtitle.toUppercaseFirstLetterEach,
          style: context.ofTheme.textTheme.labelMedium?.copyWith(
            color: kLightGrayColor,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  _handleSignOut(BuildContext context) async {
    final isConfirmed = await context.confirmUserActionDialog(
      onAccept: 'Sign Out',
    );
    if (context.mounted && isConfirmed) {
      final authBloc = BlocProvider.of<AuthBloc>(context);
      authBloc.add(AuthSignOutRequested());
    }
  }
}
