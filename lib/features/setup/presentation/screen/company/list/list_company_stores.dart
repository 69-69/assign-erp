import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/dynamic_table.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/setup/data/models/company_stores_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/company/company_stores_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:assign_erp/features/setup/presentation/screen/company/add/add_store_locations.dart';
import 'package:assign_erp/features/setup/presentation/screen/company/update/update_store.dart';
import 'package:assign_erp/features/setup/presentation/screen/company/widget/can_add_more_stores.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListCompanyStores extends StatefulWidget {
  const ListCompanyStores({super.key});

  @override
  State<ListCompanyStores> createState() => _ListCompanyStoresState();
}

class _ListCompanyStoresState extends State<ListCompanyStores> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CompanyStoresBloc>(
      create: (context) =>
          CompanyStoresBloc(firestore: FirebaseFirestore.instance)
            ..add(GetSetups<CompanyStores>()),
      child: CustomScaffold(
        noAppBar: true,
        body: _buildBody(),
        floatingActionButton: context.canAddMoreStores
            ? context.buildFloatingBtn(
                'Add Stores',
                onPressed: () => context.openAddStoreLocations(),
              )
            : const SizedBox.shrink(),
        bottomNavigationBar: const SizedBox.shrink(),
      ),
    );
  }

  BlocBuilder<CompanyStoresBloc, SetupState<CompanyStores>> _buildBody() {
    return BlocBuilder<CompanyStoresBloc, SetupState<CompanyStores>>(
      builder: (context, state) {
        return switch (state) {
          LoadingSetup<CompanyStores>() => context.loader,
          SetupsLoaded<CompanyStores>(data: var results) =>
            results.isEmpty
                ? context.buildAddButton(
                    'Add Stores',
                    onPressed: () => context.openAddStoreLocations(),
                  )
                : _buildCard(results),
          SetupError<CompanyStores>(error: final error) => context.buildError(
            error,
          ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  Widget _buildCard(List<CompanyStores> stores) {
    return DynamicDataTable(
      skip: true,
      skipPos: 2,
      showIDToggle: true,
      headers: CompanyStores.dataTableHeader,
      anyWidget: _buildAnyWidget(stores),
      rows: stores.map((d) => d.itemAsList()).toList(),
      onEditTap: (row) async => _onEditTap(stores, row[1]),
      onDeleteTap: (row) async => _onDeleteTap(stores, row[1]),
      optButtonIcon: Icons.store,
      optButtonLabel: 'Switch Store',
      onOptButtonTap: (row) async {
        final store = _findStoresById(stores, row[1]);
        await context.onSwitchStore(
          store.storeNumber,
          location: store.location,
        );
      },
    );
  }

  _buildAnyWidget(List<CompanyStores> sales) {
    return context.buildTotalItems(
      'Refresh Stores',
      label: 'Stores',
      count: sales.length,
      onPressed: () =>
          context.read<CompanyStoresBloc>().add(RefreshSetups<CompanyStores>()),
    );
  }

  CompanyStores _findStoresById(List<CompanyStores> stores, String id) =>
      CompanyStores.findStoresById(stores, id).first;

  Future<void> _onEditTap(List<CompanyStores> stores, String id) async {
    final store = _findStoresById(stores, id);
    await context.openUpdateStore(store: store);
  }

  Future<void> _onDeleteTap(List<CompanyStores> stores, String id) async {
    {
      final store = _findStoresById(stores, id);

      final isConfirmed = await context.confirmUserActionDialog();
      if (mounted && isConfirmed) {
        /// Delete specific Store
        context.read<CompanyStoresBloc>().add(
          DeleteSetup(documentId: store.id),
        );
      }
    }
  }
}
