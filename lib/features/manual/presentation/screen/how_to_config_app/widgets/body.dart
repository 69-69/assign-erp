import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/manual/data/models/manual_model.dart';
import 'package:assign_erp/features/manual/presentation/bloc/how_to/how_to_bloc.dart';
import 'package:assign_erp/features/manual/presentation/bloc/manual_bloc.dart';
import 'package:assign_erp/features/manual/presentation/screen/how_to_config_app/add/add_manual.dart';
import 'package:assign_erp/features/manual/presentation/screen/widget/manual_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Body extends StatelessWidget {
  final String manualCategory;
  final bool isDeveloper;
  const Body({
    super.key,
    required this.manualCategory,
    this.isDeveloper = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HowToBloc, ManualState<Manual>>(
      builder: (context, state) {
        return switch (state) {
          LoadingManuals<Manual>() => context.loader,
          ManualsLoaded<Manual>(data: var results) => _buildManualList(
            context,
            results,
            isDeveloper,
          ),
          ManualError<Manual>(error: final error) => context.buildError(error),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  Widget _buildManualList(
    BuildContext context,
    List<Manual> results,
    bool canAccessDev,
  ) {
    if (results.isEmpty) {
      return canAccessDev
          ? context.buildAddButton(
              'Add New Manual',
              onPressed: () => context.openAddManual(category: manualCategory),
            )
          : _buildEmptyMessage(context);
    }
    final manuals = results
        .where((Manual result) => result.category == manualCategory)
        .toList();

    return ManualCard(manuals: manuals, isEdit: canAccessDev);
  }

  Center _buildEmptyMessage(BuildContext context) {
    return Center(
      child: Text(
        '${manualCategory.toUpperCase()}: No manuals found.',
        textScaler: TextScaler.linear(context.textScaleFactor),
      ),
    );
  }
}
