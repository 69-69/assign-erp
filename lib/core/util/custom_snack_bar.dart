import 'dart:async';

import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:flutter/material.dart';

/// Helper class to show a snackBar using the passed context.
/*class ScaffoldSnackBar {
  // ignore: public_member_api_docs
  ScaffoldSnackBar(this._context);

  /// The scaffold of current context.
  factory ScaffoldSnackBar.of(BuildContext context) {
    return ScaffoldSnackBar(context);
  }

  final BuildContext _context;

  /// Helper method to show a SnackBar.
  void show(String message) {
    ScaffoldMessenger.of(_context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}*/

extension ScaffoldSnackBar on BuildContext {
  /// Material Banner [showCustomMaterialBanner]
  void showCustomMaterialBanner(String message) {
    /*ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showMaterialBanner()*/

    final banner = MaterialBanner(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      leading: const Icon(Icons.info, color: Colors.white),
      backgroundColor: Colors.green,
      actions: [
        TextButton(
          onPressed: () =>
              ScaffoldMessenger.of(this).hideCurrentMaterialBanner(),
          child: const Text('DISMISS', style: TextStyle(color: Colors.white)),
        ),
      ],
    );

    ScaffoldMessenger.of(this).showMaterialBanner(banner);

    // Automatically hide the banner after 3 seconds
    Timer(const Duration(seconds: 3), () {
      ScaffoldMessenger.of(this).hideCurrentMaterialBanner();
    });
  }

  void showAlertOverlay(
    String message, {
    Color? bgColor,
    String? label,
    VoidCallback? onPressed,
    int? duration,
  }) {
    OverlayEntry? overlayEntry;
    final overlay = Overlay.of(this);

    // Remove the OverlayEntry.
    void removeHighlightOverlay() {
      overlayEntry?.remove();
      overlayEntry?.dispose();
      overlayEntry = null;
    }

    // Remove the existing OverlayEntry.
    removeHighlightOverlay();

    assert(overlayEntry == null);

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50.0,
        left: 20.0,
        right: 20.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: bgColor ?? Colors.green,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            padding: const EdgeInsets.all(6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: context.copyPasteText(
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                if (label != null && onPressed != null)
                  TextButton(
                    onPressed: onPressed,
                    child: Text(
                      label,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: removeHighlightOverlay,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry!);

    // Remove the overlay after a delay
    Future.delayed(
      Duration(seconds: duration ?? 4),
      () => overlayEntry?.remove(),
    );
  }

  /// Material SnackBar [showAlertOverlay]
  void showCustomSnackBar(
    String message, {
    Color? bgColor,
    String? label,
    VoidCallback? onPressed,
  }) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: bgColor ?? Colors.green,
      duration: const Duration(seconds: 4),
      margin: EdgeInsets.only(bottom: screenHeight - 200),
      action: SnackBarAction(
        label: label ?? 'Close',
        textColor: Colors.white,
        onPressed:
            onPressed ??
            () {
              if (mounted) {
                // Perform some action when the action button is clicked
                ScaffoldMessenger.of(this).hideCurrentSnackBar();
              }
              // ..didChangeDependencies();
            },
      ),
    );

    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}

class ShowToast extends StatefulWidget {
  final String message;

  const ShowToast({super.key, required this.message});

  @override
  State<ShowToast> createState() => _ShowToastState();
}

class _ShowToastState extends State<ShowToast> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isVisible = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isVisible
        ? Card(
            color: Colors.green,
            elevation: 5.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
