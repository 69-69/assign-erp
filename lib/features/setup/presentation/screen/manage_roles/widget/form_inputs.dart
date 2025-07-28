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

class FilterPermissions extends StatelessWidget {
  const FilterPermissions({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      validator: (_) => null,
      keyboardType: TextInputType.none,
      inputDecoration: InputDecoration(
        filled: true,
        labelText: 'Search permissions...',
        prefixIcon: Icon(Icons.search),
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        border: InputBorder.none,
      ),
    );
  }
}
