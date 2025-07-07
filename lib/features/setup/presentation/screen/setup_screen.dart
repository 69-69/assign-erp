import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/custom_tab.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/auth/presentation/screen/workspace/update/update_workspace_password.dart';
import 'package:assign_erp/features/setup/presentation/index.dart';
import 'package:flutter/material.dart';

const _sidetabs = [
  {'label': 'company info', 'icon': Icons.info_outline},
  {'label': 'staff account', 'icon': Icons.manage_accounts},
  {'label': 'product config', 'icon': Icons.category},
  {'label': 'back up', 'icon': Icons.backup},
  {'label': 'renew license', 'icon': Icons.local_police},
  {'label': 'app update', 'icon': Icons.update},
];

class SetupScreen extends StatelessWidget {
  final String openTab;

  const SetupScreen({super.key, this.openTab = '0'});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: setupAppTitle.toUpperCase(),
      body: _buildBody(context),
      actions: const [],
      floatingActionBtnLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: context.buildFloatingBtn(
        'Change Workspace Password',
        icon: Icons.workspaces_outline,
        onPressed: () async => await context.openUpdateWorkspacePopUp(),
      ),
    );
  }

  CustomTab _buildBody(BuildContext context) {
    final openThisTab = int.tryParse(openTab) ?? 0;

    return CustomTab(
      isVerticalTab: true,
      openThisTab: openThisTab,
      length: 6,
      tabs: _sidetabs,
      children: [
        const CompanyInfoScreen(),
        const CreateUserAccScreen(),
        const ProductConfigScreen(),
        const BackUp(),
        const LicenseRenewal(),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: context.screenWidth * 0.1),
          child: Text(
            'All set! You have the latest update installed',
            style: context.ofTheme.textTheme.titleLarge,
            textScaler: TextScaler.linear(context.textScaleFactor),
          ),
        ),
      ],
    );
  }
}
