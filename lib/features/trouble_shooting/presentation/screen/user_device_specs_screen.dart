import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/column_row_builder.dart';
import 'package:assign_erp/core/util/custom_snack_bar.dart';
import 'package:assign_erp/core/util/device_info_service.dart';
import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/custom_scroll_bar.dart';
import 'package:assign_erp/core/widgets/data_backup_manager.dart';
import 'package:assign_erp/core/widgets/file_doc_manager.dart';
import 'package:assign_erp/core/widgets/prompt_user_for_action.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/refresh_entire_app.dart';
import 'package:assign_erp/features/trouble_shooting/presentation/widget/restore_backup_preference_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserDeviceSpecScreen extends StatefulWidget {
  const UserDeviceSpecScreen({super.key});

  @override
  State<UserDeviceSpecScreen> createState() => _UserDeviceSpecScreenState();
}

class _UserDeviceSpecScreenState extends State<UserDeviceSpecScreen> {
  final ScrollController _scrollController = ScrollController();
  Map<String, dynamic> _deviceInfo = {};

  @override
  void initState() {
    super.initState();
    _fetchDeviceInfo();
  }

  // Function to copy text to clipboard
  void _copyToClipboard(String textToCopy) async {
    await Clipboard.setData(ClipboardData(text: textToCopy));
    if (mounted) {
      context.showAlertOverlay('Copied to clipboard');
    }
  }

  // Fetch device info from the service
  Future<void> _fetchDeviceInfo() async {
    final deviceInfo = await DeviceInfoService.getDeviceInfo();
    setState(() => _deviceInfo = deviceInfo);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      noAppBar: true,
      body: CustomScrollBar(
        padding: const EdgeInsets.only(top: 28.0),
        controller: _scrollController,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Text(
          'Your Device Specs',
          semanticsLabel: 'user device specs',
          style: context.ofTheme.textTheme.titleLarge?.copyWith(
            color: kTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        divLine,
        _buildDeviceSpecs(context),
        Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Text(
            'Data Manipulation',
            style: context.ofTheme.textTheme.titleLarge?.copyWith(
              color: kTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        divLine,
        _buildCopyAppDataDirectoryPath(context),
        _buildCopyLocalBackupPath(context),
        _buildDeleteDeviceInfo(context),
        _buildDeleteAppData(context),
        _buildRestoreAppDataLocally(context),
      ],
    );
  }

  _buildDeviceSpecs(BuildContext context) {
    return Container(
      color: kGrayColor.withAlpha((0.2 * 255).toInt()),
      alignment: Alignment.bottomLeft,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: context.columnBuilder(
        isScrollable: false,
        itemCount: _deviceInfo.entries.length,
        crossAxisAlignment: CrossAxisAlignment.start,
        itemBuilder: (context, index) {
          final entry = _deviceInfo.entries.elementAt(index);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              '* ${entry.key}: ${entry.value}',
              textAlign: TextAlign.start,
              style: context.ofTheme.textTheme.bodyLarge,
            ),
          );
        },
      ),
    );
  }

  // Widget to copy App-Data-Director path to clipboard
  Widget _buildCopyAppDataDirectoryPath(BuildContext context) {
    return context.optCardBuilder(
      buttonLabel: 'Copy Path',
      label: 'App Data Directory',
      borderColor: kGrayBlueColor,
      icon: Icons.file_copy_sharp,
      desc: 'Path to the app\'s cache directory on this device.',
      onPressed: () async {
        final dir = await FileDocManager.getLocalBackupDir();
        _copyToClipboard(dir.dirPath);
      },
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
  }

  // Widget to copy Local-Backup-path to clipboard
  Widget _buildCopyLocalBackupPath(BuildContext context) {
    return context.optCardBuilder(
      buttonLabel: 'Copy Path',
      label: 'Local Backup Directory',
      borderColor: kPrimaryLightColor,
      icon: Icons.file_copy_sharp,
      desc: 'Path to the temporary backup directory on this device.',
      onPressed: () async {
        final dir = await FileDocManager.getTemporaryDir();
        _copyToClipboard(dir.path);
      },
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
  }

  // Widget to reset user device info
  Widget _buildDeleteDeviceInfo(BuildContext context) {
    return context.optCardBuilder(
      icon: Icons.lock_reset,
      buttonLabel: 'Delete Info',
      borderColor: kWarningColor,
      label: 'Reset Device Info',
      desc: 'Clears all locally cached user\'s device information.',
      onPressed: () async {
        final isConfirmed = await context.confirmAction(
          const Text('Do you want to proceed with resetting the device info?'),
          onAccept: "Reset ID",
          onReject: "Cancel",
        );

        if (isConfirmed) {
          DeviceInfoService.resetCache();
          if (context.mounted) {
            RefreshEntireApp.restartApp(context);
          }
        }
      },
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
  }

  Widget _buildDeleteAppData(BuildContext context) {
    return context.optCardBuilder(
      icon: Icons.reset_tv,
      buttonLabel: 'Factory Reset',
      borderColor: kDangerColor,
      label: 'Factory Reset App',
      desc: 'Deletes all locally cached app data from this device.',
      onPressed: () async {
        final isConfirmed = await context.confirmAction(
          const Text('Do you want to proceed with resetting the app and data?'),
          onAccept: "Factory Reset",
          onReject: "Cancel",
        );

        if (isConfirmed) {
          await DataBackupManager.deleteCacheData();
          if (context.mounted) {
            RefreshEntireApp.restartApp(context);
          }
        }
      },
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
  }

  // Widget to locally restore app data from previous backups
  Widget _buildRestoreAppDataLocally(BuildContext context) {
    return context.optCardBuilder(
      label: 'Restore Data',
      borderColor: kSuccessColor,
      buttonLabel: 'Restore Backup',
      icon: Icons.settings_backup_restore,
      desc: 'Restore data from previously backed-up data (Local | Drive).',
      onPressed: () async {
        final isConfirmed = await context.confirmAction(
          const Text(
            'Do you want to proceed with unzipping and restoring the data?',
          ),
          onAccept: "Continue",
          onReject: "Cancel",
        );

        if (context.mounted && isConfirmed) {
          context.openRestoreBackupPreferencePopUp();
          // _confirmRestoreDialog('Internal');
        }
        // FileDocManager.unzipFile(zipFileName: 'in_app_data.zip');
      },
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
  }
}
