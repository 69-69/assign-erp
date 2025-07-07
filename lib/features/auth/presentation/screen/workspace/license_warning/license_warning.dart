import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:flutter/material.dart';

extension LicenseWarningBottomSheet on BuildContext {
  Future<void> openLicenseWarningPopUp() => showModalBottomSheet(
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
    return AlertDialog(
      scrollable: true,
      icon: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: const Icon(Icons.warning_amber_outlined, color: kLightColor),
        ),
      ),
      iconPadding: const EdgeInsets.only(right: 5, top: 5),
      backgroundColor: Colors.red[900],
      title: Wrap(
        children: [
          _buildTitle(context),
          Divider(color: kDangerColor),
        ],
      ),
      content: _buildBody(context),
      actions: const [],
    );
  }

  _buildTitle(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(
        'Upgrade your Plan'.toUpperCase(),
        textAlign: TextAlign.center,
        style: context.ofTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: kLightColor,
          fontSize: 18,
        ),
        textScaler: TextScaler.linear(context.textScaleFactor),
      ),
      subtitle: Text(
        "Oops, Device Limit Reached!",
        textAlign: TextAlign.center,
        style: context.ofTheme.textTheme.titleSmall?.copyWith(
          color: kLightColor,
          fontSize: 13,
          fontWeight: FontWeight.normal,
        ),
        textScaler: TextScaler.linear(context.textScaleFactor),
      ),
    );
  }

  _buildBody(BuildContext context) {
    return Container(
      width: context.screenWidth * 0.6,
      padding: EdgeInsets.only(bottom: context.bottomInsetPadding),
      child: Text(
        "You've reached the limit of devices for your current plan. To continue using your account, please remove a device or upgrade your subscription to support more devices. If you need help, our 24/7 support team is here for you.\n\nThank You!",
        textAlign: TextAlign.center,
        style: context.ofTheme.textTheme.bodyLarge?.copyWith(
          color: kLightColor,
          fontSize: 13,
          fontWeight: FontWeight.normal,
        ),
        textScaler: TextScaler.linear(context.textScaleFactor),
      ),
    );
  }
}
