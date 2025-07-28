import 'package:assign_erp/core/constants/account_status.dart';
import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/adaptive_layout.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/core/widgets/custom_dropdown_field.dart';
import 'package:assign_erp/core/widgets/custom_text_field.dart';
import 'package:assign_erp/features/setup/data/data_sources/remote/get_roles.dart';
import 'package:assign_erp/features/setup/data/models/role_model.dart';
import 'package:assign_erp/features/setup/data/role/employee_role.dart';
import 'package:assign_erp/features/setup/presentation/screen/company/widget/search_stores.dart';
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

/// Employee Role & Email [EmailAndRole]
class EmailAndRole extends StatelessWidget {
  const EmailAndRole({
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

/// Passcode & Store locations Dropdown [StoreLocationsDropdown]
class StoreLocationsAndPasscode extends StatelessWidget {
  final Function(String, String) onStoresChange;
  final TextEditingController passcodeController;
  final Function(String?) onPasscodeChanged;
  final String? serverValue;

  const StoreLocationsAndPasscode({
    super.key,
    this.serverValue,
    required this.onStoresChange,
    required this.onPasscodeChanged,
    required this.passcodeController,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TemporaryPasscode(
          controller: passcodeController,
          onChanged: onPasscodeChanged,
        ),
        StoreLocationsDropdown(
          onChange: onStoresChange,
          serverValue: serverValue,
        ),
      ],
    );
  }
}

/// Generate Temporary Passcode [TemporaryPasscode]
/// Temporary passcode required during employee sign-in process,
/// after the organization's workspace sign-in.
class TemporaryPasscode extends StatefulWidget {
  const TemporaryPasscode({
    super.key,
    required this.onChanged,
    required this.controller,
  });

  final TextEditingController controller;
  final Function(String?) onChanged;

  @override
  State<TemporaryPasscode> createState() => _TemporaryPasscodeState();
}

class _TemporaryPasscodeState extends State<TemporaryPasscode> {
  bool _secureText = true;
  get _controller => widget.controller;
  get helperText =>
      'Generate temporary passcode for employee access to the organization\'s workspace.';

  void showHide() => setState(() => _secureText = !_secureText);

  @override
  void initState() {
    super.initState();
    _controller.text = _generateTemporaryPasscode();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      key: const Key('temp_pass_code_textField'),
      controller: _controller,
      obscureText: _secureText,
      onChanged: widget.onChanged,
      maxLines: 1,
      maxLength: 20,
      autofillHints: const [AutofillHints.password],
      keyboardType: TextInputType.visiblePassword,
      inputDecoration: InputDecoration(
        isDense: true,
        alignLabelWithHint: true,
        prefixIcon: Icon(Icons.lock),
        labelText: 'Temporary Passcode',
        contentPadding: const EdgeInsets.all(1.0),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: FittedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _toggleVisibility(),
              const SizedBox(width: 4),
              _generateButton(context),
              const SizedBox(width: 4),
            ],
          ),
        ),
        helperText: helperText,
      ),
    );
  }

  Widget _generateButton(BuildContext context) {
    return context.elevatedButton(
      'Generate',
      tooltip: helperText,
      color: kLightColor,
      bgColor: kDangerColor,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      onPressed: () => _controller.text = _generateTemporaryPasscode(),
    );
  }

  IconButton _toggleVisibility() {
    return IconButton(
      onPressed: showHide,
      icon: Icon(
        _secureText ? Icons.visibility_off : Icons.visibility,
        color: _secureText ? kGrayColor : kTextColor,
        semanticLabel: 'visibility icon',
      ),
    );
  }

  /// Generates a new Temporary passcode prefixed with [kTemporaryPasscodePrefix].
  String _generateTemporaryPasscode() {
    final tempCode = '$kTemporaryPasscodeLength'.generateUID(
      type: UIDType.numeric,
    );
    return '$kTemporaryPasscodePrefix$tempCode';
  }
}

/// Store locations Dropdown [StoreLocationsDropdown]
class StoreLocationsDropdown extends StatelessWidget {
  final String? serverValue;
  final Function(String, String) onChange;

  const StoreLocationsDropdown({
    super.key,
    required this.onChange,
    this.serverValue,
  });

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
          key: Key('key-emp-role'),
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

/// Employee Role Dropdown [RoleDropdown]
class RoleDropdown extends StatelessWidget {
  final String? serverValue;
  final Function(String, String) onChanged;

  const RoleDropdown({super.key, this.serverValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CustomDropdownSearch<Role>(
      labelText: (serverValue ?? 'Search Role...').toTitleCase,
      asyncItems: (String filter, loadProps) async => await GetRoles.load(),
      filterFn: (role, filter) {
        var f = filter.isEmpty ? (serverValue ?? '') : filter;
        return role.filterByAny(f);
      },
      itemAsString: (role) => role.itemAsString,
      onChanged: (role) => onChanged(role!.id, role.name),
      validator: (role) => role == null ? 'Role is required' : null,
    );
  }

  /*_getProductCategory() async {
    final categories = await GetProductCategory.load();
    return categories.map((m) => m.name).toList();
  }*/
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
