import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/tile_card.dart';
import 'package:assign_erp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
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
          body: _buildTiles(context),
          floatingActionBtnLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Widget _buildTiles(BuildContext context) {
    final employee = context.employee;

    /* Role Based Access Control */
    final tiles = [...?customerTiles[employee?.role]?.tiles];
    return TileCard(
      tiles: tiles,
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
