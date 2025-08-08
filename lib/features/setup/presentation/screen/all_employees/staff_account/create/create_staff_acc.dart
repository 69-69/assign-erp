import 'package:assign_erp/core/constants/account_status.dart';
import 'package:assign_erp/core/util/secret_hasher.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/dialog/custom_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/dialog/form_bottom_sheet.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/setup/data/models/employee_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/create_acc/employee_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:assign_erp/features/setup/presentation/screen/all_employees/staff_account/widget/form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension CreateStaffAcc<T> on BuildContext {
  Future<void> openCreateStaffAcc() => openBottomSheet(
    isExpand: false,
    child: FormBottomSheet(title: 'Add New Staff', body: _CreateStaffAccForm()),
  );
}

class _CreateStaffAccForm extends StatefulWidget {
  const _CreateStaffAccForm();

  @override
  State<_CreateStaffAccForm> createState() => _CreateStaffAccFormState();
}

class _CreateStaffAccFormState extends State<_CreateStaffAccForm> {
  String _selectedRoleId = '';
  String _selectedRole = '';
  String _selectedStoreNumber = '';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passcodeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Employee get _employee => Employee(
    fullName: _nameController.text,
    email: _emailController.text,
    mobileNumber: _phoneController.text,
    storeNumber: _selectedStoreNumber,
    roleId: _selectedRoleId,
    role: _selectedRole,
    status: AccountStatus.enabled.label,
    workspaceId: context.workspace!.id,
    passCode: SecretHasher.hash(_passcodeController.text),
    createdBy: context.employee!.fullName,
  );

  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      /// Create employee account
      final item = _employee;

      context.read<EmployeeBloc>().add(AddSetup<Employee>(data: item));

      _formKey.currentState!.reset();

      if (mounted) {
        context.showAlertOverlay(
          '${_nameController.text.toTitleCase} successfully created',
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: _buildBody(context),
    );
  }

  Column _buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: 20.0),
        NameAndMobile(
          nameController: _nameController,
          mobileController: _phoneController,
          onNameChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
          onMobileChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
        ),
        const SizedBox(height: 20.0),
        EmailAndRole(
          emailController: _emailController,
          onEmailChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
          onRoleChanged: (id, role) {
            if (_formKey.currentState!.validate()) {
              setState(() {
                _selectedRoleId = id!;
                _selectedRole = role!;
              });
            }
          },
        ),
        const SizedBox(height: 20.0),
        StoreLocationsAndPasscode(
          passcodeController: _passcodeController,
          onPasscodeChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
          onStoresChange: (id, store) =>
              setState(() => _selectedStoreNumber = id),
        ),
        const SizedBox(height: 20.0),
        context.confirmableActionButton(
          label: 'Add Staff',
          onPressed: _onSubmit,
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }
}
