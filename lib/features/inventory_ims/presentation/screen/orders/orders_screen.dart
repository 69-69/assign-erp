import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/tile_card.dart';
import 'package:assign_erp/features/inventory_ims/presentation/inventory_tiles.dart';
import 'package:flutter/material.dart';

/// All ORDERS: Sales Order, purchase Order & Misc Order
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      isGradientBg: true,
      title: allOrderScreenTitle.toUpperCase(),
      body: TileCard(tiles: ordersTiles),
      actions: const [],
    );
  }
}
