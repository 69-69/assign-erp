import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:flutter/material.dart';

class RightColumnPane extends StatelessWidget {
  final Widget? signOutButton;
  final List<Widget> children;

  const RightColumnPane({
    super.key,
    required this.children,
    this.signOutButton,
  });

  @override
  Widget build(BuildContext context) {
    return _buildRightColumn(context);
  }

  Container _buildRightColumn(BuildContext context) {
    return Container(
      color: kLightBlueColor.withAlpha((0.9 * 255).toInt()),
      width: context.screenWidth,
      height: context.screenHeight,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Need Help?',
                  softWrap: false,
                  style: context.ofTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                    color: context.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              // Sign out button
              ?signOutButton,
            ],
          ),
          divLine,
          ...children,
        ],
      ),
    );
  }
}
