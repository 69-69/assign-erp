import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/widgets/button/custom_button.dart';
import 'package:assign_erp/core/widgets/layout/dynamic_table.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/setup/data/models/employee_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/create_acc/employee_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:assign_erp/features/setup/presentation/screen/all_employees/staff_account/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ListStaffs extends StatefulWidget {
  const ListStaffs({super.key});

  @override
  State<ListStaffs> createState() => _ListStaffsState();
}

class _ListStaffsState extends State<ListStaffs> {
  bool? _isChecked;
  Employee? _selectedEmployee;

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  BlocBuilder<EmployeeBloc, SetupState<Employee>> _buildBody() {
    return BlocBuilder<EmployeeBloc, SetupState<Employee>>(
      builder: (context, state) {
        return switch (state) {
          LoadingSetup<Employee>() => context.loader,
          SetupsLoaded<Employee>(data: var results) =>
            results.isEmpty
                ? context.buildAddButton(
                    'Add Staff',
                    onPressed: () => context.openCreateStaffAcc(),
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
      showIDToggle: true,
      headers: Employee.dataTableHeader,
      anyWidget: _buildAnyWidget(),
      anyWidgetAlignment: WrapAlignment.end,
      rows: employees.map((d) => d.itemAsList()).toList(),
      onChecked: (bool? isChecked, row) =>
          _onChecked(employees, row[1], isChecked),
      onEditTap: (row) async => _onEditTap(employees, row[1]),
      onDeleteTap: (row) async => _onDeleteTap(employees, row[1]),
      optButtonIcon: Icons.lock,
      optButtonLabel: 'Reset Passcode',
      onOptButtonTap: (row) async {
        Employee employee = _findEmployee(row[1], employees);
        await context.openForgotPasscode(employee: employee);
      },
    );
  }

  // Handle onChecked employee
  void _onChecked(List<Employee> employees, String id, bool? isChecked) async {
    Employee employee = _findEmployee(id, employees);

    setState(() {
      _isChecked = isChecked;
      if (_isChecked == true) {
        _selectedEmployee = employee;
      }
    });
  }

  _buildAnyWidget() {
    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      runAlignment: WrapAlignment.end,
      children: [
        context.elevatedIconBtn(
          Icon(Icons.person_add, color: kLightColor),
          label: 'Add Staff',
          onPressed: () async => await context.openCreateStaffAcc(),
          bgColor: kDangerColor,
          color: kLightColor,
        ),
        context.elevatedButton(
          'Roles & Permissions',
          onPressed: () => context.pushNamed(
            RouteNames.manageRoles,
            pathParameters: {'openTab': '2'},
          ),
          bgColor: kGrayBlueColor,
          color: kLightColor,
        ),
        if (_isChecked == true) ...[
          context.elevatedButton(
            'Assign Role',
            tooltip: 'Assign Employee to a Role',
            onPressed: () async => await context.openAssignEmployeeRoleDialog(
              employeeId: _selectedEmployee!.id,
              employeeName: _selectedEmployee?.fullName,
            ),
            bgColor: kPrimaryAccentColor,
            color: kLightColor,
          ),

          context.elevatedButton(
            'Assign Store',
            tooltip: 'Assign Employee to a Store',
            onPressed: () async =>
                await context.assignEmployeeToStoreLocationDialog(
                  employeeId: _selectedEmployee!.id,
                  employeeName: _selectedEmployee?.fullName,
                ),
            bgColor: kWarningColor,
            color: kLightColor,
          ),
        ],
      ],
    );
  }

  Employee _findEmployee(String id, List<Employee> employees) {
    final employee = Employee.findById(employees, id).first;
    return employee;
  }

  Future<void> _onEditTap(List<Employee> employees, String id) async {
    Employee employee = _findEmployee(id, employees);

    /// Update specific Employee Account
    await context.openUpdateStaffAcc(employee: employee);
  }

  Future<void> _onDeleteTap(List<Employee> employees, String id) async {
    {
      Employee employee = _findEmployee(id, employees);

      final isConfirmed = await context.confirmUserActionDialog();
      if (mounted && isConfirmed) {
        /// Delete specific Employee Account
        context.read<EmployeeBloc>().add(DeleteSetup(documentId: employee.id));
      }
    }
  }
}
