import 'package:assign_erp/core/constants/account_status.dart';
import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/password_hashing.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/custom_bottom_sheet.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/top_header_bottom_sheet.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/setup/data/models/employee_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/create_acc/employee_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:assign_erp/features/setup/presentation/screen/create_acc/widget/form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension CreateEmployeeAcc<T> on BuildContext {
  Future<void> openCreateEmployeeAcc() =>
      openBottomSheet(isExpand: false, child: const _EmployeeAcc());
}

class _EmployeeAcc extends StatelessWidget {
  const _EmployeeAcc();

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      padding: EdgeInsets.only(bottom: context.bottomInsetPadding),
      initialChildSize: 0.90,
      maxChildSize: 0.90,
      header: _buildHeader(context),
      child: BlocBuilder<EmployeeBloc, SetupState<Employee>>(
        builder: (context, state) => _buildBody(context),
      ),
    );
  }

  TopHeaderRow _buildHeader(BuildContext context) {
    return TopHeaderRow(
      title: Text(
        'Add Company Info',
        semanticsLabel: 'add company info',
        style: context.ofTheme.textTheme.titleLarge?.copyWith(
          color: kGrayColor,
        ),
      ),
      btnText: 'Close',
      onPress: () => Navigator.pop(context),
    );
  }

  _buildBody(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
      child: _CreateEmployeeAccFormBody(),
    );
  }
}

class _CreateEmployeeAccFormBody extends StatefulWidget {
  const _CreateEmployeeAccFormBody();

  @override
  State<_CreateEmployeeAccFormBody> createState() =>
      _CreateEmployeeAccFormBodyState();
}

class _CreateEmployeeAccFormBodyState
    extends State<_CreateEmployeeAccFormBody> {
  String _selectedRole = '';
  String _selectedStoreNumber = '';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

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
    role: Employee.getRoleByString(_selectedRole),
    status: AccountStatus.enabled.label,
    workspaceId: context.workspace!.id,
    passCode: PasswordHash.hashPassword(temporalWeakPasscode),
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
          '${_nameController.text.toUppercaseFirstLetterEach} successfully created',
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
        RoleAndStores(
          emailController: _emailController,
          onEmailChanged: (s) {
            if (_formKey.currentState!.validate()) setState(() {});
          },
          onRoleChanged: (s) => setState(() => _selectedRole = s ?? ''),
        ),
        const SizedBox(height: 20.0),
        StoresDropdown(
          onChange: (id, store) => setState(() => _selectedStoreNumber = id),
        ),
        const SizedBox(height: 20.0),
        context.elevatedBtn(label: 'Create Account', onPressed: _onSubmit),
        const SizedBox(height: 20.0),
      ],
    );
  }
}
