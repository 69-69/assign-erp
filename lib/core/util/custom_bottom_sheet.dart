import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/horizontal_line.dart';
import 'package:assign_erp/core/util/neumorphism.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:flutter/material.dart';

/*extension ShowBottomSheet<T> on BuildContext {
  Future<T?> openBottomSheet({required Widget child, bool isExpand = true}) {
    var num = isMobile ? 1 : 0.9;

    return showModalBottomSheet(
      context: this,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints:
          isExpand ? BoxConstraints(maxWidth: screenWidth * num) : null,
      builder: (context) => child,
    );
  }
}*/

extension ShowBottomSheet<T> on BuildContext {
  Future<T?> openBottomSheet({required Widget child, bool isExpand = true}) {
    // Initialize zoom level
    final ValueNotifier<double> zoomLevel =
        ValueNotifier<double>(isExpand ? 1.0 : 0.5);

    return showModalBottomSheet(
      context: this,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(maxWidth: screenWidth),
      builder: (context) => _buildZoom(zoomLevel, child),
    );
  }

  ValueListenableBuilder<double> _buildZoom(
      ValueNotifier<double> zoomLevel, Widget child) {
    var isSmall = isMobile || isTablet;

    return ValueListenableBuilder<double>(
      valueListenable: zoomLevel,
      builder: (context, value, child) {
        return Container(
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          constraints:
              BoxConstraints(maxWidth: screenWidth * (isSmall ? 1 : value)),
          child: Column(
            children: [
              if (!isSmall) ...{
                Align(
                  alignment: Alignment.topCenter,
                  child: IconButton(
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: LinearBorder.none,
                      backgroundColor:
                          (value > 1.0 ? kDangerColor : kGrayBlueColor)
                              .withAlpha((0.4 * 255).toInt()),
                    ),
                    icon: Icon(
                      size: 30,
                      semanticLabel: 'zoom',
                      color: context.ofTheme.colorScheme.surface,
                      value > 1.0 ? Icons.zoom_out_map : Icons.zoom_in_map,
                    ).addNeumorphism(
                      topShadowColor: kDangerColor,
                      offset: const Offset(1, 1),
                    ),
                    onPressed: () => zoomLevel.value = value > 1.0 ? 0.5 : 1.2,
                  ),
                ),
              },
              Expanded(child: child!),
            ],
          ),
        );
      },
      child: child,
    );
  }
}

class CustomBottomSheet extends StatelessWidget {
  final double? initialChildSize, maxChildSize;
  final Widget child;
  final Widget? header;
  final Function()? onPress;
  final EdgeInsets? padding;
  final bool isScrollable;
  final Color? sheetBgColor;

  const CustomBottomSheet({
    super.key,
    required this.child,
    this.onPress,
    this.padding,
    this.isScrollable = true,
    this.initialChildSize,
    this.maxChildSize,
    this.header,
    this.sheetBgColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildSheet() {
      final initialCSize = initialChildSize ?? 0.33;
      final maxCSize = maxChildSize ?? 0.8;

      return makeDismissible(
        context,
        child: DraggableScrollableSheet(
          initialChildSize: initialCSize,
          minChildSize: 0.2,
          maxChildSize: maxCSize,
          builder: (cxt, controller) =>
              isScrollable ? _buildBody(controller, cxt) : child,
        ),
      );
    }

    return buildSheet();
  }

  Widget makeDismissible(BuildContext context, {required Widget child}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPress ?? () => Navigator.of(context).pop(),
      child: GestureDetector(
        onTap: () {},
        child: child,
      ),
    );
  }

  Container _buildBody(ScrollController controller, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16.00),
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        // color: const Color.fromRGBO(0, 0, 0, 0.001),
        color: sheetBgColor ?? context.ofTheme.cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16.00),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.remove, color: context.ofTheme.colorScheme.surface),
          if (header != null) ...{
            header!,
            const HorizontalLine(),
          },
          Expanded(
            child: SingleChildScrollView(
              controller: controller,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
