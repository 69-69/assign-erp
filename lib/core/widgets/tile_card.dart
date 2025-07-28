import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/network/data_sources/models/dashboard_model.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/dashboard_metrics.dart';
import 'package:assign_erp/core/widgets/delayed_tooltip.dart';
import 'package:assign_erp/core/widgets/prompt_user_for_action.dart';
import 'package:assign_erp/core/widgets/side_nav.dart';
import 'package:assign_erp/features/auth/data/role/workspace_role.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/*class PermissionService {
  final Set<dynamic> userPermissions;

  PermissionService(this.userPermissions);

  bool has(dynamic permission) => userPermissions.contains(permission);
}
final permissionService = PermissionService(currentUser.permissions);
final ps = context.read<PermissionService>();

...

if (ps.has(InventoryPermission.viewItems))
  DashboardTile(
    icon: Icons.inventory,
    title: 'Inventory',
    onTap: () => Navigator.push(...),
  ),

*/

class TileCard extends StatefulWidget {
  final Color? bgColor;
  final bool isAdaptive;
  final void Function()? onTap;
  final List<DashboardTile> tiles;
  final String metricsTitle;
  final String metricsSubtitle;
  final Map<String, int>? metrics;

  const TileCard({
    super.key,
    this.isAdaptive = true,
    required this.tiles,
    this.onTap,
    this.bgColor,
    this.metrics,
    this.metricsTitle = '',
    this.metricsSubtitle = '',
  });

  @override
  State<TileCard> createState() => _TileCardState();
}

class _TileCardState extends State<TileCard> {
  late double maxCrossAxisExtent;
  // late List<DashboardTile> _visibleTiles;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /*final ps = context.read<PermissionService>();

    _visibleTiles = widget.tiles.where((tile) {
      if (tile.requiredPermission == null) return true;
      return ps.has(tile.requiredPermission);
    }).toList();*/

    _updateMaxCrossAxisExtent();
  }

  void _updateMaxCrossAxisExtent() {
    // context.isMobile ? screenW :
    var screenW = context.screenWidth;
    maxCrossAxisExtent = (context.isMiniMobile
        ? screenW
        : (context.isPortraitMode ? screenW / 2 : screenW / 3));
  }

  @override
  Widget build(BuildContext context) {
    double pad = 20;

    return widget.tiles.length > 1
        ? _buildBody(context, pad)
        : _buildGridView(context, pad);
  }

  Row _buildBody(BuildContext context, double pad) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SideNav(tiles: widget.tiles),
        Expanded(
          child: widget.metrics != null
              ? Column(
                  children: [
                    DashboardMetrics(
                      title: widget.metricsTitle,
                      subtitle: widget.metricsSubtitle,
                      metrics: widget.metrics!,
                    ),

                    // create full-width card for summary of the inventory in the dash
                    const SizedBox(height: 10),
                    Expanded(child: _buildGridView(context, pad)),
                  ],
                )
              : _buildGridView(context, pad),
        ),
      ],
    );
  }

  GridView _buildGridView(BuildContext context, double pad) {
    // List<DashboardTile> tiles = List.from(widget.tiles)..removeAt(0);

    return GridView.builder(
      primary: false,
      itemCount: widget.tiles.length,
      padding: EdgeInsets.all(pad),
      physics: const RangeMaintainingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        // mainAxisExtent: maxCrossAxisExtent,
        // Spacing between rows
        mainAxisSpacing: 20,
        // Spacing between columns
        crossAxisSpacing: 20,
        // Ratio between the width and height of grid items
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final tile = widget.tiles[index];
        // isLastIndex = index == tile.length - 1;
        return _buildCard(context, index: index, tile: tile);
      },
    );
  }

  _buildCard(
    BuildContext context, {
    int index = 0,
    required DashboardTile tile,
  }) {
    final viewCard = tile.label.contains('logo')
        ? _buildLogoCard(context, tile)
        : _buildIconCard(tile, context);

    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      onHover: (value) => TooltipController.enabled = value,
      onTapDown: (details) => TooltipController.enabled = true,
      onFocusChange: (value) => TooltipController.enabled = value,
      onTapUp: (details) => TooltipController.enabled = false,
      onTap:
          widget.onTap ??
          () async {
            // Check if the WorkspaceRole is AgentFranchise and tile action is liveChatSupport
            final shouldStop = await checkLiveChatSupportAccess(
              context,
              tile.action,
            );
            if (shouldStop) return;

            if (context.mounted) {
              tile.param.entries.isEmpty
                  ? context.goNamed(tile.action)
                  : context.goNamed(
                      tile.action,
                      extra: tile.param,
                      pathParameters: tile.param,
                    );
            }
          },
      child: AnimatedContainer(
        alignment: Alignment.center,
        // width: context.mediaShortSize / 1.3, Color(0xff4a5d8c)
        padding: const EdgeInsets.all(20.0),
        duration: kAnimateDuration,
        decoration: BoxDecoration(
          color:
              widget.bgColor ??
              randomBgColors[index], // context.colorScheme.secondary,
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        child: DelayedTooltip(
          message: (tile.description ?? '').toTitleCase,
          child: context.isMiniMobile
              ? viewCard
              : _buildGridTile(tile, context, viewCard),
        ),
      ),
    ); // .fluidGlassMorphism(addBorder: false);
  }

  GridTile _buildGridTile(DashboardTile tile, BuildContext context, viewCard) {
    return GridTile(
      header: Text(
        tile.label.toUpperCaseAll,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: kLightColor),
        textScaler: TextScaler.linear(context.textScaleFactor),
      ),
      footer: context.isMobile
          ? null
          : Text(
              (tile.description ?? '').toTitleCase,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: kLightColor),
            ),
      child: viewCard,
    );
  }

  _buildIconCard(DashboardTile tile, BuildContext context) {
    final parts = tile.label.split(' - ');
    final title = parts.first;
    final subTitle = parts.length > 1 ? parts[1] : '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: TextButton.icon(
            onPressed: null,

            /*onPressed:
                widget.onTap ??
                () async {
                  TooltipController.enabled = false;
                  // Check if the WorkspaceRole is AgentFranchise and tile action is liveChatSupport
                  final shouldStop = await checkLiveChatSupportAccess(
                    context,
                    tile.action,
                  );
                  if (shouldStop) return;

                  Future.delayed(Duration.zero, () {
                    if (context.mounted) {
                      tile.param.entries.isEmpty
                          ? context.goNamed(tile.action)
                          : context.goNamed(
                              tile.action,
                              extra: tile.param,
                              pathParameters: tile.param,
                            );
                    }
                  });
                },*/
            icon: Expanded(
              child: Icon(
                tile.icon,
                color: kLightBlueColor,
                size: context.screenWidth * 0.1,
                semanticLabel: title,
              ),
            ),
            label: context.isMobile
                ? const SizedBox.shrink()
                : _buildListTile(title, context, subTitle),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              alignment: Alignment.center,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> checkLiveChatSupportAccess(
    BuildContext context,
    String route,
  ) async {
    final role = context.workspace?.role;

    if (route == RouteNames.liveChatSupport &&
        role != WorkspaceRole.subscriber) {
      await context.confirmAction(
        Text('Please use Agent Support/Chat for assistance.'),
        title: "Live Chat Support",
        onAccept: "Ok",
        onReject: "Cancel",
      );
      return true; // prompt was shown; further action should stop
    }

    return false; // no prompt; proceed normally
  }

  ListTile _buildListTile(String title, BuildContext context, String subTitle) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title.toUpperCaseAll,
        textAlign: TextAlign.center,
        style: context.ofTheme.textTheme.titleMedium?.copyWith(
          color: kLightBlueColor,
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.bold,
        ),
        textScaler: TextScaler.linear(context.textScaleFactor),
      ),
      subtitleTextStyle: context.ofTheme.textTheme.titleSmall?.copyWith(
        overflow: TextOverflow.ellipsis,
        color: kLightBlueColor,
      ),
      subtitle: subTitle.isEmpty
          ? null
          : Text(
              subTitle.toUpperCaseAll,
              textAlign: TextAlign.center,
              textScaler: TextScaler.linear(context.textScaleFactor),
            ),
    );
  }

  _buildLogoCard(BuildContext context, DashboardTile tile) {
    return Wrap(
      runAlignment: WrapAlignment.center,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Image.asset(
          appLogo,
          fit: BoxFit.contain,
          width: maxCrossAxisExtent * 0.3,
        ),
        if (!context.isMobile) ...[
          const SizedBox(width: 10),
          Text(
            tile.label.toUpperCaseAll,
            textAlign: TextAlign.center,
            style: context.ofTheme.textTheme.titleMedium?.copyWith(
              color: kLightColor,
            ),
            textScaler: TextScaler.linear(context.textScaleFactor),
          ),
        ],
      ],
    );
  }
}
