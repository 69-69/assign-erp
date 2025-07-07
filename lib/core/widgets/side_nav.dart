import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/network/data_sources/models/dashboard_model.dart';
import 'package:assign_erp/core/network/data_sources/models/workspace_model.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
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
  final insetPadding = const EdgeInsets.all(6);
  Workspace? _workspace;

  @override
  void initState() {
    super.initState();
    _getWorkspace();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _widthAnimation = Tween<double>(begin: 50, end: 200).animate(_controller);
  }

  void _getWorkspace() {
    // Get Logged-In Workspace info
    setState(() => _workspace = context.workspace);
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

  // Determine the size of the drawer based on its open state
  Size _buildResize() => Size(_isDrawerOpen ? _widthAnimation.value : 50, 50);

  // Get the background color based on whether the drawer is open
  Color get _bgColor =>
      _isDrawerOpen ? context.colorScheme.secondary : kTransparentColor;

  // Get the icon color based on whether the drawer is open
  Color get _iconColor =>
      _isDrawerOpen ? kLightColor : context.colorScheme.primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: context.isDesktop ? 20 : 8),
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
        _profileButton(context),
        const SizedBox(height: 10),
        Expanded(child: _buildNav(context)),
        const SizedBox(height: 10),
        _buildLogout(),
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
              ? kLightBlueColor
              : _bgColor;
        }),
      ),
      icon: Icon(Icons.menu, color: _iconColor),
      onPressed: _toggleDrawer,
      label: Text(
        'Menu',
        style: context.ofTheme.textTheme.titleMedium?.copyWith(
          color: kLightBlueColor,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // Build the toggle button for the side navigation drawer
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
      onPressed: () => context.go('/${RouteNames.mainDashboard}'),
      label: Text(
        (_workspace?.workspaceName ?? appName).toUpperCase(),
        style: context.ofTheme.textTheme.titleMedium?.copyWith(
          color: kLightBlueColor,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // Build the navigation links list
  Widget _buildNav(BuildContext context) {
    return SingleChildScrollView(
      primary: true,
      padding: EdgeInsets.zero,
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.tiles.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildLinks(context, tile: s),
            ),
          ),
        ],
      ),
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
        tile.label.toUppercaseAllLetter,
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
      fixedSize: _buildResize(),
      alignment: Alignment.centerLeft,
      padding: insetPadding,
      backgroundColor: _bgColor,
      shape: const RoundedRectangleBorder(),
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
        'Sign out',
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

/*class SideNav2 extends StatefulWidget {
  final List<NavLinks> tiles;

  const SideNav2({super.key, required this.tiles});

  @override
  State<SideNav2> createState() => _SideNav2State();
}

class _SideNav2State extends State<SideNav2> {
  bool _isDrawerOpen = false;
  final insetPadding = const EdgeInsets.fromLTRB(18, 18, 6, 18);

  void _toggleDrawer() => setState(() => _isDrawerOpen = !_isDrawerOpen);

  Size _buildResize() => Size(_isDrawerOpen ? 200 : 50, 50);

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  _buildBody(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _toggleDrawer(),
      onExit: (_) => _toggleDrawer(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _toggleButton(context),
          Expanded(
            child: _buildNav(context),
          ),
        ],
      ),
    );
  }

  _toggleButton(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        elevation: 30,
        padding: insetPadding,
        alignment: Alignment.centerLeft,
        fixedSize: _buildResize(),
        shape: const RoundedRectangleBorder(),
        backgroundColor: context.colorScheme.primary,
      ),
      icon: const Icon(Icons.menu, color: kLightColor),
      onPressed: () => _toggleDrawer(),
      label: Align(
        alignment: Alignment.centerRight,
        child: Row(
          children: [
            Text(
              appName,
              style: context.ofTheme.textTheme.titleMedium
                  ?.copyWith(color: kLightBlueColor),
            ),
            Image.asset(
              appLogo2,
              width: 40,
              alignment: Alignment.centerRight,
            ),
          ],
        ),
      ),
    );
  }

  SingleChildScrollView _buildNav(BuildContext context) {
    return SingleChildScrollView(
      primary: true,
      padding: EdgeInsets.zero,
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 10.0),
          for (NavLinks s in widget.tiles) _buildLinks(context, tile: s),
          _buildLogout(),
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }

  _buildLinks(BuildContext context, {required NavLinks tile}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextButton.icon(
        style: TextButton.styleFrom(
          elevation: 30,
          fixedSize: _buildResize(),
          alignment: Alignment.centerLeft,
          padding: insetPadding,
          shape: const RoundedRectangleBorder(),
          backgroundColor: context.colorScheme.primary,
        ),
        onPressed: () => tile.param.entries.isEmpty
            ? context.goNamed(tile.action)
            : context.goNamed(
          tile.action,
          extra: tile.param,
          pathParameters: tile.param,
        ),
        label: Text(
          softWrap: false,
          tile.label.toUppercaseAllLetter,
          style: context.ofTheme.textTheme.bodySmall?.copyWith(
            color: kLightColor,
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.w500,
          ),
        ),
        icon: Icon(tile.icon, color: kLightColor),
      ),
    );
  }

  _buildLogout() {
    return TextButton.icon(
      style: TextButton.styleFrom(
        elevation: 30,
        fixedSize: _buildResize(),
        alignment: Alignment.centerLeft,
        padding: insetPadding,
        shape: const RoundedRectangleBorder(),
        backgroundColor: context.colorScheme.primary,
      ),
      onPressed: () {},
      label: Text(
        softWrap: false,
        'Logout',
        style: context.ofTheme.textTheme.bodySmall?.copyWith(
          color: kLightColor,
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.w500,
        ),
      ),
      icon: const Icon(Icons.logout, color: kLightColor),
    );
  }
}*/

/*ExpansionTile _formBody() {
    return ExpansionTile(
      dense: true,
      title: Text(
        'Modify this Delivery',
        textAlign: TextAlign.center,
        style: context.ofTheme.textTheme.titleLarge,
      ),
      subtitle: Text(
        'steve'.toUppercaseAllLetter,
        textAlign: TextAlign.center,
      ),
      childrenPadding: const EdgeInsets.only(bottom: 20.0),
      children: [
        const SizedBox(height: 20),
        Text(
          'steve'.toUppercaseAllLetter,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPanel() {
    final List<Item> _data = generateItems(1);

    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() => _data[index].isExpanded = isExpanded);
      },
      children: _data.map<ExpansionPanel>((Item item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(item.headerValue),
            );
          },
          body: ListTile(
              title: Text(item.expandedValue),
              subtitle:
              const Text('To icon'),
              trailing: const Icon(Icons.delete),
              onTap: () {
                setState(() {
                  _data.removeWhere((Item currentItem) => item == currentItem);
                });
              }),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }*/ /*
}*/

// stores ExpansionPanel state information
/*class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}

List<Item> generateItems(int numberOfItems) {
  return List<Item>.generate(numberOfItems, (int index) {
    return Item(
      headerValue: 'Panel $index',
      expandedValue: 'This is item number $index',
    );
  });
}*/
