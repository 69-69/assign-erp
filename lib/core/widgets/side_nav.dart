import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/constants/hosting_type.dart';
import 'package:assign_erp/core/network/data_sources/models/dashboard_model.dart';
import 'package:assign_erp/core/util/format_date_utl.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/auth/data/model/workspace_model.dart';
import 'package:assign_erp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/setup/data/models/employee_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SideNav extends StatefulWidget {
  final List<DashboardTile> tiles;

  const SideNav({super.key, required this.tiles});

  @override
  State<SideNav> createState() => _SideNavState();
}

class _SideNavState extends State<SideNav> with SingleTickerProviderStateMixin {
  bool _isDrawerOpen = false;
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  Workspace? _workspace;
  Employee? _employee;
  bool isHovered = false; // Define it inside the builder

  @override
  void initState() {
    super.initState();
    _getWorkspace();
    _controller = AnimationController(vsync: this, duration: kAnimateDuration);
    _widthAnimation = Tween<double>(begin: 50, end: 200).animate(_controller);
  }

  void _getWorkspace() {
    // Get Logged-In Workspace & Employee info
    setState(() {
      _workspace = context.workspace;
      _employee = context.employee;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Toggle the drawer open state and update the animation accordingly
  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
      _isDrawerOpen ? _controller.forward() : _controller.reverse();
    });
  }

  void _toggleInDrawer() {
    setState(() {
      _isDrawerOpen = true;
      _controller.forward();
    });
  }

  void _toggleExitDrawer() {
    setState(() {
      _isDrawerOpen = false;
      _controller.reverse();
    });
  }

  double get _dynamicWidth => _isDrawerOpen ? _widthAnimation.value : 50;

  // Get the background color based on whether the drawer is open
  Color get _bgColor =>
      _isDrawerOpen ? context.secondaryColor : kTransparentColor;

  // Get the icon color based on whether the drawer is open
  Color get _iconColor =>
      _isDrawerOpen ? kLightColor : context.surfaceTintColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16),
      height: context.screenHeight - (kAppBarHeight + 40),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Column(
            children: [
              Expanded(
                child: context.isMobile
                    ? _buildBody(context)
                    : MouseRegion(
                        onEnter: (_) => _toggleInDrawer(),
                        onExit: (_) => _toggleExitDrawer(),
                        child: _buildBody(context),
                      ),
              ),
              const SizedBox(height: 10),
              _toggleButton(context),
            ],
          );
        },
      ),
    );
  }

  // Build the main content of the side navigation
  Widget _buildBody(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        /*_profileButton(context),*/
        _WorkspaceInfoCard(
          workspace: _workspace,
          employee: _employee,
          isDrawerOpen: _isDrawerOpen,
          dynamicWidth: _dynamicWidth,
          bgColor: _isDrawerOpen ? context.colorScheme.primary : _bgColor,
          iconColor: _iconColor,
        ),

        const SizedBox(height: 10),
        Expanded(child: _buildNav(context)),
      ],
    );
  }

  // Build the toggle button for the side navigation drawer
  Widget _toggleButton(BuildContext context) {
    return TextButton.icon(
      style: _btnStyle(context).copyWith(
        overlayColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          return states.contains(WidgetState.hovered)
              ? kGrayBlueColor
              : _bgColor;
        }),
      ),
      icon: Icon(_isDrawerOpen ? Icons.close : Icons.menu, color: _iconColor),
      onPressed: _toggleDrawer,
      label: Text(
        _isDrawerOpen ? 'Close' : 'Menu',
        style: context.ofTheme.textTheme.titleMedium?.copyWith(
          color: kLightBlueColor,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  bool _shouldShowDashboardTile(BuildContext cxt) =>
      cxt.routeFromUri != '/${RouteNames.mainDashboard}';

  List<DashboardTile> _buildTiles(BuildContext cxt) {
    final List<DashboardTile> tiles = [];

    if (_shouldShowDashboardTile(cxt)) {
      tiles.add(
        DashboardTile(
          icon: Icons.dashboard,
          label: 'Dashboard',
          action: RouteNames.mainDashboard,
          description: 'Access to dashboard',
        ),
      );
    }

    tiles.addAll(widget.tiles);
    return tiles;
  }

  Widget _buildNav(BuildContext context) {
    final tiles = _buildTiles(context);

    return SingleChildScrollView(
      primary: true,
      padding: EdgeInsets.zero,
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      child: _buildTileList(tiles),
    );
  }

  Widget _buildTileList(List<DashboardTile> tiles) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...tiles.map(
          (tile) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildLinks(context, tile: tile),
          ),
        ),
        _buildLogout(),
      ],
    );
  }

  // Build individual navigation links
  Widget _buildLinks(BuildContext context, {required DashboardTile tile}) {
    return TextButton.icon(
      style: _btnStyle(context),
      onPressed: () {
        tile.param.entries.isEmpty
            ? context.goNamed(tile.action)
            : context.goNamed(
                tile.action,
                extra: tile.param,
                pathParameters: tile.param,
              );
      },
      label: Text(
        softWrap: false,
        tile.label.toUpperCaseAll,
        style: context.ofTheme.textTheme.bodySmall?.copyWith(
          color: kLightColor,
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.w500,
        ),
      ),
      icon: Icon(tile.icon, color: _iconColor),
    );
  }

  // Button style
  ButtonStyle _btnStyle(BuildContext context) {
    var styleFrom = TextButton.styleFrom(
      elevation: 30,
      padding: const EdgeInsets.all(6),
      backgroundColor: _bgColor,
      fixedSize: Size(_dynamicWidth, 50),
      alignment: _isDrawerOpen ? Alignment.centerLeft : Alignment.center,
      animationDuration: kAnimateDuration,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    );
    return context.isMobile
        ? styleFrom
        : styleFrom.copyWith(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              return states.contains(WidgetState.hovered)
                  ? context.colorScheme.primary
                  : _bgColor;
            }),
          );
  }

  // Build the logout button
  Widget _buildLogout() {
    return TextButton.icon(
      style: _btnStyle(context),
      onPressed: () async {
        final isConfirmed = await context.confirmUserActionDialog(
          onAccept: 'Sign Out',
        );
        if (mounted && isConfirmed) {
          _handleSignOut(context);
        }
      },
      label: Text(
        'SIGN OUT',
        style: context.ofTheme.textTheme.bodySmall?.copyWith(
          color: kLightColor,
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.w500,
        ),
      ),
      icon: Icon(Icons.logout, color: _iconColor),
    );
  }

  // Handle the sign-out process
  void _handleSignOut(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    authBloc.add(AuthSignOutRequested());
  }
}

class _WorkspaceInfoCard extends StatelessWidget {
  const _WorkspaceInfoCard({
    required this.isDrawerOpen,
    required this.dynamicWidth,
    required this.bgColor,
    required this.iconColor,
    this.workspace,
    this.employee,
  });

  final bool isDrawerOpen;
  final double dynamicWidth;
  final Color bgColor;
  final Color iconColor;
  final Workspace? workspace;
  final Employee? employee;

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  _buildBody(BuildContext context) {
    return workspace == null
        ? const SizedBox.shrink()
        : AnimatedContainer(
            width: dynamicWidth,
            padding: const EdgeInsets.all(6.0),
            duration: kAnimateDuration,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: _buildCard(context),
          );
  }

  Column _buildCard(BuildContext context) {
    final miniScreen = context.screenHeight <= 600;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          mouseCursor: SystemMouseCursors.click,
          title: Text(
            workspace!.workspaceName.toUpperCase(),
            style: context.ofTheme.textTheme.bodyMedium?.copyWith(
              color: kLightColor,
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          leading: workspace != null
              ? Icon(Icons.workspaces, color: iconColor)
              : Image.asset(
                  appLogoWithBG,
                  scale: 24,
                  alignment: Alignment.centerLeft,
                ),
          onTap: () => context.goNamed(RouteNames.switchStoresAccount),
        ),
        if (isDrawerOpen && !miniScreen) ...[
          Divider(thickness: 6),
          _buildListTile(
            context,
            title: 'SUBSCRIPTION: ${workspace?.license.name}',
            subtitle: 'Valid Until: ${workspace?.expiresOn.toStandardDT}',
          ),
          _buildListTile(
            context,
            title:
                "Multi-Location: ${workspace!.maxAllowedDevices > 1 ? 'On' : 'Off'}",
            subtitle: 'Max-Devices: ${workspace?.maxAllowedDevices}',
          ),
          _buildListTile(
            context,
            title: 'Hosting: ${workspace!.hostingType.label}',
            subtitle: 'Store Location: ${employee?.storeNumber}',
          ),
        ],
      ],
    );
  }

  ListTile _buildListTile(
    BuildContext context, {
    String title = '',
    String subtitle = '',
  }) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      mouseCursor: SystemMouseCursors.click,
      title: Text(
        title.toUpperCaseAll,
        style: context.ofTheme.textTheme.bodySmall?.copyWith(
          color: kLightColor,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      subtitle: Text(
        subtitle.toTitleCase,
        style: context.ofTheme.textTheme.labelSmall?.copyWith(
          color: kLightColor,
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.normal,
        ),
      ),
      onTap: () => context.goNamed(RouteNames.switchStoresAccount),
    );
  }
}

/* Build the toggle button for the side navigation drawer
  Widget _profileButton(BuildContext context) {
    return TextButton.icon(
      style: _btnStyle(context),
      icon: _workspace != null
          ? Icon(Icons.workspaces, color: _iconColor)
          : Image.asset(
              appLogoWithBG,
              scale: 24,
              alignment: Alignment.centerLeft,
            ),
      onPressed: () => context.goNamed(RouteNames.swicthStoresAccount),
      label: Text(
        (_workspace?.workspaceName ?? appName).toUpperCase(),
        style: context.ofTheme.textTheme.titleMedium?.copyWith(
          color: kLightBlueColor,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }*/

/*// Build the navigation links list
  Widget _buildNav2(BuildContext context) {
    // Check if we're not on the main dashboard route
    final isNotOnDashboard = context.routeFromUri != RouteNames.mainDashboard;

    // Build the dashboard tile conditionally
    final List<DashboardTile> tiles = [
      if (isNotOnDashboard)
        DashboardTile(
          icon: Icons.dashboard,
          label: 'Dashboard',
          action: RouteNames.mainDashboard,
          description: 'Access to dashboard',
        ),
      ...widget.tiles,
    ];

    return SingleChildScrollView(
      primary: true,
      padding: EdgeInsets.zero,
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...tiles.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildLinks(context, tile: s),
            ),
          ),
          _buildLogout(),
        ],
      ),
    );
  }*/
