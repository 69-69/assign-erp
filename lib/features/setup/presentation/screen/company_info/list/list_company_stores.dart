import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/async_progress_dialog.dart';
import 'package:assign_erp/core/util/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/dynamic_table.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/auth/presentation/screen/widget/stores_switcher.dart';
import 'package:assign_erp/features/setup/data/models/company_stores_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/company_info/company_store_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:assign_erp/features/setup/presentation/screen/company_info/add/add_store.dart';
import 'package:assign_erp/features/setup/presentation/screen/company_info/update/update_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ListCompanyStores extends StatefulWidget {
  const ListCompanyStores({super.key});

  @override
  State<ListCompanyStores> createState() => _ListCompanyStoresState();
}

class _ListCompanyStoresState extends State<ListCompanyStores> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CompanyStoreBloc>(
      create: (context) =>
          CompanyStoreBloc(firestore: FirebaseFirestore.instance)
            ..add(GetSetup<CompanyStores>()),
      child: CustomScaffold(
        noAppBar: true,
        body: _buildBody(),
        floatingActionButton: context.buildFloatingBtn(
          'add stores',
          onPressed: () => context.openAddStore(),
        ),
      ),
    );
  }

  BlocBuilder<CompanyStoreBloc, SetupState<CompanyStores>> _buildBody() {
    return BlocBuilder<CompanyStoreBloc, SetupState<CompanyStores>>(
      builder: (context, state) {
        return switch (state) {
          LoadingSetup<CompanyStores>() => context.loader,
          SetupLoaded<CompanyStores>(data: var results) =>
            results.isEmpty
                ? context.buildAddButton(
                    'Add Stores',
                    onPressed: () => context.openAddStore(),
                  )
                : _buildCard(context, results),
          SetupError<CompanyStores>(error: final error) => context.buildError(
            error,
          ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  Widget _buildCard(BuildContext c, List<CompanyStores> stores) {
    return DynamicDataTable(
      skip: true,
      toggleHideID: true,
      headers: CompanyStores.dataTableHeader,
      anyWidget: _buildAnyWidget(stores),
      rows: stores.map((d) => d.itemAsList()).toList(),
      onEditTap: (row) async => _onEditTap(stores, row),
      onDeleteTap: (row) async => _onDeleteTap(stores, row),
      optButtonIcon: Icons.store,
      optButtonLabel: 'Switch Store',
      onOptButtonTap: (row) async => await _onSwitchStoreTap(stores, row),
    );
  }

  _buildAnyWidget(List<CompanyStores> sales) {
    return context.buildTotalItems(
      'Refresh Stores',
      label: 'Stores',
      count: sales.length,
      onPressed: () {
        // Refresh Stores Data
        context.read<CompanyStoreBloc>().add(RefreshSetup<CompanyStores>());
      },
    );
  }

  CompanyStores _findStoresById(List<CompanyStores> stores, List<String> row) =>
      CompanyStores.findStoresById(stores, row.first).first;

  Future<void> _onEditTap(List<CompanyStores> stores, List<String> row) async {
    final store = _findStoresById(stores, row);
    await context.openUpdateStore(store: store);
  }

  Future<void> _onDeleteTap(
    List<CompanyStores> stores,
    List<String> row,
  ) async {
    {
      final store = _findStoresById(stores, row);

      final isConfirmed = await context.confirmUserActionDialog();
      if (mounted && isConfirmed) {
        /// Delete specific Store
        context.read<CompanyStoreBloc>().add(DeleteSetup(documentId: store.id));
      }
    }
  }

  Future<void> _onSwitchStoreTap(
    List<CompanyStores> stores,
    List<String> row,
  ) async {
    final store = _findStoresById(stores, row);

    // Confirm the action with the user
    final isConfirmed = await context.confirmUserActionDialog(
      onAccept: 'Switch Store',
    );

    if (mounted && isConfirmed) {
      // Cache the updated employee data
      storeSwitcher(context, storeNumber: store.storeNumber);

      // Show progress dialog while updating store number
      await _showProgressDialog();
    }
  }

  /// Shows a progress dialog while updating the store number.
  Future<void> _showProgressDialog() async {
    await context.progressBarDialog(
      request: _updateStoreNumber(),
      onSuccess: (_) => context.showAlertOverlay('Store switching successful'),
      onError: (error) => context.showAlertOverlay(
        'Store switching failed',
        bgColor: kDangerColor,
      ),
    );
  }

  /// Simulates updating the store number and navigates to the home page.
  ///
  /// This method demonstrates a delay to simulate a network request or some processing time,
  /// and then navigates to the home page.
  ///
  /// Returns:
  /// - A [Future] that completes after the navigation.
  Future<void> _updateStoreNumber() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) context.go('/${RouteNames.mainDashboard}');
  }
}
