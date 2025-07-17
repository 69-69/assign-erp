import 'package:assign_erp/config/routes/route_names.dart';
import 'package:assign_erp/features/auth/presentation/bloc/auth_status_enum.dart';
import 'package:assign_erp/features/index.dart';
import 'package:assign_erp/features/live_support/presentation/bloc/index.dart';
import 'package:assign_erp/features/setup/data/models/company_info_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required FirebaseFirestore fireStore,
    required AuthRepository authRepo,
  }) : _fireStore = fireStore,
       _authRepo = authRepo;

  final FirebaseFirestore _fireStore;
  final AuthRepository _authRepo;

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;

    /// Retrieves the default theme for the platform
    TextTheme textTheme = Theme.of(context).textTheme;
    MaterialTheme theme = MaterialTheme(textTheme);

    final blocProviders = [
      // _bloc<AuthBloc>(() => AuthBloc(authRepository: _authRepo)),
      _bloc<SignInBloc>(() => SignInBloc(authRepository: _authRepo)),
      _bloc<CompanyBloc>(
        () =>
            CompanyBloc(firestore: _fireStore)
              ..add(GetSetups<Company>()) /* Get Setup data on app startup */,
      ),
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
      _bloc<SystemWideBloc>(() => SystemWideBloc(firestore: _fireStore)),
      // Software User Guide BlocProvider
      _bloc<HowToBloc>(() => HowToBloc(firestore: _fireStore)),
      // Live Support/Chat BlocProvider
      _bloc<ChatBloc>(() => ChatBloc(firestore: _fireStore)),
      // _bloc<ChatOverviewBloc>(() => ChatOverviewBloc(firestore: _fireStore)),
    ];

    // https://bloclibrary.dev/tutorials/flutter-login/
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

class _AppView extends StatelessWidget {
  final ThemeData theme;

  const _AppView({required this.theme});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: appName.replaceAll('.', ' '),
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      theme: theme,
      builder: (_, child) => _authStateListener(child, appRouter),
    );
  }

  BlocListener<AuthBloc, AuthState> _authStateListener(
    Widget? child,
    GoRouter appRoute,
  ) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (_, state) {
        final loc = appRoute.state.matchedLocation;
        final route = _authRedirect(state, loc);

        if (route != null && route != loc) {
          /*if (loc == RouteNames.mainDashboard) {
            appRoute.refresh();
          }*/
          appRoute.go(route);
        }
      },
      child: child,
    );
  }

  String? _authRedirect(AuthState state, String curLocation) {
    switch (state.authStatus) {
      case AuthStatus.unauthenticated:
        return RouteNames.initialScreen;

      case AuthStatus.workspaceAuthenticated:
        return state.workspace != null ? '/${RouteNames.employeeSignIn}' : '/';

      case AuthStatus.authenticated:
        if (state.workspace != null) {
          return state.employee != null
              ? '/${RouteNames.mainDashboard}'
              : '/${RouteNames.employeeSignIn}';
        }
        return null;

      case AuthStatus.hasTemporalPasscode:
        return '/${RouteNames.changeTemporalPasscode}';

      case AuthStatus.emailNotVerified:
        return '/${RouteNames.verifyWorkspaceEmail}';

      default:
        // Handle unexpected cases by returning null
        return null;
    }
  }
}
