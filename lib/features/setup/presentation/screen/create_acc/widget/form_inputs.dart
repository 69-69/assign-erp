import 'package:assign_erp/core/constants/account_status.dart';
import 'package:assign_erp/core/util/adaptive_layout.dart';
import 'package:assign_erp/core/widgets/custom_dropdown_field.dart';
import 'package:assign_erp/core/widgets/custom_text_field.dart';
import 'package:assign_erp/features/setup/data/models/employee_model.dart';
import 'package:assign_erp/features/setup/presentation/screen/company_info/widget/search_stores.dart';
import 'package:flutter/material.dart';

/// FullName And Mobile number TextField [NameAndMobile]
class NameAndMobile extends StatelessWidget {
  const NameAndMobile({
    super.key,
    required this.mobileController,
    required this.nameController,
    this.onMobileChanged,
    this.onNameChanged,
  });

  final TextEditingController mobileController;
  final TextEditingController nameController;
  final ValueChanged? onMobileChanged;
  final ValueChanged? onNameChanged;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomTextField(
          labelText: 'Full name',
          onChanged: onNameChanged,
          controller: nameController,
          keyboardType: TextInputType.name,
        ),
        CustomTextField(
          labelText: 'Mobile number',
          onChanged: onMobileChanged,
          controller: mobileController,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}

/// Role & Email [RoleAndStores]
class RoleAndStores extends StatelessWidget {
  const RoleAndStores({
    super.key,
    required this.onRoleChanged,
    required this.emailController,
    this.onEmailChanged,
    this.serverRole,
  });

  final TextEditingController emailController;
  final ValueChanged? onEmailChanged;
  final Function(String?) onRoleChanged;
  final String? serverRole;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomTextField(
          labelText: 'Email address',
          onChanged: onEmailChanged,
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        CustomDropdown(
          items: employeeRolesToList(),
          labelText: 'employee role',
          serverValue: serverRole,
          onValueChange: (String? v) => onRoleChanged(v),
        ),
      ],
    );
  }
}

/// Stores location Dropdown [StoresDropdown]
class StoresDropdown extends StatelessWidget {
  final String? serverValue;
  final Function(String, String) onChange;

  const StoresDropdown({super.key, required this.onChange, this.serverValue});

  @override
  Widget build(BuildContext context) {
    return SearchStores(
      serverValue: serverValue,
      onChanged: (id, store) => onChange(id, store),
    );
  }
}

/// Employee Role & Account Status [EmployeeRoleAndStatus]
class EmployeeRoleAndStatus extends StatelessWidget {
  const EmployeeRoleAndStatus({
    super.key,
    this.serverStatus,
    required this.onStatusChanged,
    required this.onRoleChanged,
    this.serverRole,
  });

  final Function(String?) onRoleChanged;
  final String? serverRole;
  final Function(String?) onStatusChanged;
  final String? serverStatus;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomDropdown(
          key: key,
          items: employeeRolesToList(),
          labelText: 'employee role',
          serverValue: serverRole,
          onValueChange: (String? v) => onRoleChanged(v),
        ),
        CustomDropdown(
          key: key,
          items: accountStatusList,
          labelText: accountStatusList.first,
          serverValue: serverStatus,
          onValueChange: (String? v) => onStatusChanged(v),
        ),
      ],
    );
  }
}

/*
/// Role & Email [RoleAndStores]
class RoleAndStores extends StatelessWidget {
  const RoleAndStores({
    super.key,
    required this.onStoreChanged,
    required this.emailController,
    this.onEmailChanged,
    this.serverStore,
  });

  final TextEditingController emailController;
  final ValueChanged? onEmailChanged;
  final String? serverStore;
  final Function(String, String) onStoreChanged;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomTextField(
          labelText: 'Email address',
          onChanged: onEmailChanged,
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        SearchStores(
          serverValue: serverStore,
          onChanged: (id, store) => onStoreChanged(id, store),
        ),
      ],
    );
  }
}
*/
