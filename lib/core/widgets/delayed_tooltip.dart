import 'package:flutter/material.dart';

class TooltipController {
  static bool enabled = true;
}

class DelayedTooltip extends StatefulWidget {
  final String message;
  final Widget child;

  const DelayedTooltip({super.key, required this.message, required this.child});

  @override
  State<DelayedTooltip> createState() => _DelayedTooltipState();
}

class _DelayedTooltipState extends State<DelayedTooltip> {
  bool _canShow = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && TooltipController.enabled) {
        setState(() => _canShow = !_canShow);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _canShow
        ? Tooltip(message: widget.message, child: widget.child)
        : widget.child;
  }
}
