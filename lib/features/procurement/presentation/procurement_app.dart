import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/widgets/layout/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/nav/dashboard_tile_card.dart';
import 'package:assign_erp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:assign_erp/features/procurement/presentation/procurement_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProcurementApp extends StatelessWidget {
  const ProcurementApp({super.key});

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
          title: procurementAppTitle,
          tiles: procurementTiles,
          body: _buildDashboard(context),
        );
      },
    );
  }

  Widget _buildDashboard(BuildContext context) {
    /* Role Based Access Control
    final employee = context.employee;
    final tiles = [...?procurementTiles[employee?.role]?.tiles]; */
    return DashboardTileCard(
      tiles: procurementTiles,
      metricsTitle: "Procurement Metrics",
      metricsSubtitle:
          "Monitor stock levels, supplier performance, and order fulfillment.",
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
