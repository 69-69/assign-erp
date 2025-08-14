import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/dialog/async_progress_dialog.dart';
import 'package:assign_erp/core/widgets/dialog/prompt_user_for_action.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/auth/data/data_sources/local/auth_cache_service.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/refresh_entire_app.dart';
import 'package:assign_erp/features/setup/data/models/company_stores_model.dart';
import 'package:assign_erp/features/setup/presentation/bloc/company/company_stores_bloc.dart';
import 'package:assign_erp/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension CompanyStoreX on BuildContext {
  /// Restricts multi-location (store/shop) additions based on the workspace subscription.
  ///
  /// Limits the number of branch stores or shops a company (subscriber) can add, according to the
  /// maximum number of allowed devices defined in the current Workspace subscription license.
  /// [canAddMoreStores]
  bool get canAddMoreStores {
    final workspace = this.workspace;
    if (workspace == null) return false; // no workspace, no action

    final state = watch<CompanyStoresBloc>().state;

    final canAddMoreStores = state is SetupsLoaded<CompanyStores>
        ? state.data.length < workspace.maxAllowedDevices
        : false; // disallow while loading or unknown state

    return canAddMoreStores;
  }

  Future<void> onSwitchStore(String storeNumber, {String location = ''}) async {
    // Confirm the action
    final isConfirmed = await confirmUserActionDialog(onAccept: 'Switch Store');

    if (mounted && isConfirmed) {
      final msg =
          'Store location changed to ${location.toTitleCase}\nstore number $storeNumber';
      // Show progress dialog while updating store number
      await progressBarDialog(
        child: const Text('Please wait...while switching store'),
        request: _updateStoreNumber(
          msg,
          storeNumber: storeNumber,
          location: location,
        ),
        onSuccess: (_) => showAlertOverlay(msg),
        onError: (error) =>
            showAlertOverlay('Store switching failed', bgColor: kDangerColor),
      );
    }
  }

  /// Simulates updating the store number and navigates to the home page.
  ///
  /// This method demonstrates a delay to simulate a network request or some processing time,
  /// and then navigates to the home page.
  ///
  /// Returns:
  /// - A [Future] that completes after the navigation.
  Future<void> _updateStoreNumber(
    String msg, {
    String location = '',
    required String storeNumber,
  }) async {
    try {
      final authCacheService = AuthCacheService();
      bool isSwitched = await authCacheService.switchStores(storeNumber);
      await Future.delayed(kRProgressDelay);

      if (isSwitched) {
        if (mounted) {
          final isDone = await confirmDone(
            Text(msg),
            title: 'Store Location Changed',
            barrierDismissible: false,
          );
          if (isDone) {
            RefreshEntireApp.restartApp(this);
          }
        }
      } else {
        throw Exception("Switching store failed. Employee not found.");
      }
    } catch (e) {
      showAlertOverlay(
        'Error switching store: ${e.toString()}',
        bgColor: kDangerColor,
      );
      rethrow;
    }
  }

  Future<bool> showUpgradeDialog() async {
    return await confirmAction(
      Text(
        'You cannot add more stores. Please extend your subscription license to add more stores.\nKindly contact support for more information.',
      ),
      onAccept: 'Done',
      onReject: 'Cancel',
      title: 'Can\'t Add More Stores',
    );
  }
}
