import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/constants/hosting_type.dart';
import 'package:assign_erp/core/util/format_date_utl.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/custom_scroll_bar.dart';
import 'package:assign_erp/core/widgets/horizontal_line.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/setup/data/models/company_stores_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/company/company_stores_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:assign_erp/features/setup/presentation/screen/company/add/add_shop_locations.dart';
import 'package:assign_erp/features/setup/presentation/screen/company/widget/can_add_more_stores.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SwitchShopLocationsScreen extends StatelessWidget {
  final String openTab;

  const SwitchShopLocationsScreen({super.key, this.openTab = '0'});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CompanyStoresBloc>(
      create: (context) =>
          CompanyStoresBloc(firestore: FirebaseFirestore.instance)
            ..add(GetSetups<CompanyStores>()),
      child: CustomScaffold(
        isGradientBg: true,
        title: storeSwitcherAppTitle.toUpperCase(),
        body: CustomScrollBar(
          controller: ScrollController(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  BlocBuilder<CompanyStoresBloc, SetupState<CompanyStores>> _buildBody() {
    return BlocBuilder<CompanyStoresBloc, SetupState<CompanyStores>>(
      builder: (context, state) {
        return switch (state) {
          LoadingSetup<CompanyStores>() => context.loader,
          SetupsLoaded<CompanyStores>(data: var results) => _buildCard(
            context,
            results,
          ),
          SetupError<CompanyStores>(error: final error) => context.buildError(
            error,
          ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  Widget _buildCard(BuildContext context, List<CompanyStores> stores) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        _workspaceInfoCard(context, showTitle: stores.isNotEmpty),
        _buildStoreSwitchList(context, stores),
      ],
    );
  }

  Wrap _buildStoreSwitchList(BuildContext context, List<CompanyStores> stores) {
    return Wrap(
      spacing: 1,
      runSpacing: 1,
      direction: Axis.horizontal,
      children: [
        _addStores(context),
        ...stores.asMap().entries.map((entry) {
          int index = entry.key;
          CompanyStores store = entry.value;

          return _buildContainer(
            context,
            title: _buildStoreCircleButton(
              context,
              color: randomBgColors[index % randomBgColors.length],
              onPressed: () async => await context.onSwitchStore(
                context,
                storeNumber: store.storeNumber,
              ),
            ),
            subtitle: _buildSubtitle(
              subtitle: '${store.name}\n${store.storeNumber}',
              context,
            ),
          );
        }),
      ],
    );
  }

  _addStores(BuildContext context) {
    final canAddStores = context.canAddMoreStores;

    return _buildContainer(
      context,
      title: _buildStoreCircleButton(
        context,
        color: canAddStores ? kPrimaryLightColor : kGrayBlueColor,
        icon: canAddStores ? Icons.add : Icons.lock,
        onPressed: () async => canAddStores
            ? await context.openAddShopLocations()
            : await context.showUpgradeDialog(),
      ),
      subtitle: _buildSubtitle(subtitle: 'Add stores\nMulti-Location', context),
    );
  }

  _buildContainer(BuildContext context, {Widget? title, Widget? subtitle}) {
    return SizedBox(
      width: 200,
      child: ListTile(
        dense: true,
        title: title,
        subtitle: subtitle,
        titleAlignment: ListTileTitleAlignment.center,
      ),
    );
  }

  _buildStoreCircleButton(
    BuildContext context, {
    IconData? icon,
    required Color color,
    required void Function()? onPressed,
  }) {
    final circleWidth = context.screenWidth * 0.03;

    return IconButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(color),
        shape: WidgetStateProperty.all(const CircleBorder()),
        padding: WidgetStateProperty.all(EdgeInsets.all(40)),
        elevation: WidgetStateProperty.all(80),
      ),
      icon: Icon(
        icon ?? Icons.store,
        color: kLightColor,
        size: context.isMobile ? 40 : circleWidth,
      ),
    );

    /*return MaterialButton(
      onPressed: onPressed,
      color: color,
      minWidth: 100,
      padding: EdgeInsets.all(60),
      shape: const CircleBorder(),
      child: Icon(icon ?? Icons.store, color: kLightColor),
    );*/
  }

  Text _buildSubtitle(BuildContext context, {required String subtitle}) {
    return Text(
      subtitle.toTitleCase,
      style: context.ofTheme.textTheme.bodyLarge?.copyWith(
        color: kPrimaryColor,
        fontWeight: FontWeight.w500,
      ),
      // textScaler: TextScaler.linear(context.textScaleFactor),
      textAlign: TextAlign.center,
    );
  }

  _workspaceInfoCard(BuildContext context, {bool showTitle = true}) {
    final workspace = context.workspace;

    return workspace != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTitle(
                context,
                title: workspace.workspaceName.toUpperCase(),
              ),

              HorizontalLine(
                width: context.screenWidth * 0.01,
                thickness: 4,
                color: kLightBlueColor,
              ),
              _buildListTile(
                context,
                title: 'SUBSCRIPTION: ${workspace.license.name.toUpperCase()}',
                subtitle: 'Valid Until: ${workspace.expiresOn.toStandardDT}',
              ),
              _buildListTile(
                context,
                title:
                    "Multi-Location: ${workspace.maxAllowedDevices > 1 ? 'On' : 'Off'}",
                subtitle: 'Max-Devices: ${workspace.maxAllowedDevices}',
              ),
              _buildTitle(
                context,
                title: 'Hosting: ${workspace.hostingType.label}'.toTitleCase,
              ),
              if (showTitle) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: _buildTitle(
                    context,
                    title: 'Switch Store Locations',
                    style: context.ofTheme.textTheme.titleMedium?.copyWith(
                      color: kLightColor,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ],
          )
        : const SizedBox.shrink();
  }

  Text _buildTitle(
    BuildContext context, {
    String title = '',
    TextStyle? style,
  }) {
    var deco =
        style ??
        context.ofTheme.textTheme.titleMedium?.copyWith(
          color: kLightColor,
          fontWeight: FontWeight.w500,
          overflow: TextOverflow.ellipsis,
        );
    return Text(
      title,
      textAlign: TextAlign.center,
      style: deco,
      overflow: TextOverflow.ellipsis,
      // textScaler: TextScaler.linear(context.textScaleFactor),
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
      titleAlignment: ListTileTitleAlignment.center,
      title: SelectionArea(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: context.ofTheme.textTheme.bodySmall?.copyWith(
            color: kLightColor,
            overflow: TextOverflow.ellipsis,
          ),
          textScaler: TextScaler.linear(context.textScaleFactor),
        ),
      ),
      subtitle: SelectionArea(
        child: Text(
          subtitle,
          textAlign: TextAlign.center,
          style: context.ofTheme.textTheme.bodyLarge?.copyWith(
            color: kLightColor,
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.normal,
          ),
          // textScaler: TextScaler.linear(context.textScaleFactor),
        ),
      ),
    );
  }
}
