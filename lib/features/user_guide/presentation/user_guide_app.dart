import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/tile_card.dart';
import 'package:assign_erp/features/user_guide/presentation/user_guide_tiles.dart';
import 'package:flutter/material.dart';

class UserGuideApp extends StatelessWidget {
  const UserGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      isGradientBg: true,
      title: userGuideAppTitle,
      body: TileCard(tiles: userGuideTiles),
    );
  }
}
