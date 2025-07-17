import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/features/auth/presentation/bloc/sign_in/sign_in_bloc.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/auth/presentation/screen/widget/form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

extension UpdateWorkspacePopUp on BuildContext {
  Future<void> openUpdateWorkspacePopUp() => showModalBottomSheet(
    context: this,
    isDismissible: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const ChangeWorkspacePassword(),
  );
}

class ChangeWorkspacePassword extends StatelessWidget {
  const ChangeWorkspacePassword({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildAlertDialog(context);

    /*MINE-STEVE
    return BlocProvider(
      create: (context) {
        return SignInBloc(
          authRepository: RepositoryProvider.of<AuthRepository>(context),
        );
      },
      child: _buildAlertDialog(context),
    );*/
  }

  _buildAlertDialog(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      icon: Align(
        alignment: Alignment.topRight,
        child: IconButton(
          style: IconButton.styleFrom(
            backgroundColor: kLightColor.withAlpha((0.4 * 255).toInt()),
          ),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: kTextColor),
        ),
      ),
      iconPadding: const EdgeInsets.only(right: 5, top: 5),
      backgroundColor: kLightColor.withAlpha((0.8 * 255).toInt()),
      title: _buildTitle(context),
      content: _buildFormBody(context),
      actions: const [UpdateWorkspacePasswordButton()],
    );
  }

  _buildTitle(BuildContext context) {
    return ListTile(
      title: Text(
        'Change Workspace Password',
        textAlign: TextAlign.center,
        style: context.ofTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: kPrimaryColor,
        ),
      ),
      subtitle: Text(
        "This is your Organization Password: ${context.workspace?.workspaceName ?? ''}",
        textAlign: TextAlign.center,
        style: context.ofTheme.textTheme.titleSmall?.copyWith(
          color: kTextColor,
        ),
      ),
    );
  }

  BlocListener<SignInBloc, SignInState> _buildFormBody(BuildContext context) {
    return BlocListener<SignInBloc, SignInState>(
      listenWhen: (oldState, newState) => oldState.status != newState.status,
      listener: (_, state) => _showSignUpAlert(state, context),
      child: Container(
        width: context.screenWidth,
        padding: EdgeInsets.only(bottom: context.bottomInsetPadding),
        child: const AutofillGroup(
          child: PasswordInput(label: 'New password', checkEmail: false),
        ),
      ),
    );
  }

  /// Shows the alert overlay if there is a failure state.
  void _showSignUpAlert(SignInState state, BuildContext context) {
    if (state.password.isValid && state.status.isFailure) {
      const msg = 'Something went wrong! Kindly try again...';

      // Ensure the overlay is displayed with the current context
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.showAlertOverlay(msg, bgColor: kDangerColor);
      });
    } else if (state.status.isSuccess) {
      context.showAlertOverlay('Successfully updated Workspace password!');
    }
  }
}
