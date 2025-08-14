import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/widgets/layout/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/nav/dashboard_tile_card.dart';
import 'package:assign_erp/features/trouble_shooting/presentation/trouble_shoot_tiles.dart';
import 'package:flutter/material.dart';

class TroubleShootingApp extends StatelessWidget {
  const TroubleShootingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      isGradientBg: true,
      title: troubleshootScreenTitle,
      tiles: troubleShootTiles,
      body: DashboardTileCard(tiles: troubleShootTiles),
    );
  }
}
