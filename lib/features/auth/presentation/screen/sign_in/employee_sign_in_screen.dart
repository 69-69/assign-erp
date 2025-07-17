import 'dart:io';

import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/widgets/adaptive_layout.dart';
import 'package:assign_erp/core/widgets/animated_hexagon_grid.dart';
import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/custom_scroll_bar.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/auth/presentation/bloc/index.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/auth/presentation/screen/widget/form_inputs.dart';
import 'package:assign_erp/features/auth/presentation/screen/widget/show_sign_in_alert.dart';
import 'package:assign_erp/features/auth/presentation/screen/widget/workspace_acc_guide.dart';
import 'package:assign_erp/features/auth/presentation/screen/workspace/create/create_workspace_acc.dart';
import 'package:assign_erp/features/refresh_entire_app.dart';
import 'package:assign_erp/features/setup/data/data_sources/local/printout_setup_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeeSignInScreen extends StatefulWidget {
  const EmployeeSignInScreen({super.key});

  @override
  State<EmployeeSignInScreen> createState() => _EmployeeSignInScreenState();
}

class _EmployeeSignInScreenState extends State<EmployeeSignInScreen> {
  final PrintoutSetupCacheService _printoutService =
      PrintoutSetupCacheService();
  final ScrollController _scrollController = ScrollController();
  bool isInitialSetupAllowed = false;
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

  @override
  Widget build(BuildContext context) {
    _canAccessInitialSetup();

    /*MINE-STEVE
    return BlocProvider(
      create: (context) {
        return SignInBloc(
          authRepository: RepositoryProvider.of<AuthRepository>(context),
        );
      },
      child: */
    return CustomScaffold(
      backButton: const SizedBox.shrink(),
      bgColor: kWarningColor,
      body: CustomScrollBar(
        controller: _scrollController,
        padding: EdgeInsets.only(top: 0, bottom: context.bottomInsetPadding),
        child: _buildBody(context),
      ),
      actions: [
        context.reloadAppIconButton(
          onPressed: () => RefreshEntireApp.restartApp(context),
        ),
      ],
      bottomNavigationBar: const SizedBox.shrink(),
    );
  }

  BlocListener<SignInBloc, SignInState> _buildBody(BuildContext context) {
    return BlocListener<SignInBloc, SignInState>(
      listenWhen: (oldState, newState) => oldState.status != newState.status,
      listener: (_, state) => context.showSignInAlert(state),
      child: Container(
        decoration: const BoxDecoration(
          color: kGrayBlueColor,
          image: DecorationImage(image: AssetImage(appBg), fit: BoxFit.cover),
        ),
        child: AnimatedHexagonGrid(child: _buildCard(context)),
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
        child: _buildSignInForm(),
      ),
    );
  }

  Column _buildSignInForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLogo(),
        ListTile(
          title: Text(
            employeeSignInTitle,
            textAlign: TextAlign.center,
            style: context.ofTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          subtitle: Text(
            "Please sign in using your credentials now.",
            textAlign: TextAlign.center,
            style: context.ofTheme.textTheme.titleSmall?.copyWith(
              color: kTextColor,
            ),
          ),
        ),
        const SizedBox(height: 2.0),
        const Flexible(child: EmailInput(label: 'Employee email')),
        const SizedBox(height: 20),
        const Flexible(child: PasswordInput(label: 'Employee password')),
        const Flexible(child: EmployeeSignInButton()),
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
          if (isInitialSetupAllowed) ...[
            _buildOpenCreateWorkspaceButton(context),
            const Divider(),
          ],
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
    context.read<AuthBloc>().add(AuthSignOutRequested());
  }
}

/*

void _canAccessInitialSetup() {
  final allowed = WorkspaceRoleGuard.canAccessInitialSetup(context);
  if (allowed != isInitialSetupAllowed) {
    setState(() => isInitialSetupAllowed = allowed);
  }
}

static bool canAccessInitialSetup(BuildContext context) {
  final authBloc = context.read<AuthBloc>();
  final role = authBloc.state.workspace?.role;

  return role == WorkspaceRole.initialSetup;
}

static bool canAccessInitialSetup(BuildContext context) {
  final workspace = context.read<AuthBloc>().state.workspace;
  return switch (workspace?.role) {
    WorkspaceRole.initialSetup => true,
    _ => false,
  };
}


void _canAccessInitialSetup() {
  final role = context.read<AuthBloc>().state.workspace?.role;
  debugPrint('🧪 Current workspace role: $role');

  final allowed = role == WorkspaceRole.initialSetup;
  debugPrint('🧪 Can access initial setup? $allowed');

  if (allowed != isInitialSetupAllowed) {
    setState(() => isInitialSetupAllowed = allowed);
  }
}



Widget _buildRightColumn(BuildContext context) {
  return BlocListener<AuthBloc, AuthState>(
    listenWhen: (prev, curr) => prev.workspace?.role != curr.workspace?.role,
    listener: (context, state) {
      final role = state.workspace?.role;
      final allowed = role == WorkspaceRole.initialSetup;
      debugPrint('🧪 Workspace role: $role');
      debugPrint('🧪 Initial setup allowed? $allowed');
      setState(() => isInitialSetupAllowed = allowed);
    },
    child: Container(
      color: kLightBlueColor.withAlpha((0.9 * 255).toInt()),
      width: context.screenWidth,
      height: context.screenHeight,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Need Help?',
                  softWrap: false,
                  style: context.ofTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
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

          // Show Setup + Guide if allowed
          if (isInitialSetupAllowed) ...[
            _buildOpenCreateWorkspaceButton(context),
            const Divider(),
          ],

          Flexible(
            child: WorkspaceGuide(isWorkspace: isInitialSetupAllowed),
          ),
        ],
      ),
    ),
  );
}
*/
