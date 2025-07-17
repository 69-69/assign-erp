import 'dart:io';

import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/widgets/adaptive_layout.dart';
import 'package:assign_erp/core/widgets/animated_hexagon_grid.dart';
import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/custom_scroll_bar.dart';
import 'package:assign_erp/core/widgets/custom_snack_bar.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/auth/presentation/bloc/index.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/auth/presentation/screen/widget/form_inputs.dart';
import 'package:assign_erp/features/auth/presentation/screen/widget/workspace_acc_guide.dart';
import 'package:assign_erp/features/auth/presentation/screen/workspace/create/create_workspace_acc.dart';
import 'package:assign_erp/features/refresh_entire_app.dart';
import 'package:assign_erp/features/setup/data/data_sources/local/printout_setup_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

class ChangeEmployeeTemporalPasscodeScreen extends StatefulWidget {
  const ChangeEmployeeTemporalPasscodeScreen({super.key});

  @override
  State<ChangeEmployeeTemporalPasscodeScreen> createState() =>
      _ChangeEmployeeTemporalPasscodeScreenState();
}

class _ChangeEmployeeTemporalPasscodeScreenState
    extends State<ChangeEmployeeTemporalPasscodeScreen> {
  final PrintoutSetupCacheService _printoutService =
      PrintoutSetupCacheService();
  final ScrollController _scrollController = ScrollController();
  bool isInitialSetupAllowed = false;
  bool isTemporalPasscode = false;
  String? companyLogo;

  @override
  void initState() {
    super.initState();
    _loadCompanyLogo();
  }

  _loadCompanyLogo() async {
    final settings = await _printoutService.getSettings();
    if (settings != null) {
      setState(() => companyLogo = settings.companyLogo);
    }
  }

  void _canAccessInitialSetup() {
    // If current workspace role can access Setup the system for client workspace
    isInitialSetupAllowed = WorkspaceRoleGuard.canAccessInitialSetup(context);
  }

  /// Shows the alert overlay if there is a failure state.
  void _showSignInAlert(SignInState state, BuildContext context) {
    if (state.password.isValid && state.status.isFailure) {
      final msg =
          state.errorMessage ??
          'Something went wrong...Sign out and SignIn again!';

      // Ensure the overlay is displayed with the current context
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.showAlertOverlay(msg, bgColor: kDangerColor);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _canAccessInitialSetup();

    return _buildBody(context);
    /*MINE-STEVE
    return BlocProvider(
      create: (context) {
        return SignInBloc(
          authRepository: RepositoryProvider.of<AuthRepository>(context),
        );
      },
      child: _buildBody(context),
    );*/
  }

  BlocListener<SignInBloc, SignInState> _buildBody(BuildContext context) {
    return BlocListener<SignInBloc, SignInState>(
      listenWhen: (oldState, newState) => oldState.status != newState.status,
      listener: (_, state) => _showSignInAlert(state, context),
      child: CustomScaffold(
        backButton: const SizedBox.shrink(),
        bgColor: kWarningColor,
        body: CustomScrollBar(
          controller: _scrollController,
          padding: EdgeInsets.only(top: 0, bottom: context.bottomInsetPadding),
          child: Container(
            decoration: const BoxDecoration(
              color: kGrayBlueColor,
              image: DecorationImage(
                image: AssetImage(appBg),
                fit: BoxFit.cover,
              ),
            ),
            child: AnimatedHexagonGrid(child: _buildCard(context)),
          ),
        ),
        actions: [
          context.reloadAppIconButton(
            onPressed: () => RefreshEntireApp.restartApp(context),
          ),
        ],
        bottomNavigationBar: const SizedBox.shrink(),
      ),
    );
  }

  _buildCard(BuildContext context) {
    return AdaptiveLayout(
      firstFlex: 3,
      isSizedBox: false,
      children: [
        Padding(
          padding: const EdgeInsets.all(30.0),
          child: Center(child: _buildLeftColumn()),
        ),
        _buildRightColumn(context),
      ],
    );
  }

  _buildLeftColumn() {
    return Card(
      elevation: 50,
      color: kLightColor.withAlpha((0.8 * 255).toInt()),
      margin: context.isMobile || context.isTablet
          ? null
          : const EdgeInsets.symmetric(horizontal: 150),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _buildChangeTemporalPasscodeForm(),
      ),
    );
  }

  Column _buildChangeTemporalPasscodeForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLogo(),
        ListTile(
          title: Text(
            'Create New Employee Password',
            textAlign: TextAlign.center,
            style: context.ofTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          subtitle: Text(
            "Your previous password was temporary. Please create a new, secure Employee Password for your account.",
            textAlign: TextAlign.center,
            style: context.ofTheme.textTheme.titleSmall?.copyWith(
              color: kTextColor,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Flexible(
          child: PasswordInput(
            checkEmail: false,
            label: 'New Employee Password',
          ),
        ),
        const Flexible(child: ChangeEmployeeTemporalPasscodeButton()),
      ],
    );
  }

  _buildLogo() {
    var wh = context.screenWidth * 0.07;

    var isComLogo =
        companyLogo != null &&
        companyLogo!.isNotEmpty &&
        File(companyLogo!).existsSync();

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Image.asset(
        isComLogo ? companyLogo! : appLogo2,
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
                  softWrap: false,
                  style: context.ofTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                    color: context.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              context.signOutButton(
                onPressed: () {
                  _handleSignOut(context);
                  RefreshEntireApp.restartApp(context);
                },
              ),
            ],
          ),
          divLine,
          if (isInitialSetupAllowed) ...{
            _buildOpenCreateWorkspaceButton(context),
            const Divider(),
          },
          Flexible(child: WorkspaceGuide(isWorkspace: isInitialSetupAllowed)),
        ],
      ),
    );
  }

  _buildOpenCreateWorkspaceButton(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(backgroundColor: kGrayBlueColor),
      onPressed: () => context.openCreateWorkspacePopUp(),
      icon: const Icon(Icons.workspaces_outline, color: kLightColor),
      label: Text(
        'Setup New Workspace',
        overflow: TextOverflow.ellipsis,
        style: context.ofTheme.textTheme.titleLarge?.copyWith(
          color: kLightColor,
        ),
      ),
    );
  }

  _handleSignOut(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    authBloc.add(AuthSignOutRequested());
  }
}
