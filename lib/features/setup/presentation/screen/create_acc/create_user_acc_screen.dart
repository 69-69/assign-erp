import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/setup/data/models/employee_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/create_acc/employee_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:assign_erp/features/setup/presentation/screen/create_acc/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateUserAccScreen extends StatelessWidget {
  const CreateUserAccScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EmployeeBloc>(
      create: (context) =>
          EmployeeBloc(firestore: FirebaseFirestore.instance)
            ..add(GetSetups<Employee>()),
      child: CustomScaffold(
        noAppBar: true,
        body: const ListEmployees(),
        floatingActionButton: context.buildFloatingBtn(
          'Create Employee Account',
          icon: Icons.person_add,
          onPressed: () async => await context.openCreateEmployeeAcc(),
        ),
        bottomNavigationBar: const SizedBox.shrink(),
      ),
    );
  }
}
