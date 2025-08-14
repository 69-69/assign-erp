import 'package:assign_erp/core/widgets/layout/custom_scaffold.dart';
import 'package:assign_erp/features/setup/data/models/role_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/create_roles/role_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:assign_erp/features/setup/presentation/screen/manage_roles/list/list_roles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManageRolesScreen extends StatelessWidget {
  const ManageRolesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RoleBloc>(
      create: (context) =>
          RoleBloc(firestore: FirebaseFirestore.instance)
            ..add(GetSetups<Role>()),
      child: CustomScaffold(
        noAppBar: true,
        body: const ListRoles(),
        bottomNavigationBar: const SizedBox.shrink(),
      ),
    );
  }
}
