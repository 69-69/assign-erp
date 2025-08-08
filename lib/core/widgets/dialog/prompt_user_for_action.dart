import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension PromptUserFor on BuildContext {
  /// Prompt User to confirm Pending Action [confirmAction]
  Future<T> confirmAction<T>(
    Widget message, {
    String title = 'Confirm',
    String onAccept = "Yes",
    String onReject = "No",
    String? anyAction,
    Color? barrierColor,
    bool barrierDismissible = true,
  }) async {
    var result = await showDialog(
      context: this,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      builder: (context) => _buildBody(
        context,
        title,
        message,
        onAccept,
        onReject,
        anyAction: anyAction,
      ),
    );
    // result ??= false as T;
    return result as T;
  }

  /// Prompt User to agree to Pending Action [confirmDone]
  Future<void> confirmDone(
    Widget message, {
    String title = 'Confirm',
    String onDone = "OK",
    bool barrierDismissible = true,
  }) async {
    return showCupertinoDialog<void>(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (context) => _buildBody(context, title, message, onDone, ''),
    );
  }

  CupertinoAlertDialog _buildBody(
    BuildContext context,
    String title,
    Widget message,
    String onAccept,
    String onReject, {
    String? anyAction,
  }) {
    var cupertinoAlertDialog = CupertinoAlertDialog(
      title: Padding(padding: const EdgeInsets.all(8.0), child: Text(title)),
      content: message,
      actions: [
        _cupertinoDialogAction(context, label: onAccept),
        if (onReject.isNotEmpty) ...{
          _cupertinoDialogAction(context, label: onReject, status: false),
        },
        if (anyAction != null) ...{
          _cupertinoDialogAction(context, label: anyAction, status: null),
        },
      ],
    );
    return cupertinoAlertDialog;
  }

  CupertinoDialogAction _cupertinoDialogAction(
    BuildContext context, {
    required String label,
    bool? status = true,
  }) {
    return CupertinoDialogAction(
      key: ValueKey(label),
      isDefaultAction: true,
      onPressed: () async => Navigator.pop(context, status),
      child: Text(label, style: TextStyle(color: context.onSecondaryContainer)),
    );
  }
}
