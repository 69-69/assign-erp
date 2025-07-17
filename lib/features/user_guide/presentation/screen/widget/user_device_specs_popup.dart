import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/widgets/custom_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/top_header_bottom_sheet.dart';
import 'package:flutter/material.dart';

extension LiveSupportBottomSheet<T> on BuildContext {
  Future<void> openLiveSupportDialog() =>
      openBottomSheet(isExpand: false, child: _LiveSupport());
}

class _LiveSupport extends StatefulWidget {
  const _LiveSupport();

  @override
  State<_LiveSupport> createState() => _LiveSupportState();
}

class _LiveSupportState extends State<_LiveSupport> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      padding: EdgeInsets.only(bottom: context.bottomInsetPadding),
      initialChildSize: 0.90,
      maxChildSize: 0.90,
      header: _buildHeader(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildBody(context)],
      ),
    );
  }

  TopHeaderRow _buildHeader(BuildContext context) {
    return TopHeaderRow(
      title: Text(
        'Live Chat',
        semanticsLabel: 'live chat',
        style: context.ofTheme.textTheme.titleLarge?.copyWith(
          color: kGrayColor,
        ),
      ),
      btnText: 'Close',
      onPress: () => Navigator.pop(context),
    );
  }

  _buildBody(BuildContext context) {
    return Container(
      color: kGrayColor.withAlpha((0.2 * 255).toInt()),
      alignment: Alignment.bottomLeft,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Text('chat message'),
    );
  }
}
