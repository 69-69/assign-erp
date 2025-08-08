import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:flutter/material.dart';

class FormTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const FormTitle({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return _buildTitle(context);
  }

  Row _buildTitle(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildCard(
            context,
            color: kLightColor.withAlpha((0.8 * 255).toInt()),

            child: ListTile(
              titleAlignment: ListTileTitleAlignment.center,
              title: Text(
                title.toTitleCase,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: kPrimaryColor,
                ),
                textScaler: TextScaler.linear(context.textScaleFactor),
              ),
              subtitle: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: context.textTheme.titleSmall?.copyWith(
                  color: kTextColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _buildCard(BuildContext context, {Color? color, Widget? child}) {
    return Card(
      elevation: 50,
      color: color ?? kLightColor.withAlpha((0.8 * 255).toInt()),
      margin: context.isMobile || context.isTablet
          ? null
          : const EdgeInsets.symmetric(horizontal: 150),
      child: child,
    );
  }
}
