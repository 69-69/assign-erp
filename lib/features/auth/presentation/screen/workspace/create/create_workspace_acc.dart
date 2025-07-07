import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/util/custom_snack_bar.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/features/auth/domain/repository/auth_repository.dart';
import 'package:assign_erp/features/auth/presentation/bloc/sign_in/sign_in_bloc.dart';
import 'package:assign_erp/features/auth/presentation/screen/widget/form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

extension CreateWorkspacePopUp on BuildContext {
  Future<void> openCreateWorkspacePopUp() => showModalBottomSheet(
    context: this,
    isDismissible: false,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const WorkspaceScreen(),
  );
}

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return SignInBloc(
          authRepository: RepositoryProvider.of<AuthRepository>(context),
        );
      },
      child: _buildAlertDialog(context),
    );
  }

  _buildAlertDialog(BuildContext context) {
    var wh = context.screenWidth * 0.06;

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
      title: _buildSignUpTitle(context, wh),
      content: _buildFormBody(context),
      actions: [SignUpButton(onPressed: (v) {})],
    );
  }

  Column _buildSignUpTitle(BuildContext context, double wh) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLogo(wh),
        const SizedBox(height: 10),
        ListTile(
          title: Text(
            'Setup New Workspace'.toUpperCase(),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: context.ofTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: kPrimaryColor,
            ),
          ),
          subtitle: Text(
            "Create a new Workspace for your new Client.",
            textAlign: TextAlign.center,
            style: context.ofTheme.textTheme.titleSmall?.copyWith(
              color: kTextColor,
            ),
          ),
        ),
      ],
    );
  }

  Image _buildLogo(double wh) {
    return Image.asset(
      appLogo2,
      fit: BoxFit.contain,
      width: wh,
      semanticLabel: appName,
    );
  }

  BlocListener<SignInBloc, SignInState> _buildFormBody(BuildContext context) {
    return BlocListener<SignInBloc, SignInState>(
      listenWhen: (oldState, newState) => oldState.status != newState.status,
      listener: (_, state) => _showSignUpAlert(state, context),
      child: Container(
        width: context.screenWidth,
        padding: EdgeInsets.only(bottom: context.bottomInsetPadding),
        child: const AutofillGroup(child: CreateNewWorkspaceForm()),
      ),
    );
  }

  /// Shows the alert overlay if there is a failure state.
  void _showSignUpAlert(SignInState state, BuildContext context) {
    if ((state.email.isValid && state.password.isValid) &&
        state.status.isFailure) {
      const msg = 'Something went wrong! Kindly try again...';

      // Ensure the overlay is displayed with the current context
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.showAlertOverlay(msg, bgColor: kDangerColor);
      });
    } else if (state.status.isSuccess) {
      context.showAlertOverlay(
        duration: 10,
        'Workspace has been successfully created!\n\n'
        'Please check your email (${state.email}) and click the verification link to complete the process.',
      );
    }
  }
}

/// Create new Workspace Account [CreateNewWorkspaceForm]
class CreateNewWorkspaceForm extends StatelessWidget {
  const CreateNewWorkspaceForm({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildColumn(context);
  }

  Column _buildColumn(BuildContext context) {
    return const Column(
      children: [
        CompanyCategory(),
        SizedBox(height: 20),
        WorkspaceNameInput(),
        SizedBox(height: 20),
        NameInput(),
        SizedBox(height: 20),
        MobileNumberInput(),
        SizedBox(height: 20),
        EmailInput(checkMobileNumber: true),
        SizedBox(height: 20),
        PasswordInput(label: 'New password'),
        SizedBox(height: 20),
      ],
    );
  }
}
