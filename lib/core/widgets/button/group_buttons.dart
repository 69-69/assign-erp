import 'package:flutter/material.dart';

class GroupButtons extends StatefulWidget {
  const GroupButtons({
    super.key,
    this.iconColor,
    this.fillColor,
    this.selectedColor,
    this.selectedBorderColor,
    required this.children,
    this.borderRadius,
  });

  final double? borderRadius;
  final Color? iconColor;
  final Color? fillColor;
  final Color? selectedColor;
  final Color? selectedBorderColor;
  final List<Widget> children;

  @override
  State<GroupButtons> createState() => _GroupButtonsState();
}

class _GroupButtonsState extends State<GroupButtons> {
  // bool vertical = false;

  // Generate the list of booleans
  List<bool> get _selectedButton => List<bool>.generate(
      widget.children.length, (index) => index == widget.children.length - 1);


  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      direction: Axis.horizontal,
      onPressed: (int index) {
        setState(() {
          // The button that is tapped is set to true, and the others to false.
          for (int i = 0; i < _selectedButton.length; i++) {
            _selectedButton[i] = i == index;
          }
        });
      },
      borderRadius: BorderRadius.all(
        Radius.circular(widget.borderRadius ?? 20.0),
      ),
      selectedBorderColor: widget.selectedBorderColor,
      selectedColor: widget.selectedColor,
      fillColor: widget.fillColor,
      color: widget.iconColor,
      isSelected: _selectedButton,
      children: widget.children,
    );
  }
}
