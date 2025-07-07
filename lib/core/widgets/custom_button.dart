import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/widgets/prompt_user_for_action.dart';
import 'package:flutter/material.dart';

extension Custombutton on BuildContext {
  Widget elevatedBtn({
    String label = 'Save Changes',
    VoidCallback? onPressed,
    bool isDisabled = false,
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
            style: ButtonStyle(
              padding: const WidgetStatePropertyAll(EdgeInsets.all(20)),
              backgroundColor: WidgetStatePropertyAll(
                ofTheme.colorScheme.secondary.withAlpha(
                  ((isDisabled ? 0.4 : 1) * 255).toInt(),
                ),
              ),
              elevation: isDisabled ? const WidgetStatePropertyAll(0) : null,
            ),
            child: Text(label, style: const TextStyle(color: kLightColor)),
          ),
        ),
      ],
    );
  }

  Widget elevatedIconBtn(
    IconData icon, {
    String label = '',
    VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.white70),
      icon: Icon(icon),
      label: Tooltip(message: label, child: Text(label)),
    );
  }

  Future<bool> _confirmUpdateDialog() async => await confirmAction(
    const Text('Are you sure?'),
    title: "Confirm Changes",
    onAccept: "Save",
    onReject: "Cancel",
  );
}
