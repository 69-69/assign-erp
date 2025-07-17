import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:flutter/material.dart';

class HorizontalLine extends StatelessWidget {
  const HorizontalLine({super.key, this.width, this.thickness = 1, this.color});

  final double? width;
  final double thickness;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cl =
        color ?? context.ofTheme.canvasColor.withAlpha((0.07 * 255).toInt());

    return width != null ? _line(cl, context) : _divider(cl);
  }

  _divider(Color color) => Divider(color: color);

  _line(Color color, BuildContext context) => Container(
    color: color,
    height: thickness,
    margin: EdgeInsets.zero,
    padding: EdgeInsets.zero,
    width: context.screenWidth / (width ?? 1),
  );
}
