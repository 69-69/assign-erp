import 'package:flutter/material.dart';

/// Controls global tooltip visibility using a ValueNotifier.
class TooltipController {
  static final ValueNotifier<bool> enabled = ValueNotifier(true);

  static void enable() => enabled.value = true;
  static void disable() => enabled.value = false;
  static void toggle() => enabled.value = !enabled.value;
}

/// A widget that conditionally shows a Tooltip based on TooltipController.
class DelayedTooltip extends StatelessWidget {
  final String message;
  final Widget child;
  final Color? bgColor;

  const DelayedTooltip({
    super.key,
    required this.message,
    required this.child,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: TooltipController.enabled,
      builder: (context, canShow, _) {
        return canShow
            ? Tooltip(
                message: message,
                decoration: bgColor != null
                    ? BoxDecoration(color: bgColor)
                    : null,
                child: child,
              )
            : child;
      },
    );
  }
}
