import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/widgets/custom_button.dart';
import 'package:assign_erp/core/widgets/dynamic_table.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/setup/data/models/employee_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/create_acc/employee_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:assign_erp/features/setup/presentation/screen/staff_account/index.dart';
import 'package:assign_erp/features/setup/presentation/screen/staff_account/widget/assign_role.dart';
import 'package:assign_erp/features/setup/presentation/screen/staff_account/widget/forgot_passcode.dart';
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
  String? _employeeId;
  String? _employeeName;

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
                    onPressed: () => context.openAddStaffAcc(),
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
      anyWidget: Padding(
        padding: EdgeInsets.fromLTRB(5, 20, 20, 0),
        child: _buildAnyWidget(),
      ),
      anyWidgetAlignment: WrapAlignment.end,
      rows: employees.map((d) => d.itemAsList()).toList(),
      onChecked: (bool? isChecked, row) =>
          _onChecked(employees, row, isChecked),
      onEditTap: (row) async => _onEditTap(employees, row),
      onDeleteTap: (row) async => _onDeleteTap(employees, row),
      optButtonIcon: Icons.lock,
      optButtonLabel: 'Reset Passcode',
      onOptButtonTap: (row) async {
        Employee employee = _findEmployee(row, employees);
        await context.openForgotPasscode(employee: employee);
      },
    );
  }

  // Handle onChecked employee
  void _onChecked(
    List<Employee> employees,
    List<String> row,
    bool? isChecked,
  ) async {
    Employee employee = _findEmployee(row, employees);

    setState(() {
      _isChecked = isChecked;
      if (_isChecked == true) {
        _employeeId = employee.id;
        _employeeName = employee.fullName;
      }
    });
  }

  _buildAnyWidget() {
    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      runAlignment: WrapAlignment.end,
      children: [
        if (_isChecked != true) ...[
          context.elevatedButton(
            'Manage Roles',
            onPressed: () {
              context.pushNamed(
                RouteNames.manageRoles,
                // extra: {'openTab': '2'},
                pathParameters: {'openTab': '2'},
              );
            },
            bgColor: kGrayBlueColor,
            color: kLightColor,
          ),

          context.elevatedIconBtn(
            Icon(Icons.person_add, color: kLightColor),
            label: 'Add Staff',
            onPressed: () async => await context.openAddStaffAcc(),
            bgColor: kDangerColor,
            color: kLightColor,
          ),
        ] else ...[
          context.elevatedButton(
            'Assign Role',
            onPressed: () async {
              await context.openAssignEmployeeRolePopUp(
                employeeId: _employeeId!,
                employeeName: _employeeName,
              );
            },
            bgColor: kGrayBlueColor,
            color: kLightColor,
          ),

          context.elevatedButton(
            'Assign Store Location',
            onPressed: () {},
            bgColor: kGrayBlueColor,
            color: kLightColor,
          ),
        ],
      ],
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
    await context.openUpdateStaffAcc(employee: employee);
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
}
