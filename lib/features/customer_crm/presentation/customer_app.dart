import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/widgets/layout/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/nav/dashboard_tile_card.dart';
import 'package:assign_erp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:assign_erp/features/customer_crm/presentation/customer_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/* https://www.hubspot.com/products/crm/what-is */

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

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
          title: customerAppTitle,
          tiles: customerTiles,
          body: _buildDashboard(context),
          floatingActionBtnLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Widget _buildDashboard(BuildContext context) {
    /* Role Based Access Control
    final employee = context.employee;
    final tiles = [...?customerTiles[employee?.role]?.tiles];*/

    return DashboardTileCard(
      tiles: customerTiles,
      metricsTitle: "CRM Metrics",
      metricsSubtitle:
          "Manage leads, customers, interactions, and support tickets.",
      metrics: {
        "Total Leads": 34,
        "Active Leads": 34,
        "Converted Leads": 34,
        "Open Tickets": 34, // Tickets: Complaints from customers
        "Closed Tickets": 18,
        "New Customers": 5,
        "Total Customers": 210,
      },
    );
  }
}
