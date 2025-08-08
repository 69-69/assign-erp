import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/dialog/bottom_sheet_header.dart';
import 'package:assign_erp/core/widgets/dialog/custom_dialog.dart';
import 'package:flutter/material.dart';

extension LicenseWarningDialog on BuildContext {
  Future<void> showUpgradeWarningDialog() => showModalBottomSheet(
    context: this,
    isDismissible: false,
    isScrollControlled: true,
    backgroundColor: Colors.red.withAlpha((0.5 * 255).toInt()),
    constraints: BoxConstraints(maxWidth: screenWidth),
    builder: (_) => const LicenseWarning(),
  );
}

class LicenseWarning extends StatelessWidget {
  const LicenseWarning({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: DialogTitle(
        title: 'Upgrade your Plan'.toUpperCaseAll,
        subtitle: "Oops, Device Limit Reached!",
        txtColor: kLightColor,
        fontSize: 18,
        textScaler: TextScaler.linear(context.textScaleFactor),
      ),
      icon: Padding(
        padding: const EdgeInsets.all(10),
        child: const Icon(Icons.warning_amber_outlined, color: kLightColor),
      ),

      bgColor: Colors.red[900],
      body: _buildBody(context),
      actions: const [],
    );
  }

  _buildBody(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: context.screenWidth * 0.6,
      padding: EdgeInsets.only(bottom: context.bottomInsetPadding),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: kDangerColor)),
      ),
      child: Text(
        "You've reached the limit of devices for your current plan. To continue using your account, please remove a device or upgrade your subscription to support more devices. If you need help, our 24/7 support team is here for you.\n\nThank You!",
        textAlign: TextAlign.center,
        style: context.textTheme.bodyLarge?.copyWith(
          color: kLightColor,
          fontSize: 13,
          fontWeight: FontWeight.normal,
        ),
        textScaler: TextScaler.linear(context.textScaleFactor),
      ),
    );
  }
}
