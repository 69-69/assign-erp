import 'package:assign_erp/core/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

/// FullName And Mobile number TextField [RoleName]
class RoleName extends StatelessWidget {
  const RoleName({
    super.key,
    this.enable,
    required this.nameController,
    this.onNameChanged,
  });

  final TextEditingController nameController;
  final ValueChanged? onNameChanged;
  final bool? enable;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      labelText: 'Role name',
      onChanged: onNameChanged,
      controller: nameController,
      keyboardType: TextInputType.name,
      enable: enable,
    );
  }
}
