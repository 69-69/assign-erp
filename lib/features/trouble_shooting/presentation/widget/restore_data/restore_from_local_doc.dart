import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/network/data_sources/local/backup_filenames_cache.dart';
import 'package:assign_erp/core/result/result.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/async_progress_dialog.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/core/widgets/custom_dropdown_field.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/data_backup_manager.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:flutter/material.dart';

class RestoreFromLocalDoc extends StatefulWidget {
  const RestoreFromLocalDoc({super.key});

  @override
  State<RestoreFromLocalDoc> createState() => _RestoreFromLocalDocState();
}

class _RestoreFromLocalDocState extends State<RestoreFromLocalDoc> {
  String? _selectedFilename;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Restore Data from Local backup (e.g., app data)',
            style: context.ofTheme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 20),
          _getLocalBackupFilenames(context),
          SizedBox(height: 20),
          context.elevatedBtn(
            isDisabled: _selectedFilename.isNullOrEmpty,
            label: 'Restore From Local',
            onPressed: () async => await _confirmRestoreDialog(context),
          ),
        ],
      ),
    );
  }

  CustomDropdown _getLocalBackupFilenames(BuildContext context) {
    final items = BackupFilenameCache().getFilenames();
    return CustomDropdown(
      items: items,
      labelText: 'List of Local Backup Files',
      onValueChange: (String? v) => setState(() {
        _selectedFilename = v?.toLowerCase();
      }),
    );
  }

  // Widget to confirm restore dialog
  Future<void> _confirmRestoreDialog(BuildContext context) async {
    final isConfirmed = await context.confirmUserActionDialog(
      onAccept: "Restore",
      msg: "Do you want to proceed with restoring the data?",
    );

    if (context.mounted && isConfirmed) {
      await context.progressBarDialog(
        child: Text('Restoring data locally...'),
        request: _restoreFromLocalDoc(),
        onSuccess: (_) =>
            context.showAlertOverlay('Local backup restored successfully'),
        onError: (error) => context.showAlertOverlay(
          'Local backup failed to restore: $error',
          bgColor: kDangerColor,
        ),
      );
    }
  }

  /// Restore from internal directories/folders (e.g., app data)
  Future<dynamic> _restoreFromLocalDoc() =>
      Future.delayed(wAnimateDuration, () async {
        try {
          final restoreResult = await DataBackupManager.startRestore(
            isLocal: true,
            zipFileName: _selectedFilename ?? '',
          );

          if (restoreResult is Success<String>) {
            debugPrint(
              'Local backup restored successfully ${restoreResult.data}',
            );
            return;
          }
          throw Exception('Restoring failed');
        } catch (e) {
          throw Exception('Restoring failed: $e');
        }
      });
}
