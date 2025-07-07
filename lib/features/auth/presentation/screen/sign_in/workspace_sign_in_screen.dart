import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/util/adaptive_layout.dart';
import 'package:assign_erp/core/util/custom_snack_bar.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/auth/domain/repository/auth_repository.dart';
import 'package:assign_erp/features/auth/presentation/bloc/sign_in/sign_in_bloc.dart';
import 'package:assign_erp/features/auth/presentation/screen/widget/form_inputs.dart';
import 'package:assign_erp/features/auth/presentation/screen/widget/workspace_acc_guide.dart';
import 'package:assign_erp/features/auth/presentation/screen/workspace/forgot/forgot_workspace_password.dart';
import 'package:assign_erp/features/auth/presentation/screen/workspace/license_warning/license_warning.dart';
import 'package:assign_erp/features/refresh_entire_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

class WorkspaceSignInForm extends StatelessWidget {
  const WorkspaceSignInForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return SignInBloc(
          authRepository: RepositoryProvider.of<AuthRepository>(context),
        );
      },
      child: _buildBody(context),
    );
  }

  /// Shows the alert overlay if there is a failure state.
  void _showSignInAlert(SignInState state, BuildContext context) {
    if ((state.email.isValid && state.password.isValid) &&
        state.status.isFailure) {
      final msg =
          state.errorMessage?.split(':').last ?? 'Incorrect email or password';

      // Ensure the overlay is displayed with the current context
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.showAlertOverlay(msg, bgColor: kDangerColor);
        if (msg.toLowerCase().contains('license')) {
          Future.delayed(const Duration(seconds: 2));
          context.openLicenseWarningPopUp();
        }
      });
    }
  }

  BlocListener<SignInBloc, SignInState> _buildBody(BuildContext context) {
    return BlocListener<SignInBloc, SignInState>(
      listenWhen: (oldState, newState) => oldState.status != newState.status,
      listener: (_, state) => _showSignInAlert(state, context),
      child: AutofillGroup(child: _buildLayout(context)),
    );
  }

  _buildLayout(BuildContext context) {
    return AdaptiveLayout(
      firstFlex: 3,
      isSizedBox: false,
      children: [
        Padding(
          padding: const EdgeInsets.all(30.0),
          child: Center(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildCard(
                        context,
                        color: kLightColor.withAlpha((0.8 * 255).toInt()),
                        child: Text(
                          welcomeTitle,
                          textAlign: TextAlign.center,
                          style: context.ofTheme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                          textScaler: TextScaler.linear(
                            context.textScaleFactor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                _buildLeftColumn(context),
              ],
            ),
          ),
        ),
        _buildRightColumn(context),
      ],
    );
  }

  _buildLeftColumn(BuildContext context) {
    return _buildCard(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLogo(context),
          ListTile(
            title: Text(
              'Workspace Sign In',
              textAlign: TextAlign.center,
              style: context.ofTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: kPrimaryColor,
              ),
            ),
            subtitle: Text(
              "First, Sign In with your Company's workspace ID.",
              textAlign: TextAlign.center,
              style: context.ofTheme.textTheme.titleSmall?.copyWith(
                color: kTextColor,
              ),
            ),
          ),
          const SizedBox(height: 2.0),
          const Flexible(child: EmailInput()),
          const SizedBox(height: 20),
          const Flexible(child: PasswordInput()),
          const SizedBox(height: 5),
          Flexible(child: WorkspaceSignInButton(onPressed: (v) {})),
        ],
      ),
    );
  }

  _buildCard(BuildContext context, {Color? color, Widget? child}) {
    return Card(
      elevation: 50,
      color: color ?? kLightColor.withAlpha((0.8 * 255).toInt()),
      margin: context.isMobile || context.isTablet
          ? null
          : const EdgeInsets.symmetric(horizontal: 150),
      child: Padding(padding: const EdgeInsets.all(20.0), child: child),
    );
  }

  _buildLogo(BuildContext context) {
    var wh = context.screenWidth * 0.07;

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Image.asset(
        appLogo2,
        fit: BoxFit.cover,
        width: wh,
        semanticLabel: 'logo',
      ),
    );
  }

  Container _buildRightColumn(BuildContext context) {
    return Container(
      color: kLightBlueColor.withAlpha((0.9 * 255).toInt()),
      width: context.screenWidth,
      height: context.screenHeight,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Need Help?',
                  style: context.ofTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 5),

              context.reloadAppIconButton(
                onPressed: () => RefreshEntireApp.restartApp(context),
              ),
            ],
          ),
          divLine,
          _buildForgotPasswordBtn(context),
          const Divider(),
          const Flexible(
            child: WorkspaceGuide(isForgotPassword: true, isWorkspace: false),
          ),
        ],
      ),
    );
  }

  _buildForgotPasswordBtn(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(backgroundColor: kGrayBlueColor),
      icon: const Icon(Icons.help_outline, color: kLightColor),
      label: Text(
        "Forgot Password?",
        semanticsLabel: "Forgot Password",
        overflow: TextOverflow.ellipsis,
        style: context.ofTheme.textTheme.titleLarge?.copyWith(
          color: kLightColor,
        ),
      ),
      onPressed: () async => await context.openForgotWorkspacePopUp(),
    );
  }
}

/*extension WorkspaceSignInPopUp on BuildContext {
  Future<void> openWorkspacePopUp() => showModalBottomSheet(
        context: this,
        isDismissible: false,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const WorkspaceSignInFormDialog(),
      );
}

class WorkspaceSignInFormDialog extends StatefulWidget {
  const WorkspaceSignInFormDialog({super.key});

  @override
  State<WorkspaceSignInFormDialog> createState() =>
      _WorkspaceSignInFormDialogState();
}

class _WorkspaceSignInFormDialogState extends State<WorkspaceSignInFormDialog> {
  SignInState _authStatus = AuthInitial();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return SignInBloc(
          authRepository: RepositoryProvider.of<AuthRepository>(context),
        );
      },
      child: _buildAlertDialog(),
    );
  }

  _buildAlertDialog() {
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
          icon: const Icon(
            Icons.close,
            color: kTextColor,
          ),
        ),
      ),
      iconPadding: const EdgeInsets.only(right: 5, top: 5),
      backgroundColor: kLightColor.withAlpha((0.8 * 255).toInt()),
      title: _buildSignInTitle(wh),
      content: _buildBody(context),
      actions: [
        WorkspaceSignInButton(
          onPressed: (v) => _showSignInAlert(v),
        ),
      ],
    );
  }

  /// Shows the alert overlay if there is a failure state.
  void _showSignInAlert(bool v) {
    // Use setState to ensure the UI is updated before showing the overlay
    setState(() {
      if (v && _authStatus.status.isFailure) {
        final msg = _authStatus.errorMessage ?? 'Incorrect email or password';

        // Ensure the overlay is displayed with the current context
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.showAlertOverlay(msg, bgColor: kDangerColor);
        });
      }
    });
  }

  Column _buildSignInTitle(double wh) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLogo(wh),
        const SizedBox(height: 10),
        ListTile(
          title: Text(
            'Workspace Sign In'.toUpperCase(),
            textAlign: TextAlign.center,
            style: context.ofTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: kPrimaryColor,
            ),
          ),
          subtitle: Text(
            "First, Sign In with Company or Organization ID.",
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

  //
  BlocListener<SignInBloc, SignInState> _buildBody(BuildContext context) {
    return BlocListener<SignInBloc, SignInState>(
      listener: (_, state) => setState(() => _authStatus = state),
      child: Container(
        width: context.screenWidth,
        padding: EdgeInsets.only(bottom: context.bottomInsetPadding),
        child: const AutofillGroup(
          child: Column(
            children: [
              EmailInput(),
              SizedBox(height: 20),
              PasswordInput(),
            ],
          ),
        ),
      ),
    );
  }
}*/
