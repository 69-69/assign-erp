import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/network/data_sources/models/dashboard_model.dart';
import 'package:assign_erp/core/util/neumorphism.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/delayed_tooltip.dart';
import 'package:assign_erp/core/widgets/side_nav.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TileCard extends StatefulWidget {
  final Color? bgColor;
  final bool isAdaptive;
  final List<DashboardTile> tiles;
  final void Function()? onTap;

  const TileCard({
    super.key,
    this.isAdaptive = true,
    required this.tiles,
    this.onTap,
    this.bgColor,
  });

  @override
  State<TileCard> createState() => _TileCardState();
}

class _TileCardState extends State<TileCard> {
  late double maxCrossAxisExtent;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMaxCrossAxisExtent();
  }

  void _updateMaxCrossAxisExtent() {
    // context.isMobile ? screenW :
    var screenW = context.screenWidth;
    maxCrossAxisExtent = (context.isPortraitMode ? screenW / 2 : screenW / 3);
  }

  @override
  Widget build(BuildContext context) {
    double pad = 20;

    return widget.tiles.length > 1
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SideNav(tiles: widget.tiles),
              Expanded(child: _buildBody(context, pad)),
            ],
          )
        : _buildBody(context, pad);
  }

  GridView _buildBody(BuildContext context, double pad) {
    return GridView.builder(
      primary: false,
      itemCount: widget.tiles.length,
      physics: const RangeMaintainingScrollPhysics(),
      padding: EdgeInsets.all(pad),
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
        return _buildCard(context, tile: tile);
      },
    );
  }

  _buildCard(BuildContext context, {required DashboardTile tile}) {
    final viewCard = tile.label.contains('logo')
        ? _buildLogoCard(context, tile)
        : _buildIconCard(tile, context);

    return AnimatedContainer(
      // width: context.mediaShortSize / 1.3, Color(0xff4a5d8c)
      padding: const EdgeInsets.all(20.0),
      duration: kAnimateDuration,
      decoration: BoxDecoration(
        color: widget.bgColor ?? context.colorScheme.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DelayedTooltip(
        message: (tile.description ?? '').toUppercaseFirstLetterEach,
        child: context.isMiniMobile
            ? viewCard
            : _buildGridTile(tile, context, viewCard),
      ),
    ).addNeumorphism();
  }

  GridTile _buildGridTile(DashboardTile tile, BuildContext context, viewCard) {
    return GridTile(
      header: Text(
        tile.label.toUppercaseAllLetter,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: kLightColor),
        textScaler: TextScaler.linear(context.textScaleFactor),
      ),
      footer: context.isMobile
          ? null
          : Text(
              (tile.description ?? '').toUppercaseFirstLetterEach,
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
            onPressed:
                widget.onTap ??
                () {
                  TooltipController.enabled = false;
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
                },
            icon: Expanded(
              child:
                  Icon(
                    tile.icon,
                    color: kLightColor,
                    size: context.screenWidth * 0.1,
                    semanticLabel: title,
                  ).addNeumorphism(
                    topShadowColor: kGrayBlueColor,
                    offset: const Offset(1, 1),
                  ),
            ),

            label: context.isMobile
                ? const SizedBox.shrink()
                : _buildListTile(title, context, subTitle),
          ),
        ),
      ],
    );
  }

  ListTile _buildListTile(String title, BuildContext context, String subTitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title.toUppercaseAllLetter,
        textAlign: TextAlign.center,
        style: context.ofTheme.textTheme.titleMedium?.copyWith(
          color: kLightColor,
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.bold,
        ),
        textScaler: TextScaler.linear(context.textScaleFactor),
      ),
      subtitleTextStyle: context.ofTheme.textTheme.titleSmall?.copyWith(
        overflow: TextOverflow.ellipsis,
        color: kLightColor,
      ),
      subtitle: subTitle.isEmpty
          ? null
          : Text(
              subTitle.toUppercaseAllLetter,
              textAlign: TextAlign.center,
              textScaler: TextScaler.linear(context.textScaleFactor),
            ),
    );
  }

  GestureDetector _buildLogoCard(BuildContext context, DashboardTile tile) {
    return GestureDetector(
      onTap: () {
        TooltipController.enabled = false;
        Future.delayed(Duration.zero, () {
          if (context.mounted) {
            context.goNamed(tile.action);
          }
        });
      },
      child: Wrap(
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
              tile.label.toUppercaseAllLetter,
              textAlign: TextAlign.center,
              style: context.ofTheme.textTheme.titleMedium?.copyWith(
                color: kLightColor,
              ),
              textScaler: TextScaler.linear(context.textScaleFactor),
            ),
          ],
        ],
      ),
    );
  }
}

/*
class _TileCardState extends State<TileCard> {
  late double maxCrossAxisExtent;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMaxCrossAxisExtent();
  }

  void _updateMaxCrossAxisExtent() {
    // context.isMobile ? screenW :
    var screenW = context.screenWidth;
    maxCrossAxisExtent = (context.isPortraitMode ? screenW / 2 : screenW / 3);
  }

  @override
  Widget build(BuildContext context) {
    double pad = 20;

    return widget.tiles.length > 1
        ? Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SideNav(tiles: widget.tiles),
        Expanded(child: _buildBody(context, pad)),
      ],
    )
        : _buildBody(context, pad);
  }

  GridView _buildBody(BuildContext context, double pad) {
    return GridView.builder(
      primary: false,
      itemCount: widget.tiles.length,
      physics: const RangeMaintainingScrollPhysics(),
      padding: EdgeInsets.all(pad),
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
        return _buildCard(context, tile: tile);
      },
    );
  }

  _buildCard(BuildContext context, {required DashboardTile tile}) {
    return AnimatedContainer(
      // width: context.mediaShortSize / 1.3, Color(0xff4a5d8c)
      color: widget.bgColor ?? context.colorScheme.secondary,
      padding: const EdgeInsets.all(20.0),
      duration: kAnimateDuration,
      child: Tooltip(
        message: (tile.description ?? '').toUppercaseFirstLetterEach,
        child: GridTile(
          header: Text(
            tile.label.toUppercaseAllLetter,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: kLightColor),
          ),
          footer: context.isMobile
              ? null
              : Text(
            (tile.description ?? '').toUppercaseFirstLetterEach,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: kLightColor),
          ),
          child: tile.label.contains('logo')
              ? _buildLogoCard(context, tile)
              : _buildIconCard(tile, context),
        ),
      ),
    ).addNeumorphism();
  }

  _buildIconCard(DashboardTile tile, BuildContext context) {
    var title =
    tile.label.contains(' - ') ? tile.label.split(' - ').first : tile.label;
    var subTitle = tile.label.contains(' - ') ? tile.label.split(' - ')[1] : '';

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: TextButton.icon(
        onPressed: widget.onTap ??
                () {
              tile.param.entries.isEmpty
                  ? context.goNamed(tile.action)
                  : context.goNamed(
                tile.action,
                extra: tile.param,
                pathParameters: tile.param,
              );
            },
        icon: Expanded(
          child: Icon(
            tile.icon,
            color: kLightColor,
            size: context.textScaleFactor * 50,
          ).addNeumorphism(
            topShadowColor: kGrayBlueColor,
            offset: const Offset(1, 1),
          ),
        ),
        label: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            title.toUppercaseAllLetter,
            textAlign: TextAlign.center,
            style: context.ofTheme.textTheme.titleLarge?.copyWith(
              color: kLightColor,
              overflow: TextOverflow.ellipsis,
              fontWeight: FontWeight.bold,
            ),
            textScaler: TextScaler.linear(context.textScaleFactor),
          ),
          subtitle: subTitle.isEmpty
              ? null
              : Text(
            subTitle.toUppercaseAllLetter,
            textAlign: TextAlign.center,
            style: context.ofTheme.textTheme.titleMedium?.copyWith(
              color: kLightColor,
              overflow: TextOverflow.ellipsis,
            ),
            textScaler: TextScaler.linear(context.textScaleFactor),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildLogoCard(BuildContext context, DashboardTile tile) {
    return GestureDetector(
      onTap: () => context.goNamed(tile.action),
      child: Wrap(
        runAlignment: WrapAlignment.center,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Image.asset(
            appLogo,
            fit: BoxFit.contain,
            width: maxCrossAxisExtent * 0.3,
          ),
          const SizedBox(width: 10),
          Text(
            tile.label.toUppercaseAllLetter,
            textAlign: TextAlign.center,
            style: context.ofTheme.textTheme.titleLarge
                ?.copyWith(color: kLightColor),
            textScaler: TextScaler.linear(context.textScaleFactor),
          ),
        ],
      ),
    );
  }
}


    return isAdaptive
        ? Align(
            alignment: Alignment.center,
            child: AdaptiveLayout(
              mainAxisSize: MainAxisSize.min,
              children: tiles
                  .map<Widget>((tile) => _buildBody(context, tile: tile))
                  .toList(),
            ),
          )
        : context.columnBuilder(
            mainAxisSize: MainAxisSize.min,
            itemCount: tiles.length,
            itemBuilder: (_, index) => _buildBody(context, tile: tiles[index]),
          );*/
