import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/constants/app_enum.dart';
import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/custom_tab.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/manual/data/models/manual_model.dart';
import 'package:assign_erp/features/manual/presentation/bloc/how_to/how_to_bloc.dart';
import 'package:assign_erp/features/manual/presentation/bloc/manual_bloc.dart';
import 'package:assign_erp/features/manual/presentation/screen/how_to_config_app/add/add_manual.dart';
import 'package:assign_erp/features/manual/presentation/screen/how_to_config_app/widgets/body.dart';
import 'package:assign_erp/features/refresh_entire_app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HowToConfigAppScreen extends StatelessWidget {
  final String openTab;

  const HowToConfigAppScreen({super.key, this.openTab = '0'});

  @override
  Widget build(BuildContext context) {
    // Check if the user has access to the Developer dashboard
    final canAccessDev = WorkspaceRoleGuard.canAccessDeveloperDashboard(
      context,
    );

    return BlocProvider<HowToBloc>(
      create: (context) =>
          HowToBloc(firestore: FirebaseFirestore.instance)
            ..add(LoadManuals<Manual>()),
      child: CustomScaffold(
        title: guideToScreenTitle,
        body: _buildBody(context, canAccessDev),
        actions: [
          context.reloadAppIconButton(
            onPressed: () => RefreshEntireApp.restartApp(context),
          ),
        ],
        floatingActionButton: _buildBuildFloatingBtn(context, canAccessDev),
      ),
    );
  }

  Widget? _buildBuildFloatingBtn(BuildContext context, bool canAccessDev) {
    return canAccessDev
        ? context.buildFloatingBtn(
            'New Manual',
            icon: Icons.note_add_outlined,
            onPressed: () async => await context.openAddManual(),
          )
        : null;
  }

  CustomTab _buildBody(BuildContext context, bool canAccessDev) {
    // Check if the user has access to the Agent dashboard
    final canAccessAgent = WorkspaceRoleGuard.canAccessAgentDashboard(context);

    final openThisTab = int.tryParse(openTab) ?? 0;

    final manualCategories = _getFilteredManualTypes(canAccessAgent);

    final tabs = manualCategories.map((type) {
      final label = type[0].toUpperCase() + type.substring(1);
      final icon = _iconForType(type);
      return {'label': label, 'icon': icon};
    }).toList();

    final children = manualCategories
        .map((type) => Body(manualCategory: type, isDeveloper: canAccessDev))
        .toList();

    return CustomTab(
      isVerticalTab: true,
      openThisTab: openThisTab,
      length: manualCategories.length,
      tabs: tabs,
      children: children,
    );
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'agent' => Icons.real_estate_agent,
      'setup' => Icons.settings,
      'pos' => Icons.point_of_sale,
      'crm' => Icons.group,
      'inventory' => Icons.inventory,
      'warehouse' => Icons.warehouse,
      _ => Icons.help_outline,
    };
  }

  List<String> _getFilteredManualTypes(bool canAccessAgent) {
    return canAccessAgent
        ? userManualCategories
        : userManualCategories.where((type) => type != 'agent').toList();
  }
}
