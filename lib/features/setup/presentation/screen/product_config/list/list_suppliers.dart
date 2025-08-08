import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/dynamic_table.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/setup/data/models/supplier_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/product_config/suppliers_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:assign_erp/features/setup/presentation/screen/product_config/add/add_suppliers.dart';
import 'package:assign_erp/features/setup/presentation/screen/product_config/update/update_supplier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListSuppliers extends StatefulWidget {
  const ListSuppliers({super.key});

  @override
  State<ListSuppliers> createState() => _ListSuppliersState();
}

class _ListSuppliersState extends State<ListSuppliers> {
  final storeBloc = SupplierBloc(firestore: FirebaseFirestore.instance);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SupplierBloc>(
      create: (context) =>
          SupplierBloc(firestore: FirebaseFirestore.instance)
            ..add(GetSetups<Supplier>()),
      child: CustomScaffold(
        noAppBar: true,
        body: _buildBody(),
        floatingActionButton: context.buildFloatingBtn(
          'Add Product Suppliers',
          onPressed: () => context.openAddSuppliers(),
        ),
        bottomNavigationBar: const SizedBox.shrink(),
      ),
    );
  }

  BlocBuilder<SupplierBloc, SetupState<Supplier>> _buildBody() {
    return BlocBuilder<SupplierBloc, SetupState<Supplier>>(
      builder: (context, state) {
        return switch (state) {
          LoadingSetup<Supplier>() => context.loader,
          SetupsLoaded<Supplier>(data: var results) =>
            results.isEmpty
                ? context.buildAddButton(
                    'Add Suppliers',
                    onPressed: () => context.openAddSuppliers(),
                  )
                : _buildCard(context, results),
          SetupError<Supplier>(error: final error) => context.buildError(error),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  Widget _buildCard(BuildContext c, List<Supplier> suppliers) {
    return DynamicDataTable(
      skip: true,
      showIDToggle: true,
      headers: Supplier.dataHeader,
      anyWidget: _buildAnyWidget(suppliers),
      rows: suppliers.map((d) => d.toListL()).toList(),
      onEditTap: (row) async => _onEditTap(suppliers, row),
      onDeleteTap: (row) async => _onDeleteTap(suppliers, row),
    );
  }

  _buildAnyWidget(List<Supplier> sales) {
    return context.buildTotalItems(
      'Refresh Suppliers',
      label: 'Suppliers',
      count: sales.length,
      onPressed: () {
        // Refresh Product-Suppliers Data
        context.read<SupplierBloc>().add(RefreshSetups<Supplier>());
      },
    );
  }

  Future<void> _onEditTap(List<Supplier> suppliers, List<String> row) async {
    final supplier = Supplier.findCategoriesById(suppliers, row.first).first;
    await context.openUpdateSupplier(supplier: supplier);
  }

  Future<void> _onDeleteTap(List<Supplier> suppliers, List<String> row) async {
    {
      final supplier = Supplier.findCategoriesById(suppliers, row.first).first;

      final isConfirmed = await context.confirmUserActionDialog();
      if (mounted && isConfirmed) {
        /// Delete specific Supplier
        context.read<SupplierBloc>().add(DeleteSetup(documentId: supplier.id));
      }
    }
  }
}
