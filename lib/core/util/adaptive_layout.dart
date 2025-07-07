import 'package:flutter/material.dart';
import 'package:assign_erp/core/util/size_config.dart';

class AdaptiveLayout extends StatelessWidget {
  // adaptive: If false, layout won't switch between ROWS and COLUMNS
  final int? firstFlex;
  final bool isSizedBox;
  final bool isFormBuilder;
  final List<Widget> children;
  final MainAxisSize mainAxisSize;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final Function(double)? layoutWidth;

  const AdaptiveLayout({
    super.key,
    required this.children,
    this.isSizedBox = true,
    this.isFormBuilder = true,
    this.mainAxisSize = MainAxisSize.max,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.layoutWidth,
    this.firstFlex,
  });

  @override
  Widget build(BuildContext context) {
    return isFormBuilder
        ? _buildFormBuilderAdaptive(context)
        : _buildLayoutBuilderAdaptive();
  }

  /*isScrollable
    ? context.columnBuilder(
        mainAxisSize: mainAxisSize,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        itemCount: children.length,
        itemBuilder: (_, index) => children[index],
      )
    : */

  LayoutBuilder _buildLayoutBuilderAdaptive() {
    return LayoutBuilder(
      builder: (context, constraints) {
        layoutWidth?.call(constraints.maxWidth);

        /// Height > Width
        final isMoreTallThanWide = constraints.maxHeight > constraints.maxWidth;

        var device = switch (isMoreTallThanWide) {
        /// Its in Portrait Mode: Tall Screen Height
          true => _buildColumn(),

        /// Its in LandScape Mode: Wide Screen Width
          _ => _buildRow()
        };

        return device;
      },
    );
  }

  Widget _buildFormBuilderAdaptive(BuildContext context) {
    var isColumn =
        context.isMobile || (context.isTablet && context.isPortraitMode);

    return isColumn
        ? _buildColumn(c: _isAdaptive(isColumn))
        : _buildRow(c: _isAdaptive(isColumn));
  }

  Row _buildRow({List<Widget>? c}) =>
      Row(
        mainAxisSize: mainAxisSize,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: c ?? children,
      );

  Column _buildColumn({List<Widget>? c}) =>
      Column(
        mainAxisSize: mainAxisSize,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: c ?? children,
      );

  List<Widget> _isAdaptive(bool isColumn) {
    if (children.isEmpty) return [];

    List<Widget> result = [];
    SizedBox space =
    isColumn ? const SizedBox(height: 20.0) : const SizedBox(width: 20.0);

    for (int i = 0; i < children.length; i++) {
      var flex = i > 0 ? 1 : (firstFlex ?? 1);

      final child =
      isColumn ? children[i] : Expanded(flex: flex, child: children[i]);

      result.add(child);

      if (isSizedBox && i < children.length - 1) {
        result.add(space);
      }
    }

    return result;
  }
}
