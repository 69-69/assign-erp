import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/util/debug_printify.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/features/auth/presentation/bloc/sign_in/sign_in_bloc.dart';
import 'package:assign_erp/features/auth/presentation/screen/workspace/license_warning/license_warning.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';

extension ShowSignInAlert on BuildContext {
  /// Shows the alert overlay if there is a failure state.
  ///
  void showSignInAlert(SignInState state, {bool isWorkspace = false}) {
    final isInputValid = state.email.isValid && state.password.isValid;
    final hasFailed = state.status.isFailure;

    if (isInputValid && hasFailed) {
      final rawMessage = state.errorMessage ?? '';
      final simplifiedError = rawMessage.split(':').last.trim();

      prettyPrint('show-sign-in-error', simplifiedError);

      const fallbackMsg =
          'Something went wrong. Please tap the red refresh icon above.';

      final msg =
          simplifiedError.toLowerCase().contains(
            'cannot add new events after calling close',
          )
          ? fallbackMsg
          : (simplifiedError.isEmpty ? fallbackMsg : simplifiedError);

      // Ensure the overlay is displayed with the current context
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAlertOverlay(msg, bgColor: kDangerColor);

        if (isWorkspace && msg.toLowerCase().contains('license')) {
          Future.delayed(wAnimateDuration);
          showUpgradeWarningDialog();
        }
      });
    }
  }
}
