import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/widgets/custom_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/custom_tab.dart';
import 'package:assign_erp/core/widgets/top_header_bottom_sheet.dart';
import 'package:assign_erp/features/trouble_shooting/presentation/widget/restore_data/index.dart';
import 'package:flutter/material.dart';

extension UserDeviceSpecsBottomSheet<T> on BuildContext {
  Future<void> openRestoreBackupPreferencePopUp() =>
      openBottomSheet(isExpand: false, child: RestoreBackupPreference());
}

class RestoreBackupPreference extends StatelessWidget {
  const RestoreBackupPreference({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      padding: EdgeInsets.only(bottom: context.bottomInsetPadding),
      initialChildSize: 0.90,
      maxChildSize: 0.90,
      header: _buildHeader(context),
      child: SizedBox(height: context.screenHeight, child: _buildBody(context)),
    );
  }

  TopHeaderRow _buildHeader(BuildContext context) {
    return TopHeaderRow(
      title: ListTile(
        title: Text(
          'Data Restore Preference',
          textAlign: TextAlign.center,
          style: context.ofTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: kTextColor,
          ),
        ),
        subtitle: Text(
          'Select your data restore/recovery source',
          textAlign: TextAlign.center,
          style: context.ofTheme.textTheme.titleSmall?.copyWith(
            color: kGrayColor,
          ),
        ),
      ),
      btnText: 'Close',
      onPress: () => Navigator.pop(context),
    );
  }

  _buildBody(BuildContext context) {
    return CustomTab(
      length: 3,
      isColoredTab: false,
      padding: EdgeInsets.zero,
      tabs: [
        {'label': 'From Local', 'icon': Icons.computer},
        {'label': 'From Drive', 'icon': Icons.storage_sharp},
        {'label': 'From Cloud', 'icon': Icons.cloud_download},
      ],
      children: [RestoreFromLocalDoc(), RestoreFromDrive(), RestoreFromCloud()],
    );
  }
}
