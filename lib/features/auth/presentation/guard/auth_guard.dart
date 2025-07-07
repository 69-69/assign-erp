import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/core/network/data_sources/models/workspace_model.dart';
import 'package:assign_erp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:assign_erp/features/auth/presentation/bloc/auth_status_enum.dart';
import 'package:assign_erp/features/setup/data/models/employee_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Base AuthGuard class for common auth-related checks [BaseAuthGuard]
abstract class BaseAuthGuard {
  final FirebaseAuth _firebaseAuth;

  BaseAuthGuard({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  AuthState? getAuthState(BuildContext context) {
    // var val = context.watch<AuthBloc>().state;
    final authState = BlocProvider.of<AuthBloc>(context).state;

    var authStatus = authState.authStatus;
    if (currentUser != null && authStatus == AuthStatusEnum.authenticated) {
      return authState;
    }
    return null;
  }
}

/// Guard for general authentication [AuthGuard]
class AuthGuard extends BaseAuthGuard {
  AuthGuard({super.firebaseAuth});

  ({Workspace? workspace, Employee? employee})? getCurrentUser(
    BuildContext context,
  ) {
    final authState = getAuthState(context);

    if (authState != null) {
      return (workspace: authState.workspace, employee: authState.employee);
    }
    return null;
  }

  Future<bool> redirect(BuildContext context, GoRouterState state) async {
    if (currentUser == null) {
      if (state.name != RouteNames.onBoarding) {
        context.goNamed(RouteNames.onBoarding);
      }
      return false;
    }
    return true;
  }
}

/// Guard for dashboard access [DashboardGuard]
class DashboardGuard extends BaseAuthGuard {
  DashboardGuard({super.firebaseAuth});

  Future<bool> redirect(BuildContext context) async {
    final authState = getAuthState(context);
    if (authState != null) {
      final workspace = authState.workspace;
      final employee = authState.employee;
      return workspace != null && employee != null;
    }
    return false;
  }
}

/// Guard for email verification [EmailVerificationGuard]
class EmailVerificationGuard extends BaseAuthGuard {
  EmailVerificationGuard({super.firebaseAuth});

  Future<bool> redirect(BuildContext context, GoRouterState state) async {
    if (currentUser == null || !currentUser!.emailVerified) {
      context.goNamed(RouteNames.verifyWorkspaceEmail);
      return false;
    }
    return true;
  }
}

/// Access Signed In User Data [GetSignedInUser]
extension GetSignedInUser on BuildContext {
  // Retrieves the currently signed-in user
  ({Employee? employee, Workspace? workspace})? get signedInUser =>
      AuthGuard().getCurrentUser(this);

  // Retrieves the workspace of the signed-in user or returns a default Workspace instance
  Workspace? get workspace => signedInUser?.workspace;

  // Retrieves the employee of the signed-in user or returns a default Employee instance
  Employee? get employee => signedInUser?.employee;
}

/// Guard for workspace role-based access [WorkspaceRoleGuard]
class WorkspaceRoleGuard {
  static bool _canAccess(
    BuildContext context,
    bool Function(Workspace) roleCheck,
  ) {
    final authState = context.watch<AuthBloc>().state;

    if (authState.authStatus == AuthStatusEnum.authenticated) {
      final workspace = authState.workspace;
      if (workspace != null) {
        return roleCheck(workspace);
      }
    }
    return false;
  }

  static bool canAccessInitialSetup(BuildContext context) {
    return _canAccess(
      context,
      (workspace) => workspace.canAccessInitialSetup(workspace),
    );
  }

  static bool canAccessSubscriberDashboard(BuildContext context) {
    return _canAccess(
      context,
      (workspace) => workspace.canAccessSubscriberDashboard(workspace),
    );
  }

  static bool canAccessAgentDashboard(BuildContext context) {
    return _canAccess(
      context,
      (workspace) => workspace.canAccessAgentDashboard(workspace),
    );
  }

  static bool canAccessDeveloperDashboard(BuildContext context) {
    return _canAccess(
      context,
      (workspace) => workspace.canAccessDeveloperDashboard(workspace),
    );
  }
}
