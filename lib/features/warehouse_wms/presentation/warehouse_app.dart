import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/core/widgets/tile_card.dart';
import 'package:assign_erp/features/refresh_entire_app.dart';
import 'package:assign_erp/features/warehouse_wms/presentation/warehouse_tiles.dart';
import 'package:flutter/material.dart';

class WarehouseApp extends StatelessWidget {
  const WarehouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: warehouseAppTitle,
      body: TileCard(tiles: warehouseTiles),
      actions: [
        context.reloadAppIconButton(
          onPressed: () => RefreshEntireApp.restartApp(context),
        ),
      ],
    );
  }
}
