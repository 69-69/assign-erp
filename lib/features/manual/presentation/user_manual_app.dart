import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/core/widgets/tile_card.dart';
import 'package:assign_erp/features/manual/presentation/manual_tiles.dart';
import 'package:assign_erp/features/refresh_entire_app.dart';
import 'package:flutter/material.dart';

class UserManualApp extends StatelessWidget {
  const UserManualApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: userManualAppTitle,
      body: TileCard(tiles: userManualTiles),
      actions: [
        context.reloadAppIconButton(
          onPressed: () => RefreshEntireApp.restartApp(context),
        ),
      ],
    );
  }
}
