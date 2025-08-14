import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/button/custom_button.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/dialog/custom_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/dialog/form_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/setup/data/models/employee_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/create_acc/employee_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:assign_erp/features/setup/presentation/screen/all_employees/staff_account/widget/form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension UpdateStaffAccount<T> on BuildContext {
  Future<void> openUpdateStaffAcc({Employee? employee}) => openBottomSheet(
    isExpand: false,
    child: FormBottomSheet(
      title: "Edit Employee's Account",
      subtitle: employee?.fullName,
      body: _UpdateStaffAccForm(employee: employee!),
    ),
  );
}

class _UpdateStaffAccForm extends StatefulWidget {
  final Employee employee;

  const _UpdateStaffAccForm({required this.employee});

  @override
  State<_UpdateStaffAccForm> createState() => _UpdateStaffAccFormState();
}

class _UpdateStaffAccFormState extends State<_UpdateStaffAccForm> {
  Employee get _employee => widget.employee;

  String? _selectedRoleId;
  String? _selectedStatus;
  String? _selectedStoreNumber;

  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: _employee.fullName);
  late final _emailController = TextEditingController(text: _employee.email);
  late final _phoneController = TextEditingController(
    text: _employee.mobileNumber,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      /// Update employee account
      final item = _employee.copyWith(
        fullName: _nameController.text,
        email: _emailController.text,
        mobileNumber: _phoneController.text,
        storeNumber: _selectedStoreNumber ?? _employee.storeNumber,
        roleId: _selectedRoleId ?? _employee.roleId,
        // role: Employee.getRoleByString(_selectedRole ?? _employee.role.name),
        updatedBy: context.employee!.fullName,
        // status: _employee.status,
        // workspaceId: _employee.workspaceId,
        // createdBy: _employee.createdBy,
      );

      context.read<EmployeeBloc>().add(
        UpdateSetup<Employee>(documentId: _employee.id, data: item),
      );

      _formKey.currentState!.reset();

      if (mounted) {
        _toastMsg('account');

        Navigator.pop(context);
      }
    }
  }

  void _toastMsg(String title) {
    context.showAlertOverlay(
      '${_employee.fullName.toTitleCase} $title updated',
    );
  }

  /// Update Employee Account Status
  void _updateAccountStatus(String status) {
    _employee.copyWith(status: status);
    setState(() => _selectedStatus = status);

    context.read<EmployeeBloc>().add(
      UpdateSetup<Employee>(
        documentId: _employee.id,
        mapData: {'status': status},
      ),
    );

    _toastMsg('status');
  }

  /// Update Employee store location
  void _updateStoreLocation(String storeNumber) {
    _employee.copyWith(storeNumber: storeNumber);
    setState(() => _selectedStoreNumber = storeNumber);

    context.read<EmployeeBloc>().add(
      UpdateSetup<Employee>(
        documentId: _employee.id,
        mapData: {'storeNumber': storeNumber},
      ),
    );

    _toastMsg('store location');
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
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Account Status & Store Location',
          style: context.textTheme.titleLarge,
        ),
        const SizedBox(height: 10.0),
        AccountStatusAndStoreLocations(
          key: const Key('Update-employee-role-acc-Status'),
          serverStore: _employee.storeNumber,
          serverStatus: _selectedStatus ?? _employee.status,
          onStoresChange: (id, role) =>
              id.isNullOrEmpty ? null : _updateStoreLocation(id!),
          onStatusChanged: (v) =>
              v.isNullOrEmpty ? null : _updateAccountStatus(v!),
        ),
        divLine,
        _formBody(),
      ],
    );
  }

  ExpansionTile _formBody() {
    return ExpansionTile(
      dense: true,
      title: Text(
        'Manage this Account',
        textAlign: TextAlign.center,
        style: context.textTheme.titleLarge,
      ),
      subtitle: Text(
        _employee.fullName.toTitleCase,
        textAlign: TextAlign.center,
      ),
      childrenPadding: const EdgeInsets.only(bottom: 20.0),
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
          serverRole: _employee.role,
          emailController: _emailController,
          onEmailChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
          onRoleChanged: (id, role) =>
              setState(() => _selectedRoleId = id ?? ''),
        ),
        const SizedBox(height: 20.0),
        context.confirmableActionButton(onPressed: _onSubmit),
      ],
    );
  }
}
