import 'package:assign_erp/core/util/size_config.dart';
import 'package:flutter/material.dart';

class HorizontalLine extends StatelessWidget {
  const HorizontalLine({
    super.key,
    this.width,
    this.thickness = 1,
  });

  final double? width;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).canvasColor.withAlpha((0.07 * 255).toInt());

    return width != null ? _line(color, context) : _divider(color);
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
