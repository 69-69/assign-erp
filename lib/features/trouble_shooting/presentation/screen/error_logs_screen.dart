import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/dynamic_table.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/trouble_shooting/data/data_sources/local/error_logs_cache.dart';
import 'package:assign_erp/features/trouble_shooting/data/models/error_logs_model.dart';
import 'package:flutter/material.dart';

class ErrorLogScreen extends StatefulWidget {
  const ErrorLogScreen({super.key});

  @override
  State<ErrorLogScreen> createState() => _ErrorLogScreenState();
}

class _ErrorLogScreenState extends State<ErrorLogScreen> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            'Error Logs'.toUpperCaseAll,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: kPrimaryLightColor,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
            textScaler: TextScaler.linear(context.textScaleFactor * 0.8),
          ),
        ),
        _buildCard(context),
      ],
    );
  }

  List<ErrorLog> _errorLogs() => ErrorLogCache().getLogs();

  Widget _buildCard(BuildContext context) {
    final logs = _errorLogs();

    return DynamicDataTable(
      skip: false,
      toggleHideID: true,
      headers: ErrorLog.dataTableHeader,
      rows: logs.map((l) => l.toListL()).toList(),
      onDeleteTap: (row) async => await _onDeleteTap(logs, row),
    );
  }

  Future<void> _onDeleteTap(List<ErrorLog> logs, List<String> row) async {
    {
      final log = ErrorLog.findLogsById(logs, row.first).first;
      {
        final isConfirmed = await context.confirmUserActionDialog();
        if (isConfirmed) {
          await ErrorLogCache().clearById(log.id ?? '');
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      }
    }
  }
}
