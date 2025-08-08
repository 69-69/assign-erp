import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/dialog/bottom_sheet_header.dart';
import 'package:assign_erp/core/widgets/dialog/custom_dialog.dart';
import 'package:assign_erp/features/auth/domain/repository/auth_repository.dart';
import 'package:assign_erp/features/auth/presentation/bloc/sign_in/workspace/workspace_sign_in_bloc.dart';
import 'package:assign_erp/features/auth/presentation/screen/widget/workspace_form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

extension CreateWorkspacePopUp on BuildContext {
  Future<void> openCreateWorkspacePopUp() => showModalBottomSheet(
    context: this,
    isDismissible: false,
    isScrollControlled: true,
    backgroundColor: kTransparentColor,
    builder: (_) => const WorkspaceScreen(),
  );
}

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return WorkspaceSignInBloc(
          authRepository: RepositoryProvider.of<AuthRepository>(context),
        );
      },
      child: _buildAlertDialog(context),
    );
    // return _buildAlertDialog(context);
  }

  _buildAlertDialog(BuildContext context) {
    return CustomDialog(
      title: DialogTitle(
        title: 'Setup New Workspace'.toUpperCaseAll,
        subtitle: "Create a new Workspace for your new Client.",
      ),
      body: _buildFormBody(context),
      actions: [SignUpButton(onPressed: (v) {})],
    );
  }

  BlocListener<WorkspaceSignInBloc, WorkspaceSignInState> _buildFormBody(
    BuildContext context,
  ) {
    return BlocListener<WorkspaceSignInBloc, WorkspaceSignInState>(
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
  void _showSignUpAlert(WorkspaceSignInState state, BuildContext context) {
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
        'Workspace has been created!\n\n'
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
    return Column(
      children: [
        const WorkspaceCategory(),
        const SizedBox(height: 20),
        const WorkspaceNameInput(),
        const SizedBox(height: 20),
        const NameInput(),
        const SizedBox(height: 20),
        const MobileNumberInput(),
        const SizedBox(height: 20),
        const EmailInput(checkMobileNumber: true),
        const SizedBox(height: 20),
        const PasswordInput(label: 'Workspace password'),
        TemporaryPasscodeInput(),
        const SizedBox(height: 20),
      ],
    );
  }
}
