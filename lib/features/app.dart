import 'package:assign_erp/config/routes/route_logger.dart';
import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/core/util/debug_printify.dart';
import 'package:assign_erp/features/access_control/domain/repository/access_control_repository.dart';
import 'package:assign_erp/features/auth/presentation/bloc/auth_status_enum.dart';
import 'package:assign_erp/features/index.dart';
import 'package:assign_erp/features/setup/data/models/company_info_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required FirebaseFirestore fireStore,
    required AuthRepository authRepo,
    required RouteLogger routeLogger,
  }) : _fireStore = fireStore,
       _authRepo = authRepo,
       _routeLogger = routeLogger;

  final FirebaseFirestore _fireStore;
  final AuthRepository _authRepo;
  final RouteLogger _routeLogger;

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;

    /// Retrieves the default theme for the platform
    TextTheme textTheme = Theme.of(context).textTheme;
    MaterialTheme theme = MaterialTheme(textTheme);

    final blocProviders = [
      // _bloc<AuthBloc>(() => AuthBloc(authRepository: _authRepo)),
      _bloc<AccessControlCubit>(
        () => AccessControlCubit(AccessControlRepository(_fireStore)),
      ),
      _bloc<WorkspaceSignInBloc>(
        () => WorkspaceSignInBloc(authRepository: _authRepo),
      ),
      _bloc<EmployeeSignInBloc>(
        () => EmployeeSignInBloc(authRepository: _authRepo),
      ),
      _bloc<CompanyBloc>(
        () =>
            CompanyBloc(firestore: _fireStore)
              ..add(GetSetups<Company>()) /* Get Setup data on app startup */,
      ),
      _bloc<RoleBloc>(() => RoleBloc(firestore: _fireStore)),
      _bloc<CompanyStoresBloc>(() => CompanyStoresBloc(firestore: _fireStore)),
      _bloc<CategoryBloc>(() => CategoryBloc(firestore: _fireStore)),
      _bloc<SupplierBloc>(() => SupplierBloc(firestore: _fireStore)),
      _bloc<EmployeeBloc>(() => EmployeeBloc(firestore: _fireStore)),
      _bloc<ProductBloc>(() => ProductBloc(firestore: _fireStore)),
      _bloc<OrderBloc>(() => OrderBloc(firestore: _fireStore)),
      _bloc<PurchaseOrderBloc>(() => PurchaseOrderBloc(firestore: _fireStore)),
      _bloc<MiscOrderBloc>(() => MiscOrderBloc(firestore: _fireStore)),
      _bloc<DeliveryBloc>(() => DeliveryBloc(firestore: _fireStore)),
      _bloc<SaleBloc>(() => SaleBloc(firestore: _fireStore)),
      _bloc<RequestForQuotationBloc>(
        () => RequestForQuotationBloc(firestore: _fireStore),
      ),
      _bloc<CustomerAccountBloc>(
        () => CustomerAccountBloc(firestore: _fireStore),
      ),
      _bloc<POSSaleBloc>(() => POSSaleBloc(firestore: _fireStore)),
      _bloc<POSOrderBloc>(() => POSOrderBloc(firestore: _fireStore)),
      _bloc<AgentClientBloc>(() => AgentClientBloc(firestore: _fireStore)),
      // Live Support/Chat BlocProvider
      _bloc<ChatBloc>(() => ChatBloc(firestore: _fireStore)),
      _bloc<AllTenantsBloc>(() => AllTenantsBloc(firestore: _fireStore)),
      _bloc<SubscriptionBloc>(() => SubscriptionBloc(firestore: _fireStore)),
      // Software User Guide BlocProvider
      _bloc<HowToBloc>(() => HowToBloc(firestore: _fireStore)),
      // _bloc<ChatOverviewBloc>(() => ChatOverviewBloc(firestore: _fireStore)),
    ];

    // https://bloclibrary.dev/tutorials/flutter-login/
    /*BlocProvider.value(
      value: context.read<EmployeeSignInBloc>(), // <== Reuse existing bloc
      child: ChangePasscodeScreen(),
    ),*/
    return MultiRepositoryProvider(
      providers: [
        // RepositoryProvider.value(value: _authRepo),
        RepositoryProvider.value(value: _fireStore),
        RepositoryProvider(
          create: (_) => _authRepo,
          dispose: (repository) => repository.dispose(),
        ),
      ],
      child: MultiBlocProvider(
        providers: blocProviders,
        child: BlocProvider(
          lazy: false,
          create: (context) =>
              AuthBloc(authRepository: context.read<AuthRepository>())
                ..add(AuthCheckRequested()),
          child: _AppView(
            theme: brightness == Brightness.light
                ? theme.light()
                : theme.dark(),
            routeLogger: _routeLogger,
          ),
        ),
      ),
    );
  }

  /// Creates a [BlocProvider] for a BLoC of type [T].
  ///
  /// The [create] function is responsible for instantiating the BLoC.
  /// It does not receive a [BuildContext].
  BlocProvider<T> _bloc<T extends StateStreamableSource<Object?>>(
    T Function() create,
  ) => BlocProvider<T>(create: (BuildContext context) => create());
}

class _AppView extends StatefulWidget {
  final ThemeData theme;
  final RouteLogger routeLogger;

  const _AppView({required this.theme, required this.routeLogger});

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  late final GoRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = appRouter(widget.routeLogger); // Only created once
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _appRouter,
      title: appName.replaceAll('.', ' '),
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      theme: widget.theme,
      builder: (_, child) => _authStateListener(child, _appRouter),
    );
  }

  BlocListener<AuthBloc, AuthState> _authStateListener(
    Widget? child,
    GoRouter appRoute,
  ) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (cxt, state) async {
        final loc = appRoute.state.matchedLocation;
        // final loc = GoRouter.of(cxt).state.matchedLocation;
        final route = _authRedirect(state, loc);

        // Clear permissions if logging out
        if (state.authStatus == AuthStatus.unauthenticated) {
          if (cxt.mounted) {
            cxt.read<AccessControlCubit>().clear();
          }
        }

        if (route != null && route != loc) {
          // ✅ Load permissions if authenticated
          await _loadPermissions(cxt, state);
          /*if (loc == RouteNames.mainDashboard) {
            appRoute.refresh();
          }*/
          appRoute.go(route);
        }
      },
      child: child,
    );
  }

  // ✅ Load permissions if authenticated
  Future<void> _loadPermissions(BuildContext context, AuthState state) async {
    if (state.authStatus == AuthStatus.authenticated &&
        state.employee != null) {
      final wId = state.workspace?.id;
      final wSubscriptionId = state.workspace?.subscriptionId;
      final wRole = state.workspace?.role;
      final roleId = state.employee?.roleId ?? '';

      Future.microtask(() async {
        prettyPrint('Subscribed-id', '$wSubscriptionId');
        try {
          if (context.mounted) {
            await context.read<AccessControlCubit>().loadAll(
              roleId,
              workspaceId: wId,
              subscriptionId: wSubscriptionId,
              workspaceRole: wRole?.name,
            );
          }
        } catch (e) {
          prettyPrint('Failed to load licenses & permissions', '$e');
        }
      });
    }
  }

  // Redirect based on auth status
  String? _authRedirect(AuthState state, String curLocation) {
    switch (state.authStatus) {
      case AuthStatus.unauthenticated:
        return RouteNames.initialScreen;

      case AuthStatus.workspaceAuthenticated:
        return state.workspace != null ? '/${RouteNames.employeeSignIn}' : '/';

      case AuthStatus.authenticated:
        if (state.workspace != null) {
          return state.employee != null
              ? '/${RouteNames.homeDashboard}'
              : '/${RouteNames.employeeSignIn}';
        }
        return null;

      case AuthStatus.hasTemporaryPasscode:
        return '/${RouteNames.changeTemporaryPasscode}';

      case AuthStatus.emailNotVerified:
        return '/${RouteNames.verifyWorkspaceEmail}';

      default:
        // Handle unexpected cases by returning null
        return null;
    }
  }
}
