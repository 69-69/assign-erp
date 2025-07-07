import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/custom_tab.dart';
import 'package:assign_erp/features/trouble_shooting/presentation/screen/index.dart';
import 'package:flutter/material.dart';

class TroubleShootingApp extends StatelessWidget {
  final String openTab;

  const TroubleShootingApp({super.key, this.openTab = '0'});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: troubleshootScreenTitle,
      body: CustomTab(
        length: 2,
        tabs: [
          {'label': 'App Issues', 'icon': Icons.bug_report_outlined},
          {'label': 'Device Specs', 'icon': Icons.important_devices_outlined},
        ],
        children: [ErrorLogScreen(), UserDeviceSpecScreen()],
      ),
      // floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  /*Widget _buildFloatingActionButton(BuildContext context) {
    return context.buildFloatingBtn(
      'Device Specs',
      icon: Icons.important_devices_sharp,
      onPressed: () => context.openUserDeviceSpecs(),
    );
  }*/
}
