import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/bottom_sheet_header.dart';
import 'package:assign_erp/core/widgets/custom_bottom_sheet.dart';
import 'package:flutter/material.dart';

class FormBottomSheet extends StatelessWidget {
  final String title;
  final Widget body;
  final String? subtitle;

  const FormBottomSheet({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      padding: EdgeInsets.only(bottom: context.bottomInsetPadding),
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      header: _buildHeader(context),
      child: _buildBody(context),
    );
  }

  DialogHeader _buildHeader(BuildContext context) {
    return DialogHeader(
      title: ListTile(
        dense: true,
        title: Text(
          title,
          semanticsLabel: title,
          textAlign: TextAlign.center,
          style: context.ofTheme.textTheme.titleLarge?.copyWith(
            color: kGrayColor,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!.toTitleCase,
                semanticsLabel: subtitle,
                textAlign: TextAlign.center,
                style: context.ofTheme.textTheme.titleMedium?.copyWith(
                  color: kGrayColor,
                ),
              )
            : null,
      ),
      btnText: 'Close',
      onPress: () => Navigator.pop(context),
    );
  }

  _buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: body,
    );
  }
}
