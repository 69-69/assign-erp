import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/widgets/dialog/prompt_user_for_action.dart';
import 'package:flutter/material.dart';

extension Custombutton on BuildContext {
  /// [confirmableActionButton] A customizable elevated button widget that optionally shows a confirmation dialog
  /// before executing an action. Ideal for form submissions or critical updates.
  ///
  /// Parameters:
  /// - [label]: The text shown on the button. If empty, a confirmation dialog will be shown before proceeding.
  /// - [onPressed]: The callback function to execute when the button is pressed.
  /// - [isDisabled]: Whether the button should appear disabled.
  ///
  /// Behavior:
  /// - If the [label] is empty, the button shows a confirmation dialog before running [onPressed].
  /// - If [isDisabled] is true, the button becomes non-interactive and lowers its opacity.
  Widget confirmableActionButton({
    String label = 'Save Changes',
    VoidCallback? onPressed,
    bool isDisabled = false,
    String? tooltip,
    ButtonStyle? style,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: label.isEmpty
                ? () async {
                    final isConfirmed = await _confirmUpdateDialog();

                    if (mounted && isConfirmed) {
                      onPressed!();
                    }
                  }
                : onPressed,
            style:
                style ??
                ButtonStyle(
                  padding: const WidgetStatePropertyAll(EdgeInsets.all(20)),
                  backgroundColor: WidgetStatePropertyAll(
                    ofTheme.colorScheme.primary.withAlpha(
                      ((isDisabled ? 0.4 : 1) * 255).toInt(),
                    ),
                  ),
                  elevation: isDisabled
                      ? const WidgetStatePropertyAll(0)
                      : null,
                ),
            child: Tooltip(
              message: tooltip ?? label,
              child: Text(
                label,
                style: const TextStyle(color: kLightColor),
                semanticsLabel: label,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget elevatedIconBtn(
    dynamic icon, {
    String label = '',
    VoidCallback? onPressed,
    Color? bgColor,
    Color? color,
    String? tooltip,
    ButtonStyle? style,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style:
          style ??
          ElevatedButton.styleFrom(backgroundColor: bgColor ?? Colors.white70),

      icon: icon is IconData ? Icon(icon) : icon,
      label: Tooltip(
        message: tooltip ?? label,
        child: Text(
          label,
          style: TextStyle(color: color),
          semanticsLabel: label,
        ),
      ),
    );
  }

  /// [elevatedButton] A customizable elevated button widget.
  ///
  Widget elevatedButton(
    String label, {
    VoidCallback? onPressed,
    Color? bgColor,
    Color? color,
    String? tooltip,
    EdgeInsetsGeometry? padding,
    ButtonStyle? style,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style:
          style ??
          ElevatedButton.styleFrom(
            backgroundColor: bgColor ?? kLightGrayColor,
            padding: padding,
          ),
      child: Tooltip(
        message: tooltip ?? label,
        child: Text(
          label,
          style: TextStyle(color: color),
          semanticsLabel: label,
        ),
      ),
    );
  }

  Future<bool> _confirmUpdateDialog() async => await confirmAction<bool>(
    const Text('Would you like to proceed?'),
    title: "Confirm Changes",
    onAccept: "Save",
    onReject: "Cancel",
  );
}
