import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/bottom_sheet_header.dart';
import 'package:assign_erp/core/widgets/custom_dialog.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/features/setup/data/models/employee_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/create_acc/employee_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:assign_erp/features/setup/presentation/screen/staff_account/widget/form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension AssignEmployeeRolePopUp on BuildContext {
  Future<void> openAssignEmployeeRolePopUp({
    required String employeeId,
    String? employeeName,
  }) => showModalBottomSheet(
    context: this,
    isDismissible: false,
    isScrollControlled: true,
    backgroundColor: kTransparentColor,
    builder: (_) =>
        AssignEmployeeRole(employeeId: employeeId, employeeName: employeeName),
  );
}

class AssignEmployeeRole extends StatelessWidget {
  final String employeeId;
  final String? employeeName;

  const AssignEmployeeRole({
    super.key,
    required this.employeeId,
    this.employeeName,
  });

  String get _employeeName => (employeeName ?? 'Employee').toTitleCase;

  @override
  Widget build(BuildContext context) {
    return _buildAlertDialog(context);
  }

  _buildAlertDialog(BuildContext context) {
    return CustomDialog(
      title: DialogTitle(
        title: 'Assign Role',
        subtitle: 'Assign a role to $_employeeName',
      ),
      body: _buildBody(context),
      actions: [],
    );
  }

  Container _buildBody(BuildContext context) {
    return Container(
      width: context.screenWidth,
      padding: EdgeInsets.only(bottom: context.bottomInsetPadding),
      child: AutofillGroup(
        child: RoleDropdown(
          onChanged: (id, role) {
            context.read<EmployeeBloc>().add(
              UpdateSetup<Employee>(
                documentId: employeeId,
                mapData: {'role': role},
              ),
            );

            context.showCustomSnackBar(
              'Role assigned to $_employeeName successfully',
            );

            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
