import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/tile_card.dart';
import 'package:assign_erp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/inventory_ims/presentation/inventory_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildBody();
    /*MINE-STEVE
    return BlocProvider(
      create: (context) => AuthBloc(
        authRepository: RepositoryProvider.of<AuthRepository>(context),
      ),
      child: _buildBody(),
    );*/
  }

  BlocBuilder<AuthBloc, AuthState> _buildBody() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return CustomScaffold(
          isGradientBg: true,
          title: inventoryAppTitle,
          // drawer: _drawer(context),
          body: _buildTiles(context),
        );
      },
    );
  }

  Widget _buildTiles(BuildContext context) {
    final employee = context.employee;

    /* Role Based Access Control */
    final tiles = [...?inventoryTiles[employee?.role]?.tiles];
    return TileCard(
      tiles: tiles,
      metricsTitle: "Inventory Metrics",
      metricsSubtitle:
          "Monitor stock levels, order statuses, and fulfillment progress.",
      metrics: {
        "Pending": 34,
        "Processing": 34,
        "Production": 34,
        "To Be Shipped": 18,
        "Delivered": 210,
        "Current Stock": 780,
        "Completed": 192,
        "Cancelled": 5,
        "Returned": 5,
      },
    );
  }
}
