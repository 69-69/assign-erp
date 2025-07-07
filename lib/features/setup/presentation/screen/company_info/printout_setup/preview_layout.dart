import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/custom_bottom_sheet.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/util/top_header_bottom_sheet.dart';
import 'package:flutter/material.dart';

extension PrintoutLayout on BuildContext {
  Future<void> previewLayout({required String img, String layoutName = ''}) =>
      openBottomSheet(
        isExpand: false,
        child: _Layout(img: img, layoutName: layoutName),
      );
}

class _Layout extends StatelessWidget {
  final String img;
  final String layoutName;

  const _Layout({required this.img, required this.layoutName});

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      padding: EdgeInsets.only(
        bottom: context.bottomInsetPadding,
      ),
      sheetBgColor:
          kTextColor, // kCupertinoModalBarrierColor.withAlpha((0.4 * 255).toInt()),
      initialChildSize: 0.90,
      maxChildSize: 0.90,
      header: _buildHeader(context),
      child: _buildBody(context),
    );
  }

  TopHeaderRow _buildHeader(BuildContext context) {
    return TopHeaderRow(
      isBackButton: false,
      title: ListTile(
        dense: true,
        title: Text(
          'Print Layout',
          textAlign: TextAlign.center,
          semanticsLabel: 'Print Layout',
          style: context.ofTheme.textTheme.titleLarge?.copyWith(
            color: kLightColor,
          ),
        ),
        subtitle: Text(
          layoutName.toUppercaseFirstLetterEach,
          textAlign: TextAlign.center,
          style: context.ofTheme.textTheme.titleMedium
              ?.copyWith(color: kLightBlueColor),
        ),
      ),
      color: kLightColor,
      btnText: 'Close',
      onPress: () => Navigator.pop(context),
    );
  }

  _buildBody(BuildContext context) {
    return Wrap(
      children: [
        Image.asset(
          img,
          fit: BoxFit.contain,
          semanticLabel: 'print $layoutName layout',
        ),
      ],
    );
  }
}
