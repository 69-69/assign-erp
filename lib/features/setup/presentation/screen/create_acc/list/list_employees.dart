import 'package:assign_erp/core/constants/account_status.dart';
import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/async_progress_dialog.dart';
import 'package:assign_erp/core/util/custom_snack_bar.dart';
import 'package:assign_erp/core/util/password_hashing.dart';
import 'package:assign_erp/core/widgets/dynamic_table.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:assign_erp/features/setup/data/models/employee_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/create_acc/employee_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:assign_erp/features/setup/presentation/screen/create_acc/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListEmployees extends StatefulWidget {
  const ListEmployees({super.key});

  @override
  State<ListEmployees> createState() => _ListEmployeesState();
}

class _ListEmployeesState extends State<ListEmployees> {
  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  BlocBuilder<EmployeeBloc, SetupState<Employee>> _buildBody() {
    return BlocBuilder<EmployeeBloc, SetupState<Employee>>(
      builder: (context, state) {
        return switch (state) {
          LoadingSetup<Employee>() => context.loader,
          SetupLoaded<Employee>(data: var results) =>
            results.isEmpty
                ? context.buildAddButton(
                    'Create Employee Account',
                    onPressed: () => context.openCreateEmployeeAcc(),
                  )
                : _buildCard(context, results),
          SetupError<Employee>(error: final error) => context.buildError(error),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  _buildCard(BuildContext c, List<Employee> employees) {
    return DynamicDataTable(
      skip: true,
      skipPos: 2,
      toggleHideID: true,
      headers: Employee.dataTableHeader,
      rows: employees.map((d) => d.itemAsList()).toList(),
      onEditTap: (row) async => _onEditTap(employees, row),
      onDeleteTap: (row) async => _onDeleteTap(employees, row),
      optButtonIcon: Icons.email_outlined,
      optButtonLabel: 'Reset Password',
      onOptButtonTap: (row) async => await _resetPasswordAction(employees, row),
    );
  }

  Employee _findEmployee(List<String> row, List<Employee> employees) {
    var id = row[1];
    final employee = Employee.findById(employees, id).first;
    return employee;
  }

  Future<void> _onEditTap(List<Employee> employees, List<String> row) async {
    Employee employee = _findEmployee(row, employees);

    /// Update specific Employee Account
    await context.openUpdateEmployeeAcc(employee: employee);
  }

  Future<void> _onDeleteTap(List<Employee> employees, List<String> row) async {
    {
      Employee employee = _findEmployee(row, employees);

      final isConfirmed = await context.confirmUserActionDialog();
      if (mounted && isConfirmed) {
        /// Delete specific Employee Account
        context.read<EmployeeBloc>().add(DeleteSetup(documentId: employee.id));
      }
    }
  }

  _resetPasswordAction(List<Employee> employees, List<String> row) async {
    final isConfirmed = await context.confirmUserActionDialog(
      onAccept: 'Password reset',
    );
    if (mounted && isConfirmed) {
      await context.progressBarDialog(
        child: Text(
          'Use the Temporary Passcode: $temporalWeakPasscode\n'
          'After signing in with this Passcode, you will be prompted to create a preferred password.',
          textAlign: TextAlign.center,
        ),
        request: _onResetPasswordTap(employees, row),
        onSuccess: (_) => context.showAlertOverlay(
          'Password Reset successful, Temporary Passcode: $temporalWeakPasscode',
        ),
        onError: (error) => context.showAlertOverlay(
          'Password Reset failed',
          bgColor: kDangerColor,
        ),
      );
    }
  }

  Future<void> _onResetPasswordTap(
    List<Employee> employees,
    List<String> row,
  ) async {
    // Simulate delayed to complete Password Reset
    Future.delayed(const Duration(seconds: 6));

    Employee employee = _findEmployee(row, employees);

    /// Reset a specific employee's account password to 'temporalWeakPasscode'.
    /// When the employee signs in with this 'temporalWeakPasscode',
    /// they will be prompted to create a preferred password.
    context.read<EmployeeBloc>().add(
      UpdateSetup(
        documentId: employee.id,
        mapData: {'passCode': PasswordHash.hashPassword(temporalWeakPasscode)},
      ),
    );
    _handleSignOut(context);
  }

  void _handleSignOut(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    authBloc.add(AuthSignOutRequested());
  }
}
